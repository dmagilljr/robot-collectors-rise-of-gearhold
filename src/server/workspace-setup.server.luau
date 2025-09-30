-- Robot Collectors: Workspace Setup
-- Creates mining areas and spawn platforms

local workspace = game:GetService("Workspace")

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
            or obj.Name == "GarageDoorTrackRight" then
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
garageShell:SetAttribute("GeneratedBySetup", true)
garageShell.Parent = workspace

local doorGroup = Instance.new("Folder")
doorGroup.Name = "GarageDoor"
doorGroup:SetAttribute("GeneratedBySetup", true)
doorGroup.Parent = workspace

local slatCount = 6
local doorWidth = 20
local doorHeight = 10
local slatThickness = 0.4
local slatHeight = doorHeight / slatCount

for i = 0, slatCount - 1 do
    local slat = Instance.new("Part")
    slat.Name = "DoorSlat_" .. i
    slat.Size = Vector3.new(doorWidth, slatHeight, slatThickness)
    slat.Anchored = true
    slat.Material = Enum.Material.Metal
    slat.Color = Color3.fromRGB(50, 120, 160)
    slat.Transparency = 0.3
    slat:SetAttribute("GeneratedBySetup", true)
    local yPosition = slatHeight / 2 + i * slatHeight
    slat.CFrame = CFrame.new(28, yPosition, 5)
    slat.Parent = doorGroup
end

local walkway = Instance.new("Part")
walkway.Name = "GarageWalkway"
walkway.Size = Vector3.new(18, 0.15, 6)
walkway.Position = Vector3.new(18, 0.08, 5)
walkway.Anchored = true
walkway.Material = Enum.Material.Metal
walkway.Color = Color3.fromRGB(90, 95, 110)
walkway:SetAttribute("GeneratedBySetup", true)
walkway.Parent = workspace

local doorHeader = Instance.new("Part")
doorHeader.Name = "GarageDoorHeader"
doorHeader.Size = Vector3.new(20.5, 1.2, 2)
doorHeader.Position = Vector3.new(28, 10.6, 4)
doorHeader.Anchored = true
doorHeader.Transparency = 1
doorHeader.CanCollide = false
doorHeader:SetAttribute("GeneratedBySetup", true)
doorHeader.Parent = workspace

local doorTrackLeft = Instance.new("Part")
doorTrackLeft.Name = "GarageDoorTrackLeft"
doorTrackLeft.Size = Vector3.new(0.5, 12, 0.5)
doorTrackLeft.Position = Vector3.new(18 - (doorWidth / 2) - 0.25, 6, 5)
doorTrackLeft.Anchored = true
doorTrackLeft.Transparency = 1
doorTrackLeft.CanCollide = false
doorTrackLeft:SetAttribute("GeneratedBySetup", true)
doorTrackLeft.Parent = workspace

local doorTrackRight = Instance.new("Part")
doorTrackRight.Name = "GarageDoorTrackRight"
doorTrackRight.Size = Vector3.new(0.5, 12, 0.5)
doorTrackRight.Position = Vector3.new(18 + (doorWidth / 2) + 0.25, 6, 5)
doorTrackRight.Anchored = true
doorTrackRight.Transparency = 1
doorTrackRight.CanCollide = false
doorTrackRight:SetAttribute("GeneratedBySetup", true)
doorTrackRight.Parent = workspace

local console = Instance.new("Part")
console.Name = "GarageConsole"
console.Size = Vector3.new(2, 3, 1)
console.Anchored = true
console.Material = Enum.Material.Neon
console.Color = Color3.fromRGB(80, 140, 200)
console.CanCollide = false
console:SetAttribute("GeneratedBySetup", true)
console.CFrame = CFrame.new(42, 1.5, 5, 0, 0, 1, 0, 1, 0, -1, 0, 0) -- position to the right of the garage, facing left
console.Parent = workspace

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "GaragePrompt"
prompt.ActionText = "Hatch Robot"
prompt.ObjectText = "Garage Console"
prompt.RequiresLineOfSight = false
prompt.HoldDuration = 0.5
prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
prompt.MaxActivationDistance = 9
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.GamepadKeyCode = Enum.KeyCode.ButtonY
prompt.Parent = console

-- Mining zones removed - using only resource balls for cleaner gameplay

-- Create mineable resource nodes scattered around
for i = 1, 25 do  -- Increased from 20 to 25 for better distribution
    local resource = Instance.new("Part")
    resource.Name = "Resource_" .. i

    -- Vary resource sizes (small, medium, large)
    local sizeVariants = {1.2, 1.5, 1.8}
    local resourceSize = sizeVariants[math.random(1, #sizeVariants)]
    resource.Size = Vector3.new(resourceSize, resourceSize, resourceSize)
    resource.Shape = Enum.PartType.Ball
    resource.Material = Enum.Material.Neon
    resource:SetAttribute("GeneratedBySetup", true)

    -- Resource types with 4th type (Crystals) added
    local resourceTypes = {
        {Color3.fromRGB(0, 212, 255), "Gearbit"},      -- Cyan
        {Color3.fromRGB(150, 0, 255), "Ion Shard"},    -- Purple
        {Color3.fromRGB(255, 215, 0), "Rare Metal"},   -- Gold
        {Color3.fromRGB(255, 255, 255), "Crystal"}     -- White
    }

    local resourceType = resourceTypes[math.random(1, #resourceTypes)]
    resource.Color = resourceType[1]

    -- Random position around the platform
    local angle = math.random(1, 360)
    local distance = math.random(15, 45)  -- Spread them out more
    resource.Position = Vector3.new(
        math.cos(math.rad(angle)) * distance,
        resourceSize / 2,  -- Position based on size
        math.sin(math.rad(angle)) * distance
    )
    resource.Anchored = true
    resource.Parent = workspace

    -- Add resource data
    local stringValue = Instance.new("StringValue")
    stringValue.Name = "ResourceType"
    stringValue.Value = resourceType[2]
    stringValue.Parent = resource

    -- Add health tracking (larger resources have more health)
    local healthValue = Instance.new("IntValue")
    healthValue.Name = "ResourceHealth"
    healthValue.Value = math.floor(resourceSize * 3)  -- 3-5 hits to deplete
    healthValue.Parent = resource

    -- Store original size for shrinking calculations
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

print("🏗️ Workspace setup complete! Large ground platform + mining zones created.")
