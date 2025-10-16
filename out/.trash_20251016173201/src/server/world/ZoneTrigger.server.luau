--!strict
-- ZoneTrigger.server.luau
-- Detects when players enter the vicinity of zone anchors (tagged "ZoneAnchor").
-- Sets Player attributes CurrentZoneName/CurrentZoneTier and fires RC_Remotes.ZoneChanged to that player.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Singleton guard: avoid multiple ZoneTrigger loops if duplicated in SSS
 do
	local existing = ReplicatedStorage:FindFirstChild("ZoneTriggerSingleton")
	if existing then
		warn("[ZoneTrigger] Another instance detected; skipping duplicate runner")
		return
	else
		local flag = Instance.new("BoolValue")
		flag.Name = "ZoneTriggerSingleton"
		flag.Value = true
		flag.Parent = ReplicatedStorage
	end
 end

-- Ensure RC_Remotes and ZoneChanged event exist
local remotes = ReplicatedStorage:FindFirstChild("RC_Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "RC_Remotes"
	remotes.Parent = ReplicatedStorage
end
local function ensureEvent(name: string)
	local evt = remotes:FindFirstChild(name)
	if not evt then
		evt = Instance.new("RemoteEvent")
		evt.Name = name
		evt.Parent = remotes
	end
	return evt :: RemoteEvent
end
local zoneChangedEvt = ensureEvent("ZoneChanged")

-- Cache anchors
export type AnchorInfo = { part: BasePart, name: string, tier: number }
local anchors: { AnchorInfo } = {}

local function addAnchor(p: Instance)
	if not p:IsA("BasePart") then return end
	local tier = tonumber(p:GetAttribute("Tier")) or -1
	local nameAttr = tostring(p:GetAttribute("ZoneName") or p.Name)
	table.insert(anchors, { part = p, name = nameAttr, tier = tier })
end

for _, inst in ipairs(CollectionService:GetTagged("ZoneAnchor")) do
	addAnchor(inst)
end
CollectionService:GetInstanceAddedSignal("ZoneAnchor"):Connect(addAnchor)

-- Per-player last zone + debounce timestamp
local lastZoneByUser: { [number]: string } = {}
local lastTierByUser: { [number]: number } = {}
local lastChangeAtByUser: { [number]: number } = {}

-- Distance threshold (studs) to "enter" a zone anchor
local ENTER_DIST = 28
-- Debounce seconds to avoid double logs/toasts when crossing a boundary
local DEBOUNCE_SEC = 0.6

local function getRoot(char: Model): BasePart?
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then return hrp end
	return nil
end

local ACCUM, INTERVAL = 0, 0.3
RunService.Heartbeat:Connect(function(dt)
	ACCUM += dt
	if ACCUM < INTERVAL then return end
	ACCUM = 0
	if #anchors == 0 then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		local root = char and getRoot(char)
		if root then
			local pos = root.Position
			local best: AnchorInfo? = nil
			local bestDist = math.huge
			for _, a in ipairs(anchors) do
				local d = (a.part.Position - pos).Magnitude
				if d < bestDist then
					bestDist = d
					best = a
				end
			end
			if best and bestDist <= ENTER_DIST then
				local last = lastZoneByUser[plr.UserId]
				local now = os.clock()
				local lastAt = lastChangeAtByUser[plr.UserId] or 0
				if last ~= best.name and (now - lastAt) > DEBOUNCE_SEC then
					lastZoneByUser[plr.UserId] = best.name
					lastTierByUser[plr.UserId] = best.tier
					lastChangeAtByUser[plr.UserId] = now

					plr:SetAttribute("CurrentZoneName", best.name)
					plr:SetAttribute("CurrentZoneTier", best.tier)
					zoneChangedEvt:FireClient(plr, { name = best.name, tier = best.tier })
					print(string.format("[ZoneTrigger] %s entered %s (Tier %d)", plr.Name, best.name, best.tier))
				end
			end
		end
	end
end)

print("[ZoneTrigger] Initialized (listening for ZoneAnchor proximity)")