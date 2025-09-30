-- Robot Collectors: Robot Management System
-- Handles robot creation, movement, and AI behavior

local workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("config")
local RobotTypes = require(Config:WaitForChild("RobotTypes"))
local GameConstants = require(Config:WaitForChild("GameConstants"))
local PlayerManager = require(script.Parent.PlayerManager)

local RobotManager = {}
local DEBUG = false

local DRILL_IDLE_COLOR = Color3.fromRGB(205, 205, 205)
local DRILL_ACTIVE_COLOR = Color3.fromRGB(255, 170, 64)

local function getDrillComponents(robotFolder)
    local drill = robotFolder:FindFirstChild("Drill")
    if not drill or not drill:IsA("BasePart") then
        return
    end

    local emitter = drill:FindFirstChild("DrillEmitter")
    local drillLight = drill:FindFirstChild("DrillLight")
    local drillSound = drill:FindFirstChild("DrillLoop")

    local statusLight
    local head = robotFolder:FindFirstChild("RobotHead")
    if head then
        statusLight = head:FindFirstChild("StatusLight")
    end

    return drill, emitter, drillLight, statusLight, drillSound
end

local function setDrillActive(robotFolder, isActive)
    local drill, emitter, drillLight, statusLight, drillSound = getDrillComponents(robotFolder)
    if drill then
        drill.Color = isActive and DRILL_ACTIVE_COLOR or DRILL_IDLE_COLOR
    end
    if emitter then
        emitter.Enabled = isActive
    end
    if drillLight then
        drillLight.Enabled = isActive
    end
    if statusLight then
        statusLight.Enabled = isActive
    end
    if drillSound and drillSound.SoundId ~= "" then
        if isActive then
            if not drillSound.IsPlaying then
                drillSound:Play()
            end
        else
            drillSound:Stop()
        end
    end
    robotFolder:SetAttribute("DrillActive", isActive)
end

local function debugPrint(robotFolder, ...)
    if not DEBUG then
        return
    end
    local prefix = "🤖[" .. (robotFolder and robotFolder.Name or "?") .. "]"
    print(prefix, ...)
end

local TASK_STATES = {
    IDLE = "idle",
    SEEKING = "seeking",
    TRAVEL = "travel",
    MINING = "mining",
    RETURNING = "return",
    COOLDOWN = "cooldown",
}

local function ensureChild(parent, className, name)
    local child = parent:FindFirstChild(name)
    if child then
        return child
    end

    child = Instance.new(className)
    child.Name = name
    child.Parent = parent
    return child
end

local function setTaskState(robotFolder, state)
    local previous = robotFolder:GetAttribute("TaskState")
    if previous ~= state then
        robotFolder:SetAttribute("TaskState", state)
        debugPrint(robotFolder, "State", previous or "none", "→", state)
    end
end

local function getRobotConfig(robotFolder)
    local robotType = robotFolder:GetAttribute("RobotType")
    if robotType then
        return RobotTypes[robotType]
    end

    local namePieces = string.split(robotFolder.Name, "_")
    local typeName = namePieces[1]
    return RobotTypes[typeName]
end

local function findRobotFolder(robotId, player)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Folder") then
            local owner = obj:FindFirstChild("Owner")
            local uniqueId = obj:FindFirstChild("UniqueId")

            if owner and owner.Value == player and uniqueId then
                if uniqueId.Value:sub(1, 8) == robotId then
                    return obj
                end
            end
        end
    end

    return nil
end

local function getHoverHeight(position, ignoreInstances)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreInstances or {}
    params.IgnoreWater = false

    local origin = Vector3.new(position.X, GameConstants.HOVER_RAYCAST_HEIGHT, position.Z)
    local result = workspace:Raycast(origin, Vector3.new(0, -GameConstants.HOVER_RAYCAST_HEIGHT * 2, 0), params)

    if result then
        return result.Position.Y + GameConstants.ROBOT_HOVER_OFFSET
    end

    return GameConstants.ROBOT_HEIGHT
end

local function getHoverPosition(position, ignoreInstances)
    return Vector3.new(position.X, getHoverHeight(position, ignoreInstances), position.Z)
end

