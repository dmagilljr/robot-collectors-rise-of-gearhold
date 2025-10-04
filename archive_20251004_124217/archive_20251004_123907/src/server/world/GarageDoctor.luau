--!strict

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local SLAT_COUNT = 12
local ANIMATION_DURATION = 1.2
local SLAT_STAGGER = 0.06

local GarageDoctor = {}

export type DoorController = {
    model: Model,
    slats: {BasePart},
    closedCFs: {CFrame},
    openCFs: {CFrame},
    tweens: {Tween},
    moving: boolean,
    pendingTarget: boolean?,
}

type Summary = {
    keptGarage: string,
    debrisRemoved: number,
    consoleOK: boolean,
    doorFrameOK: boolean,
    doorFrameSize: Vector2,
    doorSlats: number,
    promptOK: boolean,
    remoteOK: boolean,
    slatDepth: number,
    doorBack: number,
    doorOffset: number,
    promptDistance: number,
    promptLOS: boolean,
    doorOpen: boolean,
}

local controller: DoorController? = nil
local remoteConnection: RBXScriptConnection? = nil
local promptConnection: RBXScriptConnection? = nil
local toggleEvent: RemoteEvent? = nil

local function log(message: string)
    print(string.format("[GarageDoctor] %s", message))
end

local function formatVector(vector: Vector3): string
    return string.format("(%.2f, %.2f, %.2f)", vector.X, vector.Y, vector.Z)
end

local function ensureChild(parent: Instance, className: string, name: string): Instance
    local existing = parent:FindFirstChild(name)
    if existing and existing.ClassName == className then
        return existing
    end
    if existing then
        existing:Destroy()
    end
    local inst = Instance.new(className)
    inst.Name = name
    inst.Parent = parent
    return inst
end

local function ensureRemoteEvent(): RemoteEvent
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
        log("Created ReplicatedStorage.Remotes")
    end

    local event = remotesFolder:FindFirstChild("ToggleGarageDoor")
    if event and not event:IsA("RemoteEvent") then
        log("Replacing invalid Remotes.ToggleGarageDoor")
        event:Destroy()
        event = nil
    end

    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = "ToggleGarageDoor"
        event.Parent = remotesFolder
        log("Created Remotes.ToggleGarageDoor")
    end

    return event
end

