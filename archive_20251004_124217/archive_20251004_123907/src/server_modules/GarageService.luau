-- GarageService: manages garage hatch requests, animation hooks, and spawn queue

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local RobotTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("RobotTypes"))
local GameConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("GameConstants"))
local PlayerManager = require(script.Parent.PlayerManager)
local RobotManager = require(script.Parent.RobotManager)

local GarageService = {}

local GarageDoorController
do
    local worldFolder = ServerScriptService:WaitForChild("World")
    local ok, module = pcall(function()
        return require(worldFolder:WaitForChild("GarageReset"))
    end)
    if ok and module then
        GarageDoorController = module
        if GarageDoorController.ensure then
            task.defer(function()
                pcall(function()
                    GarageDoorController.ensure()
                end)
            end)
        end
    end
end


local GARAGE_MODEL_NAMES = {
    Floor = "GarageFloor",
    Shell = "GarageShell",
    Door = "GarageDoor",
    Walkway = "GarageWalkway",
}

local garageParts = {}
local activeHatches = {}
local garageEffects = nil
local Remotes: { [string]: RemoteEvent }? = nil
local initialized = false

local ensureGarageParts
local collectDoorSlats
local buildDoorAnimationData
local ensureGarageEffects
local getRolloutWaypoints
local handleGarageWorkspaceMutation
local closeGarageDoor
local openGarageDoor
local toggleDoor

local TRACKED_GARAGE_NAMES = {
    [GARAGE_MODEL_NAMES.Floor] = true,
    [GARAGE_MODEL_NAMES.Shell] = true,
    [GARAGE_MODEL_NAMES.Door] = true,
    [GARAGE_MODEL_NAMES.Walkway] = true,
    GarageDoorHeader = true,
    GarageDoorTrackLeft = true,
    GarageDoorTrackRight = true,
    GarageConsoleDeck = true,
    GarageConsoleSurface = true,
    GarageConsoleHolo = true,
    GarageHatchPlatform = true,
    GarageHatchRamp = true,
    GarageInterior = true,
    DoorHandle = true,
    GarageTerminal = true,
}

local function findGarageItem(name: string): Instance?
    local garage = Workspace:FindFirstChild("Garage")
    if not garage or not garage:IsA("Model") then
        return Workspace:FindFirstChild(name)
    end

    local inside = garage:FindFirstChild(name, true)
    if inside then
        return inside
    end

    return Workspace:FindFirstChild(name)
end

local doorState = {
    isOpen = false,
    isAnimating = false,
}

local connections = {
    doorButton = nil :: RBXScriptConnection?,
    terminalPrompt = nil :: RBXScriptConnection?,
}

type SlatAnimation = {
    part: BasePart,
    baseCFrame: CFrame,
    liftCFrame: CFrame,
    tuckCFrame: CFrame,
}

type DoorAnimationData = {
    slats: {SlatAnimation},
    shellBaseCFrame: CFrame,
}

local cachedDoorData: DoorAnimationData? = nil

local function debugPrint(...)
    if RunService:IsStudio() then
        print("[GarageDoor]", ...)
    end
end

local function setDoorVisibility(isOpen: boolean)
    ensureGarageParts()
    local doorGroup = garageParts.Door
    if not (doorGroup and doorGroup:IsA("Model")) then
        debugPrint("setDoorVisibility missing door model")
        return
    end
    for _, inst in ipairs(doorGroup:GetChildren()) do
        if inst:IsA("BasePart") then
            if isOpen then
                inst.Transparency = 1
                inst.CanCollide = false
            else
                inst.Transparency = 0.05
                inst.CanCollide = true
            end
        end
    end
end

local function playerIsNearDoor(player: Player): boolean
    local character = player.Character
    if not character then
        debugPrint("no character for", player and player.Name)
        return false
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local doorControl = findGarageItem("DoorHandle") or findGarageItem("DoorFrame")
    if not (root and doorControl and doorControl:IsA("BasePart")) then
        debugPrint("missing door handle or hrp", player.Name)
        return false
    end

    local distance = (root.Position - doorControl.Position).Magnitude
    debugPrint("distance", player.Name, distance)
    return distance <= 15
end

local function invalidateGarageCaches()
    if garageEffects then
        if garageEffects.steamEmitter then
            garageEffects.steamEmitter.Enabled = false
            garageEffects.steamEmitter.Rate = 0
        end
        if garageEffects.steamEmitters then
            for _, emitter in ipairs(garageEffects.steamEmitters) do
                emitter.Enabled = false
                emitter.Rate = 0
            end
        end
    end

    garageEffects = nil
    cachedDoorData = nil
    table.clear(garageParts)
    doorState.isAnimating = false
    doorState.isOpen = false
end

local function areGaragePartsValid(): boolean
    for _, inst in pairs(garageParts) do
        if typeof(inst) == "Instance" and inst.Parent == nil then
            return false
        end
    end
    return true
end

local function getConsoleRoster(player)
    return PlayerManager.getRobotSummaries(player.UserId)
end

local function fireConsoleEvent(player, action, payload)
    if Remotes and Remotes.GarageConsole then
        Remotes.GarageConsole:FireClient(player, action, payload)
    end
end

local function fireStatus(player, status, payload)
    if Remotes and Remotes.GarageStatus then
        Remotes.GarageStatus:FireClient(player, status, payload)
    end
end

local function sendConsoleSnapshot(player)
    fireConsoleEvent(player, "refresh", {
        roster = getConsoleRoster(player),
        palettes = (GameConstants.GARAGE_APPEARANCE and GameConstants.GARAGE_APPEARANCE.Palettes) or {},
    })
end

local function playConsoleEffect(effectName)
    local effects = ensureGarageEffects()
    if not effects then
        return
    end

    if effectName == "upgrade" then
        if effects.upgradeSound then
            effects.upgradeSound:Play()
        end
    elseif effectName == "appearance" then
        if effects.appearanceSound then
            effects.appearanceSound:Play()
        end
    end

    local emitter = effects.consoleEmitter
    if emitter then
        emitter.Enabled = true
        emitter.Rate = effectName == "upgrade" and 45 or 30
        task.delay(0.35, function()
            if emitter.Parent then
                emitter.Enabled = false
                emitter.Rate = 0
            end
        end)
    end
end

local function handleUpgradeRequest(player, payload)
    local uniqueId = payload and payload.uniqueId
    if typeof(uniqueId) ~= "string" or uniqueId == "" then
        fireConsoleEvent(player, "upgradeResult", {
            success = false,
            message = "Invalid robot selection.",
        })
        return
    end

    local success, robotSummaryOrMessage = PlayerManager.upgradeRobot(player.UserId, uniqueId)
    if not success then
        fireConsoleEvent(player, "upgradeResult", {
            success = false,
            message = robotSummaryOrMessage,
        })
        fireStatus(player, "upgrade_failed", {
            message = robotSummaryOrMessage,
        })
        return
    end

    local robotSummary = robotSummaryOrMessage
    RobotManager.applyUpgrade(uniqueId, robotSummary.level, player)
    playConsoleEffect("upgrade")

    fireStatus(player, "upgrade_success", {
        robotName = robotSummary.name,
        level = robotSummary.level,
    })

    fireConsoleEvent(player, "upgradeResult", {
        success = true,
        robot = robotSummary,
    })

    sendConsoleSnapshot(player)
