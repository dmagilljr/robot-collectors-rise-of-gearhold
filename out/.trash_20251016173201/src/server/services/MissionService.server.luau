--!strict
-- File: MissionService.server.luau
-- v0.6.0-alpha — Phase 2 scaffold
-- Responsibilities:
--   - Maintain per-player mission state (MVP: "Collect X <Resource>")
--   - Listen for objective/collection events (from WorldInteract / ResourceService)
--   - Emit client updates and completion rewards via RC_Remotes.Missions
-- Idempotent: safe to run multiple times (checks/creates instances defensively)

print("🏗️ MissionService.server.luau ACTIVE", os.time())

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local shared = ReplicatedStorage:WaitForChild("shared")

local MissionDefs = require(shared:WaitForChild("config"):WaitForChild("MissionDefs"))

type LengthBand = "SHORT" | "MEDIUM" | "LONG" | "XL" | "XXL"

--// === Remotes Bootstrap =====================================================
-- Root: RC_Remotes / Missions
local RC_Remotes = ReplicatedStorage:FindFirstChild("RC_Remotes") or Instance.new("Folder")
RC_Remotes.Name = "RC_Remotes"
RC_Remotes.Parent = ReplicatedStorage

local MissionsFolder = RC_Remotes:FindFirstChild("Missions") or Instance.new("Folder")
MissionsFolder.Name = "Missions"
MissionsFolder.Parent = RC_Remotes

-- Server listens for world/objective signals (server-originated or bridged from client)
local ObjectiveEvent = MissionsFolder:FindFirstChild("ObjectiveEvent") :: RemoteEvent
if not ObjectiveEvent then
	ObjectiveEvent = Instance.new("RemoteEvent")
	ObjectiveEvent.Name = "ObjectiveEvent"
	ObjectiveEvent.Parent = MissionsFolder
end

-- Server may receive collection reports programmatically (no client hop)
-- For convenience, we expose BOTH:
--   1) A BindableEvent (server→server, e.g., ResourceService fires it)
--   2) A RemoteEvent (optional client→server bridge if needed)
local ServerCollected = ServerStorage:FindFirstChild("RC_ServerCollected") :: BindableEvent
if not ServerCollected then
	ServerCollected = Instance.new("BindableEvent")
	ServerCollected.Name = "RC_ServerCollected"
	ServerCollected.Parent = ServerStorage
end

local CollectedBridge = MissionsFolder:FindFirstChild("CollectedBridge") :: RemoteEvent
if not CollectedBridge then
	CollectedBridge = Instance.new("RemoteEvent")
	CollectedBridge.Name = "CollectedBridge"
	CollectedBridge.Parent = MissionsFolder
end

-- Server → Client mission HUD updates / FX pings
local MissionUpdate = MissionsFolder:FindFirstChild("MissionUpdate") :: RemoteEvent
if not MissionUpdate then
	MissionUpdate = Instance.new("RemoteEvent")
	MissionUpdate.Name = "MissionUpdate"
	MissionUpdate.Parent = MissionsFolder
end

-- Optional FX hook (client plays particles/light spike on collect)
local CollectedFX = MissionsFolder:FindFirstChild("CollectedFX") :: RemoteEvent
if not CollectedFX then
	CollectedFX = Instance.new("RemoteEvent")
	CollectedFX.Name = "CollectedFX"
	CollectedFX.Parent = MissionsFolder
end

--// === Config (MVP, keep data-driven later in Shared/Config/MissionDefs.luau) ==
type CollectMission = {
	id: string,
	kind: "collect",
	resourceType: string,
	target: number,
	progress: number,
	reward: { scrap: number?, energy: number?, components: number? },
	status: "active" | "complete" | "claimed",
	startedAt: number,
	length: LengthBand?,
	dropHint: { rarePct: number? }?,
}

local function mkCollectMission(resourceType: string, target: number): CollectMission
	return {
		id = ("COLLECT_%s_%d_%d"):format(resourceType, target, os.time()),
		kind = "collect",
		resourceType = resourceType,
		target = target,
		progress = 0,
		reward = {
			scrap = 0,
			energy = 0,
			components = 0,
		},
		status = "active",
		startedAt = os.time(),
		length = nil,
		dropHint = nil,
	}
end

--// === State =================================================================
type PlayerMissions = {
	active: { [string]: CollectMission },
	completed: { [string]: CollectMission },
}
local missionByPlayer: { [number]: PlayerMissions } = {}

local function ensurePlayer(p: Player): PlayerMissions
	local key = p.UserId
	local bag = missionByPlayer[key]
	if not bag then
		bag = { active = {}, completed = {} }
		missionByPlayer[key] = bag
	end
	return bag
end

--// === Emitters ==============================================================

local function emitUpdate(p: Player, payload: any)
	-- One compact event consumer on client HUD (shows list/progress/toasts)
	MissionUpdate:FireClient(p, payload)
