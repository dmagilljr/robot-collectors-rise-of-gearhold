-- DebugPaverWatch.client.luau  (temporary)
-- Purpose: detect rogue paver tiles or ProximityPrompt attachments appearing client-side

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local plr = Players.LocalPlayer

local function isThinGround(part: BasePart): boolean
	return part.Size.Y <= 1.5 and part.Position.Y <= 2.2
end

local function nearDoor(part: BasePart): boolean
	local p = part.Position
	return math.abs(p.X) <= 14 and p.Z >= -52 and p.Z <= -30
end

local function logPart(prefix: string, part: BasePart)
	print(string.format(
		"%s %s  sz=(%.2f,%.2f,%.2f)  y=%.2f  path=%s",
		prefix,
		part.ClassName,
		part.Size.X, part.Size.Y, part.Size.Z,
		part.Position.Y,
		part:GetFullName()
	))
end

-- 1) Watch for new thin near-door parts appearing client-side
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and isThinGround(obj) and nearDoor(obj) then
		logPart("[CLIENT WATCH] ThinNearDoor+", obj)
	end
end)

-- 2) Watch for new ProximityPrompts added under any BasePart
workspace.DescendantAdded:Connect(function(inst)
	if not inst:IsA("ProximityPrompt") then return end
	local p = inst:FindFirstAncestorWhichIsA("BasePart")
	if p then
		logPart("[CLIENT WATCH] PromptAdd→Parent", p)
	end
end)

-- 3) Watch for ResourceNode tags assigned client-side
local ok, conn = pcall(function()
	return CollectionService:GetInstanceAddedSignal("ResourceNode")
end)
if ok then
	conn:Connect(function(inst)
		if inst:IsA("BasePart") then
			logPart("[CLIENT WATCH] TagAdd:ResourceNode", inst)
		end
	end)
end

-- 4) One-shot sweep after boot to catch any pre-existing thin near-door parts
task.defer(function()
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and isThinGround(d) and nearDoor(d) then
			logPart("[CLIENT WATCH] ThinNearDoor@boot", d)
		end
	end
	print("🔎 DebugPaverWatch ACTIVE (client)")
end)
