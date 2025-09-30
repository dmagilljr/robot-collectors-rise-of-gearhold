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

local function sampleHoverPosition(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = false
    params.FilterDescendantsInstances = {}

    local origin = Vector3.new(position.X, GameConstants.HOVER_RAYCAST_HEIGHT, position.Z)
    local result = Workspace:Raycast(origin, Vector3.new(0, -GameConstants.HOVER_RAYCAST_HEIGHT * 2, 0), params)

    if result then
        return Vector3.new(position.X, result.Position.Y + GameConstants.ROBOT_HOVER_OFFSET, position.Z)
    end

    return Vector3.new(position.X, GameConstants.ROBOT_HEIGHT, position.Z)
end

local function findGarageParts()
    local floor = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Floor)
    local shell = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Shell)
    local door = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Door)
    local walkway = Workspace:FindFirstChild(GARAGE_MODEL_NAMES.Walkway)

    if floor and shell and door then
        garageParts.Floor = floor
        garageParts.Shell = shell
        garageParts.Door = door
        garageParts.Walkway = walkway
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
    local door = garageParts.Door
    local shell = garageParts.Shell
    if not (walkway and door and shell) then
        return nil
    end

    local audioConfig = GameConstants.AUDIO or {}
    garageEffects = {}

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
        local rumbleSound = door:FindFirstChild("GarageRumbleSound")
        if not rumbleSound then
            rumbleSound = Instance.new("Sound")
            rumbleSound.Name = "GarageRumbleSound"
            rumbleSound.SoundId = audioConfig.GARAGE_RUMBLE
            rumbleSound.Volume = 0.7
            rumbleSound.Looped = false
            rumbleSound.RollOffMode = Enum.RollOffMode.Linear
            rumbleSound.RollOffMaxDistance = 80
            rumbleSound.Parent = door
        end
        garageEffects.rumbleSound = rumbleSound
    end

    if audioConfig.GARAGE_DOOR_OPEN and audioConfig.GARAGE_DOOR_OPEN ~= "" then
        local openSound = door:FindFirstChild("GarageDoorOpen")
        if not openSound then
            openSound = Instance.new("Sound")
            openSound.Name = "GarageDoorOpen"
            openSound.SoundId = audioConfig.GARAGE_DOOR_OPEN
            openSound.Volume = 0.6
            openSound.Looped = false
            openSound.Parent = door
        end
        garageEffects.doorOpenSound = openSound
    end

    if audioConfig.GARAGE_DOOR_CLOSE and audioConfig.GARAGE_DOOR_CLOSE ~= "" then
        local closeSound = door:FindFirstChild("GarageDoorClose")
        if not closeSound then
            closeSound = Instance.new("Sound")
            closeSound.Name = "GarageDoorClose"
            closeSound.SoundId = audioConfig.GARAGE_DOOR_CLOSE
            closeSound.Volume = 0.55
            closeSound.Looped = false
            closeSound.Parent = door
        end
        garageEffects.doorCloseSound = closeSound
    end

    return garageEffects
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

local function rollOutRobot(robotFolder)
    ensureGarageParts()
    local walkway = garageParts.Walkway
    local floor = garageParts.Floor
    local door = garageParts.Door
    if not (walkway and floor and door) then
        return
    end

    local robotBody = robotFolder and robotFolder:FindFirstChild("RobotBody")
    if not robotBody then
        return
    end

    robotBody.Anchored = true

    local targets = {}

    local floorStart = floor.CFrame * CFrame.new(-floor.Size.X/2 + 4, floor.Size.Y/2, 0)
    table.insert(targets, sampleHoverPosition(Vector3.new(floorStart.X, 0, floorStart.Z)))

    local walkwayStart = walkway.CFrame * CFrame.new(-walkway.Size.X/2 + 1.5, walkway.Size.Y/2, 0)
    table.insert(targets, sampleHoverPosition(Vector3.new(walkwayStart.X, 0, walkwayStart.Z)))

    local walkwayMid = walkway.CFrame * CFrame.new(0, walkway.Size.Y/2, 0)
    table.insert(targets, sampleHoverPosition(Vector3.new(walkwayMid.X, 0, walkwayMid.Z)))

    local walkwayEnd = walkway.CFrame * CFrame.new(walkway.Size.X/2 - 1.5, walkway.Size.Y/2, 0)
    table.insert(targets, sampleHoverPosition(Vector3.new(walkwayEnd.X, 0, walkwayEnd.Z)))

    local padTarget = sampleHoverPosition(Vector3.new(0, 0, 0))
    table.insert(targets, padTarget)

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local index = 1
    local function step()
        local target = targets[index]
        if not target then
            robotBody.Anchored = false
            return
        end
        local nextTarget = targets[index + 1] or (target + Vector3.new(0, 0, -1))
        local cframeTarget = CFrame.new(target, nextTarget)
        local tween = TweenService:Create(robotBody, tweenInfo, {CFrame = cframeTarget})
        tween.Completed:Connect(function()
            index += 1
            step()
        end)
        tween:Play()
    end

    step()
end

local function animateGarage(duration)
    ensureGarageParts()
    if not (garageParts.Shell and garageParts.Door) then
        return
    end

    local effects = ensureGarageEffects()
    local openDuration = duration or 2.5
    local door = garageParts.Door
    local shell = garageParts.Shell

    local doorGoalOpen = {CFrame = door.CFrame * CFrame.new(0, 0, -3)}
    local doorGoalClose = {CFrame = door.CFrame}

    local openTween = TweenService:Create(door, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), doorGoalOpen)
    local closeTween = TweenService:Create(door, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), doorGoalClose)

    local shakeTween
    local baseShellCFrame = shell.CFrame
    shakeTween = TweenService:Create(shell, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 6, true), {CFrame = baseShellCFrame * CFrame.Angles(0, 0, math.rad(2))})
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
    end

    openTween:Play()

    task.delay(openDuration, function()
        if shakeTween then
            shakeTween:Cancel()
            shell.CFrame = baseShellCFrame
        end
        if effects and effects.doorCloseSound then
            effects.doorCloseSound:Play()
        end
        closeTween:Play()
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
        local ok, robotDataOrError, robotFolder = pcall(RobotManager.spawnRobot, robotType, player)
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
            rollOutRobot(robotFolder)
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
