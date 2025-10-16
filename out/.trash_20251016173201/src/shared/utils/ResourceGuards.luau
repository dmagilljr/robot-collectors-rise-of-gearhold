local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local M = {}

function M.inGD(inst: Instance): boolean
	local gd = Workspace:FindFirstChild("GD_Garage")
	return gd and inst:IsDescendantOf(gd) or false
end

function M.isCharacterPart(inst: Instance): boolean
	local m = inst:FindFirstAncestorOfClass("Model")
	return m and m:FindFirstChildOfClass("Humanoid") ~= nil
end

function M.isThinGround(p: BasePart): boolean
	return p.Size.Y <= 1.5 and p.Position.Y <= 2.2
end

function M.nearDoor(p: BasePart): boolean
	local x, _, z = p.Position.X, p.Position.Y, p.Position.Z
	return math.abs(x) <= 14 and z >= -52 and z <= -30
end

function M.isTaggedResource(p: Instance): boolean
	local ok, tagged = pcall(function()
		return CollectionService:HasTag(p, "ResourceNode")
	end)
	return ok and tagged
end

function M.shouldTreatAsResource(p: Instance): boolean
	if not p then return false end
	if not p:IsA("BasePart") then return false end
	if M.isCharacterPart(p) then return false end
	-- HARD GATES
	if M.inGD(p) then return false end
	if M.isThinGround(p) and M.nearDoor(p) then return false end
	-- Tag-only
	if not M.isTaggedResource(p) then return false end
	return true
end

function M.blockAndTrace(prefix: string, inst: Instance)
	local path = {}
	local cur = inst
	while cur and cur ~= Workspace do
		table.insert(path, 1, cur.Name)
		cur = cur.Parent
	end
	local full = "Workspace." .. table.concat(path, ".")
	warn(prefix .. " BLOCKED @ " .. full)
	warn(debug.traceback(prefix .. " TRACE", 2))
end

return M