local function gatherGarageModel(): Model
    local candidates = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == "Garage" then
            table.insert(candidates, child)
        end
    end

    table.sort(candidates, function(a, b)
        return a:GetDebugId() < b:GetDebugId()
    end)

    local garage: Model
    if #candidates == 0 then
        garage = Instance.new("Model")
        garage.Name = "Garage"
        garage.Parent = Workspace
        log("Created workspace.Garage")
    else
        garage = candidates[1]
        if #candidates > 1 then
            for index = 2, #candidates do
                log(string.format("Destroying duplicate Garage model: %s", candidates[index]:GetFullName()))
                candidates[index]:Destroy()
            end
            log(string.format("Removed %d duplicate Garage models", #candidates - 1))
        end
    end

    return garage
end

local EXTRA_DEBRIS_NAMES = {
    DoorHandle = true,
    GarageDoorPrompt = true,
    GarageDoorButton = true,
    GarageDoorControl = true,
    ConsoleSupportLeft = true,
    ConsoleSupportRight = true,
    ConsoleSupport = true,
}

local function cleanupDebris(garage: Model, rootPart: BasePart?): (number, number, {string})
    local removed = 0
    local scanned = 0
    local nearMatches: {string} = {}

    local rootPos: Vector3? = nil
    if rootPart then
        rootPos = rootPart.Position
    elseif garage.PrimaryPart then
        rootPos = garage.PrimaryPart.Position
    else
        local okPivot, pivot = pcall(function()
            return garage:GetPivot()
        end)
        if okPivot then
            rootPos = pivot.Position
        end
    end

    local RADIUS = 60

    for _, inst in ipairs(workspace:GetDescendants()) do
        if not inst.Parent then
            continue
        end
        if inst == garage or inst:IsDescendantOf(garage) then
            continue
        end
        if not (inst:IsA("BasePart") or inst:IsA("Model")) then
            continue
        end

        local name = inst.Name
        local lower = string.lower(name)
        local looksGarage = false
        if EXTRA_DEBRIS_NAMES[name] then
            looksGarage = true
        elseif lower:find("garage") or lower:find("door") or lower:find("console") or lower:find("frame") then
            looksGarage = true
        end

        local nearRoot = false
        if not rootPos then
            nearRoot = true
        else
            if inst:IsA("BasePart") then
                nearRoot = (inst.Position - rootPos).Magnitude <= RADIUS
            else
                local candidate: Vector3? = nil
                if inst.PrimaryPart then
                    candidate = inst.PrimaryPart.Position
                else
                    local okModelPivot, modelPivot = pcall(function()
                        return inst:GetPivot()
                    end)
                    if okModelPivot then
                        candidate = modelPivot.Position
                    end
                end
                if candidate then
                    nearRoot = (candidate - rootPos).Magnitude <= RADIUS
                end
            end
        end

        if nearRoot then
            scanned += 1
            if not looksGarage and #nearMatches < 12 then
                local pos: Vector3? = nil
                if inst:IsA("BasePart") then
                    pos = inst.Position
                elseif inst.PrimaryPart then
                    pos = inst.PrimaryPart.Position
                else
                    local okPivot, modelPivot = pcall(function()
                        return inst:GetPivot()
                    end)
                    if okPivot then
                        pos = modelPivot.Position
                    end
                end
                local distance = 0
                if pos and rootPos then
                    distance = (pos - rootPos).Magnitude
                end
                local info = string.format("%s (%.1f studs)", inst:GetFullName(), distance)
                table.insert(nearMatches, info)
            end
        end

        if not looksGarage or not nearRoot then
            continue
        end

        log(string.format("Destroying debris: %s", inst:GetFullName()))
        local ok = pcall(function()
            inst:Destroy()
        end)
        if ok then
            removed += 1
        end
    end

    log(string.format("Cleaned debris: %d (radius=%d)", removed, RADIUS))
    return removed, scanned, nearMatches
end

local function animateDoor(desired: boolean)
    if not controller or not controller.model then
        return
    end

    local doorModel = controller.model
    if controller.moving then
        controller.pendingTarget = desired
        doorModel:SetAttribute("TargetOpen", desired)
        return
    end

    controller.moving = true
    doorModel:SetAttribute("Moving", true)
    doorModel:SetAttribute("TargetOpen", desired)

    table.clear(controller.tweens)

    if desired then
        for _, slat in ipairs(controller.slats) do
            slat.CanCollide = false
        end
    end

    for index, slat in ipairs(controller.slats) do
        local targetCF = desired and controller.openCFs[index] or controller.closedCFs[index]
        local tween = TweenService:Create(
            slat,
            TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, (index - 1) * SLAT_STAGGER),
            { CFrame = targetCF }
        )
        tween:Play()
        controller.tweens[#controller.tweens + 1] = tween
    end

    local totalTime = ANIMATION_DURATION + math.max(0, #controller.slats - 1) * SLAT_STAGGER
    task.delay(totalTime, function()
        if not controller or controller.model ~= doorModel then
            return
        end

        controller.moving = false
        doorModel:SetAttribute("Moving", false)

        if not desired then
            for _, slat in ipairs(controller.slats) do
                slat.CanCollide = true
            end
        end

        table.clear(controller.tweens)

        if controller.pendingTarget ~= nil and controller.pendingTarget ~= desired then
            local nextTarget = controller.pendingTarget
            controller.pendingTarget = nil
            if doorModel:GetAttribute("IsOpen") ~= nextTarget then
                doorModel:SetAttribute("IsOpen", nextTarget)
            end
        else
            controller.pendingTarget = nil
        end
    end)
end

local function ensureConsole(garage: Model, summary: Summary): (Model, BasePart, ProximityPrompt)
    local console = garage:FindFirstChild("GarageConsole")
    if console and not console:IsA("Model") then
        log("Replacing invalid GarageConsole container")
        console:Destroy()
        console = nil
    end
    if not console then
        console = Instance.new("Model")
        console.Name = "GarageConsole"
        console.Parent = garage
        log("Created GarageConsole model")
    end

    local primary = console.PrimaryPart
    local deck = console:FindFirstChild("GarageConsoleDeck")
    if deck and deck:IsA("BasePart") then
        console.PrimaryPart = deck
        primary = deck
    end

    if not primary or not primary:IsA("BasePart") then
        local base = console:FindFirstChild("Base")
        if base and not base:IsA("BasePart") then
            base:Destroy()
            base = nil
        end
        if not base then
            base = Instance.new("Part")
            base.Name = "Base"
            base.Size = Vector3.new(3, 1, 3)
            base.Anchored = true
            base.CanCollide = true
            base.Material = Enum.Material.Metal
            base.Color = Color3.fromRGB(70, 80, 95)
            base.CFrame = CFrame.new(28, 0.5, 0)
            base.Parent = console
            log("Created GarageConsole.Base at (28, 0.5, 0)")
        end
        console.PrimaryPart = base
        primary = base
    else
        primary.Anchored = true
    end

    local handle = console:FindFirstChild("DoorHandle")
    if handle and not handle:IsA("BasePart") then
        log("Replacing invalid DoorHandle")
        handle:Destroy()
        handle = nil
    end
    if not handle then
        handle = Instance.new("Part")
        handle.Name = "DoorHandle"
        handle.Size = Vector3.new(0.5, 1.2, 0.5)
        handle.Material = Enum.Material.Metal
        handle.Color = Color3.fromRGB(95, 205, 255)
        handle.Parent = console
        log("Created GarageConsole.DoorHandle")
    end
    local handlePart = handle :: BasePart
    handlePart.Anchored = true
    handlePart.CanCollide = false
    handlePart.CanQuery = false
    if primary and not handlePart:GetAttribute("GeneratedBySetup") then
        handlePart.CFrame = primary.CFrame * CFrame.new(0, 1.2, -(primary.Size.Z * 0.5 + 0.75))
    end

    for _, descendant in ipairs(handlePart:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            log(string.format("Removing duplicate prompt: %s", descendant:GetFullName()))
            descendant:Destroy()
        end
    end

    local prompt = handlePart:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Parent = handlePart
        log("Created GarageDoor ProximityPrompt")
    end
    prompt.ObjectText = "Garage Access"
    prompt.ActionText = "Toggle Door"
    prompt.KeyboardKeyCode = Enum.KeyCode.F
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 18
    prompt.Style = Enum.ProximityPromptStyle.Default

    summary.consoleOK = true
    summary.promptOK = prompt ~= nil

    return console, primary, prompt
end

local function ensureDoorFrame(garage: Model, consolePrimary: BasePart, summary: Summary): BasePart
    local frame = garage:FindFirstChild("DoorFrame")
    if frame and not frame:IsA("BasePart") then
        log("Replacing invalid DoorFrame container")
        frame:Destroy()
        frame = nil
    end
    if not frame then
        frame = Instance.new("Part")
        frame.Name = "DoorFrame"
        frame.Parent = garage
        log("Created DoorFrame")
    end

    local doorFrame = frame :: BasePart
    doorFrame.Anchored = true
    doorFrame.CanCollide = false
    doorFrame.CanQuery = false
    doorFrame.Material = Enum.Material.Metal
    doorFrame.Transparency = 0.4
    local preserveFrame = doorFrame:GetAttribute("GeneratedBySetup") == true
    if doorFrame.Size.Magnitude < 0.01 then
        doorFrame.Size = Vector3.new(6, 6, 0.2)
        preserveFrame = false
    end

    if not preserveFrame then
        local position = consolePrimary.CFrame * CFrame.new(0, doorFrame.Size.Y * 0.5, -(consolePrimary.Size.Z * 0.5 + 4))
        local facing = position.Position + consolePrimary.CFrame.LookVector
        doorFrame.CFrame = CFrame.lookAt(position.Position, facing)
    end

    summary.doorFrameOK = true
    summary.doorFrameSize = Vector2.new(doorFrame.Size.X, doorFrame.Size.Y)

    if not garage.PrimaryPart then
        pcall(function()
            garage.PrimaryPart = doorFrame
        end)
    end

    return doorFrame
end

local function positionPrompt(doorFrame: BasePart, console: Model, prompt: ProximityPrompt?)
    if not prompt then
        return
    end

    local frameCF = doorFrame.CFrame
    local right = frameCF.RightVector
    local up = frameCF.UpVector
    local fwd = frameCF.LookVector

    local handle = console:FindFirstChild("DoorHandle")
    if handle and handle:IsA("BasePart") then
        local handlePart = handle :: BasePart
        handlePart.Anchored = true
        handlePart.CanCollide = false
        handlePart.CanQuery = false
        handlePart.CFrame = CFrame.fromMatrix(
            frameCF.Position + (fwd * 2.0) + (up * 1.2),
            right,
            up,
            fwd
        )
    end

    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 18
    prompt.KeyboardKeyCode = Enum.KeyCode.F
    prompt.HoldDuration = 0
    prompt.Style = Enum.ProximityPromptStyle.Default
    prompt.ObjectText = "Garage Access"
    prompt.ActionText = "Toggle Door"

    log(string.format("Prompt placed in front of frame (dist=%.1f)", 2.0))
end

local function computePathCFrame(points: {Vector3}, upDir: Vector3, forwardHint: Vector3, alpha: number): CFrame
    local segmentCount = #points - 1
    if segmentCount <= 0 then
        return CFrame.new(points[1])
    end

    local scaled = math.clamp(alpha, 0, 1) * segmentCount
    local index = math.clamp(math.floor(scaled) + 1, 1, segmentCount)
    local localT = scaled - (index - 1)
    local startPos = points[index]
    local endPos = points[index + 1]
    local position = startPos:Lerp(endPos, localT)

    local sampleNext: Vector3
    if localT < 0.95 then
        sampleNext = startPos:Lerp(endPos, math.min(1, localT + 0.05))
    elseif index < segmentCount then
        sampleNext = endPos:Lerp(points[index + 2], math.min(1, (scaled + 0.05) - index))
    else
        sampleNext = position + forwardHint
    end

    local direction = sampleNext - position
    if direction.Magnitude < 0.001 then
        direction = forwardHint
    end
    direction = direction.Unit

    local rightVector = direction:Cross(upDir)
    if rightVector.Magnitude < 0.001 then
        rightVector = forwardHint:Cross(upDir)
        if rightVector.Magnitude < 0.001 then
            rightVector = Vector3.new(1, 0, 0)
        end
    end
    rightVector = rightVector.Unit

    return CFrame.fromMatrix(position, rightVector, upDir, -direction)
end

local function rebuildDoor(garage: Model, doorFrame: BasePart, summary: Summary): DoorController
    local doorModel = garage:FindFirstChild("GarageDoor")
    if doorModel and not doorModel:IsA("Model") then
        log("Replacing invalid GarageDoor container")
        doorModel:Destroy()
        doorModel = nil
    end
    if not doorModel then
        doorModel = Instance.new("Model")
        doorModel.Name = "GarageDoor"
        doorModel.Parent = garage
        log("Created GarageDoor model")
    end

    for _, child in ipairs(doorModel:GetChildren()) do
        child:Destroy()
    end
    log("Cleared previous GarageDoor children")

    local frame = doorFrame :: Part
    local frameCF = frame.CFrame
    local right = frameCF.RightVector
    local up = frameCF.UpVector
    local fwd = frameCF.LookVector

    local width = frame.Size.X
    local height = frame.Size.Y
    local depth = 0.30
    local offsetIntoOpening = 0.60
    local back = 3.0
    local nSlats = SLAT_COUNT
    local hPer = height / nSlats
    local center = frameCF.Position + (-fwd * offsetIntoOpening)

    summary.slatDepth = depth
    summary.doorBack = back
    summary.doorOffset = offsetIntoOpening

    local track = ensureChild(doorModel, "Part", "Track") :: BasePart
    track.Parent = doorModel
    track.Size = Vector3.new(width + 2, 0.4, back + 1)
    track.Transparency = 1
    track.CanCollide = false
    track.CanQuery = false
    track.Anchored = true
    track.CFrame = frameCF * CFrame.new(0, height * 0.5 + 0.2, -(back * 0.5))
    log("Created GarageDoor.Track")

    local A0 = center + up * (-height * 0.5 + 0.10)
    local A1 = center + up * (height * 0.5)
    local A2 = A1 + (-fwd * (back * 0.5))
    local A3 = A1 + (-fwd * back)
    local A4 = A3 + up * 0.10
    local pathPoints = {A0, A1, A2, A3, A4}

    for index, worldPos in ipairs(pathPoints) do
        local attachment = ensureChild(track, "Attachment", string.format("A%d", index - 1)) :: Attachment
        attachment.Parent = track
        attachment.WorldPosition = worldPos
    end

    local debugColor = Color3.fromRGB(255, 0, 255)
    for index, worldPos in ipairs(pathPoints) do
        local dbg = Instance.new("Part")
        dbg.Name = string.format("DoorPath_%d", index - 1)
        dbg.Shape = Enum.PartType.Ball
        dbg.Size = Vector3.new(0.35, 0.35, 0.35)
        dbg.Color = debugColor
        dbg.Material = Enum.Material.Neon
        dbg.Anchored = true
        dbg.CanCollide = false
        dbg.CanQuery = false
        dbg.Transparency = 0.25
        dbg.Parent = doorModel
        dbg.CFrame = CFrame.new(worldPos)
        task.delay(10, function()
            if dbg and dbg.Parent then
                dbg:Destroy()
            end
        end)
    end

    local slats: {BasePart} = {}
    local closedCFs: {CFrame} = {}
    local openCFs: {CFrame} = {}
    local startOpen = doorModel:GetAttribute("IsOpen") == true

    for index = 1, nSlats do
        local slat = ensureChild(doorModel, "Part", string.format("Slat_%02d", index)) :: Part
        slat.Parent = doorModel
        slat.Anchored = true
        slat.Material = Enum.Material.Metal
        slat.Color = Color3.fromRGB(130, 190, 255)
        slat.Transparency = 0
        slat.CanCollide = not startOpen
        slat.CanQuery = false
        slat.Size = Vector3.new(width, hPer, depth)

        local y = (-height * 0.5) + (hPer * (index - 0.5))
        local localOffset = up * y
        local closedCF = CFrame.fromMatrix(center + localOffset, right, up, fwd)
        slat.CFrame = closedCF
        closedCFs[index] = closedCF

        local alpha = if nSlats == 1 then 1 else (index - 1) / (nSlats - 1)
        local openCF = computePathCFrame(pathPoints, up, -fwd, alpha)
        openCFs[index] = openCF
        if startOpen then
            slat.CFrame = openCF
            slat.CanCollide = false
        end

        slats[index] = slat
    end

    log(string.format("Slats posed: width=%.2f height=%.2f depth=%.2f offset=%.2f", width, height, depth, offsetIntoOpening))
    if slats[1] then
        log(string.format("First slat at %s", formatVector(slats[1].Position)))
    end

    doorModel.PrimaryPart = track
    doorModel:SetAttribute("IsOpen", startOpen)
    doorModel:SetAttribute("Moving", false)
    doorModel:SetAttribute("TargetOpen", startOpen)

    summary.doorOpen = startOpen
    summary.doorSlats = #slats
    log(string.format("Rebuilt GarageDoor with %d slats", #slats))

    local newController: DoorController = {
        model = doorModel,
        slats = slats,
        closedCFs = closedCFs,
        openCFs = openCFs,
        tweens = {},
        moving = false,
        pendingTarget = nil,
    }

    controller = newController

    if doorModel:GetAttribute("ListenerBound") ~= true then
        doorModel:SetAttribute("ListenerBound", true)
        doorModel:GetAttributeChangedSignal("IsOpen"):Connect(function()
            local desired = doorModel:GetAttribute("IsOpen") == true
            log(string.format("Animating %s", desired and "OPEN" or "CLOSE"))
            animateDoor(desired)
        end)
    end

    return newController
end

local function setDoorState(target: boolean)
    if not controller or not controller.model then
        warn("[GarageDoctor] Door controller not ready")
        return
    end

    local doorModel = controller.model
    if doorModel:GetAttribute("Moving") == true then
        controller.pendingTarget = target
        doorModel:SetAttribute("TargetOpen", target)
        return
    end

    if doorModel:GetAttribute("IsOpen") ~= target then
        doorModel:SetAttribute("IsOpen", target)
    end
end

local function processToggle(source: string)
    log(string.format("Toggle request from %s", source))
    if not controller or not controller.model then
        warn("[GarageDoctor] Toggle requested before controller ready")
        return
    end

    local doorModel = controller.model
    local current = doorModel:GetAttribute("IsOpen") == true
    local target = not current
    setDoorState(target)
end


function GarageDoctor.requestToggle(player: Player?)
    processToggle(player and player.Name or "system")
end

function GarageDoctor.toggleDoor()
    processToggle("service")
end

function GarageDoctor.openDoor()
    setDoorState(true)
end

function GarageDoctor.closeDoor()
    setDoorState(false)
end

function GarageDoctor.getDoorModel(): Model?
    return controller and controller.model or nil
end

function GarageDoctor.run(): Summary
    if Workspace:GetAttribute("WorkspaceSetupComplete") ~= true then
        log("Awaiting WorkspaceSetupComplete")
        Workspace:GetAttributeChangedSignal("WorkspaceSetupComplete"):Wait()
    end

    local summary: Summary = {
        keptGarage = "Garage",
        debrisRemoved = 0,
        consoleOK = false,
        doorFrameOK = false,
        doorFrameSize = Vector2.new(0, 0),
        doorSlats = 0,
        promptOK = false,
        remoteOK = false,
        slatDepth = 0,
        doorBack = 0,
        doorOffset = 0,
        promptDistance = 0,
        promptLOS = false,
        doorOpen = false,
    }

    local garage = gatherGarageModel()
    summary.keptGarage = garage.Name

    local console, primary, prompt = ensureConsole(garage, summary)
    local doorFrame = ensureDoorFrame(garage, primary, summary)

    local debrisRemoved, scannedCount, nearMatches = cleanupDebris(garage, doorFrame)
    summary.debrisRemoved = debrisRemoved

    toggleEvent = ensureRemoteEvent()
    summary.remoteOK = toggleEvent ~= nil

    controller = rebuildDoor(garage, doorFrame, summary)
    positionPrompt(doorFrame, console, prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        summary.promptDistance = prompt.MaxActivationDistance
        summary.promptLOS = prompt.RequiresLineOfSight
    end

    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end

    if prompt and prompt:IsA("ProximityPrompt") then
        promptConnection = prompt.Triggered:Connect(function(player)
            GarageDoctor.requestToggle(player)
        end)
    end

    if toggleEvent then
        if remoteConnection then
            remoteConnection:Disconnect()
            remoteConnection = nil
        end
        remoteConnection = toggleEvent.OnServerEvent:Connect(function(player)
            processToggle(player and player.Name or "remote")
        end)
    end

    summary.promptOK = promptConnection ~= nil
    summary.remoteOK = summary.remoteOK and remoteConnection ~= nil

    log("Ready")
    log(string.format("  keptGarage: %s", summary.keptGarage))
    log(string.format("  debrisRemoved: %d", summary.debrisRemoved))
    log(string.format("  consoleOK: %s", tostring(summary.consoleOK)))
    log(string.format(
        "  doorFrameOK: %s (size WxH = %.2fx%.2f)",
        tostring(summary.doorFrameOK),
        summary.doorFrameSize.X,
        summary.doorFrameSize.Y
    ))
    log(string.format("  doorSlats: %d", summary.doorSlats))
    log(string.format("  promptOK: %s", tostring(summary.promptOK)))
    log(string.format("  remoteOK: %s", tostring(summary.remoteOK)))
    log(string.format("  slatDepth=%.2f back=%.2f offset=%.2f", summary.slatDepth, summary.doorBack, summary.doorOffset))
    log(string.format("  prompt settings: LOS=%s, dist=%d", tostring(summary.promptLOS), summary.promptDistance))
    log(string.format("  doorOpen: %s", tostring(summary.doorOpen)))
    if scannedCount > 0 and #nearMatches > 0 then
        log("  nearby non-matched instances:")
        for _, entry in ipairs(nearMatches) do
            log("    " .. entry)
        end
    end

    Workspace:SetAttribute("GarageDoctorReady", true)

    return summary
end

GarageDoctor.ensure = GarageDoctor.run
GarageDoctor.open = GarageDoctor.openDoor
GarageDoctor.close = GarageDoctor.closeDoor
GarageDoctor.toggle = GarageDoctor.toggleDoor

return GarageDoctor