end

local function emitFX(p: Player, resourceType: string, amount: number)
	CollectedFX:FireClient(p, {
		resourceType = resourceType,
		amount = amount,
		t = os.clock(),
	})
end

--// === API (callable from other server scripts) ==============================

-- Programmatic report from ResourceService (preferred server→server path)
-- Usage:
--   local MissionService = require(path.to.thisModuleIfItWereModule) -- N/A; this is a Script
--   MissionService.ReportCollected(player, "Scrap", 1)
-- Since this is a Script (not ModuleScript), expose via _G for now:
_G.RC_MissionService = _G.RC_MissionService or {}
local API = _G.RC_MissionService

function API.StartCollectMission(p: Player, resourceType: string, target: number)
	local bag = ensurePlayer(p)
	local preset = MissionDefs.makeCollectPreset(resourceType, target, "SHORT")
	local m = mkCollectMission(resourceType, target)
	m.reward = preset.rewardHint
	m.length = preset.length
	m.dropHint = preset.dropHint
	bag.active[m.id] = m
	emitUpdate(p, { t = "mission_started", mission = m })
	return m.id
end

local function tryComplete(p: Player, m: CollectMission)
	if m.progress >= m.target and m.status == "active" then
		m.status = "complete"
		local bag = ensurePlayer(p)
		bag.completed[m.id] = m
		bag.active[m.id] = nil
		emitUpdate(p, { t = "mission_completed", mission = m })
	end
end

function API.ReportCollected(p: Player, resourceType: string, amount: number)
	local bag = ensurePlayer(p)
	for _, m in pairs(bag.active) do
		if m.kind == "collect" and m.resourceType == resourceType and m.status == "active" then
			m.progress += amount
			emitUpdate(p, {
				t = "progress",
				missionId = m.id,
				resourceType = resourceType,
				progress = m.progress,
				target = m.target,
			})
			tryComplete(p, m)
		end
	end
	emitFX(p, resourceType, amount)
end

function API.ClaimRewards(p: Player, missionId: string)
	local bag = ensurePlayer(p)
	local m = bag.completed[missionId]
	if not m or m.status ~= "complete" then
		return false, "not_complete"
	end
	m.status = "claimed"
	-- TODO: integrate with your currency/inventory service
	emitUpdate(p, { t = "claimed", missionId = missionId, reward = m.reward })
	return true
end

function API.List(p: Player)
	local bag = ensurePlayer(p)
	return {
		active = bag.active,
		completed = bag.completed,
	}
end

--// === Event Wiring ==========================================================

-- Bridge: client or server can raise objective events (e.g., WorldInteract on prompt)
-- Payload expectations:
--   { kind = "collect", resourceType = "Scrap", amount = 1 }
ObjectiveEvent.OnServerEvent:Connect(function(p: Player, payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.kind == "collect" then
		local resourceType = tostring(payload.resourceType or "Scrap")
		local amount = tonumber(payload.amount or 1) or 1
		API.ReportCollected(p, resourceType, amount)
	end
end)

-- Server-only path (ResourceService → MissionService) without client involvement
ServerCollected.Event:Connect(function(p: Player, resourceType: string, amount: number)
	if typeof(p) ~= "Instance" or p.ClassName ~= "Player" then
		return
	end
	API.ReportCollected(p, resourceType, amount)
end)

-- Optional client→server bridge if some legacy clients emit collection
CollectedBridge.OnServerEvent:Connect(function(p: Player, payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.resourceType and payload.amount then
		API.ReportCollected(p, tostring(payload.resourceType), tonumber(payload.amount) or 1)
	end
end)

-- Auto-provision a tutorial mission on join (MVP: Collect 5 Scrap)
local function onPlayerAdded(p: Player)
	ensurePlayer(p)
	API.StartCollectMission(p, "Scrap", 5)
end

local function onPlayerRemoving(p: Player)
	missionByPlayer[p.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, p in ipairs(Players:GetPlayers()) do
	task.defer(onPlayerAdded, p)
end

-- Developer trace attribute support (toggle in Studio if desired)
local DEV_TRACE = false
local worldFolder = game:GetService("ServerScriptService"):FindFirstChild("World")
if worldFolder and worldFolder:GetAttribute("DEV_TRACE") == true then
	DEV_TRACE = true
end
if DEV_TRACE then
	print("[MissionService] DEV_TRACE enabled")
end

-- === ECHO (first ~60 logical lines) =========================================
do
	local ok, src = pcall(function()
		return script.Source
	end)
	if ok and typeof(src) == "string" then
		local linesShown = 0
		for line in string.gmatch(src, "([^\n]*)\n?") do
			linesShown += 1
			print(("[MissionService:%02d] %s"):format(linesShown, line))
			if linesShown >= 60 then
				break
			end
		end
	end
end