end

local function handleAppearanceRequest(player, payload)
    local uniqueId = payload and payload.uniqueId
    local paletteId = payload and payload.paletteId

    if typeof(uniqueId) ~= "string" or uniqueId == "" then
        fireConsoleEvent(player, "appearanceResult", {
            success = false,
            message = "Invalid robot selection.",
        })
        return
    end

    if typeof(paletteId) ~= "string" or paletteId == "" then
        fireConsoleEvent(player, "appearanceResult", {
            success = false,
            message = "Select a paint scheme first.",
        })
        return
    end

    local success, robotSummaryOrMessage = PlayerManager.updateRobotAppearance(player.UserId, uniqueId, paletteId)
    if not success then
        fireConsoleEvent(player, "appearanceResult", {
            success = false,
            message = robotSummaryOrMessage,
        })
        fireStatus(player, "appearance_failed", {
            message = robotSummaryOrMessage,
        })
        return
    end

    local robotSummary = robotSummaryOrMessage
    RobotManager.applyAppearance(uniqueId, robotSummary.appearance, player)
    playConsoleEffect("appearance")

    fireStatus(player, "appearance_success", {
        robotName = robotSummary.name,
        paletteId = robotSummary.appearance and robotSummary.appearance.PaletteId,
    })

    fireConsoleEvent(player, "appearanceResult", {
        success = true,
        robot = robotSummary,
    })

    sendConsoleSnapshot(player)
end

local function handleConsoleRequest(player, action, payload)
    if action == "refresh" then
        sendConsoleSnapshot(player)
    elseif action == "upgrade" then
        handleUpgradeRequest(player, payload)
    elseif action == "appearance" then
        handleAppearanceRequest(player, payload)
    elseif action == "open" then
        fireConsoleEvent(player, "open", {
            prompt = nil,
            roster = getConsoleRoster(player),
            palettes = (GameConstants.GARAGE_APPEARANCE and GameConstants.GARAGE_APPEARANCE.Palettes) or {},
            initialTab = payload and payload.desiredTab or "Hatch",
            focusRobot = payload and payload.focusRobot,
            upgrades = GameConstants.GARAGE_UPGRADES,
        })
    end
end

local function sampleHoverPosition(position, extraIgnore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = false

    local ignoreList = {}
    if garageParts.Shell then
        table.insert(ignoreList, garageParts.Shell)
    end
    if garageParts.Door then
        table.insert(ignoreList, garageParts.Door)
    end
    if extraIgnore then
        for _, inst in ipairs(extraIgnore) do
            if inst then
                table.insert(ignoreList, inst)
            end
        end
    end

    params.FilterDescendantsInstances = ignoreList

    local origin = Vector3.new(position.X, GameConstants.HOVER_RAYCAST_HEIGHT, position.Z)
    local result = Workspace:Raycast(origin, Vector3.new(0, -GameConstants.HOVER_RAYCAST_HEIGHT * 2, 0), params)

    if result then
        return Vector3.new(position.X, result.Position.Y + GameConstants.ROBOT_HOVER_OFFSET, position.Z)
    end

    return Vector3.new(position.X, GameConstants.ROBOT_HEIGHT, position.Z)
end

local function closeGarageDoor()
    if GarageDoorController and GarageDoorController.close then
        GarageDoorController.close()
        return
    end
    if not doorState then
        return
    end
    debugPrint("closeGarageDoor invoked")
    if doorState.isAnimating or not doorState.isOpen then
        if doorState.isAnimating and DEBUG then
            warn("[Garage] close aborted: animating")
        elseif not doorState.isOpen and DEBUG then
            warn("[Garage] close aborted: already closed")
        end
        return
    end

    ensureGarageParts()
    local shell = garageParts.Shell
    if not shell then
        setDoorVisibility(false)
        return
    end

    local data = cachedDoorData or buildDoorAnimationData()
    if not data then
        debugPrint("closeGarageDoor missing animation data")
        doorState.isOpen = false
        doorState.isAnimating = false
        setDoorVisibility(false)
        doorState.isOpen = false
        doorState.isAnimating = false
        return
    end

    doorState.isAnimating = true
    if DEBUG then
        print("[Garage] Closing door")
    end

    local effects = ensureGarageEffects()
    if effects and effects.doorCloseSound then
        effects.doorCloseSound:Play()
    end
    if effects then
        if effects.steamEmitter then
            effects.steamEmitter.Enabled = false
            effects.steamEmitter.Rate = 0
        end
        if effects.steamEmitters then
            for _, emitter in ipairs(effects.steamEmitters) do
                emitter.Enabled = false
                emitter.Rate = 0
            end
        end
        if effects.interiorLight then
            TweenService:Create(
                effects.interiorLight,
                TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Brightness = 0}
            ):Play()
            task.delay(0.5, function()
                if effects.ambientStrip then
                    effects.ambientStrip.Brightness = 1
                end
                effects.interiorLight.Enabled = false
            end)
        end
        if effects.focusLights then
            for _, spot in ipairs(effects.focusLights) do
                TweenService:Create(spot, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                    Brightness = 1.8,
                    Range = 12,
                }):Play()
            end
        end
        if effects.ambientStrip then
            TweenService:Create(effects.ambientStrip, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                Brightness = 1,
            }):Play()
        end
    end

    for index = #data.slats, 1, -1 do
        local info = data.slats[index]
        local tween = TweenService:Create(info.part, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
            CFrame = info.baseCFrame,
        })
        task.delay(0.05 * (#data.slats - index), function()
            tween.Completed:Connect(function()
                info.part.CanCollide = true
            end)
            tween:Play()
        end)
    end

    TweenService:Create(shell, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
        CFrame = data.shellBaseCFrame,
    }):Play()

    task.delay(0.6, function()
        cachedDoorData = nil
        doorState.isOpen = false
        doorState.isAnimating = false
        setDoorVisibility(false)
    end)
end

