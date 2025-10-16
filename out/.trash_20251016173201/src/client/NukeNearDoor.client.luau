-- NukeNearDoor.client.luau (mirror)
local Workspace = game:GetService("Workspace")

local X_HALF, Z_MIN, Z_MAX, Y_MAX = 60, -120, 40, 10
local WATCH_S = 20

local function inBounds(p: BasePart): boolean
	local pos = p.Position
	return math.abs(pos.X) <= X_HALF and pos.Z >= Z_MIN and pos.Z <= Z_MAX and pos.Y <= Y_MAX
end

local function isCharacterPart(inst: Instance): boolean
	local m = inst:FindFirstAncestorOfClass("Model")
	return m and m:FindFirstChildOfClass("Humanoid") ~= nil
end

local function chain(inst: Instance): string
	local t, cur = {}, inst
	while cur and cur ~= Workspace do
		table.insert(t, 1, cur.Name)
		cur = cur.Parent
	end
	return "Workspace."..table.concat(t, ".")
end

local function kill(p: BasePart, reason: string)
	print(("[CLIENT-NUKE:%s] %s  pos=(%.2f,%.2f,%.2f)  path=%s")
		:format(reason, p.ClassName, p.Position.X,p.Position.Y,p.Position.Z, chain(p)))
	p:Destroy()
end

local function sweep(tag: string)
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("BasePart") and not isCharacterPart(d) and inBounds(d) then
			kill(d, tag)
		end
	end
end

task.defer(function()
	sweep("boot")
	local stopAt = os.clock() + WATCH_S
	Workspace.DescendantAdded:Connect(function(o)
		if os.clock() > stopAt then return end
		if o:IsA("BasePart") and not isCharacterPart(o) and inBounds(o) then
			kill(o, "added")
		end
	end)
	print(string.format("🧨 CLIENT NUKE ACTIVE (watch=%ds)", WATCH_S))
end)
