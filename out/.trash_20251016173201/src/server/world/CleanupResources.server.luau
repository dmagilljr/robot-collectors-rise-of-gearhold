--!strict
-- Remove all resource nodes at boot when resources are disabled
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local GameConstants = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("GameConstants"))

-- Read flag from World folder (same convention used elsewhere)
local worldFolder = ServerScriptService:FindFirstChild("World")
local RESOURCES_ON = false
if worldFolder then
    local attr = worldFolder:GetAttribute("RESOURCES_ENABLED")
    RESOURCES_ON = (attr == true)
end

if not RESOURCES_ON then
    -- Delete tagged nodes first (authoritative)
    local removed = 0
    for _, inst in ipairs(CollectionService:GetTagged("ResourceNode")) do
        if inst then inst:Destroy(); removed += 1 end
    end

    -- Also remove name-matched parts/models (fallback for untagged prefabs)
    local function looksLikeResourceName(n: string): boolean
        n = n:lower()
        return n:match("scrap") or n:match("crystal") or n:match("energy")
            or n:match("component") or n:match("raremetal") or n:match("ore")
    end

    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Model") and looksLikeResourceName(inst.Name) then
            inst:Destroy(); removed += 1
        elseif inst:IsA("BasePart") and looksLikeResourceName(inst.Name) then
            inst:Destroy(); removed += 1
        end
    end

    if removed > 0 and GameConstants.DEBUG then
        print(("[CleanupResources] Removed %d resource instances (disabled)"):format(removed))
    end
end

-- Defensive scrub: remove prompt-bearing thin parts near the garage apron, regardless of tag.
do
    local function _nearGarage(bp: BasePart): boolean
        local p = bp.Position
        return math.abs(p.X) <= 18 and p.Z > -60 and p.Z < -28 and p.Y <= 4
    end
    local removed = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and _nearGarage(d) then
            local hasPrompt = d:FindFirstChildOfClass("ProximityPrompt") ~= nil
            local lname = d.Name:lower()
            if hasPrompt or lname:find("scrap") or lname:find("resource") then
                d:Destroy()
                removed += 1
            end
        end
    end
    if removed > 0 and GameConstants.DEBUG then
        print(string.format("[CleanupResources] Defensive removed %d near-door rogue parts", removed))
    end
end

do
    local function planarDistance(a: Vector3, b: Vector3): number
        local dx, dz = a.X - b.X, a.Z - b.Z
        return math.sqrt(dx * dx + dz * dz)
    end
    local MIN_RADIUS = GameConstants.MIN_GARAGE_RADIUS
    local DOOR_CENTER = (function()
        local g = workspace:FindFirstChild("GD_Garage")
        local v = g and g:GetAttribute("DoorCenter")
        if typeof(v) == "Vector3" then return v end
        return GameConstants.GARAGE_DEFAULT_DOOR_CENTER
    end)()

    local removed = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and planarDistance(d.Position, DOOR_CENTER) < MIN_RADIUS then
            local tagged = CollectionService:HasTag(d, "ResourceNode")
            local parent = d.Parent
            local inPlayerBucket = parent and parent:IsA("Folder")
                and parent.Name == "Resources"
                and parent.Parent and tostring(parent.Parent):find("PlayerSpawns")
            if tagged or inPlayerBucket then
                d:Destroy()
                removed += 1
            end
        end
    end
    if removed > 0 and GameConstants.DEBUG then
        print(string.format("[CleanupResources] Removed %d near-garage nodes within %d studs", removed, MIN_RADIUS))
    end
end
