-- HideResourceOverlays.client.luau
local Workspace = game:GetService("Workspace")

local X_HALF, Z_MIN, Z_MAX, Y_MAX = 60, -120, 40, 10

local function inBoundsBase(part: BasePart): boolean
	local p = part.Position
	return math.abs(p.X) <= X_HALF and p.Z >= Z_MIN and p.Z <= Z_MAX and p.Y <= Y_MAX
end

local function path(inst: Instance): string
	local t, cur = {}, inst
	while cur and cur ~= game do
		table.insert(t, 1, cur.Name); cur = cur.Parent
	end
	return table.concat(t, ".")
end

local function disableGui(gui: Instance, tag: string)
	local adornee = nil
	pcall(function() adornee = (gui :: any).Adornee end)
	if not adornee then
		local p = gui:FindFirstAncestorWhichIsA("BasePart")
		if p then adornee = p end
	end
	if adornee and adornee:IsA("BasePart") and inBoundsBase(adornee) then
		if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
			pcall(function() (gui :: any).Enabled = false end)
		end
		print(string.format("[CLIENT OVERLAY-OFF:%s] %s adornee=%s", tag, path(gui), path(adornee)))
	end
end

local function hideDecal(obj: Instance, tag: string)
	local p = obj.Parent
	if p and p:IsA("BasePart") and inBoundsBase(p) then
		if obj:IsA("Decal") or obj:IsA("Texture") then
			pcall(function() (obj :: any).Transparency = 1 end)
		end
		print(string.format("[CLIENT OVERLAY-HIDE:%s] %s on %s", tag, path(obj), path(p)))
	end
end

task.defer(function()
	for _,d in ipairs(game:GetDescendants()) do
		if d:IsA("SurfaceGui") or d:IsA("BillboardGui") then disableGui(d, "boot")
		elseif d:IsA("Decal") or d:IsA("Texture") or d:IsA("Adornment") or d:IsA("HandleAdornment") then hideDecal(d, "boot") end
	end
	local stopAt = os.clock() + 15
	game.DescendantAdded:Connect(function(o)
		if os.clock() > stopAt then return end
		if o:IsA("SurfaceGui") or o:IsA("BillboardGui") then disableGui(o, "added")
		elseif o:IsA("Decal") or o:IsA("Texture") or o:IsA("Adornment") or o:IsA("HandleAdornment") then hideDecal(o, "added") end
	end)
	print("[CLIENT OVERLAY] mirror ACTIVE")
end)
