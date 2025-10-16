

--!strict
-- MissionService.server.luau
-- Handles mission state, timers, and reward payout.
-- TODO[SERVER]: Expand to include persistence and real reward tables (v0.6.0).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Ensure RC_Remotes exists
local folder = ReplicatedStorage:FindFirstChild("RC_Remotes") or Instance.new("Folder")
folder.Name = "RC_Remotes"
folder.Parent = ReplicatedStorage

-- Ensure Missions subfolder and MissionUpdate event for HUD updates
local missionsFolder = folder:FindFirstChild("Missions")
if not missionsFolder then
    missionsFolder = Instance.new("Folder")
    missionsFolder.Name = "Missions"
    missionsFolder.Parent = folder
end
local missionUpdate = missionsFolder:FindFirstChild("MissionUpdate") :: RemoteEvent
if not missionUpdate then
    missionUpdate = Instance.new("RemoteEvent")
    missionUpdate.Name = "MissionUpdate"
    missionUpdate.Parent = missionsFolder
end

-- Ensure Mission Events
local function ensureEvent(name: string)
	local evt = folder:FindFirstChild(name)
	if not evt then
		evt = Instance.new("RemoteEvent")
		evt.Name = name
		evt.Parent = folder
	end
	return evt :: RemoteEvent
end

local startMission = ensureEvent("StartMission")
local completeMission = ensureEvent("MissionComplete")

-- Mission data stored in memory for now
local activeMissions: {[number]: { [string]: any }} = {}

-- Simplified reward tables (placeholder)
local rewardTable = {
	Scouting = { scrap = 50, components = 1, duration = 300 },
	Harvesting = { scrap = 100, energy = 20, duration = 1800 },
	Combat = { scrap = 250, components = 3, duration = 3600 },
	Engineering = { scrap = 400, components = 5, duration = 7200 },
	Expedition = { scrap = 800, components = 10, duration = 14400 },
}

-- === Auto-Adapt Collect Missions (per-resource, lightweight) =======================
type CollectMission = {
    id: string,
    resourceType: string,
    target: number,
    progress: number,
    status: "active" | "complete" | "claimed",
    startedAt: number,
}

-- playerId → resourceType → mission
local collectMissions: {[number]: {[string]: CollectMission}} = {}

local function ensurePlayerBag(p: Player)
    local bag = collectMissions[p.UserId]
    if not bag then
        bag = {}
        collectMissions[p.UserId] = bag
    end
    return bag
end

local function emitUpdate(p: Player, payload: any)
    missionUpdate:FireClient(p, payload)
end

local function startCollectMission(p: Player, resourceType: string, target: number): CollectMission
    local bag = ensurePlayerBag(p)
    local m: CollectMission = {
        id = ("COLLECT_%s_%d_%d"):format(resourceType, target, os.time()),
        resourceType = resourceType,
        target = target,
        progress = 0,
        status = "active",
        startedAt = os.time(),
    }
    bag[resourceType] = m
    emitUpdate(p, { t = "mission_started", mission = m })
    return m
end

local function tryComplete(p: Player, m: CollectMission)
    if m.status == "active" and m.progress >= m.target then
        m.status = "complete"
        emitUpdate(p, { t = "mission_completed", mission = m })
    end
end

-- Listen for server-side collection reports from ResourceService
local serverCollected = ServerStorage:FindFirstChild("RC_ServerCollected")
if not serverCollected then
    -- create the bindable if it doesn't exist so other services can fire it
    serverCollected = Instance.new("BindableEvent")
    serverCollected.Name = "RC_ServerCollected"
    serverCollected.Parent = ServerStorage
end

(serverCollected :: BindableEvent).Event:Connect(function(p: Player, resourceType: string, amount: number)
    if typeof(p) ~= "Instance" or p.ClassName ~= "Player" then return end
    if typeof(resourceType) ~= "string" then return end
    amount = tonumber(amount) or 1

    local bag = ensurePlayerBag(p)
    local m = bag[resourceType]
    if not m or m.status ~= "active" then
        m = startCollectMission(p, resourceType, 5)
    end

    m.progress += amount
    emitUpdate(p, {
        t = "progress",
        missionId = m.id,
        resourceType = resourceType,
        progress = m.progress,
        target = m.target,
    })
    tryComplete(p, m)
end)

-- Clean up memory on player leave
Players.PlayerRemoving:Connect(function(p)
    collectMissions[p.UserId] = nil
end)

-- Utility to start mission
local function startNewMission(player: Player, missionType: string)
	local userId = player.UserId
	if not rewardTable[missionType] then return end

	activeMissions[userId] = activeMissions[userId] or {}
	local missionData = table.clone(rewardTable[missionType])
	missionData.startTime = os.time()
	missionData.endTime = os.time() + missionData.duration
	missionData.type = missionType
	activeMissions[userId][missionType] = missionData

	print(string.format("[MissionService] %s started %s mission (%ds)", player.Name, missionType, missionData.duration))
end

startMission.OnServerEvent:Connect(function(player: Player, missionType: string)
	startNewMission(player, missionType)
end)

-- Claim mission rewards when complete
completeMission.OnServerEvent:Connect(function(player: Player, missionType: string)
	local userId = player.UserId
	if not activeMissions[userId] then return end
	local mission = activeMissions[userId][missionType]
	if not mission then return end
	if os.time() < mission.endTime then
		player:Kick("Tried to claim early mission reward.")
		return
	end

	-- Placeholder reward logic
	print(string.format("[MissionService] %s completed %s mission!", player.Name, missionType))
	-- TODO[REWARD]: Add actual resource payout and persistence.

	activeMissions[userId][missionType] = nil
end)

print("[MissionService] Initialized (prototype)")