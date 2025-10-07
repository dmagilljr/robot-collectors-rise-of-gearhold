--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local INIT_VERSION = "init-" .. tostring(os.time())

local World = ServerScriptService:WaitForChild("World")
local Boot = require(World:WaitForChild("_bootstrap"))
Boot.cleanStale()

do
    local targetWorld = ServerScriptService:WaitForChild("World")
    local targetModule = targetWorld:FindFirstChild("GarageReset")
    local removed = 0
    for _, inst in ipairs(game:GetDescendants()) do
        if inst:IsA("ModuleScript") and inst.Name == "GarageReset" and inst ~= targetModule then
            if not inst:IsDescendantOf(targetWorld) then
                warn("[INIT] Removing duplicate GarageReset at: " .. inst:GetFullName())
                inst:Destroy()
                removed += 1
            end
        end
    end
    print(string.format("[INIT] Duplicate GarageReset modules removed: %d", removed))
end

-- init remotes first (safe to call twice)
local RemoteSetup = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("RemoteSetup"))
RemoteSetup.init()

-- Require GarageReset but defer execution until workspace setup resolves
local GarageReset = require(ServerScriptService:WaitForChild("World"):WaitForChild("GarageReset"))

print("🤖 Robot Collectors: Modular Server Starting... v3.4")
print(
    string.format(
        "🧩 World VERSION=%s | init VERSION=%s | GarageReset VERSION=%s",
        Boot.VERSION,
        INIT_VERSION,
        tostring(GarageReset and GarageReset.VERSION or "nil")
    )
)

if Workspace:GetAttribute("WorkspaceSetupComplete") ~= true then
    Workspace:GetAttributeChangedSignal("WorkspaceSetupComplete"):Wait()
end

local serverFolder = script.Parent

local function bootstrapRemotes()
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end

    local manifest = {
        {name = "HatchRobot", class = "RemoteEvent"},
        {name = "SetRobotState", class = "RemoteEvent"},
        {name = "ManualMine", class = "RemoteEvent"},
        {name = "AssignRobotToResource", class = "RemoteEvent"},
        {name = "GarageStatus", class = "RemoteEvent"},
        {name = "GarageConsole", class = "RemoteEvent"},
        {name = "RobotCountChanged", class = "RemoteEvent"},
        {name = "RequestActivateBooster", class = "RemoteEvent"},
        {name = "RequestEquipSkin", class = "RemoteEvent"},
        {name = "ToggleGarageDoor", class = "RemoteEvent"},
        {name = "RequestBuyWithShards", class = "RemoteFunction"},
    }

    for _, entry in ipairs(manifest) do
        local existing = remotesFolder:FindFirstChild(entry.name)
        if existing then
            if existing.ClassName ~= entry.class then
                existing:Destroy()
                existing = nil
            end
        end
        if not existing then
            local remote = Instance.new(entry.class)
            remote.Name = entry.name
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
    GarageConsole = remotesFolder:WaitForChild("GarageConsole"),
    ToggleGarageDoor = remotesFolder:WaitForChild("ToggleGarageDoor"),
    RequestActivateBooster = remotesFolder:WaitForChild("RequestActivateBooster"),
    RequestEquipSkin = remotesFolder:WaitForChild("RequestEquipSkin"),
    RequestBuyWithShards = remotesFolder:WaitForChild("RequestBuyWithShards"),
}

local function tryLoadHandlers()
    local handlersFolder = serverFolder:FindFirstChild("handlers")
    if not handlersFolder then
        return
    end
    local economyHandler = handlersFolder:FindFirstChild("EconomyHandlers")
    if economyHandler then
        require(economyHandler)
    end
end

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("config")
local GameConstants = require(Config:WaitForChild("GameConstants"))

