

--!strict
-- TerrainLoader.server.luau
-- Phase 1: Base ground + plaza + zone anchors + paths (idempotent)
-- NOTE: This script only creates placeholder geometry; swap with Mesh/Terrain later.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local WORLD_FOLDER_NAME = "WorldZones"
local GROUND_FOLDER = "Ground"
local PATH_FOLDER = "Paths"
local ANCHOR_FOLDER = "Anchors"
local PROP_FOLDER = "Props"

-- Reference points (keep near your garage/spawn). Existing spawn pad ~ (0, 3.5, -12)
local ORIGIN = Vector3.new(0, 0, -12) -- center the plaza around this

local PLAZA_SIZE = Vector3.new(120, 1, 120)
local PLAZA_COLOR = Color3.fromRGB(60, 66, 76)

local function ensureFolder(parent: Instance, name: string): Folder
	local f = parent:FindFirstChild(name)
	if not (f and f:IsA("Folder")) then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local function ensurePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, collidable: boolean)
	local p = parent:FindFirstChild(name)
	if not (p and p:IsA("BasePart")) then
		p = Instance.new("Part")
		p.Name = name
		p.Parent = parent
	end
	local bp = p :: BasePart
	bp.Anchored = true
	bp.CanCollide = collidable
	bp.Size = size
	bp.CFrame = cframe
	bp.Material = material
	bp.Color = color
	return bp
end

local function ensureAnchor(parent: Instance, name: string, pos: Vector3, color: Color3, tier: number)
	local a = parent:FindFirstChild(name)
	if not (a and a:IsA("Part")) then
		a = Instance.new("Part")
		a.Name = name
		a.Shape = Enum.PartType.Ball
		a.Parent = parent
		CollectionService:AddTag(a, "ZoneAnchor")
	end
	local ap = a :: BasePart
	ap.Anchored = true
	ap.CanCollide = false
	ap.Material = Enum.Material.Neon
	ap.Color = color
	ap.Size = Vector3.new(2, 2, 2)
	ap.CFrame = CFrame.new(pos + Vector3.new(0, 1.1, 0))
	ap:SetAttribute("Tier", tier)
	ap:SetAttribute("ZoneName", name)
	return ap
end

local function ensurePath(parent: Instance, name: string, fromPos: Vector3, toPos: Vector3, width: number)
	-- Create a simple rectangular path segment between two points on XZ plane
	local mid = (fromPos + toPos) * 0.5
	local delta = toPos - fromPos
	delta = Vector3.new(delta.X, 0, delta.Z)
	local length = math.max(2, delta.Magnitude)
	local cf = CFrame.new(mid) * CFrame.lookAt(Vector3.new(0,0,0), delta.Unit).Rotation
	local p = ensurePart(parent, name, Vector3.new(width, 0.2, length), cf, Color3.fromRGB(85, 90, 100), Enum.Material.Concrete, true)
	return p
end

-- Main build
local worldRoot = ensureFolder(workspace, WORLD_FOLDER_NAME)
local groundFolder = ensureFolder(worldRoot, GROUND_FOLDER)
local pathFolder = ensureFolder(worldRoot, PATH_FOLDER)
local anchorFolder = ensureFolder(worldRoot, ANCHOR_FOLDER)
local propFolder = ensureFolder(worldRoot, PROP_FOLDER)

-- Plaza (Tier 0)
local plaza = ensurePart(groundFolder, "T0_Plaza", PLAZA_SIZE, CFrame.new(ORIGIN + Vector3.new(0, -0.5, 0)), PLAZA_COLOR, Enum.Material.Slate, true)

-- Zone target positions (rough layout per WORLD_BLUEPRINT.md)
local T0 = ORIGIN
local T1 = ORIGIN + Vector3.new(100, 0, 0)    -- Scrapyard (east)
local T2 = ORIGIN + Vector3.new(0, 0, 100)    -- Power Fields (south from T0 perspective)
local T3 = ORIGIN + Vector3.new(-100, 0, 0)   -- Ruined City (west)
local T4 = ORIGIN + Vector3.new(0, 0, -140)   -- Orbital Gate (north, beyond garage)

-- Anchors
local a0 = ensureAnchor(anchorFolder, "ZoneAnchor_T0_GarageBase", T0, Color3.fromRGB(120,170,255), 0)
local a1 = ensureAnchor(anchorFolder, "ZoneAnchor_T1_Scrapyard", T1, Color3.fromRGB(200,150,90), 1)
local a2 = ensureAnchor(anchorFolder, "ZoneAnchor_T2_PowerFields", T2, Color3.fromRGB(120,255,220), 2)
local a3 = ensureAnchor(anchorFolder, "ZoneAnchor_T3_RuinedCity", T3, Color3.fromRGB(180,180,200), 3)
local a4 = ensureAnchor(anchorFolder, "ZoneAnchor_T4_OrbitalGate", T4, Color3.fromRGB(255,200,120), 4)

-- Paths from T0 → T1/T2/T3/T4
ensurePath(pathFolder, "Path_T0_T1", T0, T1, 8)
ensurePath(pathFolder, "Path_T0_T2", T0, T2, 8)
ensurePath(pathFolder, "Path_T0_T3", T0, T3, 8)
ensurePath(pathFolder, "Path_T0_T4", T0, T4, 8)

-- Simple props (scrap piles) near T1; energy crystals near T2
local function ensureProp(name: string, pos: Vector3, size: Vector3, color: Color3, material: Enum.Material)
	return ensurePart(propFolder, name, size, CFrame.new(pos), color, material, true)
end

for i = 1, 6 do
	local offset = Vector3.new(math.random(-12, 12), 0, math.random(-12, 12))
	ensureProp(string.format("ScrapPile_%02d", i), T1 + offset, Vector3.new(4, 1, 3), Color3.fromRGB(110, 100, 90), Enum.Material.CorrodedMetal)
end
for i = 1, 4 do
	local offset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
	ensureProp(string.format("EnergyCrystal_%02d", i), T2 + offset, Vector3.new(2, 6, 2), Color3.fromRGB(90, 230, 210), Enum.Material.Neon)
end

if RunService:IsStudio() then
	print("[TerrainLoader] Base world generated: plaza, anchors, and paths ready.")
end