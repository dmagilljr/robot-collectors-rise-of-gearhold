--!strict
-- ResourceSpawner — per-player instanced spawns based on quest/level unlocks

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local Workspace = workspace
local shared = ReplicatedStorage:WaitForChild("shared")

local GameConstants = require(shared:WaitForChild("config"):WaitForChild("GameConstants"))
local Unlocks = require(shared:WaitForChild("config"):WaitForChild("Unlocks"))
local ResourceDefs = require(shared:WaitForChild("ResourceDefs"))

local Modules = game:GetService("ServerScriptService"):WaitForChild("Modules")
local QuestService = require(Modules:WaitForChild("QuestService"))
local Progression = require(Modules:WaitForChild("ProgressionService"))

local function resourcesAreEnabled(): boolean
  if script:GetAttribute("RESOURCES_ENABLED") == true then
    return true
  end
  local worldFolder = game:GetService("ServerScriptService"):FindFirstChild("World")
  if worldFolder and worldFolder:GetAttribute("RESOURCES_ENABLED") == true then
    return true
  end
  return false
end

local function getDoorCenter(): Vector3
	local garage = Workspace:FindFirstChild("GD_Garage")
	if garage and garage:IsA("Model") then
		local attr = garage:GetAttribute("DoorCenter")
		if typeof(attr) == "Vector3" then
			return attr
		end
	end
	return GameConstants.GARAGE_DEFAULT_DOOR_CENTER
end

local function planarDistance(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

local function getOrCreateBucket(p: Player): Folder
  local root = workspace:FindFirstChild("PlayerSpawns") :: Folder
  if not root then
    root = Instance.new("Folder")
    root.Name = "PlayerSpawns"
    root.Parent = workspace
  end
  local userFolder = root:FindFirstChild(tostring(p.UserId)) :: Folder
  if not userFolder then
    userFolder = Instance.new("Folder")
    userFolder.Name = tostring(p.UserId)
    userFolder.Parent = root
  end
  local resources = userFolder:FindFirstChild("Resources") :: Folder
  if not resources then
    resources = Instance.new("Folder")
    resources.Name = "Resources"
    resources.Parent = userFolder
  end
  return resources
end

local function clearFolder(f: Instance)
  for _, child in ipairs(f:GetChildren()) do
    child:Destroy()
  end
end

local function spawnSimpleNode(resourceType: string): BasePart
  local def = ResourceDefs[resourceType]
  local part = Instance.new("Part")
  part.Name = resourceType .. "_Node"
  part.Size = Vector3.new(2.4, 2.4, 2.4)
  part.Anchored = true
  part.CanCollide = true
 if def then
    part.Color = def.color or Color3.fromRGB(200, 200, 200)
    if def.materialPrimary then
      part.Material = def.materialPrimary
    end
  end
  CollectionService:AddTag(part, "ResourceNode")
  return part
end

local function spawnFromTemplate(resourceType: string): Instance?
  local node: Instance? = nil
  local templates = ServerStorage:FindFirstChild("ResourceTemplates")
  if templates then
    local tpl = templates:FindFirstChild(resourceType)
    if tpl then
      node = tpl:Clone()
    end
  end

  if not node then
    node = spawnSimpleNode(resourceType)
  end

  if not node then
    return nil
  end

  if not CollectionService:HasTag(node, "ResourceNode") then
    if GameConstants.DEBUG then
      warn(("[ResourceSpawner] Rejecting untagged template for resourceType=%s"):format(tostring(resourceType)))
    end
    node:Destroy()
    return nil
  end

  if node:IsA("BasePart") and node.Size.Y <= GameConstants.THIN_TILE_Y_MAX then
    if GameConstants.DEBUG then
      warn(("[ResourceSpawner] Rejecting thin node (Y=%.2f) type=%s"):format(node.Size.Y, tostring(resourceType)))
    end
    node:Destroy()
    return nil
  end

  return node
end

-- Anchor seeds used for per-player resource placement.
-- NOTE: We intentionally exclude the garage apron (see NO_SPAWN_ANCHORS and isForbiddenAnchor).
local ZoneAnchors = {
  -- Keep other anchors as-needed, but do NOT place at the garage apron.
  T1_Scrapyard = Vector3.new(-40, 0, -20),
  T2_PowerFields = Vector3.new(40, 0, -20),
  T3_RuinedCity = Vector3.new(0, 0, 40),
}

-- Hard no-spawn list for anchors by name (safety net).
local NO_SPAWN_ANCHORS = {
  T0_GarageBase = true,
}

-- Reject near the garage door apron: |X| ≤ 18, -60 < Z < -28, Y ≤ 4.
local function isForbiddenAnchor(name: string?, pos: Vector3)
  if name and NO_SPAWN_ANCHORS[name] then
    return true
  end
  local x, y, z = pos.X, pos.Y, pos.Z
  if math.abs(x) <= 18 and z > -60 and z < -28 and y <= 4 then
    return true
  end
  return false
end

local function placeAround(anchor: Vector3, count: number, idx: number): CFrame
  local ring = math.max(1, math.ceil(math.sqrt(count)))
  local x = (idx % ring) - ring / 2
  local z = math.floor(idx / ring) - ring / 2
  return CFrame.new(anchor + Vector3.new(x * 6, 0, z * 6))
end

local function refreshForPlayer(p: Player)
  local bucket = getOrCreateBucket(p)
  clearFolder(bucket)

  if not resourcesAreEnabled() then
    return
  end

  local doorCenter = getDoorCenter()

  for zoneName, zoneTable in pairs(Unlocks.spawn) do
    local anchor = ZoneAnchors[zoneName] or Vector3.new(0, 0, 0)
    if isForbiddenAnchor(zoneName, anchor) then
      if GameConstants.DEBUG then
        print(("[ResourceSpawner] Skipping forbidden anchor %s @ %s"):format(tostring(zoneName), tostring(anchor)))
      end
      continue
    end
    for resourceType, desired in pairs(zoneTable) do
      if QuestService:IsUnlocked(p, resourceType) or Progression:IsLevelUnlocked(p, resourceType) then
        for n = 1, desired do
          local node = spawnFromTemplate(resourceType)
          if not node then
            continue
          end
          local placeCF = placeAround(anchor, desired, n - 1)
          local targetPos = placeCF.Position
          local distance = planarDistance(targetPos, doorCenter)
          if distance < GameConstants.MIN_GARAGE_RADIUS then
            if GameConstants.DEBUG then
              warn(("[ResourceSpawner] Skipping spawn inside garage radius (%.1f < %.1f) at %s")
                :format(distance, GameConstants.MIN_GARAGE_RADIUS, tostring(targetPos)))
            end
            node:Destroy()
            continue
          end
          if node:IsA("BasePart") then
            node.CFrame = placeCF
            node.Parent = bucket
          elseif node:IsA("Model") then
            node.Parent = bucket
            local pp = node.PrimaryPart
            if not pp then
              for _, d in ipairs(node:GetDescendants()) do
                if d:IsA("BasePart") then
                  pp = d
                  break
                end
              end
            end
            if pp then
              pp.CFrame = placeCF
            end
          else
            node.Parent = bucket
          end
        end
      end
    end
  end
end

local M = {}
function M:RefreshFor(p: Player)
  refreshForPlayer(p)
end

Players.PlayerAdded:Connect(function(p)
  task.defer(function()
    refreshForPlayer(p)
  end)
end)

Progression:LevelChanged():Connect(function(p)
  refreshForPlayer(p)
end)

return M
