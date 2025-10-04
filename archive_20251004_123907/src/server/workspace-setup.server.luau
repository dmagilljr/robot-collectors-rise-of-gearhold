-- Robot Collectors: Workspace Setup
-- Creates mining areas and spawn platforms

local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("GameConstants"))

local LODService
if GameConstants.ENABLE_LOD then
    local ok, service = pcall(function()
        return require(script.Parent:WaitForChild("util"):WaitForChild("LODService"))
    end)
    if ok then
        LODService = service
    else
        warn("[LOD] failed to load LODService:", service)
    end
end

local function ensureModel(parent: Instance, name: string): Model
    local existing = parent:FindFirstChild(name)
    if not existing or not existing:IsA("Model") then
        if existing then
            existing:Destroy()
        end
        local created = Instance.new("Model")
        created.Name = name
        created.Parent = parent
        return created
    end
    return existing
end

local function destroyDuplicates(root: Instance, startsWith: string)
    local keep: Instance? = nil
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Model") and child.Name:match("^" .. startsWith) then
            if not keep then
                keep = child
            else
                child:Destroy()
            end
        end
    end
    return keep
end

local function ensureBasePart(parent: Instance, className: string, name: string, props)
    local existing = parent:FindFirstChild(name)
    if not existing or not existing:IsA(className) then
        if existing then
            existing:Destroy()
        end
        existing = Instance.new(className)
        existing.Name = name
    end

    local part = existing :: BasePart
    if props.Size then
        part.Size = props.Size
    end
    if props.CFrame then
        part.CFrame = props.CFrame
    end
    if props.Anchored ~= nil then
        part.Anchored = props.Anchored
    else
        part.Anchored = true
    end
    if props.CanCollide ~= nil then
        part.CanCollide = props.CanCollide
    end
    if props.CanQuery ~= nil then
        part.CanQuery = props.CanQuery
    end
    if props.Material then
        part.Material = props.Material
    end
    if props.Color then
        part.Color = props.Color
    end
    if props.Transparency ~= nil then
        part.Transparency = props.Transparency
    end
    if props.Shape and part:IsA("Part") then
        part.Shape = props.Shape
    end
    if props.CastShadow ~= nil then
        part.CastShadow = props.CastShadow
    end
    if props.Reflectance ~= nil then
        part.Reflectance = props.Reflectance
    end
    part.Parent = parent
    part:SetAttribute("GeneratedBySetup", true)
    return part
end

-- Clear previously generated assets only
local function shouldRemove(obj)
    if obj:GetAttribute("GeneratedBySetup") then
        return true
    end

    if obj:IsA("BasePart") then
        if obj.Name == "GroundPlatform"
            or obj.Name == "DeploymentPad"
            or obj.Name == "DeploymentRing"
            or obj.Name == "SpawnPlatform"
            or obj.Name == "GarageFloor"
            or obj.Name == "GarageShell"
            or obj.Name == "GarageDoor"
            or obj.Name == "GarageDoorHeader"
            or obj.Name == "GarageDoorTrackLeft"
            or obj.Name == "GarageDoorTrackRight"
            or obj.Name == "GarageConsoleDeck"
            or obj.Name == "GarageConsoleSurface"
            or obj.Name == "GarageConsoleHolo"
            or obj.Name == "ConsoleSupport"
            or obj.Name == "ConsoleStool"
            or obj.Name == "ConsoleStoolCushion"
            or obj.Name == "GarageConsoleMonitor"
            or obj.Name == "GarageConsoleMonitorScreen"
            or obj.Name == "GarageConsoleKeyboard"
            or obj.Name == "GarageConsoleKeyboardKeys"
            or obj.Name == "GarageFrontPath"
            or obj.Name == "FutureZoneConnector"
            or obj.Name == "FutureZonePad"
            or obj.Name == "FutureZonePadTrim"
            or obj.Name == "FutureZoneSignStand"
            or obj.Name == "FutureZoneSign"
            or obj.Name == "FutureZoneBeacon"
            or obj.Name == "GarageHatchPlatform"
            or obj.Name == "GarageHatchTrim"
            or obj.Name == "GarageHatchRamp" then
            return true
        end

        if string.match(obj.Name, "^Resource_%d+$") or string.match(obj.Name, "^Wall_%d+$") then
            return true
        end
    end

    return false
end

for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name ~= "SpawnLocation" and obj.Name ~= "Terrain" and shouldRemove(obj) then
        obj:Destroy()
    end
end

-- Create LARGE main ground platform (flush plaza)
local groundPlatform = Instance.new("Part")
groundPlatform.Name = "GroundPlatform"
groundPlatform.Size = Vector3.new(140, 2, 140)
groundPlatform.Position = Vector3.new(0, -1, 0)
groundPlatform.Anchored = true
groundPlatform.Material = Enum.Material.Concrete
groundPlatform.Color = Color3.fromRGB(70, 75, 90)
groundPlatform:SetAttribute("GeneratedBySetup", true)
groundPlatform.Parent = workspace

local deploymentPad = Instance.new("Part")
deploymentPad.Name = "DeploymentPad"
deploymentPad.Size = Vector3.new(18, 0.2, 18)
deploymentPad.Position = Vector3.new(0, 0.1, 0)
deploymentPad.Anchored = true
deploymentPad.Material = Enum.Material.Metal
deploymentPad.Color = Color3.fromRGB(110, 120, 140)
deploymentPad.Transparency = 0.05
deploymentPad:SetAttribute("GeneratedBySetup", true)
deploymentPad.Parent = workspace

local deploymentRing = Instance.new("Part")
deploymentRing.Name = "DeploymentRing"
deploymentRing.Size = Vector3.new(24, 0.2, 24)
deploymentRing.Position = Vector3.new(0, 0.11, 0)
deploymentRing.Anchored = true
deploymentRing.Material = Enum.Material.Neon
deploymentRing.Color = Color3.fromRGB(90, 140, 210)
deploymentRing.Transparency = 0.6
deploymentRing:SetAttribute("GeneratedBySetup", true)
deploymentRing.Parent = workspace

local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if spawnLocation then
    spawnLocation.CFrame = CFrame.new(0, 0.5, -6)
    spawnLocation.Anchored = true
    spawnLocation.CanCollide = false
end

-- Garage shell for hatching interactions
local garageFloor = Instance.new("Part")
garageFloor.Name = "GarageFloor"
garageFloor.Size = Vector3.new(24, 0.2, 18)
garageFloor.Position = Vector3.new(28, 0.1, -4)
garageFloor.Anchored = true
garageFloor.Material = Enum.Material.Metal
garageFloor.Color = Color3.fromRGB(80, 85, 95)
garageFloor:SetAttribute("GeneratedBySetup", true)
garageFloor.Parent = workspace

local garageShell = Instance.new("Part")
garageShell.Name = "GarageShell"
garageShell.Size = Vector3.new(24, 12, 18)
garageShell.Position = Vector3.new(28, 6, -4)
garageShell.Anchored = true
garageShell.Material = Enum.Material.Metal
garageShell.Color = Color3.fromRGB(60, 65, 75)
garageShell.Transparency = 0.25
garageShell.CanCollide = false
garageShell.CanQuery = false
garageShell:SetAttribute("GeneratedBySetup", true)
garageShell.Parent = workspace

local walkway = Instance.new("Part")
walkway.Name = "GarageWalkway"
walkway.Size = Vector3.new(22, 0.2, 12)
local walkwayHeight = garageFloor.Position.Y + (garageFloor.Size.Y * 0.5) + (walkway.Size.Y * 0.5) + 0.02
walkway.Position = Vector3.new(28, walkwayHeight, -1)
walkway.Anchored = true
walkway.Material = Enum.Material.DiamondPlate
walkway.Color = Color3.fromRGB(105, 110, 125)
walkway.CanCollide = true
walkway.CanQuery = false
walkway:SetAttribute("GeneratedBySetup", true)
walkway.Parent = workspace