local function openGarageDoor(openDuration: number?, autoClose: boolean?)
    if GarageDoorController and GarageDoorController.open then
        GarageDoorController.open()
        if autoClose ~= false then
            local delayTime = (openDuration or 1.2) + 0.5
            task.delay(delayTime, function()
                if GarageDoorController and GarageDoorController.close then
                    GarageDoorController.close()
                end
            end)
        end
        return
    end
    if not doorState then
        return
    end
    debugPrint("openGarageDoor invoked")
    if doorState.isAnimating or doorState.isOpen then
        if DEBUG then
            warn("[Garage] open aborted (animating=", doorState.isAnimating, ", open=", doorState.isOpen, ")")
        end
        return
    end

    ensureGarageParts()
    local shell = garageParts.Shell
    if not shell then
        return
    end

    doorState.isAnimating = true
    autoClose = autoClose == nil and true or autoClose

    local data = buildDoorAnimationData()
    if not data then
        debugPrint("openGarageDoor missing animation data")
        doorState.isAnimating = false
        doorState.isOpen = true
        setDoorVisibility(true)
        if DEBUG then
            warn("[Garage] No door animation data; forcing open visibility")
        end
        return
    end
    cachedDoorData = data

    local effects = ensureGarageEffects()
    local duration = openDuration or 2.5

    if effects then
        if effects.rumbleSound then
            effects.rumbleSound:Play()
        end
        if effects.doorOpenSound then
            effects.doorOpenSound:Play()
        end

        local function setSteam(enabled: boolean)
            if effects.steamEmitter then
                effects.steamEmitter.Enabled = enabled
                effects.steamEmitter.Rate = enabled and 30 or 0
            end
            if effects.steamEmitters then
                for _, emitter in ipairs(effects.steamEmitters) do
                    emitter.Enabled = enabled
                    emitter.Rate = enabled and 30 or 0
                end
            end
        end

        setSteam(true)
        task.delay(duration, function()
            if cachedDoorData then
                setSteam(false)
            end
        end)

        if effects.steamSound then
            effects.steamSound:Play()
        end
        if effects.interiorLight then
            effects.interiorLight.Enabled = true
            effects.interiorLight.Brightness = 0
            TweenService:Create(
                effects.interiorLight,
                TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Brightness = 7}
            ):Play()
        end
        if effects.focusLights then
            for _, spot in ipairs(effects.focusLights) do
                TweenService:Create(spot, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Brightness = 8,
                    Range = 18,
                }):Play()
            end
        end
        if effects.ambientStrip then
            TweenService:Create(effects.ambientStrip, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Brightness = 3.5,
            }):Play()
        end
    end

    local shakeTween
    if shell then
        shakeTween = TweenService:Create(shell, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 6, true), {
            CFrame = data.shellBaseCFrame * CFrame.Angles(0, 0, math.rad(2.5)),
        })
        shakeTween:Play()
        task.delay(duration, function()
            if shakeTween then
                shakeTween:Cancel()
                shell.CFrame = data.shellBaseCFrame
            end
        end)
    end

    for index, info in ipairs(data.slats) do
        debugPrint("animating slat", index)
        info.part.CanCollide = false
        local liftTween = TweenService:Create(info.part, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            CFrame = info.liftCFrame,
        })
        local tuckTween = TweenService:Create(info.part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            CFrame = info.tuckCFrame,
        })
        task.delay(0.05 * (#data.slats - index), function()
            liftTween.Completed:Connect(function()
                tuckTween:Play()
            end)
            liftTween:Play()
        end)
    end

    doorState.isOpen = true
    setDoorVisibility(true)
    if DEBUG then
        print("[Garage] Door opening started with", #data.slats, "slats")
    end

    if autoClose then
        task.delay(duration + 3, function()
            doorState.isAnimating = false
            closeGarageDoor()
        end)
    else
        task.delay(duration + 0.6, function()
            doorState.isAnimating = false
        end)
    end
end

local function animateGarage(duration, autoClose)
    if GarageDoorController and GarageDoorController.open then
        GarageDoorController.open()
        if autoClose ~= false then
            local delayTime = (duration or 2.5)
            task.delay(delayTime, function()
                if GarageDoorController and GarageDoorController.close then
                    GarageDoorController.close()
                end
            end)
        end
        return
    end
    openGarageDoor(duration or 2.5, autoClose ~= false)
end

local function bindDoorPrompt()
    ensureGarageParts()
    local doorControl = findGarageItem("DoorHandle")
    local prompt = doorControl and doorControl:FindFirstChildWhichIsA("ProximityPrompt")
    debugPrint("bindDoorPrompt", doorControl, prompt)
    if connections.doorButton then
        connections.doorButton:Disconnect()
        connections.doorButton = nil
    end
    if GarageDoorController and GarageDoorController.toggle then
        return
    end
    if prompt then
        connections.doorButton = prompt.Triggered:Connect(function(player)
            if not player or not player:IsA("Player") then
                return
            end
            if GarageDoorController and GarageDoorController.toggle then
                GarageDoorController.toggle()
            else
                toggleDoor()
            end
        end)
        debugPrint("bindDoorPrompt attached")
    else
        debugPrint("bindDoorPrompt missing proximity prompt")
    end
end

local function bindTerminalPrompt()
    local terminalBase = findGarageItem("GarageTerminal")
    local prompt = terminalBase and terminalBase:FindFirstChild("GarageTerminalPrompt")
    debugPrint("bindTerminalPrompt", terminalBase, prompt)
    if connections.terminalPrompt then
        connections.terminalPrompt:Disconnect()
        connections.terminalPrompt = nil
    end
    if prompt then
        connections.terminalPrompt = prompt.Triggered:Connect(function(player)
            if not player or not player:IsA("Player") then
                return
            end
            fireConsoleEvent(player, "open", {
                prompt = prompt,
                roster = getConsoleRoster(player),
                upgrades = GameConstants.GARAGE_UPGRADES,
                palettes = (GameConstants.GARAGE_APPEARANCE and GameConstants.GARAGE_APPEARANCE.Palettes) or {},
                initialTab = "Hatch",
            })
        end)
    end
end

handleGarageWorkspaceMutation = function(instance: Instance?)
    if not instance or not TRACKED_GARAGE_NAMES[instance.Name] then
        return
    end

    invalidateGarageCaches()

    task.defer(function()
        ensureGarageParts()
        ensureGarageEffects()
        bindDoorPrompt()
        bindTerminalPrompt()
    end)
end

toggleDoor = function()
    if GarageDoorController and GarageDoorController.toggle then
        GarageDoorController.toggle()
        return
    end
    if not doorState then
        return
    end
    debugPrint("toggleDoor state", doorState.isOpen, doorState.isAnimating)
    if doorState.isAnimating then
        return
    end
    if doorState.isOpen then
        closeGarageDoor()
    else
        openGarageDoor(nil, false)
    end
end

function GarageService.init(remotes)
    if initialized then
        debugPrint("init called again; ignoring")
        return
    end
    Remotes = remotes
    debugPrint("init remotes", remotes)
    bindDoorPrompt()
    bindTerminalPrompt()

    if Remotes and Remotes.GarageConsole then
        Remotes.GarageConsole.OnServerEvent:Connect(function(player, action, payload)
            handleConsoleRequest(player, action, payload)
        end)
    end

    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "Garage" then
            task.defer(function()
                bindDoorPrompt()
                bindTerminalPrompt()
            end)
        end

        handleGarageWorkspaceMutation(child)
    end)

    Workspace.ChildRemoved:Connect(function(child)
        handleGarageWorkspaceMutation(child)
    end)
    initialized = true
end

local function pointOnPartSurface(part, offset)
    if not part then
        return nil
    end
    local worldCFrame = part.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)
    local worldPosition = worldCFrame.Position
    return sampleHoverPosition(worldPosition)