local function moveRobot(robotBody, targetPosition, config, speedMultiplier, deltaTime)
    speedMultiplier = speedMultiplier or 1
    deltaTime = math.max(deltaTime or GameConstants.MOVEMENT_UPDATE_INTERVAL, 1e-3)

    local ignoreList = {robotBody}
    if robotBody.Parent then
        table.insert(ignoreList, robotBody.Parent)
    end

    local planarTarget = Vector3.new(targetPosition.X, 0, targetPosition.Z)
    local targetY = getHoverHeight(planarTarget, ignoreList)
    local target = Vector3.new(planarTarget.X, targetY, planarTarget.Z)

    local currentPosition = robotBody.Position
    local planarCurrent = Vector3.new(currentPosition.X, 0, currentPosition.Z)
    local delta = Vector3.new(target.X - planarCurrent.X, 0, target.Z - planarCurrent.Z)
    local distance = delta.Magnitude

    if distance <= 0.02 then
        local lookDir = robotBody.CFrame.LookVector
        local planarLook = Vector3.new(lookDir.X, 0, lookDir.Z)
        if planarLook.Magnitude < 0.001 then
            planarLook = Vector3.zAxis
        else
            planarLook = planarLook.Unit
        end
        robotBody.CFrame = CFrame.new(target, target + planarLook)
        robotBody.AssemblyLinearVelocity = Vector3.zero
        return 0
    end

    local maxStep = (config.Speed or 1) * GameConstants.ROBOT_TRAVEL_SPEED * speedMultiplier * deltaTime
    if maxStep > distance then
        maxStep = distance
    end

    local nextPlanar = planarCurrent + delta.Unit * maxStep
    local nextY = getHoverHeight(nextPlanar, ignoreList)
    local nextPosition = Vector3.new(nextPlanar.X, nextY, nextPlanar.Z)

    local travelDir = Vector3.new(target.X - nextPosition.X, 0, target.Z - nextPosition.Z)
    if travelDir.Magnitude < 0.001 then
        travelDir = Vector3.zAxis
    else
        travelDir = travelDir.Unit
    end

    robotBody.CFrame = CFrame.new(nextPosition, nextPosition + travelDir)
    robotBody.AssemblyLinearVelocity = Vector3.zero

    return math.max(distance - maxStep, 0)
end

function RobotManager.spawnRobot(robotType, player, spawnPosition, spawnLookAt)
    local robotConfig = RobotTypes[robotType]
    if not robotConfig then
        warn("Unknown robot type:", robotType)
        return nil
    end

    -- Create unique robot data
    local uniqueId = HttpService:GenerateGUID(false)
    local robotData = {
        Type = robotType,
        Name = robotConfig.Name,
        Rarity = robotConfig.Rarity,
        Level = 1,
        UniqueId = uniqueId
    }

    -- Create physical robot in workspace
    local robotFolder = RobotManager.createRobotModel(robotConfig, robotData, player, spawnPosition, spawnLookAt)
    if robotFolder then
        print("✨ Robot", robotConfig.Name, "spawned for", player.Name)
        return robotData, robotFolder
    end

    return nil, nil
end