local frontPath = Instance.new("Part")
frontPath.Name = "GarageFrontPath"
frontPath.Size = Vector3.new(12, 0.2, 20)
frontPath.Anchored = true
frontPath.Material = Enum.Material.Metal
frontPath.Color = Color3.fromRGB(82, 88, 104)
frontPath.CanCollide = true
frontPath.CanQuery = false
frontPath:SetAttribute("GeneratedBySetup", true)
frontPath.CFrame = CFrame.new(23, walkwayHeight, 3)
frontPath.Parent = workspace

local zoneConnector = Instance.new("Part")
zoneConnector.Name = "FutureZoneConnector"
zoneConnector.Size = Vector3.new(16, 0.25, 8)
zoneConnector.Anchored = true
zoneConnector.Material = Enum.Material.Metal
zoneConnector.Color = Color3.fromRGB(70, 78, 96)
zoneConnector.CanCollide = true
zoneConnector.CanQuery = false
zoneConnector:SetAttribute("GeneratedBySetup", true)
zoneConnector.CFrame = CFrame.new(35, walkwayHeight, 6)
zoneConnector.Parent = workspace

local zonePad = Instance.new("Part")
zonePad.Name = "FutureZonePad"
zonePad.Size = Vector3.new(28, 0.3, 24)
zonePad.Anchored = true
zonePad.Material = Enum.Material.Concrete
zonePad.Color = Color3.fromRGB(60, 68, 82)
zonePad.CanCollide = true
zonePad.CanQuery = false
zonePad:SetAttribute("GeneratedBySetup", true)
zonePad.CFrame = CFrame.new(54, walkwayHeight + 0.05, 10)
zonePad.Parent = workspace

local zoneTrim = Instance.new("Part")
zoneTrim.Name = "FutureZonePadTrim"
zoneTrim.Size = Vector3.new(28.2, 0.1, 24.2)
zoneTrim.Anchored = true
zoneTrim.Material = Enum.Material.Neon
zoneTrim.Color = Color3.fromRGB(95, 205, 255)
zoneTrim.Transparency = 0.5
zoneTrim.CanCollide = false
zoneTrim.CanQuery = false
zoneTrim:SetAttribute("GeneratedBySetup", true)
zoneTrim.CFrame = zonePad.CFrame * CFrame.new(0, 0.2, 0)
zoneTrim.Parent = workspace

local zoneSignStand = Instance.new("Part")
zoneSignStand.Name = "FutureZoneSignStand"
zoneSignStand.Size = Vector3.new(0.6, 4.2, 0.6)
zoneSignStand.Anchored = true
zoneSignStand.Material = Enum.Material.Metal
zoneSignStand.Color = Color3.fromRGB(48, 54, 70)
zoneSignStand.CanCollide = false
zoneSignStand.CanQuery = false
zoneSignStand:SetAttribute("GeneratedBySetup", true)
zoneSignStand.CFrame = zoneConnector.CFrame * CFrame.new(0, 2.2, 4.2)
zoneSignStand.Parent = workspace

local zoneSign = Instance.new("Part")
zoneSign.Name = "FutureZoneSign"
zoneSign.Size = Vector3.new(6, 2.6, 0.4)
zoneSign.Anchored = true
zoneSign.Material = Enum.Material.SmoothPlastic
zoneSign.Color = Color3.fromRGB(28, 32, 45)
zoneSign.CanCollide = false
zoneSign.CanQuery = false
zoneSign:SetAttribute("GeneratedBySetup", true)
local signBaseCFrame = zoneSignStand.CFrame * CFrame.new(0, 1.6, 0.25)
local signTargetPosition = Vector3.new(GameConstants.CENTER_POS.X, signBaseCFrame.Position.Y, GameConstants.CENTER_POS.Z)
zoneSign.CFrame = CFrame.lookAt(signBaseCFrame.Position, signTargetPosition)
zoneSign.Parent = workspace

local zoneGui = Instance.new("SurfaceGui")
zoneGui.Name = "FutureZoneSignGui"
zoneGui.AlwaysOnTop = true
zoneGui.Face = Enum.NormalId.Front
zoneGui.CanvasSize = Vector2.new(512, 256)
zoneGui.Parent = zoneSign

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, 0, 1, 0)
zoneLabel.BackgroundTransparency = 1
zoneLabel.TextColor3 = Color3.fromRGB(210, 235, 255)
zoneLabel.Font = Enum.Font.GothamBold
zoneLabel.TextScaled = true
zoneLabel.Text = "Expansion Site"
zoneLabel.Parent = zoneGui

local beacon = Instance.new("Part")
beacon.Name = "FutureZoneBeacon"
beacon.Size = Vector3.new(0.4, 6, 0.4)
beacon.Anchored = true
beacon.Material = Enum.Material.Neon
beacon.Color = Color3.fromRGB(95, 205, 255)
beacon.Transparency = 0.3
beacon.CanCollide = false
beacon.CanQuery = false
beacon:SetAttribute("GeneratedBySetup", true)
beacon.CFrame = zonePad.CFrame * CFrame.new(0, 3.2, 0)
beacon.Parent = workspace

local beaconLight = Instance.new("PointLight")
beaconLight.Name = "FutureZoneBeaconLight"
beaconLight.Range = 18
beaconLight.Brightness = 2
beaconLight.Color = Color3.fromRGB(95, 205, 255)
beaconLight.Parent = beacon
local interiorFolder = Instance.new("Folder")
interiorFolder.Name = "GarageInterior"
interiorFolder:SetAttribute("GeneratedBySetup", true)
interiorFolder.Parent = workspace

