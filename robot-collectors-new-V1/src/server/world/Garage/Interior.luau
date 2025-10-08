--!strict
local Interior = {}

local function ensure(parent: Instance, name: string, size: Vector3, cf: CFrame, props: {[string]: any}?): BasePart
	local p = parent:FindFirstChild(name) :: BasePart?
	if not p then p = Instance.new("Part"); p.Name = name; p.Parent = parent end
	p.Anchored = true; p.Size = size; p.CFrame = cf
	if props then for k,v in pairs(props) do (p :: any)[k] = v end end
	return p
end

-- Place basic clubhouse pads relative to DoorPlane basis
-- basis(cfPos, right, up, outward)
function Interior.Mount(root: Model, spec: {width:number,height:number,depth:number}, basis: (Vector3, Vector3, Vector3, Vector3) -> CFrame, center: Vector3, r: Vector3, u: Vector3, inw: Vector3, out: Vector3)
	local COLOR_PAD  = Color3.fromRGB(55,160,200)
	local COLOR_FIX  = Color3.fromRGB(200,160,55)
	local COLOR_CORE = Color3.fromRGB(120,200,255)
	local COLOR_UI   = Color3.fromRGB(90,110,140)
	local COLOR_SHELF= Color3.fromRGB(70,80,90)

	-- Derive a reliable floor-top Y from the GD_FloorInterior part
	local floorPart = root:FindFirstChild("GD_FloorInterior") :: BasePart?
	local floorTopY: number
	if floorPart then
		floorTopY = floorPart.CFrame.Position.Y + floorPart.Size.Y * 0.5
	else
		-- Fallback: assume floor around center Y
		floorTopY = center.Y + 0.1
	end
	print(("[Interior] floorTopY=%.3f"):format(floorTopY))

	-- Place a box so its base sits on the floor (sizeY is height of the box)
	local function onFloor(dx: number, dz: number, sizeY: number): CFrame
		-- world position of the part's center at given dx,dz on the floor + 1/2 size + small gap
		local worldPos = center
			+ r * (dx * spec.width)
			+ inw * (dz * spec.depth)
			+ u * ((floorTopY + sizeY * 0.5 + 0.01) - center.Y)
		return basis(worldPos, r, u, out)
	end

	-- A) Hatch Pad (front-left)
	ensure(root, "GD_HatchPad", Vector3.new(6,0.2,6), onFloor(-0.30, 0.28, 0.2), {Material=Enum.Material.Metal, Color=COLOR_PAD})
	-- B) Repair Pad (front-right)
	ensure(root, "GD_RepairPad",   Vector3.new(5,0.2,6), onFloor(0.30, 0.28, 0.2), {Material=Enum.Material.Metal, Color=COLOR_FIX})
	-- Gantry over Repair Pad (visual)
	ensure(root, "GD_RepairGantry",Vector3.new(5,3.0,0.3), onFloor(0.30, 0.28, 3.0) * CFrame.new(0, 1.3, 0), {Material=Enum.Material.Metal, Color=COLOR_FIX, CanCollide=false})

	-- C) Power Core (mid-back)
	ensure(root, "GD_PowerCoreBase", Vector3.new(3.4,0.4,3.4), onFloor(0.0, 0.58, 0.4), {Material=Enum.Material.Metal, Color=COLOR_CORE})
	ensure(root, "GD_PowerCore",     Vector3.new(2.6,3.2,2.6), onFloor(0.0, 0.58, 3.2), {Material=Enum.Material.SmoothPlastic, Color=COLOR_CORE, Transparency=0})

	-- D) Command Console (mid)
	ensure(root, "GD_CommandConsole", Vector3.new(3.0,1.5,0.2), onFloor(0.0, 0.40, 1.5), {Material=Enum.Material.Metal, Color=COLOR_UI, CanCollide=false})

	-- E) Storage Lockers (side walls; 3 left, 3 right)
	local z = {0.42, 0.54, 0.66}
	for i,zi in ipairs(z) do
		ensure(root, ("GD_LockerL_%d"):format(i), Vector3.new(1.8,3.0,0.6), onFloor(-0.46, zi, 3.0), {Material=Enum.Material.Metal, Color=COLOR_SHELF})
		ensure(root, ("GD_LockerR_%d"):format(i), Vector3.new(1.8,3.0,0.6), onFloor(0.46, zi, 3.0), {Material=Enum.Material.Metal, Color=COLOR_SHELF})
	end
end

return Interior