local function loadServices()
    local servicesFolder = serverFolder:WaitForChild("services", math.huge)

    local function loadServiceModule(name: string)
        print("[Services] requiring", name)
        local ok, result = pcall(function()
            return require(servicesFolder:WaitForChild(name))
        end)
        if not ok then
            warn(string.format("Failed to load %s:", name), result)
            return nil
        end
        return result
    end

    local SaveService = loadServiceModule("SaveService")
    if not SaveService then
        return nil
    end

    local EntitlementService = loadServiceModule("EntitlementService")
    if not EntitlementService then
        return nil
    end

    local EconomyService = loadServiceModule("EconomyService")
    if not EconomyService then
        return nil
    end

    local PlayerService = loadServiceModule("PlayerService")
    if not PlayerService then
        return nil
    end

    local RobotService = loadServiceModule("RobotService")
    if not RobotService then
        return nil
    end

    local WorldService = loadServiceModule("WorldService")
    if not WorldService then
        return nil
    end

    local services = {
        SaveService = SaveService,
        EntitlementService = EntitlementService,
        EconomyService = EconomyService,
        PlayerService = PlayerService,
        RobotService = RobotService,
        WorldService = WorldService,
    }
    print("[Services] loaded", services)
    _G.RC_Services = services
    return services
end

local Services = loadServices()
print("[Services] final", Services)

if RunService:IsStudio() then
    print("[RobotCollectors] Server init OK; constants loaded")
end

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

    if not Services then
        if initAttempts % 5 == 0 then
            warn("Core services not loaded; retrying module init")
        end
        task.delay(1, initializeModules)
        return
    end

    local requiredServices = { "PlayerService", "RobotService", "WorldService" }
    for _, serviceName in ipairs(requiredServices) do
        if not Services[serviceName] then
            if initAttempts % 5 == 0 then
                warn(string.format("Waiting for %s to load", serviceName))
            end
            task.delay(1, initializeModules)
            return
        end
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

    tryLoadHandlers()

    local PlayerService = Services.PlayerService
    local RobotService = Services.RobotService
    local WorldService = Services.WorldService

    local okWorldInit, worldErr = pcall(function()
        WorldService.init(Remotes)
    end)
    if not okWorldInit then
        warn("[WorldService] init failed", worldErr)
    end

    -- Reconcile RemoteEvents with module helper (idempotent)
    RemoteSetup.createRemotes()

    Players.PlayerRemoving:Connect(function(player)
        RobotService.despawnRobotsForPlayer(player)
        PlayerService.cleanupPlayer(player)
    end)

    handlers.HatchRobot = function(player, robotType, amount)
        amount = amount or 1
        if amount ~= 1 then
            warn("Garage only supports single hatch atm")
        end

        local function notify(status, payload)
            Remotes.GarageStatus:FireClient(player, status, payload or {})
        end

        local success, err = WorldService.hatchRobot(player, robotType, notify)
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
        RobotService.setRobotState(robotId, newState, player)
    end

    handlers.AssignRobotToResource = function(player, robotId, resourceNode)
        if typeof(resourceNode) ~= "Instance" or not resourceNode.Parent then
            warn("AssignRobotToResource received invalid resource for", player.Name)
            return
        end

        print("🎯 Assigning robot", robotId, "to resource", resourceNode.Name, "for", player.Name)
        RobotService.assignRobotToResource(robotId, resourceNode, player)
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
        if _G.RC_Services and _G.RC_Services.EconomyService and currencyType == "Gearbits" then
            local mult = _G.RC_Services.EconomyService.consumeActiveBoost(player, "Gearbits")
            mineAmount = math.max(1, math.floor(mineAmount * mult))
        end

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

        PlayerService.updatePlayerCurrency(player.UserId, currencyType, mineAmount)
        print("⛏️", player.Name, "manually mined", mineAmount, currencyType)
    end

    modulesReady = true

    for queueName in pairs(pendingQueues) do
        processQueue(queueName)
    end

    RobotService.startMovementUpdates()

    print("🎮 Robot Collectors server initialized! v3.3")
end

initializeModules()

task.delay(1, function()
    print("⏩ Running GarageReset.run() after workspace-setup")
    local ok, err = pcall(function()
        GarageReset.run()
    end)
    if not ok then
        warn("[INIT] GarageReset.run error:", err)
    end
end)