local function createInteriorPart(name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Material = material
    part.Color = color
    part.Transparency = 0.05
    part:SetAttribute("GeneratedBySetup", true)
    part.Parent = interiorFolder
    return part
end

local function snapToGrid(value, grid)
    return math.floor(value / grid + 0.5) * grid
end

local function ensureRunwayStrips(startPos: Vector3, endPos: Vector3, baseName: string)
    local collectionName = baseName .. "Runway"
    local existingContainer = workspace:FindFirstChild(collectionName)
    if existingContainer then
        existingContainer:Destroy()
    end

    local model = Instance.new("Model")
    model.Name = collectionName
    model:SetAttribute("GeneratedBySetup", true)
    model.Parent = workspace

    local direction = (endPos - startPos)
    local totalDistance = direction.Magnitude
    if totalDistance < 2 then
        return
    end

    direction = direction.Unit
    local stripCount = math.clamp(math.floor(totalDistance / 12), 3, 5)
    for index = 1, stripCount do
        local t = index / (stripCount + 1)
        local worldPos = startPos + direction * totalDistance * t
        local snappedPos = Vector3.new(
            snapToGrid(worldPos.X, 2),
            snapToGrid(worldPos.Y, 2),
            snapToGrid(worldPos.Z, 2)
        )

        local strip = Instance.new("Part")
        strip.Name = baseName .. "Strip" .. index
        strip.Size = Vector3.new(4, 0.1, 0.4)
        strip.CFrame = CFrame.new(snappedPos, snappedPos + direction)
        strip.Material = Enum.Material.Neon
        strip.Color = Color3.fromRGB(0, 255, 255)
        strip.Anchored = true
        strip.CanCollide = false
        strip.CanQuery = false
        strip:SetAttribute("GeneratedBySetup", true)
        strip.Parent = model
    end

    if LODService then
        local primary = model:FindFirstChildWhichIsA("BasePart")
        if primary then
            model.PrimaryPart = primary
        end
        LODService.attach(model)
    end
end

local function getSpawnPosition(): Vector3
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if spawn and spawn:IsA("SpawnLocation") then
        return spawn.Position
    end
    return Vector3.new(0, 0, 0)
end

local function getGarageConsolePosition(): Vector3
    local deck = workspace:FindFirstChild("GarageConsoleDeck")
    if deck and deck:IsA("BasePart") then
        return deck.Position
    end
    return Vector3.new(28, 0, -4)
end

local function getExpansionPosition(): Vector3
    local sign = workspace:FindFirstChild("FutureZoneSign")
    if sign and sign:IsA("BasePart") then
        return sign.Position
    end
    return Vector3.new(35, 0, 6)
end

local function ensureGuidanceStrips()
    ensureRunwayStrips(getSpawnPosition(), getGarageConsolePosition(), "SpawnToGarage")
    ensureRunwayStrips(getSpawnPosition(), getExpansionPosition(), "SpawnToExpansion")
end

ensureGuidanceStrips()

ensureRunwayStrips(getSpawnPosition(), getGarageConsolePosition(), "SpawnToGarage")
ensureRunwayStrips(getSpawnPosition(), getExpansionPosition(), "SpawnToExpansion")

local interiorColor = Color3.fromRGB(110, 120, 140)
local accentColor = Color3.fromRGB(80, 180, 220)

local function keepOneConsole(root: Instance)
    local found = {}
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Model") and string.find(child.Name, "GarageConsole") then
            table.insert(found, child)
        end
    end
    table.sort(found, function(a, b)
        return a.Name < b.Name
    end)
    for index = 2, #found do
        found[index]:Destroy()
    end
    return found[1]
end

local backWall = createInteriorPart(
    "GarageBackWall",
    Vector3.new(22, 10, 1.2),
    Vector3.new(28, 5, -13.5),
    interiorColor,
    Enum.Material.SmoothPlastic
)

local leftWall = createInteriorPart(
    "GarageSideWallLeft",
    Vector3.new(1, 10, 18),
    Vector3.new(17.5, 5, -4),
    interiorColor,
    Enum.Material.SmoothPlastic
)

local rightWall = createInteriorPart(
    "GarageSideWallRight",
    Vector3.new(1, 10, 18),
    Vector3.new(38.5, 5, -4),
    interiorColor,
    Enum.Material.SmoothPlastic
)

local ceiling = createInteriorPart(
    "GarageCeiling",
    Vector3.new(22, 1, 18),
    Vector3.new(28, 11.2, -4),
    Color3.fromRGB(70, 75, 95),
    Enum.Material.Metal
)
ceiling.Transparency = 0.15

local lightBar = Instance.new("Part")
lightBar.Name = "GarageLightBar"
lightBar.Size = Vector3.new(16, 0.4, 0.6)
lightBar.Position = Vector3.new(28, 10.2, -6)
lightBar.Anchored = true
lightBar.CanCollide = false
lightBar.CanQuery = false
lightBar.Material = Enum.Material.Neon
lightBar.Color = accentColor
lightBar.Transparency = 0.35
lightBar:SetAttribute("GeneratedBySetup", true)
lightBar.Parent = interiorFolder

local lightStrip = Instance.new("SurfaceLight")
lightStrip.Name = "GarageAmbientStrip"
lightStrip.Angle = 135
lightStrip.Brightness = 1
lightStrip.Range = 18
lightStrip.Color = Color3.fromRGB(190, 235, 255)
lightStrip.Parent = lightBar

local attachmentLeft = Instance.new("Attachment")
attachmentLeft.Name = "GarageSpotAttachmentLeft"
attachmentLeft.Position = Vector3.new(-6, -0.1, 0)
attachmentLeft.Orientation = Vector3.new(90, 0, 0)
attachmentLeft.Parent = lightBar

local attachmentRight = Instance.new("Attachment")
attachmentRight.Name = "GarageSpotAttachmentRight"
attachmentRight.Position = Vector3.new(6, -0.1, 0)
attachmentRight.Orientation = Vector3.new(90, 0, 0)
attachmentRight.Parent = lightBar

local spotlightLeft = Instance.new("SpotLight")
spotlightLeft.Name = "GarageSpotLeft"
spotlightLeft.Angle = 90
spotlightLeft.Brightness = 1.5
spotlightLeft.Range = 16
spotlightLeft.Color = Color3.fromRGB(255, 230, 180)
spotlightLeft.Parent = attachmentLeft

local spotlightRight = spotlightLeft:Clone()
spotlightRight.Name = "GarageSpotRight"
spotlightRight.Parent = attachmentRight

local trim = createInteriorPart(
    "GarageTrim",
    Vector3.new(22, 0.2, 18),
    Vector3.new(28, 0.35, -4),
    Color3.fromRGB(60, 65, 75),
    Enum.Material.Metal
)
trim.Transparency = 0.2

local function createBackWallPanels()
    local panelCount = 5
    local spacing = 4.4
    for index = 1, panelCount do
        local offset = (index - (panelCount + 1) / 2) * spacing
        local basePanel = createInteriorPart(
            "GarageWallPanel_" .. index,
            Vector3.new(3.6, 7.6, 0.35),
            backWall.Position + Vector3.new(offset, 0.1, 0.45),
            Color3.fromRGB(80, 88, 110),
            Enum.Material.Metal
        )
        basePanel.Transparency = 0.18

        local inset = createInteriorPart(
            "GarageWallInset_" .. index,
            Vector3.new(3, 6.4, 0.15),
            basePanel.Position + Vector3.new(0, 0.05, 0.2),
            Color3.fromRGB(45, 50, 70),
            Enum.Material.SmoothPlastic
        )
        inset.Transparency = 0.25

        local accentColumn = Instance.new("Part")
        accentColumn.Name = "GarageWallAccent_" .. index
        accentColumn.Size = Vector3.new(0.2, 6.6, 0.2)
        accentColumn.Position = basePanel.Position + Vector3.new(-1.55, 0.05, 0.28)
        accentColumn.Anchored = true
        accentColumn.CanCollide = false
        accentColumn.CanQuery = false
        accentColumn.Material = Enum.Material.Neon
        accentColumn.Color = accentColor
        accentColumn.Transparency = 0.2
        accentColumn:SetAttribute("GeneratedBySetup", true)
        accentColumn.Parent = interiorFolder

        local accentMirror = accentColumn:Clone()
        accentMirror.Position = basePanel.Position + Vector3.new(1.55, 0.05, 0.28)
        accentMirror.Parent = interiorFolder
    end
end

createBackWallPanels()

local function createSupportColumn(offsetX: number)
    local base = createInteriorPart(
        "GarageColumn_" .. offsetX,
        Vector3.new(0.75, 8.5, 0.75),
        Vector3.new(28 + offsetX, 4.25, -9),
        Color3.fromRGB(75, 85, 105),
        Enum.Material.Metal
    )
    local basePlate = createInteriorPart(
        "GarageColumnBase_" .. offsetX,
        Vector3.new(1.6, 0.35, 1.6),
        base.Position - Vector3.new(0, base.Size.Y * 0.5, 0),
        Color3.fromRGB(55, 60, 70),
        Enum.Material.Metal
    )
    local hinge = createInteriorPart(
        "GarageColumnHinge_" .. offsetX,
        Vector3.new(0.6, 0.6, 2.8),
        base.Position + Vector3.new(0, base.Size.Y * 0.5 - 0.2, 0),
        accentColor,
        Enum.Material.Neon
    )
    hinge.Transparency = 0.4
    return base
end

createSupportColumn(-6)
createSupportColumn(6)

local function addSideWallAccents()
    local function addForSide(isLeft: boolean)
        local wall = isLeft and leftWall or rightWall
        local direction = isLeft and 1 or -1
        local baseX = wall.Position.X + (direction * 0.45)
        for index, offsetZ in ipairs({-6.5, -2, 2.5}) do
            local panel = createInteriorPart(
                (isLeft and "GarageSideInsetLeft_" or "GarageSideInsetRight_") .. index,
                Vector3.new(0.3, 7.5, 3.4),
                Vector3.new(baseX, 4.8, offsetZ - 4),
                Color3.fromRGB(70, 78, 98),
                Enum.Material.Metal
            )
            panel.Transparency = 0.18

            local accent = Instance.new("Part")
            accent.Name = (isLeft and "GarageSideBeamLeft_" or "GarageSideBeamRight_") .. index
            accent.Size = Vector3.new(0.2, 7.6, 0.25)
            accent.Position = panel.Position + Vector3.new(direction * 0.4, 0, 1.85)
            accent.Anchored = true
            accent.CanCollide = false
            accent.CanQuery = false
            accent.Material = Enum.Material.Neon
            accent.Color = Color3.fromRGB(90, 205, 255)
            accent.Transparency = 0.25
            accent:SetAttribute("GeneratedBySetup", true)
            accent.Parent = interiorFolder
        end
    end

    addForSide(true)
    addForSide(false)
end

addSideWallAccents()

local function createStorageBench(nameSuffix: string, position: Vector3, length: number)
    local bench = createInteriorPart(
        "GarageBenchBase_" .. nameSuffix,
        Vector3.new(length, 1.1, 1.4),
        position,
        Color3.fromRGB(65, 70, 85),
        Enum.Material.Metal
    )
    bench.Transparency = 0.12

    local top = createInteriorPart(
        "GarageBenchTop_" .. nameSuffix,
        Vector3.new(length - 0.6, 0.2, 1.2),
        position + Vector3.new(0, 0.65, 0),
        Color3.fromRGB(95, 105, 130),
        Enum.Material.SmoothPlastic
    )
    top.Transparency = 0.08

    return bench
end

createStorageBench("West", Vector3.new(22, 1, -8.5), 4)
createStorageBench("East", Vector3.new(34, 1, -8.5), 4)

local function createFloorInlay(nameSuffix: string, position: Vector3)
    local inlay = createInteriorPart(
        "GarageFloorInlay_" .. nameSuffix,
        Vector3.new(0.6, 0.05, 11.5),
        position,
        Color3.fromRGB(45, 120, 165),
        Enum.Material.SmoothPlastic
    )
    inlay.Transparency = 0.25

    local glow = Instance.new("Part")
    glow.Name = "GarageFloorGlow_" .. nameSuffix
    glow.Size = Vector3.new(0.35, 0.05, 11.1)
    glow.Position = position + Vector3.new(0, 0.08, 0)
    glow.Anchored = true
    glow.CanCollide = false
    glow.CanQuery = false
    glow.Material = Enum.Material.Neon
    glow.Color = Color3.fromRGB(95, 210, 255)
    glow.Transparency = 0.3
    glow:SetAttribute("GeneratedBySetup", true)
    glow.Parent = interiorFolder

    return inlay
end

createFloorInlay("West", Vector3.new(23.1, 0.5, -1.5))
createFloorInlay("East", Vector3.new(32.9, 0.5, -1.5))

local indicator = Instance.new("Part")
indicator.Name = "GarageStatusPanel"
indicator.Size = Vector3.new(0.6, 3.6, 0.25)
indicator.Position = Vector3.new(25.2, 4.6, -2.4)
indicator.Anchored = true
indicator.CanCollide = false
indicator.CanQuery = false
indicator.Material = Enum.Material.SmoothPlastic
indicator.Color = Color3.fromRGB(65, 150, 205)
indicator.Transparency = 0.2
indicator:SetAttribute("GeneratedBySetup", true)
indicator.Parent = interiorFolder

local indicatorLight = Instance.new("SurfaceLight")
indicatorLight.Brightness = 0.8
indicatorLight.Range = 10
indicatorLight.Face = Enum.NormalId.Front
indicatorLight.Color = Color3.fromRGB(190, 255, 255)
indicatorLight.Parent = indicator

local ambientHum = Instance.new("Sound")
ambientHum.Name = "GarageAmbientHum"
ambientHum.SoundId = "rbxassetid://87234272914801"
ambientHum.Volume = 0.15
ambientHum.Looped = true
ambientHum.RollOffMode = Enum.RollOffMode.Linear
ambientHum.RollOffMaxDistance = 80
ambientHum.Parent = interiorFolder

local steamAttachmentLeft = Instance.new("Attachment")
steamAttachmentLeft.Name = "GarageSteamAttachmentLeft"
steamAttachmentLeft.Position = Vector3.new(23, 5.5, 4)
steamAttachmentLeft.Parent = interiorFolder

local steamAttachmentRight = steamAttachmentLeft:Clone()
steamAttachmentRight.Name = "GarageSteamAttachmentRight"
steamAttachmentRight.Position = Vector3.new(33, 5.5, 4)
steamAttachmentRight.Parent = interiorFolder

local function createSteamEmitter(parentAttachment: Attachment)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "GarageSteamEmitter"
    emitter.Enabled = false
    emitter.Texture = "rbxassetid://241594284"
    emitter.LightEmission = 0.65
    emitter.Speed = NumberRange.new(3, 6)
    emitter.Lifetime = NumberRange.new(0.8, 1.3)
    emitter.SpreadAngle = Vector2.new(35, 45)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.5, 1.6),
        NumberSequenceKeypoint.new(1, 2.1)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Rate = 0
    emitter.Parent = parentAttachment
    return emitter