end

local function findGarageParts()
    local floor = findGarageItem(GARAGE_MODEL_NAMES.Floor)
    local shell = findGarageItem(GARAGE_MODEL_NAMES.Shell)
    local door = findGarageItem(GARAGE_MODEL_NAMES.Door)
    local walkway = findGarageItem(GARAGE_MODEL_NAMES.Walkway)
    local header = findGarageItem("GarageDoorHeader")
    local trackLeft = findGarageItem("GarageDoorTrackLeft")
    local trackRight = findGarageItem("GarageDoorTrackRight")
    local interiorFolder = findGarageItem("GarageInterior")
    local consoleDeck = findGarageItem("GarageConsoleDeck")
    local consoleSurface = findGarageItem("GarageConsoleSurface")
    local consoleHolo = findGarageItem("GarageConsoleHolo")
    local hatchPlatform = findGarageItem("GarageHatchPlatform")
    local hatchRamp = findGarageItem("GarageHatchRamp")

    if floor and shell and door then
        garageParts.Floor = floor
        garageParts.Shell = shell
        garageParts.Door = door
        garageParts.Walkway = walkway
        garageParts.DoorHeader = header
        garageParts.DoorTrackLeft = trackLeft
        garageParts.DoorTrackRight = trackRight
        garageParts.ConsoleDeck = consoleDeck
        garageParts.ConsoleSurface = consoleSurface
        garageParts.ConsoleHolo = consoleHolo
        garageParts.HatchPlatform = hatchPlatform
        garageParts.HatchRamp = hatchRamp
        garageParts.Interior = interiorFolder
        if interiorFolder and interiorFolder:IsA("Folder") then
            garageParts.SteamAttachmentLeft = interiorFolder:FindFirstChild("GarageSteamAttachmentLeft")
            garageParts.SteamAttachmentRight = interiorFolder:FindFirstChild("GarageSteamAttachmentRight")
            garageParts.SpotAttachmentLeft = interiorFolder:FindFirstChild("GarageSpotAttachmentLeft")
            garageParts.SpotAttachmentRight = interiorFolder:FindFirstChild("GarageSpotAttachmentRight")
            garageParts.LightBar = interiorFolder:FindFirstChild("GarageLightBar")
            garageParts.AmbientStrip = interiorFolder:FindFirstChild("GarageAmbientStrip")
        else
            garageParts.SteamAttachmentLeft = nil
            garageParts.SteamAttachmentRight = nil
            garageParts.SpotAttachmentLeft = nil
            garageParts.SpotAttachmentRight = nil
            garageParts.LightBar = nil
            garageParts.AmbientStrip = nil
        end
        debugPrint("findGarageParts success")
    else
        debugPrint("findGarageParts missing core parts", floor, shell, door)
    end
end

collectDoorSlats = function()
    ensureGarageParts()
    local slats = {}
    local doorGroup = garageParts.Door
    if not (doorGroup and doorGroup:IsA("Model")) then
        return slats
    end

    for _, child in ipairs(doorGroup:GetChildren()) do
        if child:IsA("BasePart") then
            local baseValue = child:FindFirstChild("GarageBaseCFrame")
            if not baseValue then
                baseValue = Instance.new("CFrameValue")
                baseValue.Name = "GarageBaseCFrame"
                baseValue.Parent = child
            end
            if not doorState.isOpen then
                baseValue.Value = child.CFrame
            end
            table.insert(slats, {
                part = child,
                baseValue = baseValue,
            })
        end
    end

    table.sort(slats, function(a, b)
        return a.part.Position.Y < b.part.Position.Y
    end)

    return slats
end

ensureGarageParts = function()
    debugPrint("ensureGarageParts invoked")
    if next(garageParts) then
        if areGaragePartsValid() then
            return
        end
        invalidateGarageCaches()
    end

    findGarageParts()
end

buildDoorAnimationData = function(): DoorAnimationData?
    ensureGarageParts()

    local doorGroup = garageParts.Door
    local shell = garageParts.Shell
    if not (doorGroup and (doorGroup:IsA("Folder") or doorGroup:IsA("Model")) and shell) then
        return nil
    end

    local slats = collectDoorSlats()
    if #slats == 0 then
        return nil
    end

    local doorMinY, doorMaxY = math.huge, -math.huge
    local centerAccumulator = Vector3.zero

    for _, info in ipairs(slats) do
        local baseCFrame = info.baseValue.Value
        local basePos = baseCFrame.Position
        doorMinY = math.min(doorMinY, basePos.Y - info.part.Size.Y / 2)
        doorMaxY = math.max(doorMaxY, basePos.Y + info.part.Size.Y / 2)
        centerAccumulator += basePos
    end

    local doorCenter = centerAccumulator / #slats
    local doorHeight = math.max(doorMaxY - doorMinY, 0)

    local header = garageParts.DoorHeader
    local floor = garageParts.Floor
    local backDepth = math.max(header and header.Size.Z or 0, 4.5)
    local interiorDir = floor and (floor.Position - doorCenter) or Vector3.new(0, 0, -1)
    interiorDir = Vector3.new(interiorDir.X, 0, interiorDir.Z)
    if interiorDir.Magnitude < 0.001 then
        interiorDir = Vector3.new(0, 0, -1)
    end
    interiorDir = interiorDir.Unit

    local slatAnimations: {SlatAnimation} = {}

    for index, info in ipairs(slats) do
        local baseCFrame = info.baseValue.Value
        local basePos = baseCFrame.Position
        local upVector = baseCFrame.UpVector
        local lookVector = baseCFrame.LookVector
        local rightVector = baseCFrame.RightVector

        local function toCFrame(position: Vector3): CFrame
            return CFrame.fromMatrix(position, rightVector, upVector, -lookVector)
        end

        local liftAmount = doorHeight + 0.9 - (index - 1) * (info.part.Size.Y * 0.78)
        local liftPos = basePos + upVector * liftAmount
        local tuckPos = liftPos + interiorDir * backDepth

        table.insert(slatAnimations, {
            part = info.part,
            baseCFrame = baseCFrame,
            liftCFrame = toCFrame(liftPos),
            tuckCFrame = toCFrame(tuckPos),
        })
    end

    return {
        slats = slatAnimations,
        shellBaseCFrame = shell.CFrame,
    }