function RobotManager.createRobotModel(robotConfig, robotData, player, spawnPosition, spawnLookAt)
    local robotFolder = Instance.new("Folder")
    robotFolder.Name = robotConfig.Name .. "_" .. string.sub(robotData.UniqueId, 1, 8)
    robotFolder.Parent = workspace

    local robotBody = Instance.new("Part")
    robotBody.Name = "RobotBody"
    robotBody.Size = Vector3.new(2.6, 1.2, 2.6)
    robotBody.Color = robotConfig.Color
    robotBody.Material = Enum.Material.Metal
    robotBody.Anchored = true
    robotBody.CanCollide = false
    local initialPlanar = spawnPosition and Vector3.new(spawnPosition.X, 0, spawnPosition.Z) or Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    local initialY = getHoverHeight(initialPlanar, {robotFolder})
    local worldSpawn = spawnPosition and Vector3.new(spawnPosition.X, spawnPosition.Y, spawnPosition.Z) or Vector3.new(initialPlanar.X, initialY, initialPlanar.Z)
    local lookVector = spawnLookAt or Vector3.zAxis
    robotBody.CFrame = CFrame.new(worldSpawn, worldSpawn + lookVector)
    robotBody.Parent = robotFolder
    robotBody.CustomPhysicalProperties = PhysicalProperties.new(0.2, 0.3, 0.3, 1, 1)

    local function weldToBody(part, offsetCFrame)
        part.Anchored = false
        part.CanCollide = false
        part.CFrame = robotBody.CFrame * offsetCFrame
        part.Massless = true
        part.Parent = robotFolder

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = robotBody
        weld.Part1 = part
        weld.Parent = robotBody
        return part
    end

    local chassis = Instance.new("Part")
    chassis.Name = "ChassisTop"
    chassis.Size = Vector3.new(2.2, 0.4, 2.2)
    chassis.Material = Enum.Material.Metal
    chassis.Color = robotConfig.Color:Lerp(Color3.fromRGB(210, 210, 210), 0.35)
    weldToBody(chassis, CFrame.new(0, 0.75, 0))

    local treadOffset = (robotBody.Size.X / 2) + 0.35
    local function createTread(name, xOffset)
        local tread = Instance.new("Part")
        tread.Name = name
        tread.Size = Vector3.new(0.6, 0.9, 2.8)
        tread.Material = Enum.Material.Metal
        tread.Color = Color3.fromRGB(65, 65, 65)
        tread.Shape = Enum.PartType.Block
        weldToBody(tread, CFrame.new(xOffset, -0.15, 0))
    end

    createTread("LeftTread", -treadOffset)
    createTread("RightTread", treadOffset)

    local head = Instance.new("Part")
    head.Name = "RobotHead"
    head.Size = Vector3.new(1.2, 0.8, 1.0)
    head.Material = Enum.Material.Metal
    head.Color = robotConfig.Color:Lerp(Color3.fromRGB(245, 245, 245), 0.45)
    weldToBody(head, CFrame.new(0, 1.3, -0.1))

    local visor = Instance.new("Part")
    visor.Name = "HeadVisor"
    visor.Size = Vector3.new(0.9, 0.35, 0.1)
    visor.Material = Enum.Material.Neon
    visor.Color = Color3.fromRGB(0, 255, 230)
    weldToBody(visor, CFrame.new(0, 1.35, -0.55))

    local drill = Instance.new("Part")
    drill.Name = "Drill"
    drill.Shape = Enum.PartType.Cylinder
    drill.Size = Vector3.new(0.5, 1.4, 0.5)
    drill.Material = Enum.Material.Metal
    drill.Color = Color3.fromRGB(205, 205, 205)
    drill.Orientation = Vector3.new(0, 0, 90)
    weldToBody(drill, CFrame.new(0, 0.2, -(robotBody.Size.Z / 2 + 0.8)))

    local drillLight = Instance.new("PointLight")
    drillLight.Name = "DrillLight"
    drillLight.Brightness = 4
    drillLight.Range = 10
    drillLight.Enabled = false
    drillLight.Color = Color3.fromRGB(255, 170, 64)
    drillLight.Parent = drill

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "DrillEmitter"
    emitter.Enabled = false
    emitter.Texture = "rbxasset://textures/particles/sparks_main.tga"
    emitter.Lifetime = NumberRange.new(0.2, 0.35)
    emitter.Rate = 35
    emitter.Speed = NumberRange.new(3, 6)
    emitter.SpreadAngle = Vector2.new(15, 35)
    emitter.Brightness = 2
    emitter.Parent = drill

    local audioConfig = GameConstants.AUDIO or {}
    if audioConfig.DRILL_LOOP and audioConfig.DRILL_LOOP ~= "" then
        local drillLoop = Instance.new("Sound")
        drillLoop.Name = "DrillLoop"
        drillLoop.SoundId = audioConfig.DRILL_LOOP
        drillLoop.Volume = 0.45
        drillLoop.Looped = true
        drillLoop.RollOffMode = Enum.RollOffMode.Linear
        drillLoop.RollOffMinDistance = 0
        drillLoop.RollOffMaxDistance = 70
        drillLoop.Parent = drill
    end

    local statusLight = Instance.new("SurfaceLight")
    statusLight.Name = "StatusLight"
    statusLight.Angle = 120
    statusLight.Brightness = 2
    statusLight.Enabled = false
    statusLight.Color = Color3.fromRGB(255, 170, 64)
    statusLight.Face = Enum.NormalId.Front
    statusLight.Parent = head

    local ownerValue = Instance.new("ObjectValue")
    ownerValue.Name = "Owner"
    ownerValue.Value = player
    ownerValue.Parent = robotFolder

    local robotState = Instance.new("StringValue")
    robotState.Name = "RobotState"
    robotState.Value = "garage_rollout"
    robotState.Parent = robotFolder

    local uniqueIdValue = Instance.new("StringValue")
    uniqueIdValue.Name = "UniqueId"
    uniqueIdValue.Value = robotData.UniqueId
    uniqueIdValue.Parent = robotFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = robotData.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = billboard

    local homePosition = getHoverPosition(Vector3.new(0, 0, 0), {robotFolder})
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart.Position
        homePosition = getHoverPosition(Vector3.new(root.X, 0, root.Z), {robotFolder})
    end

    robotFolder:SetAttribute("RobotType", robotData.Type)
    robotFolder:SetAttribute("TaskState", TASK_STATES.IDLE)
    robotFolder:SetAttribute("CargoAmount", 0)
    robotFolder:SetAttribute("CargoCurrency", "")
    robotFolder:SetAttribute("HomePosition", homePosition)
    robotFolder:SetAttribute("FollowOffset", nil)
    robotFolder:SetAttribute("LastUpdate", os.clock())
    robotFolder:SetAttribute("MiningTimer", 0)
    robotFolder:SetAttribute("CooldownTimer", 0)
    robotFolder:SetAttribute("SeekingTimer", 0)

    ensureChild(robotFolder, "ObjectValue", "TargetResource")
    setDrillActive(robotFolder, false)

    return robotFolder