end

createSteamEmitter(steamAttachmentLeft)
createSteamEmitter(steamAttachmentRight)

local doorHeader = Instance.new("Part")
doorHeader.Name = "GarageDoorHeader"
doorHeader.Size = Vector3.new(20.5, 1.2, 2)
doorHeader.Position = Vector3.new(28, 10.6, 4)
doorHeader.Anchored = true
doorHeader.Transparency = 1
doorHeader.CanCollide = false
doorHeader.CanQuery = false
doorHeader:SetAttribute("GeneratedBySetup", true)
doorHeader.Parent = workspace

local doorTrackLeft = Instance.new("Part")
doorTrackLeft.Name = "GarageDoorTrackLeft"
local doorWidth = 20
doorTrackLeft.Size = Vector3.new(0.5, 12, 0.5)
doorTrackLeft.Position = Vector3.new(18 - (doorWidth / 2) - 0.25, 6, 5)
doorTrackLeft.Anchored = true
doorTrackLeft.Transparency = 1
doorTrackLeft.CanCollide = false
doorTrackLeft.CanQuery = false
doorTrackLeft:SetAttribute("GeneratedBySetup", true)
doorTrackLeft.Parent = workspace

local doorTrackRight = Instance.new("Part")
doorTrackRight.Name = "GarageDoorTrackRight"
doorTrackRight.Size = Vector3.new(0.5, 12, 0.5)
doorTrackRight.Position = Vector3.new(18 + (doorWidth / 2) + 0.25, 6, 5)
doorTrackRight.Anchored = true
doorTrackRight.Transparency = 1
doorTrackRight.CanCollide = false
doorTrackRight.CanQuery = false
doorTrackRight:SetAttribute("GeneratedBySetup", true)
doorTrackRight.Parent = workspace

local doorControl = Instance.new("Part")
doorControl.Name = "GarageDoorControl"
doorControl.Size = Vector3.new(1.6, 2.4, 0.4)
doorControl.Anchored = true
doorControl.Material = Enum.Material.Metal
doorControl.Color = Color3.fromRGB(70, 95, 120)
doorControl.CanCollide = false
doorControl.CanQuery = false
doorControl:SetAttribute("GeneratedBySetup", true)
doorControl.CFrame = CFrame.new(24, 2.2, 9.2, 0, 0, 1, 0, 1, 0, -1, 0, 0)
doorControl.Parent = workspace