end

ensureGarageEffects = function()
    if garageEffects then
        return garageEffects
    end

    ensureGarageParts()

    local walkway = garageParts.Walkway
    local doorGroup = garageParts.Door
    local shell = garageParts.Shell
    local consoleDeck = garageParts.ConsoleDeck
    local consoleHolo = garageParts.ConsoleHolo
    if not (walkway and doorGroup and shell) then
        return nil
    end

    local audioConfig = GameConstants.AUDIO or {}
    garageEffects = {}

    local doorReference = doorGroup:FindFirstChildWhichIsA("BasePart")
    if not doorReference then
        doorReference = walkway
    end

    local steamAttachment = walkway:FindFirstChild("GarageSteamAttachment")
    if not steamAttachment then
        steamAttachment = Instance.new("Attachment")
        steamAttachment.Name = "GarageSteamAttachment"
        steamAttachment.Position = Vector3.new(0, walkway.Size.Y * 0.5, 0)
        steamAttachment.Parent = walkway
    end

    local steamEmitter = steamAttachment:FindFirstChild("GarageSteamEmitter")
    if not steamEmitter then
        steamEmitter = Instance.new("ParticleEmitter")
        steamEmitter.Name = "GarageSteamEmitter"
        steamEmitter.Enabled = false
        steamEmitter.Texture = "rbxassetid://241594284"
        steamEmitter.Lifetime = NumberRange.new(0.8, 1.2)
        steamEmitter.Rate = 0
        steamEmitter.Speed = NumberRange.new(3, 6)
        steamEmitter.SpreadAngle = Vector2.new(20, 40)
        steamEmitter.Color = ColorSequence.new(Color3.fromRGB(220, 235, 255), Color3.fromRGB(180, 195, 210))
        steamEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(0.3, 1.1),
            NumberSequenceKeypoint.new(1, 0.4)
        })
        steamEmitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1)
        })
        steamEmitter.Parent = steamAttachment
    end
    garageEffects.steamEmitter = steamEmitter

    local additionalEmitters = {}
    if garageParts.SteamAttachmentLeft and garageParts.SteamAttachmentLeft:IsA("Attachment") then
        local emitterLeft = garageParts.SteamAttachmentLeft:FindFirstChild("GarageSteamEmitter")
        if emitterLeft and emitterLeft:IsA("ParticleEmitter") then
            emitterLeft.Enabled = false
            emitterLeft.Rate = 0
            table.insert(additionalEmitters, emitterLeft)
        end
    end
    if garageParts.SteamAttachmentRight and garageParts.SteamAttachmentRight:IsA("Attachment") then
        local emitterRight = garageParts.SteamAttachmentRight:FindFirstChild("GarageSteamEmitter")
        if emitterRight and emitterRight:IsA("ParticleEmitter") then
            emitterRight.Enabled = false
            emitterRight.Rate = 0
            table.insert(additionalEmitters, emitterRight)
        end
    end
    if #additionalEmitters > 0 then
        garageEffects.steamEmitters = additionalEmitters
    end

    if audioConfig.GARAGE_STEAM and audioConfig.GARAGE_STEAM ~= "" then
        local steamSound = steamAttachment:FindFirstChild("GarageSteamSound")
        if not steamSound then
            steamSound = Instance.new("Sound")
            steamSound.Name = "GarageSteamSound"
            steamSound.SoundId = audioConfig.GARAGE_STEAM
            steamSound.Volume = 0.5
            steamSound.Looped = false
            steamSound.RollOffMode = Enum.RollOffMode.Linear
            steamSound.RollOffMaxDistance = 60
            steamSound.Parent = steamAttachment
        end
        garageEffects.steamSound = steamSound
    end

    if audioConfig.GARAGE_RUMBLE and audioConfig.GARAGE_RUMBLE ~= "" then
        local rumbleSound = doorReference:FindFirstChild("GarageRumbleSound")
        if not rumbleSound then
            rumbleSound = Instance.new("Sound")
            rumbleSound.Name = "GarageRumbleSound"
            rumbleSound.SoundId = audioConfig.GARAGE_RUMBLE
            rumbleSound.Volume = 0.7
            rumbleSound.Looped = false
            rumbleSound.RollOffMode = Enum.RollOffMode.Linear
            rumbleSound.RollOffMaxDistance = 80
            rumbleSound.Parent = doorReference
        end
        garageEffects.rumbleSound = rumbleSound
    end

    if audioConfig.GARAGE_DOOR_OPEN and audioConfig.GARAGE_DOOR_OPEN ~= "" then
        local openSound = doorReference:FindFirstChild("GarageDoorOpen")
        if not openSound then
            openSound = Instance.new("Sound")
            openSound.Name = "GarageDoorOpen"
            openSound.SoundId = audioConfig.GARAGE_DOOR_OPEN
            openSound.Volume = 0.6
            openSound.Looped = false
            openSound.Parent = doorReference
        end
        garageEffects.doorOpenSound = openSound
    end

    if audioConfig.GARAGE_DOOR_CLOSE and audioConfig.GARAGE_DOOR_CLOSE ~= "" then
        local closeSound = doorReference:FindFirstChild("GarageDoorClose")
        if not closeSound then
            closeSound = Instance.new("Sound")
            closeSound.Name = "GarageDoorClose"
            closeSound.SoundId = audioConfig.GARAGE_DOOR_CLOSE
            closeSound.Volume = 0.55
            closeSound.Looped = false
            closeSound.Parent = doorReference
        end
        garageEffects.doorCloseSound = closeSound
    end

    if audioConfig.GARAGE_READY_CHIME and audioConfig.GARAGE_READY_CHIME ~= "" then
        local readySound = walkway:FindFirstChild("GarageReadyChime")
        if not readySound then
            readySound = Instance.new("Sound")
            readySound.Name = "GarageReadyChime"
            readySound.SoundId = audioConfig.GARAGE_READY_CHIME
            readySound.Volume = 0.55
            readySound.Looped = false
            readySound.RollOffMode = Enum.RollOffMode.Linear
            readySound.RollOffMaxDistance = 70
            readySound.Parent = walkway
        end
        garageEffects.readyChime = readySound
    end

    if audioConfig.GARAGE_UPGRADE_CHIME and audioConfig.GARAGE_UPGRADE_CHIME ~= "" then
        local upgradeSound = (consoleDeck or walkway):FindFirstChild("GarageUpgradeChime")
        if not upgradeSound then
            upgradeSound = Instance.new("Sound")
            upgradeSound.Name = "GarageUpgradeChime"
            upgradeSound.SoundId = audioConfig.GARAGE_UPGRADE_CHIME
            upgradeSound.Volume = 0.6
            upgradeSound.RollOffMode = Enum.RollOffMode.Linear
            upgradeSound.RollOffMaxDistance = 60
            upgradeSound.Parent = consoleDeck or walkway
        end
        garageEffects.upgradeSound = upgradeSound
    end

    if audioConfig.GARAGE_APPEARANCE_WHOOSH and audioConfig.GARAGE_APPEARANCE_WHOOSH ~= "" then
        local appearanceSound = (consoleDeck or walkway):FindFirstChild("GarageAppearanceWhoosh")
        if not appearanceSound then
            appearanceSound = Instance.new("Sound")
            appearanceSound.Name = "GarageAppearanceWhoosh"
            appearanceSound.SoundId = audioConfig.GARAGE_APPEARANCE_WHOOSH
            appearanceSound.Volume = 0.55
            appearanceSound.RollOffMode = Enum.RollOffMode.Linear
            appearanceSound.RollOffMaxDistance = 60
            appearanceSound.Parent = consoleDeck or walkway
        end
        garageEffects.appearanceSound = appearanceSound
    end

    local interiorLight = shell:FindFirstChild("GarageInteriorLight")
    if not interiorLight then
        interiorLight = Instance.new("PointLight")
        interiorLight.Name = "GarageInteriorLight"
        interiorLight.Range = 18
        interiorLight.Brightness = 0
        interiorLight.Enabled = false
        interiorLight.Color = Color3.fromRGB(255, 214, 170)
        interiorLight.Shadows = true
        interiorLight.Parent = shell
    end
    garageEffects.interiorLight = interiorLight

    local interiorFolder = garageParts.Interior
    if interiorFolder then
        local ambientHum = interiorFolder:FindFirstChild("GarageAmbientHum")
        if ambientHum and ambientHum:IsA("Sound") then
            garageEffects.ambientHum = ambientHum
            if not ambientHum.IsPlaying then
                ambientHum:Play()
            end
        end

        local spotLights = {}
        for _, attachmentName in ipairs({"SpotAttachmentLeft", "SpotAttachmentRight"}) do
            local attachment = garageParts[attachmentName]
            if attachment and attachment:IsA("Attachment") then
                local spot = attachment:FindFirstChildWhichIsA("SpotLight")
                if spot then
                    spot.Brightness = 0
                    table.insert(spotLights, spot)
                end
            end
        end
        if #spotLights > 0 then
            garageEffects.focusLights = spotLights
        end

        local ambientStripLight = garageParts.AmbientStrip and garageParts.AmbientStrip:IsA("SurfaceLight") and garageParts.AmbientStrip or nil
        if ambientStripLight then
            ambientStripLight.Brightness = 0.5
            garageEffects.ambientStrip = ambientStripLight
        end

        local steamEmitters = {}
        local leftAttachment = garageParts.SteamAttachmentLeft
        local rightAttachment = garageParts.SteamAttachmentRight
        for _, attachment in ipairs({leftAttachment, rightAttachment}) do
            if attachment and attachment:IsA("Attachment") then
                local emitter = attachment:FindFirstChild("GarageSteamEmitter")
                if emitter and emitter:IsA("ParticleEmitter") then
                    emitter.Enabled = false
                    emitter.Rate = 0
                    table.insert(steamEmitters, emitter)
                end
            end
        end
        if #steamEmitters > 0 then
            garageEffects.steamEmitters = steamEmitters
        end
    end

    if consoleHolo and consoleHolo:IsA("BasePart") then
        local holoAttachment = consoleHolo:FindFirstChild("ConsoleHoloAttachment")
        if holoAttachment and holoAttachment:IsA("Attachment") then
            local emitter = holoAttachment:FindFirstChild("ConsolePulseEmitter")
            if emitter and emitter:IsA("ParticleEmitter") then
                emitter.Enabled = false
                emitter.Rate = 0
                garageEffects.consoleEmitter = emitter
            end
        end
    end

    return garageEffects
