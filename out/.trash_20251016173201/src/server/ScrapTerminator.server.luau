-- ScrapTerminator.server.luau (nuclear)
-- Deletes ANY BasePart within a wide box in front of the garage door and logs full ancestry.
-- Use short watchdog so you can see respawns; widen/narrow bounds after we identify the source.

local Workspace = game:GetService("Workspace")

-- ===== WIDE BOUNDS =====
local X_HALF   = 60   -- left/right from center
local Z_MIN    = -120 -- far in front of door
local Z_MAX    =  40  -- slightly behind player
local Y_MAX    =  10  -- ground-ish vertical envelope (raise if needed)
local WATCH_S  = 20   -- watchdog seconds
local INCLUDE_GD_CHILDREN = true -- kill even if under GD_Garage (set false once we find source)
-- =======================

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

local function inGD(inst: Instance): boolean
	local gd = Workspace:FindFirstChild("GD_Garage")
	return gd and inst:IsDescendantOf(gd) or false
end

local function shouldKill(p: BasePart): boolean
	if isCharacterPart(p) then return false end
	if not inBounds(p) then return false end
	if not INCLUDE_GD_CHILDREN and inGD(p) then return false end
	return true
end

local function kill(p: BasePart, reason: string)
	print(("[NUKE:%s] %s  size=(%.2f,%.2f,%.2f)  pos=(%.2f,%.2f,%.2f)  path=%s")
		:format(reason, p.ClassName, p.Size.X,p.Size.Y,p.Size.Z, p.Position.X,p.Position.Y,p.Position.Z, chain(p)))
	p:Destroy()
end

local function sweep(tag: string)
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("BasePart") and shouldKill(d) then
			kill(d, tag)
		end
	end
	print("[NUKE] sweep complete tag="..tag)
end

task.defer(function()
	sweep("boot")
	local stopAt = os.clock() + WATCH_S
	Workspace.DescendantAdded:Connect(function(o)
		if os.clock() > stopAt then return end
		if o:IsA("BasePart") and shouldKill(o) then
			kill(o, "added")
		end
	end)
end)

print(string.format("[NUKE] ScrapTerminator ACTIVE — box X±%d Z[%d..%d] Y<=%d, watch=%ds", X_HALF, Z_MIN, Z_MAX, Y_MAX, WATCH_S))