local doorButton = Instance.new("ProximityPrompt")
doorButton.Name = "GarageDoorButton"
doorButton.ActionText = "Toggle Door"
doorButton.ObjectText = "Garage Access"
doorButton.RequiresLineOfSight = false
doorButton.HoldDuration = 0.2
doorButton.MaxActivationDistance = 8
doorButton.KeyboardKeyCode = Enum.KeyCode.F
doorButton.GamepadKeyCode = Enum.KeyCode.ButtonB
doorButton.Parent = doorControl


local consoleDeck = Instance.new("Part")
consoleDeck.Name = "GarageConsoleDeck"
consoleDeck.Size = Vector3.new(4.2, 0.4, 2.6)
consoleDeck.Anchored = true
consoleDeck.Material = Enum.Material.Metal
consoleDeck.Color = Color3.fromRGB(55, 65, 85)
consoleDeck.Transparency = 0.05
consoleDeck.CanCollide = false
consoleDeck.CanQuery = false
consoleDeck:SetAttribute("GeneratedBySetup", true)
consoleDeck.CFrame = CFrame.lookAt(Vector3.new(23, 1.35, 1.4), Vector3.new(27.5, 1.35, 1.4))
consoleDeck.Parent = workspace

local consoleSurface = Instance.new("Part")
consoleSurface.Name = "GarageConsoleSurface"
consoleSurface.Size = Vector3.new(4.0, 0.15, 1.6)
consoleSurface.Anchored = true
consoleSurface.Material = Enum.Material.Metal
consoleSurface.Color = Color3.fromRGB(42, 48, 66)
consoleSurface.CanCollide = false
consoleSurface.CanQuery = false
consoleSurface:SetAttribute("GeneratedBySetup", true)
consoleSurface.CFrame = consoleDeck.CFrame * CFrame.new(0, 0.3, -0.1)
consoleSurface.Parent = workspace

local monitorStand = Instance.new("Part")
monitorStand.Name = "GarageConsoleMonitor"
monitorStand.Size = Vector3.new(0.4, 1, 1.4)
monitorStand.Anchored = true
monitorStand.Material = Enum.Material.Metal
monitorStand.Color = Color3.fromRGB(38, 44, 58)
monitorStand.CanCollide = false
monitorStand.CanQuery = false
monitorStand:SetAttribute("GeneratedBySetup", true)
monitorStand.CFrame = consoleDeck.CFrame * CFrame.new(0, 0.75, -0.32) * CFrame.Angles(math.rad(6), 0, 0)
monitorStand.Parent = workspace

local monitorScreen = Instance.new("Part")
monitorScreen.Name = "GarageConsoleMonitorScreen"
monitorScreen.Size = Vector3.new(0.25, 1.2, 1.7)
monitorScreen.Anchored = true
monitorScreen.Material = Enum.Material.Neon
monitorScreen.Color = Color3.fromRGB(120, 220, 255)
monitorScreen.Transparency = 0.15
monitorScreen.CanCollide = false
monitorScreen.CanQuery = false
monitorScreen:SetAttribute("GeneratedBySetup", true)
monitorScreen.CFrame = monitorStand.CFrame * CFrame.new(0.25, 0.12, 0)
monitorScreen.Parent = workspace

local keyboard = Instance.new("Part")
keyboard.Name = "GarageConsoleKeyboard"
keyboard.Size = Vector3.new(1.4, 0.12, 0.55)
keyboard.Anchored = true
keyboard.Material = Enum.Material.SmoothPlastic
keyboard.Color = Color3.fromRGB(75, 85, 105)
keyboard.CanCollide = false
keyboard.CanQuery = false
keyboard.Transparency = 0.05
keyboard:SetAttribute("GeneratedBySetup", true)
keyboard.CFrame = consoleDeck.CFrame * CFrame.new(-0.25, 0.45, 0.28)
keyboard.Parent = workspace

local holoProjection = Instance.new("Part")
holoProjection.Name = "GarageConsoleHolo"
holoProjection.Size = Vector3.new(3.6, 1, 0.25)
holoProjection.Anchored = true
holoProjection.Material = Enum.Material.Neon
holoProjection.Color = Color3.fromRGB(120, 220, 255)
holoProjection.Transparency = 0.35
holoProjection.CanCollide = false
holoProjection.CanQuery = false
holoProjection:SetAttribute("GeneratedBySetup", true)
holoProjection.CFrame = consoleDeck.CFrame * CFrame.new(0, 0.8, -0.45) * CFrame.Angles(math.rad(12), 0, 0)
holoProjection.Parent = workspace

local holoLight = Instance.new("SurfaceLight")
holoLight.Name = "ConsoleGlow"
holoLight.Angle = 135
holoLight.Brightness = 2
holoLight.Range = 16
holoLight.Color = Color3.fromRGB(120, 220, 255)
holoLight.Parent = holoProjection

local holoAttachment = Instance.new("Attachment")
holoAttachment.Name = "ConsoleHoloAttachment"
holoAttachment.Parent = holoProjection

local holoEmitter = Instance.new("ParticleEmitter")
holoEmitter.Name = "ConsolePulseEmitter"
holoEmitter.Enabled = false
holoEmitter.Texture = "rbxassetid://241594284"
holoEmitter.LightEmission = 0.7
holoEmitter.Speed = NumberRange.new(1, 2)
holoEmitter.Lifetime = NumberRange.new(0.4, 0.6)
holoEmitter.SpreadAngle = Vector2.new(15, 25)
holoEmitter.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.3, 1.4),
    NumberSequenceKeypoint.new(1, 0.4)
})
holoEmitter.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(1, 1)
})
holoEmitter.Rate = 0
holoEmitter.Parent = holoAttachment

for _, offset in ipairs({-2.6, 2.6}) do
    local support = Instance.new("WedgePart")
    support.Name = "ConsoleSupport"
    support.Size = Vector3.new(1.2, 1.4, 0.6)
    support.Anchored = true
    support.Material = Enum.Material.Metal
    support.Color = Color3.fromRGB(40, 48, 62)
    support.CanCollide = false
    support.CanQuery = false
    support:SetAttribute("GeneratedBySetup", true)
    support.CFrame = consoleDeck.CFrame * CFrame.new(offset * 0.55, -0.65, 0.35) * CFrame.Angles(0, math.rad(180), 0)
    support.Parent = workspace
end

do
    local chairBase = Instance.new("Part")
    chairBase.Name = "ConsoleStool"
    chairBase.Size = Vector3.new(1.25, 0.45, 1.25)
    chairBase.Anchored = true
    chairBase.Material = Enum.Material.Metal
    chairBase.Color = Color3.fromRGB(32, 36, 48)
    chairBase.CanCollide = false
    chairBase.CanQuery = false
    chairBase:SetAttribute("GeneratedBySetup", true)
    chairBase.CFrame = consoleDeck.CFrame * CFrame.new(0, -0.55, 0.85)
    chairBase.Parent = workspace

    local cushion = Instance.new("Part")
    cushion.Name = "ConsoleStoolCushion"
    cushion.Size = Vector3.new(1.05, 0.25, 1.05)
    cushion.Anchored = true
    cushion.Material = Enum.Material.SmoothPlastic
    cushion.Color = Color3.fromRGB(85, 95, 130)
    cushion.CanCollide = false
    cushion.CanQuery = false
    cushion:SetAttribute("GeneratedBySetup", true)
    cushion.CFrame = chairBase.CFrame * CFrame.new(0, 0.35, 0)
    cushion.Parent = workspace
end