end

getRolloutWaypoints = function()
    ensureGarageParts()

    local floor = garageParts.Floor
    local walkway = garageParts.Walkway
    local doorGroup = garageParts.Door

    local basePosition = floor and floor.Position or (walkway and walkway.Position) or Vector3.new(28, 0, -4)
    local doorCenter
    if doorGroup and doorGroup:IsA("Folder") then
        local sum = Vector3.zero
        local count = 0
        for _, child in ipairs(doorGroup:GetChildren()) do
            if child:IsA("BasePart") then
                sum += child.Position
                count += 1
            end
        end
        if count > 0 then
            doorCenter = sum / count
        end
    end

    if not doorCenter and walkway then
        doorCenter = walkway.Position + walkway.CFrame.LookVector * -math.max(walkway.Size.Z * 0.5, 1)
    elseif not doorCenter then
        doorCenter = basePosition + Vector3.new(0, 0, 6)
    end

    local forward = Vector3.new(doorCenter.X - basePosition.X, 0, doorCenter.Z - basePosition.Z)
    if forward.Magnitude < 0.001 then
        forward = Vector3.new(0, 0, 1)
    end
    forward = forward.Unit

    local halfDepth = floor and floor.Size.Z * 0.5 or (walkway and walkway.Size.Z * 0.5) or 8
    local startDepth = math.max(halfDepth - 2.5, 2)
    local thresholdDepth = math.max(halfDepth - 1, halfDepth * 0.6)
    local greetDepth = halfDepth + 3.5

    local platform = garageParts.HatchPlatform
    local startSample
    if platform and platform:IsA("BasePart") then
        local offset = platform.CFrame.UpVector * (platform.Size.Y * 0.5 + GameConstants.ROBOT_HOVER_OFFSET)
        startSample = platform.Position + offset
    else
        startSample = basePosition - forward * startDepth
    end

    local thresholdSample = basePosition + forward * thresholdDepth
    local greetSample = basePosition + forward * greetDepth

    local lateral = forward:Cross(Vector3.yAxis)
    if walkway and lateral.Magnitude > 0.001 then
        lateral = lateral.Unit
        local toWalkway = walkway.Position - basePosition
        local offset = toWalkway:Dot(lateral)
        startSample += lateral * math.clamp(offset, -6, 6)
        thresholdSample += lateral * math.clamp(offset, -6, 6)
        greetSample += lateral * math.clamp(offset, -6, 6)
    end

    local startPosition = sampleHoverPosition(startSample)
    local thresholdPosition = sampleHoverPosition(thresholdSample)
    local greetPosition = sampleHoverPosition(greetSample)

    return startPosition, thresholdPosition, greetPosition
end

local function beginGreeting(robotFolder, player)
    local robotState = robotFolder:FindFirstChild("RobotState")
    if not robotState then
        return
    end

    robotFolder:SetAttribute("GreetingPlayerId", player and player.UserId or nil)
    robotFolder:SetAttribute("GreetingStartTime", os.clock())
    robotFolder:SetAttribute("TaskState", "idle")
    robotState.Value = "garage_greeting"
