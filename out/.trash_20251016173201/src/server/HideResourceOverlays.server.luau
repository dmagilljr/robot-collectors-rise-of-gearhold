-- HideResourceOverlays.server.luau
-- Disables SurfaceGui/BillboardGui, and hides Decal/Texture/Adornments whose adornee/parent sits near the door.

local Workspace = game:GetService("Workspace")

-- Bounds (wide, adjust if needed)
local X_HALF, Z_MIN, Z_MAX, Y_MAX = 60, -120, 40, 10

local function inBoundsBase(part: BasePart): boolean
	local p = part.Position
	return math.abs(p.X) <= X_HALF and p.Z >= Z_MIN and p.Z <= Z_MAX and p.Y <= Y_MAX
end

local function path(inst: Instance): string
	local t, cur = {}, inst
	while cur and cur ~= game do
		table.insert(t, 1, cur.Name)
		cur = cur.Parent
	end
	return table.concat(t, ".")
end

local function tryDisableGui(gui: Instance, reason: string)
	-- SurfaceGui/BillboardGui can have Adornee, else parent might be a Part
	local adornee = nil
	pcall(function() adornee = (gui :: any).Adornee end)
	if not adornee then
		local p = gui:FindFirstAncestorWhichIsA("BasePart")
		if p then adornee = p end
	end
	if adornee and adornee:IsA("BasePart") and inBoundsBase(adornee) then
		-- Disable/hide
		if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
			pcall(function() (gui :: any).Enabled = false end)
		end
		print(string.format("[OVERLAY-OFF:%s] %s gui=%s adornee=%s",
			reason, path(gui), gui.ClassName, path(adornee)))
	end
end

local function tryHideDecalLike(obj: Instance, reason: string)
	local adornee = obj.Parent
	if adornee and adornee:IsA("BasePart") and inBoundsBase(adornee) then
		if obj:IsA("Decal") or obj:IsA("Texture") then
			pcall(function() (obj :: any).Transparency = 1 end)
			print(string.format("[OVERLAY-HIDE:%s] %s on %s", reason, path(obj), path(adornee)))
		end
	end
end

local function sweep(tag: string)
	for _,d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
			tryDisableGui(d, tag)
		elseif d:IsA("Decal") or d:IsA("Texture") then
			tryHideDecalLike(d, tag)
		elseif d:IsA("HandleAdornment") or d:IsA("Adornment") then
			tryDisableGui(d, tag) -- many adornments expose Adornee
		end
	end
	print("[OVERLAY] sweep "..tag.." complete")
end

task.defer(function()
	sweep("boot")
	-- watch new overlays for 15s
	local stopAt = os.clock() + 15
	Workspace.DescendantAdded:Connect(function(o)
		if os.clock() > stopAt then return end
		if o:IsA("SurfaceGui") or o:IsA("BillboardGui") then
			tryDisableGui(o, "added")
		elseif o:IsA("Decal") or o:IsA("Texture") or o:IsA("Adornment") or o:IsA("HandleAdornment") then
			-- adornments/decals often come in after the adornee exists
			task.defer(function()
				tryDisableGui(o, "added")
				tryHideDecalLike(o, "added")
			end)
		end
	end)
end)

print(string.format("[OVERLAY] HideResourceOverlays ACTIVE — X±%d Z[%d..%d] Y<=%d", X_HALF, Z_MIN, Z_MAX, Y_MAX))
