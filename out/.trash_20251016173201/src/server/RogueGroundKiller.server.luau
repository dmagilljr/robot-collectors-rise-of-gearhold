-- RogueGroundKiller.server.luau (temporary)
-- Removes thin, near-door ground-ish parts that shouldn't exist. Logs before delete.

local CollectionService = game:GetService("CollectionService")

local function nearDoor(p: BasePart): boolean
	local pos = p.Position
	return math.abs(pos.X) <= 14 and pos.Z >= -52 and pos.Z <= -30
end

local function isThinGround(p: BasePart): boolean
	return p.Size.Y <= 1.5 and p.Position.Y <= 2.2
end

local function isCharacterPart(inst: Instance): boolean
	local m = inst:FindFirstAncestorOfClass("Model")
	return m and m:FindFirstChildOfClass("Humanoid") ~= nil
end

local function isInGarage(p: Instance): boolean
	local a = p:FindFirstAncestorOfClass("Model")
	if not a then return false end
	return a.Name == "GD_Garage" or a:FindFirstAncestor("GD_Garage") ~= nil
end

local function shouldKill(p: BasePart): boolean
	if isCharacterPart(p) then return false end
	if isInGarage(p) then return false end
	if not isThinGround(p) then return false end
	if not nearDoor(p) then return false end
	return true
end

local function kill(p: BasePart, tag: string)
	print(string.format("[KILL:%s] %s  sz=(%.2f,%.2f,%.2f) y=%.2f path=%s",
		tag, p.ClassName, p.Size.X, p.Size.Y, p.Size.Z, p.Position.Y, p:GetFullName()))
	p:Destroy()
end

-- One-shot sweep soon after boot
task.defer(function()
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and shouldKill(d) then
			kill(d, "boot")
		end
	end
end)

-- Catch anything added after boot for a short window (10s)
local stopAt = os.clock() + 10
workspace.DescendantAdded:Connect(function(obj)
	if os.clock() > stopAt then return end
	if obj:IsA("BasePart") and shouldKill(obj) then
		kill(obj, "added")
	end
end)

print("🛡️ RogueGroundKiller ACTIVE (server)")