end

local function canAfford(player, robotType)
    return PlayerManager.canAffordRobot(player.UserId, robotType)
end

local function deductCost(player, robotType)
    return PlayerManager.purchaseRobot(player.UserId, robotType)
end

local function refundCost(player, robotType)
    local definition = RobotTypes[robotType]
    if not definition then
        return
    end

    for currency, amount in pairs(definition.Cost or {}) do
        PlayerManager.updatePlayerCurrency(player.UserId, currency, amount)
    end
end

local function rollOutRobot(robotFolder, player, onReady)
    ensureGarageParts()
    local robotBody = robotFolder and robotFolder:FindFirstChild("RobotBody")
    if not robotBody then
        return
    end

    local effects = ensureGarageEffects()

    local startPosition, thresholdPosition, greetPosition = getRolloutWaypoints()
    local basePosition = startPosition
    robotBody.Anchored = true
    local forwardDirection = (thresholdPosition - startPosition)
    if forwardDirection.Magnitude < 0.001 then
        forwardDirection = Vector3.new(0, 0, 1)
    end
    forwardDirection = forwardDirection.Unit
    local baseCFrame = CFrame.new(startPosition, startPosition + forwardDirection)
    robotBody.CFrame = baseCFrame
    robotBody.AssemblyLinearVelocity = Vector3.zero
    robotBody.AssemblyAngularVelocity = Vector3.zero

    if effects and effects.interiorLight then
        TweenService:Create(
            effects.interiorLight,
            TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Brightness = 9}
        ):Play()
    end

    local hiddenParts: {[Instance]: number} = {}
    local disabledEmitters: {[Instance]: boolean} = {}

    local function setRobotVisible(isVisible: boolean)
        for instance, original in pairs(hiddenParts) do
            if instance.Parent then
                instance.Transparency = isVisible and original or 1
            end
        end
        for emitter, enabled in pairs(disabledEmitters) do
            if emitter.Parent and emitter:IsA("ParticleEmitter") then
                emitter.Enabled = isVisible and enabled or false
            end
        end
    end

    local function cacheRobotAppearance()
        table.clear(hiddenParts)
        table.clear(disabledEmitters)
        for _, descendant in ipairs(robotFolder:GetDescendants()) do
            if descendant:IsA("BasePart") then
                hiddenParts[descendant] = descendant.Transparency
            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                hiddenParts[descendant] = descendant.Transparency
            elseif descendant:IsA("ParticleEmitter") then
                disabledEmitters[descendant] = descendant.Enabled
            end
        end
        setRobotVisible(false)
    end

    local function performReveal(onComplete)
        cacheRobotAppearance()

        if effects then
            if effects.focusLights then
                for _, spot in ipairs(effects.focusLights) do
                    TweenService:Create(spot, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                        Brightness = 8,
                        Range = 18,
                    }):Play()
                end
            end
            if effects.ambientStrip then
                TweenService:Create(effects.ambientStrip, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Brightness = 3.5,
                }):Play()
            end
        end

        local crate = Instance.new("Model")
        crate.Name = "GarageCrate"

        local base = Instance.new("Part")
        base.Name = "CrateBase"
        base.Size = Vector3.new(3.6, 2.8, 3.6)
        base.Material = Enum.Material.Metal
        base.Color = Color3.fromRGB(110, 120, 135)
        base.Transparency = 0.05
        base.CanCollide = false
        base.CanQuery = false
        base.Parent = crate

        local lid = Instance.new("Part")
        lid.Name = "CrateLid"
        lid.Size = Vector3.new(3.6, 0.4, 3.6)
        lid.Material = Enum.Material.Metal
        lid.Color = Color3.fromRGB(80, 90, 105)
        lid.Transparency = 0.1
        lid.CanCollide = false
        lid.CanQuery = false
        lid.Parent = crate

        local accent = Instance.new("Part")
        accent.Name = "CrateAccent"
        accent.Size = Vector3.new(3.6, 0.1, 3.6)
        accent.Material = Enum.Material.Neon
        accent.Color = Color3.fromRGB(95, 205, 255)
        accent.Transparency = 0.4
        accent.CanCollide = false
        accent.CanQuery = false
        accent.Parent = crate

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = base
        weld.Part1 = lid
        weld.Parent = base

        local weldAccent = Instance.new("WeldConstraint")
        weldAccent.Part0 = base
        weldAccent.Part1 = accent
        weldAccent.Parent = base

        local cratePrimary = Instance.new("Attachment")
        cratePrimary.Parent = base

        crate.PrimaryPart = base
        base.Anchored = true
        lid.Anchored = true
        accent.Anchored = true
        local floorY = startPosition.Y - GameConstants.ROBOT_HOVER_OFFSET
        local crateHeight = base.Size.Y * 0.5
        local cratePosition = Vector3.new(basePosition.X, floorY + crateHeight, basePosition.Z)
        crate:SetPrimaryPartCFrame(CFrame.lookAt(cratePosition, cratePosition + forwardDirection))
        crate.Parent = robotFolder

        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromRGB(255, 220, 180)
        glow.Range = 12
        glow.Brightness = 0
        glow.Shadows = false
        glow.Parent = crate

        local dustEmitter = Instance.new("ParticleEmitter")
        dustEmitter.Name = "GarageCrateDust"
        dustEmitter.Enabled = false
        dustEmitter.Texture = "rbxassetid://4821867471"
        dustEmitter.Lifetime = NumberRange.new(0.4, 0.7)
        dustEmitter.Speed = NumberRange.new(6, 9)
        dustEmitter.SpreadAngle = Vector2.new(35, 35)
        dustEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.4, 1.2),
            NumberSequenceKeypoint.new(1, 1.8)
        })
        dustEmitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1)
        })
        dustEmitter.Rate = 0
        dustEmitter.Parent = crate

        local crateBaseCFrame = crate.PrimaryPart and crate.PrimaryPart.CFrame or base.CFrame

        TweenService:Create(glow, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 2, true), {Brightness = 5}):Play()

        local shakeTween = TweenService:Create(
            base,
            TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 4, true),
            {CFrame = crateBaseCFrame * CFrame.new(0, 0.4, 0)}
        )

        shakeTween.Completed:Connect(function()
            local collapseTween = TweenService:Create(
                base,
                TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1}
            )

            collapseTween.Completed:Connect(function()
                lid.Transparency = 1
                accent.Transparency = 1
                crate:Destroy()
                setRobotVisible(true)
                table.clear(hiddenParts)
                table.clear(disabledEmitters)
                if effects then
                    if effects.focusLights then
                        for _, spot in ipairs(effects.focusLights) do
                            TweenService:Create(spot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                                Brightness = 2.2,
                                Range = 14,
                            }):Play()
                        end
                    end
                    if effects.ambientStrip then
                        TweenService:Create(effects.ambientStrip, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                            Brightness = 1.2,
                        }):Play()
                    end
                end
                if onComplete then
                    onComplete()
                end
            end)

            dustEmitter.Enabled = true
            dustEmitter.Rate = 60
            task.delay(0.25, function()
                dustEmitter.Enabled = false
                dustEmitter.Rate = 0
            end)

            collapseTween:Play()
        end)

        shakeTween:Play()
    end

    local function playHatchDance(onComplete)
        local raiseCFrame = baseCFrame * CFrame.new(0, 0.6, 0)
        local lowerCFrame = baseCFrame
        local leanForward = baseCFrame * CFrame.Angles(math.rad(-6), 0, 0)
        local leanBackward = baseCFrame * CFrame.Angles(math.rad(5), 0, 0)
        local swayLeft = baseCFrame * CFrame.Angles(math.rad(-2), 0, math.rad(4))
        local swayRight = baseCFrame * CFrame.Angles(math.rad(2), 0, math.rad(-4))

        local function tweenTo(targetCFrame: CFrame, duration: number, easingStyle: Enum.EasingStyle, easingDir: Enum.EasingDirection, callback)
            local tween = TweenService:Create(robotBody, TweenInfo.new(duration, easingStyle, easingDir), {CFrame = targetCFrame})
            if callback then
                tween.Completed:Connect(callback)
            end
            tween:Play()
        end

        tweenTo(raiseCFrame, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
            tweenTo(lowerCFrame, 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, function()
                tweenTo(leanForward, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
                    tweenTo(leanBackward, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In, function()
                        tweenTo(swayLeft, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
                            tweenTo(swayRight, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, function()
                                tweenTo(lowerCFrame, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                                    if onComplete then
                                        onComplete()
                                    end
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end

    local function tweenToPosition(target: Vector3, duration: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection, onComplete)
        local forwardXZ = Vector3.new(forwardDirection.X, 0, forwardDirection.Z)
        if forwardXZ.Magnitude < 0.001 then
            forwardXZ = Vector3.new(0, 0, 1)
        end
        forwardXZ = forwardXZ.Unit

        local tween = TweenService:Create(robotBody, TweenInfo.new(duration, easingStyle, easingDirection), {
            CFrame = CFrame.lookAt(target, target + forwardXZ)
        })
        if onComplete then
            tween.Completed:Connect(onComplete)
        end
        tween:Play()
    end

    performReveal(function()
        playHatchDance(function()
            local extendedMid = startPosition + forwardDirection * 5.5
            tweenToPosition(extendedMid, 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                tweenToPosition(greetPosition, 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                    robotBody.AssemblyLinearVelocity = Vector3.zero
                    robotBody.AssemblyAngularVelocity = Vector3.zero

                    local forwardXZ = Vector3.new(forwardDirection.X, 0, forwardDirection.Z)
                    if forwardXZ.Magnitude < 0.001 then
                        forwardXZ = Vector3.new(0, 0, 1)
                    end
                    forwardXZ = forwardXZ.Unit
                    local finalCFrame = CFrame.lookAt(greetPosition, greetPosition + forwardXZ)

                    local nodDown = TweenService:Create(
                        robotBody,
                        TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        {CFrame = finalCFrame * CFrame.Angles(math.rad(-4), 0, 0)}
                    )
                    local nodUp = TweenService:Create(
                        robotBody,
                        TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                        {CFrame = finalCFrame}
                    )

                    nodUp.Completed:Connect(function()
                        robotBody.Anchored = false
                        robotFolder:SetAttribute("HomePosition", greetPosition)
                        robotFolder:SetAttribute("GreetingPlayerId", player and player.UserId or nil)
                        robotFolder:SetAttribute("GreetingStartTime", os.clock())
                        robotFolder:SetAttribute("TaskState", "idle")
                        local robotState = robotFolder:FindFirstChild("RobotState")
                        if robotState then
                            robotState.Value = "garage_idle"
                        end
                        if effects and effects.readyChime then
                            effects.readyChime:Play()
                        end
                        if onReady then
                            task.defer(onReady)
                        end
                    end)

                    nodDown.Completed:Connect(function()
                        nodUp:Play()
                    end)

                    robotBody.Anchored = true
                    robotBody.CFrame = finalCFrame
                    nodDown:Play()
                end)
            end)
        end)
    end)
end

function GarageService.hatchRobot(player, robotType, notify)
    ensureGarageParts()

    local function signal(status, payload)
        if not notify then
            return
        end

        local ok, err = pcall(notify, status, payload)
        if not ok then
            warn("Garage notify failed:", err)
        end
    end

    if activeHatches[player] then
        return false, "Garage busy"
    end

    if not canAfford(player, robotType) then
        return false, "Not enough resources"
    end

    if not deductCost(player, robotType) then
        return false, "Failed to deduct cost"
    end

    activeHatches[player] = true

    signal("started", {
        robotType = robotType,
    })

    animateGarage(2.5)

    task.delay(1.0, function()
        local spawnPosition, thresholdPosition = getRolloutWaypoints()
        local spawnLook
        if spawnPosition and thresholdPosition then
            local dir = thresholdPosition - spawnPosition
            if dir.Magnitude > 0 then
                spawnLook = dir.Unit
            end
        end

        if not spawnPosition and GameConstants.GARAGE_HOME_POSITION then
            spawnPosition = GameConstants.GARAGE_HOME_POSITION
        end

        local ok, robotDataOrError, robotFolder = pcall(RobotManager.spawnRobot, robotType, player, spawnPosition, spawnLook)
        if not ok then
            warn("Failed to spawn robot after hatch:", robotDataOrError)
            refundCost(player, robotType)
            signal("failed", {
                robotType = robotType,
                message = "Robot assembly failed. Resources refunded.",
            })
            activeHatches[player] = nil
            return
        end

        local robotData = robotDataOrError
        if not robotData then
            warn("RobotManager.spawnRobot returned nil data for", robotType)
            refundCost(player, robotType)
            signal("failed", {
                robotType = robotType,
                message = "Robot assembly failed. Resources refunded.",
            })
            activeHatches[player] = nil
            return
        end

        PlayerManager.addRobotToPlayer(player.UserId, robotData)
        if robotFolder then
            local robotState = robotFolder:FindFirstChild("RobotState")
            if robotState then
                robotState.Value = "garage_rollout"
            end
            rollOutRobot(robotFolder, player)
        end

        signal("completed", {
            robotType = robotType,
            robotName = robotData.Name,
            uniqueId = robotData.UniqueId,
        })

        activeHatches[player] = nil
    end)

    task.delay(3.0, function()
        if activeHatches[player] then
            activeHatches[player] = nil
            signal("failed", {
                robotType = robotType,
                message = "Garage reset due to timeout.",
            })
            refundCost(player, robotType)
        end
    end)

    return true
end

return GarageService
