-- GarageService: manages garage hatch requests, animation hooks, and spawn queue

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RobotTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("RobotTypes"))
local GameConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("GameConstants"))
local PlayerManager = require(script.Parent.PlayerManager)
local RobotManager = require(script.Parent.RobotManager)

local GarageService = {}

local GARAGE_MODEL_NAMES = {
    Floor = "GarageFloor",
    Shell = "GarageShell",
    Door = "GarageDoor",
    Walkway = "GarageWalkway",
}

local garageParts = {}
local activeHatches = {}
local garageEffects = nil

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

local function pointOnPartSurface(part, offset)
    if not part then
        return nil
    end
    local worldCFrame = part.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)
    local worldPosition = worldCFrame.Position
    return sampleHoverPosition(worldPosition)
end

local function findGarageParts()
    local floor = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Floor)
    local shell = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Shell)
    local door = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Door)
    local walkway = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Walkway)
    local header = Workspace:FindFirstChild("GarageDoorHeader")
    local trackLeft = Workspace:FindFirstChild("GarageDoorTrackLeft")
    local trackRight = Workspace:FindFirstChild("GarageDoorTrackRight")

    if floor and shell and door then
        garageParts.Floor = floor
        garageParts.Shell = shell
        garageParts.Door = door
        garageParts.Walkway = walkway
        garageParts.DoorHeader = header
        garageParts.DoorTrackLeft = trackLeft
        garageParts.DoorTrackRight = trackRight
    end
end

local function ensureGarageParts()
    if next(garageParts) then
        return
    end
    findGarageParts()
end

local function ensureGarageEffects()
    if garageEffects then
        return garageEffects
    end

    ensureGarageParts()

    local walkway = garageParts.Walkway
    local doorGroup = garageParts.Door
    local shell = garageParts.Shell
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
        steamEmitter.Rate = 40
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

    return garageEffects
end

local function getRolloutWaypoints()
    ensureGarageParts()
    local walkway = garageParts.Walkway
    if walkway then
        local topOffset = walkway.Size.Y / 2
        local halfWidth = walkway.Size.X / 2
        local halfDepth = walkway.Size.Z / 2

        local interiorZ = walkway.Position.Z - halfDepth + 0.8
        local thresholdZ = walkway.Position.Z - halfDepth + 2.4
        local greetZ = walkway.Position.Z + halfDepth - 0.8

        local centerX = walkway.Position.X
        local greetX = math.clamp(walkway.Position.X + 3, walkway.Position.X - halfWidth + 1, walkway.Position.X + halfWidth - 1)

        local startPosition = sampleHoverPosition(Vector3.new(centerX, 0, interiorZ))
        local thresholdPosition = sampleHoverPosition(Vector3.new(centerX, 0, thresholdZ))
        local greetPosition = sampleHoverPosition(Vector3.new(greetX, 0, greetZ))

        return startPosition, thresholdPosition, greetPosition
    end

    local fallback = sampleHoverPosition(Vector3.new(22, 0, 4))
    return fallback, fallback, fallback
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

local function rollOutRobot(robotFolder, player)
    ensureGarageParts()
    local robotBody = robotFolder and robotFolder:FindFirstChild("RobotBody")
    if not robotBody then
        return
    end

    local startPosition, thresholdPosition, greetPosition = getRolloutWaypoints()
    robotBody.Anchored = true
    robotBody.CFrame = CFrame.new(startPosition, thresholdPosition)
    robotBody.AssemblyLinearVelocity = Vector3.zero
    robotBody.AssemblyAngularVelocity = Vector3.zero

    local function tweenToPosition(target, duration, easingStyle, easingDirection, onComplete)
        local lookAt = greetPosition
        if (target - lookAt).Magnitude < 0.01 then
            lookAt = target + Vector3.new(0, 0, -1)
        end
        local tween = TweenService:Create(robotBody, TweenInfo.new(duration, easingStyle, easingDirection), {
            CFrame = CFrame.new(target, lookAt)
        })
        if onComplete then
            tween.Completed:Connect(onComplete)
        end
        tween:Play()
    end

    tweenToPosition(thresholdPosition, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, function()
        task.delay(0.4, function()
            tweenToPosition(greetPosition, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                robotBody.AssemblyLinearVelocity = Vector3.zero
                robotBody.AssemblyAngularVelocity = Vector3.zero
                robotBody.Anchored = false
                robotFolder:SetAttribute("HomePosition", greetPosition)
                beginGreeting(robotFolder, player)
            end)
        end)
    end)
