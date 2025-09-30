-- Robot Collectors: Rise of Gearhold - Server Entry Point
-- VERSION: v3.3-modular (2025-09-28)
print("🤖 Robot Collectors: Modular Server Starting... v3.3")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local serverFolder = script.Parent

-- Ensure core RemoteEvents exist immediately so clients never hang on WaitForChild
local function bootstrapRemotes()
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end

    local names = {
        "HatchRobot",
        "SetRobotState",
        "ManualMine",
        "AssignRobotToResource",
        "GarageStatus",
    }

    for _, remoteName in ipairs(names) do
        if not remotesFolder:FindFirstChild(remoteName) then
            local remote = Instance.new("RemoteEvent")
            remote.Name = remoteName
            remote.Parent = remotesFolder
        end
    end

    return remotesFolder
end

local remotesFolder = bootstrapRemotes()
local Remotes = {
    HatchRobot = remotesFolder:WaitForChild("HatchRobot"),
    SetRobotState = remotesFolder:WaitForChild("SetRobotState"),
    ManualMine = remotesFolder:WaitForChild("ManualMine"),
    AssignRobotToResource = remotesFolder:WaitForChild("AssignRobotToResource"),
    GarageStatus = remotesFolder:WaitForChild("GarageStatus"),
}

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("config")
local GameConstants = require(Config:WaitForChild("GameConstants"))

-- Queuing system so early player actions are replayed once modules finish loading
local modulesReady = false
local handlers = {}
local pendingQueues = {
    HatchRobot = {},
    SetRobotState = {},
    ManualMine = {},
    AssignRobotToResource = {},
}

local initAttempts = 0

local function enqueue(queueName, ...)
    local args = table.pack(...)
    table.insert(pendingQueues[queueName], args)
end

local function processQueue(queueName)
    local queue = pendingQueues[queueName]
    if not queue then
        return
    end

    for _, args in ipairs(queue) do
        handlers[queueName](table.unpack(args, 1, args.n))
    end

    table.clear(queue)
end

local function createGateway(queueName)
    return function(...)
        if modulesReady and handlers[queueName] then
            handlers[queueName](...)
        else
            enqueue(queueName, ...)
        end
    end
end

Remotes.HatchRobot.OnServerEvent:Connect(function(player, robotType, amount)
    if modulesReady and handlers.HatchRobot then
        handlers.HatchRobot(player, robotType, amount)
    else
        enqueue("HatchRobot", player, robotType, amount)
    end
end)
Remotes.SetRobotState.OnServerEvent:Connect(createGateway("SetRobotState"))
Remotes.ManualMine.OnServerEvent:Connect(createGateway("ManualMine"))
Remotes.AssignRobotToResource.OnServerEvent:Connect(createGateway("AssignRobotToResource"))