end

function RobotManager.findNearestResource(position, maxDistance)

function RobotManager.findNearestResourceOfType(position, maxDistance, resourceType)
    local nearestResource = nil
    local nearestDistance = maxDistance

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Resource_") and obj:IsA("Part") then
            local typeValue = obj:FindFirstChild("ResourceType")
            if typeValue and typeValue.Value == resourceType then
                local distance = (obj.Position - position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestResource = obj
                end
            end
        end
    end

    return nearestResource
end

    local nearestResource = nil
    local nearestDistance = maxDistance

    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Resource_") and obj:IsA("Part") then
            local distance = (obj.Position - position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestResource = obj
            end
        end
    end

    return nearestResource
end

function RobotManager.assignRobotToResource(robotId, resourceNode, player)
    if not resourceNode or not resourceNode.Parent then
        return false
    end

    local robotFolder = findRobotFolder(robotId, player)
    if not robotFolder then
        return false
    end

    local targetResourceValue = ensureChild(robotFolder, "ObjectValue", "TargetResource")
    targetResourceValue.Value = resourceNode

    local resourceTypeValue = resourceNode:FindFirstChild("ResourceType")
    if resourceTypeValue then
        robotFolder:SetAttribute("PreferredResourceType", resourceTypeValue.Value)
    end

    setTaskState(robotFolder, TASK_STATES.TRAVEL)
    robotFolder:SetAttribute("CargoAmount", 0)
    robotFolder:SetAttribute("CargoCurrency", "")
    robotFolder:SetAttribute("MiningTimer", 0)
    robotFolder:SetAttribute("CooldownTimer", 0)
    robotFolder:SetAttribute("SeekingTimer", 0)
    setDrillActive(robotFolder, false)

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPos = player.Character.HumanoidRootPart.Position
        robotFolder:SetAttribute("HomePosition", getHoverPosition(Vector3.new(rootPos.X, 0, rootPos.Z), {robotFolder}))
    end

    local robotState = robotFolder:FindFirstChild("RobotState")
    if robotState then
        robotState.Value = "auto_mining"
    end

    print("✅ Robot", robotFolder.Name, "assigned to resource", resourceNode.Name)
    return true
end

function RobotManager.setRobotState(robotId, newState, player)
    local robotFolder = findRobotFolder(robotId, player)
    if not robotFolder then
        return false
    end

    local robotState = robotFolder:FindFirstChild("RobotState")
    if robotState then
        robotState.Value = newState
    end

    local targetResourceValue = ensureChild(robotFolder, "ObjectValue", "TargetResource")
    local robotBody = robotFolder:FindFirstChild("RobotBody")

    setDrillActive(robotFolder, false)

    if newState == "auto_mining" then
        setTaskState(robotFolder, TASK_STATES.SEEKING)
        robotFolder:SetAttribute("MiningTimer", 0)
        robotFolder:SetAttribute("CooldownTimer", 0)
        robotFolder:SetAttribute("SeekingTimer", 0)
        robotFolder:SetAttribute("FollowOffset", nil)

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos = player.Character.HumanoidRootPart.Position
            robotFolder:SetAttribute("HomePosition", getHoverPosition(Vector3.new(rootPos.X, 0, rootPos.Z), {robotFolder}))
        end

        if not targetResourceValue.Value then
            if robotBody then
                local nearest = RobotManager.findNearestResource(robotBody.Position, GameConstants.AUTO_MINE_SEARCH_RADIUS)
                targetResourceValue.Value = nearest
            end
        end
    else
        local ownerValue = robotFolder:FindFirstChild("Owner")
        local cargoAmount = robotFolder:GetAttribute("CargoAmount") or 0
        local cargoCurrency = robotFolder:GetAttribute("CargoCurrency")

        if ownerValue and ownerValue.Value and cargoAmount > 0 and cargoCurrency and cargoCurrency ~= "" then
            PlayerManager.updatePlayerCurrency(ownerValue.Value.UserId, cargoCurrency, cargoAmount)
            print("🪙", ownerValue.Value.Name, "collected", cargoAmount, cargoCurrency, "from", robotFolder.Name, "(manual deposit)")
        end

        setTaskState(robotFolder, TASK_STATES.IDLE)
        targetResourceValue.Value = nil
        robotFolder:SetAttribute("PreferredResourceType", nil)
        robotFolder:SetAttribute("CargoAmount", 0)
        robotFolder:SetAttribute("CargoCurrency", "")
        robotFolder:SetAttribute("MiningTimer", 0)
        robotFolder:SetAttribute("SeekingTimer", 0)
        robotFolder:SetAttribute("CooldownTimer", 0)
        robotFolder:SetAttribute("FollowOffset", nil)
        if robotBody then
            robotBody.AssemblyLinearVelocity = Vector3.zero
        end
    end

    print("✅ Robot", robotFolder.Name, "state changed to", newState)
    return true
end

function RobotManager.updateRobotMovement()
    local currentTime = os.clock()

    for _, robotFolder in pairs(workspace:GetChildren()) do
        if not robotFolder:IsA("Folder") then
            continue
        end

        local robotBody = robotFolder:FindFirstChild("RobotBody")
        local robotState = robotFolder:FindFirstChild("RobotState")
        local ownerValue = robotFolder:FindFirstChild("Owner")

        if not (robotBody and robotState and ownerValue and ownerValue.Value) then
            continue
        end

        local player = ownerValue.Value
        local lastUpdate = robotFolder:GetAttribute("LastUpdate") or currentTime
        local deltaTime = currentTime - lastUpdate
        if deltaTime < 0 then
            deltaTime = 0
        end

        local config = getRobotConfig(robotFolder)
        if not config then
            continue
        end

        if not robotFolder:GetAttribute("TaskState") then
            setTaskState(robotFolder, TASK_STATES.IDLE)
        end

        local taskState = robotFolder:GetAttribute("TaskState") or TASK_STATES.IDLE
        local targetResourceValue = ensureChild(robotFolder, "ObjectValue", "TargetResource")
        local targetResource = targetResourceValue and targetResourceValue.Value

        if taskState ~= TASK_STATES.MINING then
            setDrillActive(robotFolder, false)
        end

        if robotState.Value == "garage_rollout" then
            robotFolder:SetAttribute("LastUpdate", currentTime)
            continue
        elseif robotState.Value == "garage_greeting" then
            local targetPosition
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local look = rootPart.CFrame.LookVector
                local right = rootPart.CFrame.RightVector
                local greetingOffset = (-look * 3) + (right * 1.5)
                targetPosition = rootPart.Position + Vector3.new(greetingOffset.X, 0, greetingOffset.Z)
            else
                targetPosition = robotFolder:GetAttribute("HomePosition") or robotBody.Position
            end

            targetPosition = getHoverPosition(Vector3.new(targetPosition.X, 0, targetPosition.Z), {robotFolder})
            local remaining = moveRobot(robotBody, targetPosition, config, 0.45, deltaTime)
            robotFolder:SetAttribute("HomePosition", targetPosition)

            if remaining <= 1.5 then
                robotBody.AssemblyLinearVelocity = Vector3.zero
                robotBody.AssemblyAngularVelocity = Vector3.zero
                robotFolder:SetAttribute("FollowOffset", nil)
                robotState.Value = "following"
            end

            robotFolder:SetAttribute("LastUpdate", currentTime)
            continue
        elseif robotState.Value == "following" then
            setTaskState(robotFolder, TASK_STATES.IDLE)

            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerRoot = player.Character.HumanoidRootPart.Position
                local playerPlanar = Vector3.new(playerRoot.X, 0, playerRoot.Z)

                local followOffset = robotFolder:GetAttribute("FollowOffset")
                if not followOffset then
                    local angle = math.random() * math.pi * 2
                    local radiusMin = GameConstants.FOLLOW_MIN_RADIUS
                    local radiusMax = GameConstants.FOLLOW_DISTANCE
                    local radius = radiusMin + math.random() * (radiusMax - radiusMin)
                    followOffset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                    robotFolder:SetAttribute("FollowOffset", followOffset)
                end

                local followPlanar = playerPlanar + followOffset
                local followTarget = getHoverPosition(followPlanar, {robotFolder})
                local remaining = moveRobot(robotBody, followTarget, config, 1, deltaTime)
                robotFolder:SetAttribute("HomePosition", followTarget)

                if remaining <= GameConstants.FOLLOW_REACHED_RADIUS then
                    local currentPos = robotBody.Position
                    local newOffset = Vector3.new(currentPos.X - playerPlanar.X, 0, currentPos.Z - playerPlanar.Z)
                    robotFolder:SetAttribute("FollowOffset", newOffset)
                end
            end
        elseif robotState.Value == "auto_mining" then
            if taskState == TASK_STATES.IDLE then
                setTaskState(robotFolder, TASK_STATES.SEEKING)
                taskState = TASK_STATES.SEEKING
            end

            if taskState == TASK_STATES.SEEKING then
                if targetResource and targetResource.Parent then
                    robotFolder:SetAttribute("SeekingTimer", 0)
                    setTaskState(robotFolder, TASK_STATES.TRAVEL)
                    taskState = TASK_STATES.TRAVEL
                else
                    local seekingTimer = (robotFolder:GetAttribute("SeekingTimer") or 0) + deltaTime
                    robotFolder:SetAttribute("SeekingTimer", seekingTimer)

                    local nearest = RobotManager.findNearestResource(robotBody.Position, GameConstants.AUTO_MINE_SEARCH_RADIUS)
                    if nearest then
                        targetResourceValue.Value = nearest
                        robotFolder:SetAttribute("SeekingTimer", 0)
                        setTaskState(robotFolder, TASK_STATES.TRAVEL)
                        taskState = TASK_STATES.TRAVEL
                    else
                        local home = robotFolder:GetAttribute("HomePosition")
                        if not home then
                            home = getHoverPosition(Vector3.new(robotBody.Position.X, 0, robotBody.Position.Z), {robotFolder})
                        end
                        moveRobot(robotBody, home, config, 1, deltaTime)

                            if seekingTimer >= GameConstants.ROBOT_IDLE_FOLLOW_DELAY then
                                targetResourceValue.Value = nil
                                robotFolder:SetAttribute("SeekingTimer", 0)
                                robotFolder:SetAttribute("CooldownTimer", 0)
                                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                    local rootPos = player.Character.HumanoidRootPart.Position
                                    robotFolder:SetAttribute("HomePosition", getHoverPosition(Vector3.new(rootPos.X, 0, rootPos.Z), {robotFolder}))
                                end
                                setTaskState(robotFolder, TASK_STATES.COOLDOWN)
                            end
                        end
                    end
                end

            if taskState == TASK_STATES.TRAVEL then
                if not targetResource or not targetResource.Parent then
                    targetResourceValue.Value = nil
                    robotFolder:SetAttribute("SeekingTimer", 0)
                    setTaskState(robotFolder, TASK_STATES.SEEKING)
                    taskState = TASK_STATES.SEEKING
                else
                    local resourcePos = targetResource.Position
                    local moveToPos = getHoverPosition(Vector3.new(resourcePos.X, 0, resourcePos.Z), {robotFolder})
                    local remainingDistance = moveRobot(robotBody, moveToPos, config, 1, deltaTime)

                    debugPrint(robotFolder, "Traveling, distance", math.floor(remainingDistance * 100) / 100)

                    if remainingDistance <= GameConstants.MINING_DISTANCE then
                        robotBody.AssemblyLinearVelocity = Vector3.zero
                        setTaskState(robotFolder, TASK_STATES.MINING)
                        robotFolder:SetAttribute("MiningTimer", 0)
                        taskState = TASK_STATES.MINING
                        setDrillActive(robotFolder, true)
                    end
                end
            end

            if taskState == TASK_STATES.MINING then
                if not targetResource or not targetResource.Parent then
                    targetResourceValue.Value = nil
                    setDrillActive(robotFolder, false)
                    setTaskState(robotFolder, TASK_STATES.SEEKING)
                    taskState = TASK_STATES.SEEKING
                else
                    local resourcePos = targetResource.Position
                    local holdPosition = getHoverPosition(Vector3.new(resourcePos.X, 0, resourcePos.Z), {robotFolder})
                    moveRobot(robotBody, holdPosition, config, 0.4, deltaTime)
                    robotBody.AssemblyLinearVelocity = Vector3.zero
                    local elapsed = currentTime - (robotFolder:GetAttribute("LastUpdate") or currentTime)
                    local miningTimer = (robotFolder:GetAttribute("MiningTimer") or 0) + elapsed

                    if miningTimer >= GameConstants.ROBOT_MINING_INTERVAL then
                        miningTimer = miningTimer - GameConstants.ROBOT_MINING_INTERVAL
                        debugPrint(robotFolder, "Mining tick", math.floor(miningTimer * 100) / 100)

                        local healthValue = targetResource:FindFirstChild("ResourceHealth")
                        local resourceTypeValue = targetResource:FindFirstChild("ResourceType")

                        if healthValue and resourceTypeValue then
                            local damage = math.max(1, config.Efficiency or 1)
                            healthValue.Value = healthValue.Value - damage

                            local originalSizeValue = targetResource:FindFirstChild("OriginalSize")
                            if originalSizeValue then
                                local maxHealth = math.max(1, originalSizeValue.Value * 3)
                                local remainingHealth = math.clamp(healthValue.Value, 0, maxHealth)
                                local ratio = math.clamp(remainingHealth / maxHealth, 0, 1)
                                local baseSize = originalSizeValue.Value
                                local minScale = 0.25
                                local scaledSize = math.max(baseSize * ratio, baseSize * minScale)
                                targetResource.Size = Vector3.new(scaledSize, scaledSize, scaledSize)
                            end

                            if healthValue.Value <= 0 then
                                local resourceInfo = GameConstants.MINING_AMOUNTS[resourceTypeValue.Value]
                                local currencyType = GameConstants.RESOURCE_TO_CURRENCY[resourceTypeValue.Value]

                                if resourceInfo and currencyType then
                                    local reward = math.random(resourceInfo.min, resourceInfo.max)
                                    reward = math.max(1, math.floor(reward * (config.Efficiency or 1)))

                                    robotFolder:SetAttribute("CargoAmount", reward)
                                    robotFolder:SetAttribute("CargoCurrency", currencyType)
                                    setTaskState(robotFolder, TASK_STATES.RETURNING)
                                    taskState = TASK_STATES.RETURNING
                                    targetResourceValue.Value = nil

                                    targetResource:Destroy()
                                else
                                    setTaskState(robotFolder, TASK_STATES.SEEKING)
                                    targetResourceValue.Value = nil
                                end
                            else
                                robotFolder:SetAttribute("MiningTimer", miningTimer)
                            end
                        else
                            setDrillActive(robotFolder, false)
                            setTaskState(robotFolder, TASK_STATES.SEEKING)
                            targetResourceValue.Value = nil
                        end
                    else
                        robotFolder:SetAttribute("MiningTimer", miningTimer)
                    end
                end
            end

            if taskState == TASK_STATES.RETURNING then
                local home = robotFolder:GetAttribute("HomePosition")
                if not home then
                    home = getHoverPosition(Vector3.new(robotBody.Position.X, 0, robotBody.Position.Z), {robotFolder})
                end
                local moveHome = getHoverPosition(Vector3.new(home.X, 0, home.Z), {robotFolder})
                local remaining = moveRobot(robotBody, moveHome, config, 0.9, deltaTime)

                debugPrint(robotFolder, "Returning, distance", math.floor(remaining * 100) / 100)

                if remaining <= GameConstants.ROBOT_RETURN_DISTANCE then
                    robotBody.AssemblyLinearVelocity = Vector3.zero
                    local cargoAmount = robotFolder:GetAttribute("CargoAmount") or 0
                    local cargoCurrency = robotFolder:GetAttribute("CargoCurrency")

                    if cargoAmount > 0 and cargoCurrency and cargoCurrency ~= "" then
                        PlayerManager.updatePlayerCurrency(player.UserId, cargoCurrency, cargoAmount)
                        print("🪙", player.Name, "collected", cargoAmount, cargoCurrency, "from", robotFolder.Name)
                    end

                    robotFolder:SetAttribute("CargoAmount", 0)
                    robotFolder:SetAttribute("CargoCurrency", "")
                    robotFolder:SetAttribute("MiningTimer", 0)

                    if robotState.Value == "auto_mining" then
                        robotFolder:SetAttribute("CooldownTimer", 0)
                        robotFolder:SetAttribute("SeekingTimer", 0)
                        setTaskState(robotFolder, TASK_STATES.COOLDOWN)
                    else
                        setTaskState(robotFolder, TASK_STATES.IDLE)
                    end
                end
            elseif taskState == TASK_STATES.COOLDOWN then
                local cooldown = (robotFolder:GetAttribute("CooldownTimer") or 0) + deltaTime
                robotFolder:SetAttribute("CooldownTimer", cooldown)

                local home = robotFolder:GetAttribute("HomePosition") or robotBody.Position
                local adjustedHome = getHoverPosition(Vector3.new(home.X, 0, home.Z), {robotFolder})
                moveRobot(robotBody, adjustedHome, config, 0.6, deltaTime)
                robotBody.AssemblyLinearVelocity = Vector3.zero

                if cooldown >= GameConstants.ROBOT_RESEEK_DELAY then
                    robotFolder:SetAttribute("CooldownTimer", 0)
                    setTaskState(robotFolder, TASK_STATES.SEEKING)
                    taskState = TASK_STATES.SEEKING
                end
            end
        end

        robotFolder:SetAttribute("LastUpdate", currentTime)
    end
end

function RobotManager.startMovementUpdates()
    task.spawn(function()
        while true do
            task.wait(GameConstants.MOVEMENT_UPDATE_INTERVAL)
            RobotManager.updateRobotMovement()
        end
    end)
end

function RobotManager.despawnRobotsForPlayer(player)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Folder") then
            local owner = obj:FindFirstChild("Owner")
            if owner and owner.Value == player then
                local cargoAmount = obj:GetAttribute("CargoAmount") or 0
                local cargoCurrency = obj:GetAttribute("CargoCurrency")
                if cargoAmount > 0 and cargoCurrency and cargoCurrency ~= "" then
                    PlayerManager.updatePlayerCurrency(player.UserId, cargoCurrency, cargoAmount)
                    print("🪙", player.Name, "collected", cargoAmount, cargoCurrency, "from", obj.Name, "before despawn")
                end
                obj:Destroy()
            end
        end
    end
end

return RobotManager