end

local function animateGarage(duration)
    ensureGarageParts()
    if not (garageParts.Shell and garageParts.Door) then
        return
    end

    local effects = ensureGarageEffects()
    local openDuration = duration or 2.5
    local doorGroup = garageParts.Door
    local shell = garageParts.Shell

    local slats = {}
    if doorGroup and doorGroup:IsA("Folder") then
        for _, child in ipairs(doorGroup:GetChildren()) do
            if child:IsA("BasePart") then
                table.insert(slats, child)
            end
        end
    end
    table.sort(slats, function(a, b)
        return a.Position.Y < b.Position.Y
    end)

    local slatData = {}
    local minY, maxY = math.huge, -math.huge
    for _, slat in ipairs(slats) do
        minY = math.min(minY, slat.Position.Y - slat.Size.Y / 2)
        maxY = math.max(maxY, slat.Position.Y + slat.Size.Y / 2)
    end
    local doorHeight = maxY - minY

    local header = garageParts.DoorHeader
    local backDepth = header and (header.Size.Z + 0.4) or 2

    for index, slat in ipairs(slats) do
        local baseCFrame = slat.CFrame
        local liftAmount = doorHeight + 0.9 - (index - 1) * (slat.Size.Y * 0.78)
        local liftCFrame = baseCFrame * CFrame.new(0, liftAmount, 0)
        local backCFrame = liftCFrame * CFrame.new(0, 0, -backDepth)
        table.insert(slatData, {
            part = slat,
            baseCFrame = baseCFrame,
            openCFrame = liftCFrame,
            backCFrame = backCFrame,
        })
    end

    local shakeTween
    local baseShellCFrame = shell.CFrame
    shakeTween = TweenService:Create(shell, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 6, true), {CFrame = baseShellCFrame * CFrame.Angles(0, 0, math.rad(2.5))})
    shakeTween:Play()

    if effects then
        if effects.rumbleSound then
            effects.rumbleSound:Play()
        end
        if effects.doorOpenSound then
            effects.doorOpenSound:Play()
        end
        if effects.steamEmitter then
            effects.steamEmitter.Enabled = true
            task.delay(openDuration, function()
                if garageEffects and garageEffects.steamEmitter then
                    garageEffects.steamEmitter.Enabled = false
                end
            end)
        end
        if effects.steamSound then
            effects.steamSound:Play()
        end
        if effects.interiorLight then
            effects.interiorLight.Enabled = true
            effects.interiorLight.Brightness = 4
        end
    end

    for index, data in ipairs(slatData) do
        data.part.CanCollide = false
        local liftTween = TweenService:Create(data.part, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = data.openCFrame})
        local backTween = TweenService:Create(data.part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = data.backCFrame})
        task.delay(0.05 * (index - 1), function()
            liftTween.Completed:Connect(function()
                backTween:Play()
            end)
            liftTween:Play()
        end)
    end

    task.delay(openDuration + 3, function()
        if shakeTween then
            shakeTween:Cancel()
            shell.CFrame = baseShellCFrame
        end
        if effects and effects.doorCloseSound then
            effects.doorCloseSound:Play()
        end
        if effects and effects.interiorLight then
            effects.interiorLight.Enabled = false
        end
        for index = #slatData, 1, -1 do
            local data = slatData[index]
            local forwardTween = TweenService:Create(data.part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CFrame = data.openCFrame})
            local dropTween = TweenService:Create(data.part, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CFrame = data.baseCFrame})
            task.delay(0.05 * (#slatData - index), function()
                forwardTween.Completed:Connect(function()
                    dropTween.Completed:Connect(function()
                        data.part.CanCollide = true
                    end)
                    dropTween:Play()
                end)
                forwardTween:Play()
            end)
        end
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