local consoleModel = keepOneConsole(workspace)
if consoleModel and consoleModel.PrimaryPart then
    local primary = consoleModel.PrimaryPart
    consoleModel:PivotTo(CFrame.new(primary.Position))

    local screen = consoleModel:FindFirstChild("Screen", true)
    if screen and screen:IsA("BasePart") then
        local screenPosition = primary.Position + primary.CFrame.LookVector * 3 + Vector3.new(0, 2, 0)
        screen.CFrame = CFrame.lookAt(screenPosition, screenPosition + primary.CFrame.LookVector)
    end

    local handle = consoleModel:FindFirstChild("DoorHandle", true)
    if handle and handle:IsA("BasePart") then
        for _, descendant in ipairs(handle:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.ObjectText ~= "Garage Access" then
                descendant:Destroy()
            end
        end
        local prompt = handle:FindFirstChildOfClass("ProximityPrompt")
        if not prompt then
            prompt = Instance.new("ProximityPrompt")
            prompt.Parent = handle
        end
        prompt.ObjectText = "Garage Access"
        prompt.ActionText = "Toggle Door"
        prompt.HoldDuration = 0
    end
end

local terminalBase = Instance.new("Part")
terminalBase.Name = "GarageTerminal"
terminalBase.Size = Vector3.new(0.6, 1.2, 0.4)
terminalBase.Anchored = true
terminalBase.Material = Enum.Material.Metal
terminalBase.Color = Color3.fromRGB(90, 110, 150)
terminalBase.Transparency = 1
terminalBase.CanCollide = false
terminalBase.CanQuery = false
terminalBase:SetAttribute("GeneratedBySetup", true)
terminalBase.CFrame = consoleDeck.CFrame * CFrame.new(-1.6, 0.6, 0.5)
terminalBase.Parent = workspace

local terminalScreen = Instance.new("Part")
terminalScreen.Name = "GarageTerminalScreen"
terminalScreen.Size = Vector3.new(0.6, 1.2, 0.4)
terminalScreen.Anchored = true
terminalScreen.Material = Enum.Material.Neon
terminalScreen.Color = Color3.fromRGB(110, 210, 255)
terminalScreen.Transparency = 1
terminalScreen.CanCollide = false
terminalScreen.CanQuery = false
terminalScreen:SetAttribute("GeneratedBySetup", true)
terminalScreen.CFrame = terminalBase.CFrame
terminalScreen.Parent = workspace

local terminalPrompt = Instance.new("ProximityPrompt")
terminalPrompt.Name = "GarageTerminalPrompt"
terminalPrompt.ActionText = "Access Console"
terminalPrompt.ObjectText = "Operations"
terminalPrompt.RequiresLineOfSight = false
terminalPrompt.HoldDuration = 0.25
terminalPrompt.MaxActivationDistance = 7
terminalPrompt.KeyboardKeyCode = Enum.KeyCode.E
terminalPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
terminalPrompt.Parent = terminalBase

local hatchPlatform = Instance.new("Part")
hatchPlatform.Name = "GarageHatchPlatform"
hatchPlatform.Shape = Enum.PartType.Cylinder
hatchPlatform.Size = Vector3.new(0.6, 6.5, 6.5)
hatchPlatform.Anchored = true
hatchPlatform.Material = Enum.Material.Metal
hatchPlatform.Color = Color3.fromRGB(80, 95, 120)
hatchPlatform.CanCollide = true
hatchPlatform.CanQuery = true
hatchPlatform:SetAttribute("GeneratedBySetup", true)
hatchPlatform.CFrame = CFrame.new(28, garageFloor.Position.Y + 0.55, -6) * CFrame.Angles(0, 0, math.rad(90))
hatchPlatform.Parent = workspace

local platformTrim = Instance.new("Part")
platformTrim.Name = "GarageHatchTrim"
platformTrim.Shape = Enum.PartType.Cylinder
platformTrim.Size = Vector3.new(0.2, 7.1, 7.1)
platformTrim.Anchored = true
platformTrim.Material = Enum.Material.Neon
platformTrim.Color = Color3.fromRGB(95, 205, 255)
platformTrim.Transparency = 0.4
platformTrim.CanCollide = false
platformTrim.CanQuery = false
platformTrim:SetAttribute("GeneratedBySetup", true)
platformTrim.CFrame = hatchPlatform.CFrame * CFrame.new(0, 0.2, 0)
platformTrim.Parent = workspace

local hatchRamp = Instance.new("WedgePart")
hatchRamp.Name = "GarageHatchRamp"
hatchRamp.Size = Vector3.new(4.6, 1.2, 3.4)
hatchRamp.Anchored = true
hatchRamp.Material = Enum.Material.Metal
hatchRamp.Color = Color3.fromRGB(70, 85, 105)
hatchRamp.CanCollide = true
hatchRamp.CanQuery = true
hatchRamp:SetAttribute("GeneratedBySetup", true)
hatchRamp.CFrame = CFrame.new(28, garageFloor.Position.Y + 0.75, -8.4) * CFrame.Angles(math.rad(-22), 0, 0)
hatchRamp.Parent = workspace

-- Mining zones removed - using only resource balls for cleaner gameplay

local function isInsideZoneXZ(positionXZ: Vector3, zones)
    for _, zone in ipairs(zones) do
        local offset = positionXZ - Vector3.new(zone.center.X, 0, zone.center.Z)
        if offset.Magnitude < zone.radius then
            return true
        end
    end
    return false
end

local function pickResourcePosition(yOffset: number, zones)
    for _ = 1, 30 do
        local angle = math.rad(math.random(0, 359))
        local distance = math.random(60, 140)
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance
        local candidate = Vector3.new(x, 0, z)
        if not isInsideZoneXZ(candidate, zones) then
            return Vector3.new(x, yOffset, z)
        end
    end
    return Vector3.new(0, yOffset, 95)
end

local excludedZones = {
    {center = Vector3.new(0, 0, 0), radius = 38},
    {center = garageFloor.Position, radius = 32},
}

for i = 1, 25 do
    local resource = Instance.new("Part")
    resource.Name = "Resource_" .. i

    local sizeVariants = {1.2, 1.5, 1.8}
    local resourceSize = sizeVariants[math.random(1, #sizeVariants)]
    resource.Size = Vector3.new(resourceSize, resourceSize, resourceSize)
    resource.Shape = Enum.PartType.Ball
    resource.Material = Enum.Material.Neon
    resource:SetAttribute("GeneratedBySetup", true)

    local resourceTypes = {
        {Color3.fromRGB(0, 212, 255), "Gearbit"},
        {Color3.fromRGB(150, 0, 255), "Ion Shard"},
        {Color3.fromRGB(255, 215, 0), "Rare Metal"},
        {Color3.fromRGB(255, 255, 255), "Crystal"},
    }

    local resourceType = resourceTypes[math.random(1, #resourceTypes)]
    resource.Color = resourceType[1]

    resource.Anchored = true
    resource.Position = pickResourcePosition(resourceSize * 0.5, excludedZones)
    resource.Parent = workspace

    resource.TopSurface = Enum.SurfaceType.Smooth
    resource.BottomSurface = Enum.SurfaceType.Smooth

    local originCFrame = CFrame.new(resource.Position)
    local baseRockColor = resource.Color:Lerp(Color3.fromRGB(40, 40, 48), 0.55)

    local function addCluster(offset: Vector3, size: Vector3, color: Color3, transparency: number?)
        local shard = Instance.new("Part")
        shard.Name = resource.Name .. "_Shard"
        shard.Anchored = true
        shard.CanCollide = false
        shard.CanQuery = false
        shard.Material = Enum.Material.Rock
        shard.Color = color
        shard.Transparency = transparency or 0
        shard.Size = size
        shard:SetAttribute("GeneratedBySetup", true)
        local rotation = CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(0, 360)), math.rad(math.random(-10, 10)))
        shard.CFrame = originCFrame * CFrame.new(offset) * rotation
        shard.Parent = resource
    end

    addCluster(Vector3.new(0.8, -0.25, 0.3), Vector3.new(resourceSize * 0.6, resourceSize * 0.4, resourceSize * 0.5), baseRockColor)
    addCluster(Vector3.new(-0.7, -0.3, -0.4), Vector3.new(resourceSize * 0.5, resourceSize * 0.6, resourceSize * 0.4), resource.Color:Lerp(Color3.fromRGB(220, 220, 240), 0.35))
    addCluster(Vector3.new(0.1, resourceSize * 0.5, -0.2), Vector3.new(resourceSize * 0.3, resourceSize * 0.7, resourceSize * 0.3), resource.Color, 0.1)

    local sparkleEmitter = Instance.new("ParticleEmitter")
    sparkleEmitter.Name = "ResourceSparkle"
    sparkleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.tga"
    sparkleEmitter.LightEmission = 0.4
    sparkleEmitter.Lifetime = NumberRange.new(0.4, 0.7)
    sparkleEmitter.Rate = 6
    sparkleEmitter.Speed = NumberRange.new(0.5, 1.2)
    sparkleEmitter.SpreadAngle = Vector2.new(12, 12)
    sparkleEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.35),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    sparkleEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    sparkleEmitter.Enabled = true
    sparkleEmitter.Parent = resource

    local glow = Instance.new("SurfaceLight")
    glow.Name = "ResourceGlow"
    glow.Face = Enum.NormalId.Top
    glow.Angle = 120
    glow.Range = 12
    glow.Brightness = 1.2
    glow.Color = resource.Color
    glow.Parent = resource

    local stringValue = Instance.new("StringValue")
    stringValue.Name = "ResourceType"
    stringValue.Value = resourceType[2]
    stringValue.Parent = resource

    local healthValue = Instance.new("IntValue")
    healthValue.Name = "ResourceHealth"
    healthValue.Value = math.floor(resourceSize * 3)
    healthValue.Parent = resource

    local originalSizeValue = Instance.new("NumberValue")
    originalSizeValue.Name = "OriginalSize"
    originalSizeValue.Value = resourceSize
    originalSizeValue.Parent = resource
end

-- Create walls around the play area
local walls = {
    {pos = Vector3.new(0, 5, 60), size = Vector3.new(120, 10, 2)},
    {pos = Vector3.new(0, 5, -60), size = Vector3.new(120, 10, 2)},
    {pos = Vector3.new(60, 5, 0), size = Vector3.new(2, 10, 120)},
    {pos = Vector3.new(-60, 5, 0), size = Vector3.new(2, 10, 120)}
}

for i, wall in ipairs(walls) do
    local wallPart = Instance.new("Part")
    wallPart.Name = "Wall_" .. i
    wallPart.Size = wall.size
    wallPart.Position = wall.pos
    wallPart.Anchored = true
    wallPart.Material = Enum.Material.Concrete
    wallPart.Color = Color3.fromRGB(80, 80, 80)
    wallPart:SetAttribute("GeneratedBySetup", true)
    wallPart.Parent = workspace
end

do
    local Garage = ensureModel(workspace, "Garage")
    destroyDuplicates(workspace, "Garage")

    for _, child in ipairs(Garage:GetChildren()) do
        child:Destroy()
    end

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant ~= Garage and not descendant:IsDescendantOf(Garage) then
            if descendant:IsA("BasePart") or descendant:IsA("Model") or descendant:IsA("Folder") then
                local name = descendant.Name
                if name:match("^Garage") or name:match("^GarageConsole") or name:match("^Console") then
                    descendant:Destroy()
                end
            end
        end
    end

    local garageFloor = ensureBasePart(Garage, "Part", "GarageFloor", {
        Size = Vector3.new(24, 0.2, 18),
        CFrame = CFrame.new(28, 0.1, -4),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(80, 85, 95),
        CanCollide = true,
        CanQuery = true,
    })

    local garageShell = ensureBasePart(Garage, "Part", "GarageShell", {
        Size = Vector3.new(24, 12, 18),
        CFrame = CFrame.new(28, 6, -4),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(60, 65, 75),
        Transparency = 0.25,
        CanCollide = false,
        CanQuery = false,
    })

    local walkwayHeight = garageFloor.Position.Y + (garageFloor.Size.Y * 0.5) + 0.12
    local garageWalkway = ensureBasePart(Garage, "Part", "GarageWalkway", {
        Size = Vector3.new(22, 0.2, 12),
        CFrame = CFrame.new(28, walkwayHeight, -1),
        Material = Enum.Material.DiamondPlate,
        Color = Color3.fromRGB(105, 110, 125),
        CanCollide = true,
        CanQuery = false,
    })

    local hatchPlatform = ensureBasePart(Garage, "Part", "GarageHatchPlatform", {
        Size = Vector3.new(0.6, 6.5, 6.5),
        CFrame = CFrame.new(28, garageFloor.Position.Y + 0.55, -6) * CFrame.Angles(0, 0, math.rad(90)),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(80, 95, 120),
        CanCollide = true,
        CanQuery = true,
        Shape = Enum.PartType.Cylinder,
    })

    local hatchTrim = ensureBasePart(Garage, "Part", "GarageHatchTrim", {
        Size = Vector3.new(0.2, 7.1, 7.1),
        CFrame = hatchPlatform.CFrame * CFrame.new(0, 0.2, 0),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(95, 205, 255),
        Transparency = 0.4,
        CanCollide = false,
        CanQuery = false,
        Shape = Enum.PartType.Cylinder,
    })

    local hatchRamp = ensureBasePart(Garage, "WedgePart", "GarageHatchRamp", {
        Size = Vector3.new(4.6, 1.2, 3.4),
        CFrame = CFrame.new(28, garageFloor.Position.Y + 0.75, -8.4) * CFrame.Angles(math.rad(-22), 0, 0),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(70, 85, 105),
        CanCollide = true,
        CanQuery = true,
    })

    local garageInterior = Garage:FindFirstChild("GarageInterior")
    if not garageInterior or not garageInterior:IsA("Folder") then
        if garageInterior then
            garageInterior:Destroy()
        end
        garageInterior = Instance.new("Folder")
        garageInterior.Name = "GarageInterior"
    end
    for _, child in ipairs(garageInterior:GetChildren()) do
        child:Destroy()
    end
    garageInterior.Parent = Garage

    local console = ensureModel(Garage, "GarageConsole")
    for _, child in ipairs(console:GetChildren()) do
        child:Destroy()
    end

    local consoleDeck = ensureBasePart(console, "Part", "GarageConsoleDeck", {
        Size = Vector3.new(4.2, 0.4, 2.6),
        CFrame = CFrame.lookAt(Vector3.new(23, 1.35, 1.4), Vector3.new(27.5, 1.35, 1.4)),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(55, 65, 85),
        Transparency = 0.05,
        CanCollide = false,
        CanQuery = false,
    })
    console.PrimaryPart = consoleDeck

    local consoleSurface = ensureBasePart(console, "Part", "GarageConsoleSurface", {
        Size = Vector3.new(4, 0.15, 1.6),
        CFrame = consoleDeck.CFrame * CFrame.new(0, 0.3, -0.1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(42, 48, 66),
        CanCollide = false,
        CanQuery = false,
    })

    local monitorStand = ensureBasePart(console, "Part", "GarageConsoleMonitor", {
        Size = Vector3.new(0.4, 1, 1.4),
        CFrame = consoleDeck.CFrame * CFrame.new(0, 0.75, -0.32) * CFrame.Angles(math.rad(6), 0, 0),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(38, 44, 58),
        CanCollide = false,
        CanQuery = false,
    })

    local monitorScreen = ensureBasePart(console, "Part", "GarageConsoleMonitorScreen", {
        Size = Vector3.new(0.25, 1.2, 1.7),
        CFrame = monitorStand.CFrame * CFrame.new(0.25, 0.12, 0),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(120, 220, 255),
        Transparency = 0.15,
        CanCollide = false,
        CanQuery = false,
    })

    local consoleKeyboard = ensureBasePart(console, "Part", "GarageConsoleKeyboard", {
        Size = Vector3.new(1.4, 0.12, 0.55),
        CFrame = consoleDeck.CFrame * CFrame.new(-0.25, 0.45, 0.28),
        Material = Enum.Material.SmoothPlastic,
        Color = Color3.fromRGB(75, 85, 105),
        Transparency = 0.05,
        CanCollide = false,
        CanQuery = false,
    })

    local consoleHolo = ensureBasePart(console, "Part", "GarageConsoleHolo", {
        Size = Vector3.new(3.6, 1, 0.25),
        CFrame = consoleDeck.CFrame * CFrame.new(0, 0.8, -0.45) * CFrame.Angles(math.rad(12), 0, 0),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(120, 220, 255),
        Transparency = 0.35,
        CanCollide = false,
        CanQuery = false,
    })

    local function ensureConsoleSupport(suffix: string, offset: Vector3)
        return ensureBasePart(console, "WedgePart", "ConsoleSupport" .. suffix, {
            Size = Vector3.new(1.2, 1.4, 0.6),
            CFrame = consoleDeck.CFrame * CFrame.new(offset.X, offset.Y, offset.Z) * CFrame.Angles(0, math.rad(180), 0),
            Material = Enum.Material.Metal,
            Color = Color3.fromRGB(40, 48, 62),
            CanCollide = false,
            CanQuery = false,
        })
    end

    ensureConsoleSupport("Left", Vector3.new(-1.43, -0.65, 0.35))
    ensureConsoleSupport("Right", Vector3.new(1.43, -0.65, 0.35))

    local consoleStool = ensureBasePart(console, "Part", "ConsoleStool", {
        Size = Vector3.new(1.25, 0.45, 1.25),
        CFrame = consoleDeck.CFrame * CFrame.new(0, -0.55, 0.85),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(32, 36, 48),
        CanCollide = false,
        CanQuery = false,
    })

    ensureBasePart(console, "Part", "ConsoleStoolCushion", {
        Size = Vector3.new(1.05, 0.25, 1.05),
        CFrame = consoleStool.CFrame * CFrame.new(0, 0.35, 0),
        Material = Enum.Material.SmoothPlastic,
        Color = Color3.fromRGB(85, 95, 130),
        CanCollide = false,
        CanQuery = false,
    })

    local terminalBase = ensureBasePart(console, "Part", "GarageTerminal", {
        Size = Vector3.new(0.6, 1.2, 0.4),
        CFrame = consoleDeck.CFrame * CFrame.new(-1.6, 0.6, 0.5),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(90, 110, 150),
        Transparency = 0.2,
        CanCollide = false,
        CanQuery = false,
    })

    ensureBasePart(console, "Part", "GarageTerminalScreen", {
        Size = Vector3.new(0.6, 1.2, 0.4),
        CFrame = terminalBase.CFrame * CFrame.new(0, 0, 0.05),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(110, 210, 255),
        Transparency = 0.15,
        CanCollide = false,
        CanQuery = false,
    })

    for _, descendant in ipairs(terminalBase:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            descendant:Destroy()
        end
    end

    local terminalPrompt = Instance.new("ProximityPrompt")
    terminalPrompt.Name = "GarageTerminalPrompt"
    terminalPrompt.ObjectText = "Garage Console"
    terminalPrompt.ActionText = "Open Menu"
    terminalPrompt.KeyboardKeyCode = Enum.KeyCode.E
    terminalPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    terminalPrompt.HoldDuration = 0
    terminalPrompt.RequiresLineOfSight = false
    terminalPrompt.MaxActivationDistance = 7
    terminalPrompt.Parent = terminalBase

    local handle = ensureBasePart(console, "Part", "DoorHandle", {
        Size = Vector3.new(0.5, 1.2, 0.5),
        CFrame = consoleDeck.CFrame * CFrame.new(0, 1.2, -2),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(95, 205, 255),
        CanCollide = false,
        CanQuery = false,
        Transparency = 0,
    })

    for _, descendant in ipairs(handle:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            descendant:Destroy()
        end
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "GarageDoorPrompt"
    prompt.ObjectText = "Garage Access"
    prompt.ActionText = "Toggle Door (F)"
    prompt.KeyboardKeyCode = Enum.KeyCode.F
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 8
    prompt.Parent = handle

    local doorFrame
    do
        local targetPosition = consoleDeck.CFrame * CFrame.new(0, 3, -4)
        local lookTarget = Vector3.new(GameConstants.CENTER_POS.X, targetPosition.Position.Y, GameConstants.CENTER_POS.Z)
        local lookCFrame = CFrame.lookAt(targetPosition.Position, lookTarget)
        doorFrame = ensureBasePart(Garage, "Part", "DoorFrame", {
            Size = Vector3.new(6, 6, 0.2),
            CFrame = lookCFrame,
            Material = Enum.Material.Metal,
            Color = Color3.fromRGB(70, 75, 90),
            Transparency = 0.6,
            CanCollide = false,
            CanQuery = false,
        })
    end

    local doorFrameSizeY = doorFrame.Size.Y
    local doorHeader = ensureBasePart(Garage, "Part", "GarageDoorHeader", {
        Size = Vector3.new(doorFrame.Size.X + 1, 0.8, 0.6),
        CFrame = doorFrame.CFrame * CFrame.new(0, (doorFrameSizeY * 0.5) + 0.4, 0),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(65, 75, 95),
        Transparency = 0.4,
        CanCollide = false,
        CanQuery = false,
    })

    local trackHeight = doorFrameSizeY + 2
    local trackSize = Vector3.new(0.35, trackHeight, 0.35)
    local heightOffset = (trackHeight - doorFrameSizeY) * 0.5
    local depthOffset = doorFrame.Size.Z * 0.5 + trackSize.Z * 0.5 + 0.2
    local halfWidth = doorFrame.Size.X * 0.5 - trackSize.X * 0.5

    ensureBasePart(Garage, "Part", "GarageDoorTrackLeft", {
        Size = trackSize,
        CFrame = doorFrame.CFrame * CFrame.new(-halfWidth, heightOffset, depthOffset),
        Material = Enum.Material.Metal,
        Transparency = 1,
        CanCollide = false,
        CanQuery = false,
    })

    ensureBasePart(Garage, "Part", "GarageDoorTrackRight", {
        Size = trackSize,
        CFrame = doorFrame.CFrame * CFrame.new(halfWidth, heightOffset, depthOffset),
        Material = Enum.Material.Metal,
        Transparency = 1,
        CanCollide = false,
        CanQuery = false,
    })

    ensureModel(Garage, "GarageDoor")

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant ~= Garage and not descendant:IsDescendantOf(Garage) then
            if descendant:IsA("BasePart") or descendant:IsA("Model") or descendant:IsA("Folder") then
                local name = descendant.Name
                if name:match("^Garage") or name:match("^GarageConsole") or name:match("^Console") then
                    descendant:Destroy()
                end
            end
        end
    end

    consoleDeck:SetAttribute("GeneratedBySetup", true)
    consoleSurface:SetAttribute("GeneratedBySetup", true)
    console:SetAttribute("GeneratedBySetup", true)
    garageShell:SetAttribute("GeneratedBySetup", true)
    garageWalkway:SetAttribute("GeneratedBySetup", true)
    hatchPlatform:SetAttribute("GeneratedBySetup", true)
    hatchTrim:SetAttribute("GeneratedBySetup", true)
    hatchRamp:SetAttribute("GeneratedBySetup", true)
    garageInterior:SetAttribute("GeneratedBySetup", true)
    doorFrame:SetAttribute("GeneratedBySetup", true)
    doorHeader:SetAttribute("GeneratedBySetup", true)
end

workspace:SetAttribute("WorkspaceSetupComplete", true)

print("🏗️ Workspace setup complete! Large ground platform + mining zones created.")