-- Load modules asynchronously so the server can respond even if Rojo connects late
local function initializeModules()
    if modulesReady then
        return
    end

    initAttempts += 1

    local modulesFolder = ServerScriptService:FindFirstChild("Modules")
    if not modulesFolder then
        if initAttempts % 5 == 0 then
            warn("Waiting for ServerScriptService.Modules to sync (attempt", initAttempts, ")")
        end
        task.delay(1, initializeModules)
        return
    end

    local remoteSetupModule = modulesFolder:FindFirstChild("RemoteSetup")
    local playerManagerModule = modulesFolder:FindFirstChild("PlayerManager")
    local robotManagerModule = modulesFolder:FindFirstChild("RobotManager")
    local garageServiceModule = modulesFolder:FindFirstChild("GarageService")

    if not (remoteSetupModule and playerManagerModule and robotManagerModule and garageServiceModule) then
        if initAttempts % 5 == 0 then
            warn("Server modules still syncing (remote/player/robot/garage missing)")
        end
        task.delay(1, initializeModules)
        return
    end

    local okRemote, RemoteSetup = pcall(require, remoteSetupModule)
    if not okRemote then
        warn("Failed to require RemoteSetup:", RemoteSetup)
        task.delay(1, initializeModules)
        return
    end

    local okPlayer, PlayerManager = pcall(require, playerManagerModule)
    if not okPlayer then
        warn("Failed to require PlayerManager:", PlayerManager)
        task.delay(1, initializeModules)
        return
    end

    local okRobot, RobotManager = pcall(require, robotManagerModule)
    if not okRobot then
        warn("Failed to require RobotManager:", RobotManager)
        task.delay(1, initializeModules)
        return
    end

    local okGarage, GarageService = pcall(require, garageServiceModule)
    if not okGarage then
        warn("Failed to require GarageService:", GarageService)
        task.delay(1, initializeModules)
        return
    end

    -- Reconcile RemoteEvents with module helper (idempotent)
    RemoteSetup.createRemotes()

    Players.PlayerRemoving:Connect(function(player)
        RobotManager.despawnRobotsForPlayer(player)
        PlayerManager.cleanupPlayer(player)
    end)

    handlers.HatchRobot = function(player, robotType, amount)
        amount = amount or 1
        if amount ~= 1 then
            warn("Garage only supports single hatch atm")
        end

        local function notify(status, payload)
            Remotes.GarageStatus:FireClient(player, status, payload or {})
        end

        local success, err = GarageService.hatchRobot(player, robotType, notify)
        if not success then
            notify("failed", {
                robotType = robotType,
                message = err or "Garage unavailable",
            })
            warn("Garage hatch failed:", err)
        end
    end

    handlers.SetRobotState = function(player, robotId, newState)
        print("🔧 Setting robot", robotId, "to state", newState, "for", player.Name)
        RobotManager.setRobotState(robotId, newState, player)
    end

    handlers.AssignRobotToResource = function(player, robotId, resourceNode)
        if typeof(resourceNode) ~= "Instance" or not resourceNode.Parent then
            warn("AssignRobotToResource received invalid resource for", player.Name)
            return
        end

        print("🎯 Assigning robot", robotId, "to resource", resourceNode.Name, "for", player.Name)
        RobotManager.assignRobotToResource(robotId, resourceNode, player)
    end

    handlers.ManualMine = function(player, resourceNode)
        if typeof(resourceNode) ~= "Instance" or not resourceNode.Parent then
            return
        end

        local resourceTypeValue = resourceNode:FindFirstChild("ResourceType")
        if not resourceTypeValue then
            return
        end

        local amounts = GameConstants.MINING_AMOUNTS[resourceTypeValue.Value]
        local currencyType = GameConstants.RESOURCE_TO_CURRENCY[resourceTypeValue.Value]

        if not amounts or not currencyType then
            warn("No mining configuration for resource type", resourceTypeValue.Value)
            return
        end

        local mineAmount = math.random(amounts.min, amounts.max)

        local healthValue = resourceNode:FindFirstChild("ResourceHealth")
        if healthValue then
            healthValue.Value = healthValue.Value - 1

            local originalSizeValue = resourceNode:FindFirstChild("OriginalSize")
            if originalSizeValue then
                local healthPercent = healthValue.Value / (originalSizeValue.Value * 3)
                if healthPercent > 0 then
                    local newSize = originalSizeValue.Value * healthPercent
                    resourceNode.Size = Vector3.new(newSize, newSize, newSize)
                    print("🔹 Resource shrunk to", math.floor(healthPercent * 100) .. "% size")
                else
                    resourceNode:Destroy()
                    print("💀 Resource depleted and removed")
                end
            end
        end

        PlayerManager.updatePlayerCurrency(player.UserId, currencyType, mineAmount)
        print("⛏️", player.Name, "manually mined", mineAmount, currencyType)
    end

    modulesReady = true

    for queueName in pairs(pendingQueues) do
        processQueue(queueName)
    end

    RobotManager.startMovementUpdates()

    print("🎮 Robot Collectors server initialized! v3.3")
end

initializeModules()
