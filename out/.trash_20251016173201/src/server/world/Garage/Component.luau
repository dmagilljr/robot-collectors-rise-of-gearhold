--!strict
local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "[Garage/Component] must run on the SERVER")

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local GarageFolder = script.Parent
local AnimateDoor = require(GarageFolder:WaitForChild("Animate"))
local Fixup = require(GarageFolder:WaitForChild("Fixup"))

local shouldSpawnPavers = function()
	local worldFolder = script.Parent
	if worldFolder and worldFolder:GetAttribute("SPAWN_PAVERS") == true then
		return true
	end
	return false
end

local OPEN_RADIUS = 9.0
local CLOSE_RADIUS = 11.0
local CHECK_INTERVAL = 0.10

-- Minimal, reliable part factory
local function ensure(parent: Instance, name: string, size: Vector3, cf: CFrame, props: {[string]: any}?): BasePart
	local p = parent:FindFirstChild(name) :: BasePart?
	if not p then
		p = Instance.new("Part")
		p.Name = name
		p.Parent = parent
	end
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	if props then
		for k, v in pairs(props) do
			(p :: any)[k] = v
		end
	end
	return p
end

local function cfFromBasis(pos: Vector3, right: Vector3, up: Vector3, out: Vector3): CFrame
	return CFrame.fromMatrix(pos, right, up, out)
end

local function planeFrom(center: Vector3, facing: Vector3)
	local cf = CFrame.lookAt(center, center + facing.Unit, Vector3.new(0, 1, 0))
	return {
		cf = cf,
		right = cf.RightVector,
		up = cf.UpVector,
		outward = cf.LookVector,
		inward = -cf.LookVector,
		planeZ = cf.Position.Z,
	}
end

local function detectFloorY(x: number, z: number): number
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {}
	local origin = Vector3.new(x, 512, z)
	local ray = workspace:Raycast(origin, Vector3.new(0, -1024, 0), params)
	return (ray and ray.Position.Y) or 0
end

local Garage = {}


local function findFrontWallCandidate(model: Instance): BasePart?
	local hints = {"FrontWall","Spandrel","Front","DoorSpandrel","FrontPanel"}
	for _, hint in ipairs(hints) do
		local candidate = model:FindFirstChild(hint, true)
		if candidate and candidate:IsA("BasePart") then
			return candidate
		end
	end
	local best: BasePart? = nil
	local bestScore = -math.huge
	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") then
			local b = inst :: BasePart
			local size = b.Size
			local area = size.X * size.Y + size.Z * size.Y
			local thin = math.min(size.X, size.Z)
			local score = area - thin * 10
			if score > bestScore then
				bestScore = score
				best = b
			end
		end
	end
	return best
end



export type Spec = {
	origin: Vector3,
	width: number,
	height: number,
	depth: number,
	facing: Vector3,
	ownerUserId: number?,
}

function Garage.Mount(spec: Spec): () -> ()
	local root = Instance.new("Model")
	root.Name = "GD_Garage"
	root.Parent = workspace
	CollectionService:AddTag(root, "GD_Garage")

	local modelRef = GarageFolder:FindFirstChild("ModelRef") :: ObjectValue?
	if not modelRef then
		modelRef = Instance.new("ObjectValue")
		modelRef.Name = "ModelRef"
		modelRef.Parent = GarageFolder
	end
	modelRef.Value = root
	-- modelRef published for sibling modules

	local groundY = detectFloorY(spec.origin.X, spec.origin.Z)
	local planeCenter = Vector3.new(spec.origin.X, groundY + spec.height * 0.5, spec.origin.Z + 6)
	local plane = planeFrom(planeCenter, spec.facing)
	local planeZ = plane.planeZ

	local WALL_T = 0.5
	local SHELL_W = spec.width + 8
	local SHELL_H = math.max(spec.height + 1.2, 8)
	local SHELL_D = math.max(spec.depth, spec.width + 6)
	local GAP = 1.0
	local FRONT_MARGIN = 0.05

local COLOR_METAL = Color3.fromRGB(45, 55, 65) -- unified darker tone to remove visible light line
	local COLOR_FLOOR = Color3.fromRGB(35, 38, 45)
	local PROPS_SOLID = { Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, Transparency = 0 }

	for _, child in ipairs(root:GetChildren()) do
		child:Destroy()
	end

	local r = plane.right
	local u = plane.up
	local inw = plane.inward
	local out = plane.outward
	local center = plane.cf.Position

	local shellHeightOffset = u * ((SHELL_H * 0.5) - (spec.height * 0.5))
	local backHeightOffset = u * (((SHELL_H - WALL_T) * 0.5) - (spec.height * 0.5))
	local function basis(pos: Vector3)
		return cfFromBasis(pos, r, u, out)
	end

	local backCenter = center + backHeightOffset + inw * (SHELL_D - WALL_T * 0.5 + FRONT_MARGIN)
	local back = ensure(root, "GD_Back", Vector3.new(SHELL_W, SHELL_H - WALL_T, WALL_T), basis(backCenter), PROPS_SOLID)

	local sideOffset = inw * (SHELL_D * 0.5 + FRONT_MARGIN)
	local sideHeightOffset = center + shellHeightOffset
	local leftCenter = sideHeightOffset + sideOffset + r * (-SHELL_W * 0.5 + WALL_T * 0.5)
	local rightCenter = sideHeightOffset + sideOffset + r * (SHELL_W * 0.5 - WALL_T * 0.5)
	local leftPart = ensure(root, "GD_Left", Vector3.new(WALL_T, SHELL_H, SHELL_D), basis(leftCenter), PROPS_SOLID)
	local rightPart = ensure(root, "GD_Right", Vector3.new(WALL_T, SHELL_H, SHELL_D), basis(rightCenter), PROPS_SOLID)

	local roofCenter = center + shellHeightOffset
		+ u * ((SHELL_H - WALL_T) * 0.5 - (SHELL_H * 0.5 - spec.height * 0.5) + 0.12)
		+ inw * (SHELL_D * 0.5 + FRONT_MARGIN)
	local roof = ensure(root, "GD_Roof", Vector3.new(SHELL_W, WALL_T, SHELL_D), basis(roofCenter), PROPS_SOLID)

	-- Single continuous floor INSIDE the shell (door plane → inner face of back wall)
	-- Back inner face lies at: door plane moved inward by (SHELL_D - WALL_T + FRONT_MARGIN)
	local floorDepth = SHELL_D - WALL_T + FRONT_MARGIN
	local floorCenter = center + u * (0.1 - spec.height * 0.5) + inw * (floorDepth * 0.5)
	ensure(root, "GD_FloorUnified", Vector3.new(SHELL_W, 0.2, math.max(0.1, floorDepth)),
	    basis(floorCenter),
	    { Material = Enum.Material.SmoothPlastic, Color = COLOR_FLOOR, Transparency = 0 })
	-- Cache floor top Y for downstream placement
	root:SetAttribute("floorTopY", floorCenter.Y + 0.1)

	local FBACK = 0.08
	local JTHK, LTHK, FDEP = 0.12, 0.12, 0.35
	ensure(root, "GD_FrameJambL", Vector3.new(JTHK, spec.height + 0.05, FDEP), basis(center + r * (-spec.width * 0.5 + JTHK * 0.5 + 0.02) + inw * FBACK), { Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false })
	ensure(root, "GD_FrameJambR", Vector3.new(JTHK, spec.height + 0.05, FDEP), basis(center + r * (spec.width * 0.5 - JTHK * 0.5 - 0.02) + inw * FBACK), { Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false })
	ensure(root, "GD_FrameLintel", Vector3.new(spec.width + 0.05, LTHK, FDEP), basis(center + u * (spec.height * 0.5 + 0.02) + inw * FBACK), { Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false })

	-- Front header cap just behind the door plane (visual fascia)
	ensure(root, "GD_FrontHeader", Vector3.new(spec.width + 0.8, 0.4, 0.6),
		basis(center + u * (spec.height * 0.5 + 0.25) + inw * 0.10),
		{ Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false }
	)

	-- Front spandrels (solid façade around the doorway). These sit just behind the plane and do NOT collide.
	local SP_DEPTH = 0.22
	-- Remove micro-gaps around the doorway to eliminate thin light seams
	local gap = 0.0
	local SIDE_OVERLAP = 0.1 -- full wrap under side walls to kill any remaining light seam
	local leftSpandrelW  = math.max(0, (SHELL_W - spec.width) * 0.5 - gap)
	local rightSpandrelW = leftSpandrelW
	-- Left spandrel
	ensure(root, "GD_FrontSpandrelL", Vector3.new(math.max(0.01, leftSpandrelW), spec.height, SP_DEPTH),
		basis(center + r * (-(spec.width * 0.5 + leftSpandrelW * 0.5 + gap + SIDE_OVERLAP * 0.5)) + inw * (FBACK)),
		{Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false}
	)
	-- Right spandrel
	ensure(root, "GD_FrontSpandrelR", Vector3.new(math.max(0.01, rightSpandrelW), spec.height, SP_DEPTH),
		basis(center + r * ( (spec.width * 0.5 + rightSpandrelW * 0.5 + gap + SIDE_OVERLAP * 0.5)) + inw * (FBACK)),
		{Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false}
	)
	-- Head spandrel (above the door)
	ensure(root, "GD_FrontSpandrelHead", Vector3.new(spec.width, 0.16, SP_DEPTH),
		basis(center + u * (spec.height * 0.5 - 0.08) + inw * (FBACK)),
		{Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false}
	)

	-- Nudge helper: shift a named part so its center is exactly at targetDist from the door plane (along forward)
	local function nudgeToPlane(partName: string, targetDist: number)
		local inst = root:FindFirstChild(partName, true)
		if not (inst and inst:IsA("BasePart")) then return end
		local p = inst :: BasePart
		local v = p.Position - center
		-- signed distance along forward (positive means in front of plane)
		local signed = v.X * out.X + v.Z * out.Z
		local delta = targetDist - math.abs(signed)
		if math.abs(delta) < 1e-4 then return end -- already close enough
		if signed >= 0 then
			p.CFrame = p.CFrame + out * delta
		else
			p.CFrame = p.CFrame - out * delta
		end
	end
	-- Nudge by FRONT FACE: compute target center distance from current depth so the front face is `inset` inside the plane
	local function nudgeFrontFaceToPlane(partName: string, inset: number)
		local inst = root:FindFirstChild(partName, true)
		if not (inst and inst:IsA("BasePart")) then return end
		local p = inst :: BasePart
		local depth = p.Size.Z -- in our basis, Z is aligned with forward
		local targetCenterDist = math.max(0, (depth * 0.5) - inset)
		nudgeToPlane(partName, targetCenterDist)
	end
	-- Pin façade a hair inside the plane to avoid z-fighting (front face sits 0.010 inside)
	nudgeFrontFaceToPlane("GD_FrontSpandrelL", 0.010)
	nudgeFrontFaceToPlane("GD_FrontSpandrelR", 0.010)
	nudgeFrontFaceToPlane("GD_FrontSpandrelHead", 0.010)
	nudgeFrontFaceToPlane("GD_FrontHeader", 0.010)

	-- Corner + header trim caps (visual only) to eliminate any remaining lighting seam at façade joints
	local TRIM_DEPTH   = SP_DEPTH + 0.02
	local TRIM_WIDTH   = 0.06
	local TRIM_HEADER_H= 0.10
	-- Left corner trim (wraps over seam between left spandrel and left wall)
	ensure(root, "GD_CornerTrimL",
		Vector3.new(TRIM_WIDTH, spec.height, TRIM_DEPTH),
		basis(center + r * (-(spec.width * 0.5 + leftSpandrelW + TRIM_WIDTH * 0.5)) + inw * FBACK),
		{ Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false }
	)
	-- Right corner trim
	ensure(root, "GD_CornerTrimR",
		Vector3.new(TRIM_WIDTH, spec.height, TRIM_DEPTH),
		basis(center + r * ( (spec.width * 0.5 + rightSpandrelW + TRIM_WIDTH * 0.5)) + inw * FBACK),
		{ Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false }
	)
	-- Header trim (thin fascia cap across the top seam)
	ensure(root, "GD_HeaderTrim",
		Vector3.new(spec.width + leftSpandrelW + rightSpandrelW + 0.12, TRIM_HEADER_H, TRIM_DEPTH),
		basis(center + u * (spec.height * 0.5 + TRIM_HEADER_H * 0.5) + inw * FBACK),
		{ Material = Enum.Material.SmoothPlastic, Color = COLOR_METAL, CanCollide = false }
	)
	-- Keep trim faces at the same depth as spandrels (already at FBACK)

	local frontWallRef = GarageFolder:FindFirstChild("FrontWallRef") :: ObjectValue?
	if not frontWallRef then
		frontWallRef = Instance.new("ObjectValue")
		frontWallRef.Name = "FrontWallRef"
		frontWallRef.Parent = GarageFolder
	end
	frontWallRef.Value = findFrontWallCandidate(root)

	-- Door baseline depth: sit clearly behind the front spandrels to avoid z-fighting
	local DOOR_BEHIND = (FBACK + 0.02) + SP_DEPTH + 0.04  -- spandrel front back + its depth + margin

	-- Bi-parting doors: two panels meet in the middle and slide into the walls
	local panelInset = 0.05
	local halfW      = spec.width * 0.5
	-- How far a panel can slide safely: just into the wall pocket minus a small margin
	local pocketMax  = math.max(0, (SHELL_W - spec.width) * 0.5 - 0.05)
	-- Limit how wide panels open as a fraction of the doorway width
	local openFrac   = 0.70  -- 70% of half-width feels good; adjust 0.60–0.80 to taste
	local slideDist  = math.min(pocketMax, halfW * openFrac)

	local panelH     = spec.height * 0.95
	local panelW     = halfW
	local leftPanel  = ensure(root, "GD_DoorL", Vector3.new(panelW, panelH, 0.30),
		basis(center + r * (-panelW * 0.5) + inw * (DOOR_BEHIND + 0.02)),
		{ Material = Enum.Material.Metal, Color = Color3.fromRGB(200,210,225), CanCollide = true }
	)
	local rightPanel = ensure(root, "GD_DoorR", Vector3.new(panelW, panelH, 0.30),
		basis(center + r * ( panelW * 0.5) + inw * (DOOR_BEHIND + 0.02)),
		{ Material = Enum.Material.Metal, Color = Color3.fromRGB(200,210,225), CanCollide = true }
	)
	-- Publish DoorCenter / DoorFacing and initialize model door state
	root:SetAttribute("DoorCenter", center)
	root:SetAttribute("DoorFacing", out)
	GarageFolder:SetAttribute("DoorCenter", center)
	GarageFolder:SetAttribute("DoorFacing", out)
	if root:GetAttribute("DoorIsOpen") == nil then
		root:SetAttribute("DoorIsOpen", false)
	end
	if spec.ownerUserId ~= nil then
		root:SetAttribute("OwnerUserId", spec.ownerUserId)
	end

	local basisForFixup = {
		doorCenter = center,
		forward = out,
		right = r,
	}
	if GarageFolder:GetAttribute("FORCE_FIXUP") == true then
		Fixup.run(root, GarageFolder, basisForFixup)
	end

	local pivot = ensure(root, "DoorPivot", Vector3.new(0.2, 0.2, 0.2), basis(center), {
		Transparency = 1,
		CanCollide = false,
	})
	root.PrimaryPart = pivot
	print(("[GarageV1] DoorCenter=%s DoorFacing=%s"):format(tostring(center), tostring(out)))

	local function frontZ(p: BasePart) return p.CFrame.Position.Z + p.Size.Z*0.5 end
	local spZ = frontZ(root:FindFirstChild("GD_FrontSpandrelL") :: BasePart)
	local dlZ = frontZ(leftPanel)
	print(string.format("[GarageV1] depth check spandrelZ=%.3f doorLZ=%.3f planeZ=%.3f", spZ, dlZ, planeZ))

	-- Panel target frames for bi-parting doors (0 closed, 1 open)
	local function leftCF(t: number): CFrame
		-- slide negative right (into left wall) at a fixed depth behind the façade
		return basis(center + r * (-panelW * 0.5 - slideDist * t) + inw * (DOOR_BEHIND + 0.02))
	end
	local function rightCF(t: number): CFrame
		-- slide positive right (into right wall) at the same fixed depth
		return basis(center + r * ( panelW * 0.5 +  slideDist * t) + inw * (DOOR_BEHIND + 0.02))
	end

	leftPanel:SetAttribute("ClosedCF", leftCF(0))
	leftPanel:SetAttribute("OpenCF", leftCF(1))
	rightPanel:SetAttribute("ClosedCF", rightCF(0))
	rightPanel:SetAttribute("OpenCF", rightCF(1))

	local doorCenterCached: Vector3? = center
	local lastDoorOpen = root:GetAttribute("DoorIsOpen") == true
	local accum = 0

	local function ensureDoorCenter(): Vector3?
		if doorCenterCached then
			return doorCenterCached
		end
		local attr = root:GetAttribute("DoorCenter")
		if typeof(attr) == "Vector3" then
			doorCenterCached = attr
			GarageFolder:SetAttribute("DoorCenter", attr)
			return attr
		end
		local derived = (leftPanel.Position + rightPanel.Position) * 0.5
		root:SetAttribute("DoorCenter", derived)
		GarageFolder:SetAttribute("DoorCenter", derived)
		doorCenterCached = derived
		return derived
	end

	local function getDoorBasis(): (Vector3?, Vector3?, Vector3?)
		local centerVal = ensureDoorCenter()
		if not centerVal then
			return nil, nil, nil
		end
		local facingAttr = root:GetAttribute("DoorFacing")
		local forwardVec = (typeof(facingAttr) == "Vector3" and facingAttr or out)
		forwardVec = Vector3.new(forwardVec.X, 0, forwardVec.Z)
		if forwardVec.Magnitude < 1e-3 then
			forwardVec = Vector3.new(out.X, 0, out.Z)
		end
		if forwardVec.Magnitude < 1e-3 then
			forwardVec = Vector3.new(0, 0, -1)
		end
		forwardVec = forwardVec.Unit
		local rightVec = Vector3.new(-forwardVec.Z, 0, forwardVec.X)
		if rightVec.Magnitude < 1e-3 then
			rightVec = Vector3.new(r.X, 0, r.Z)
		end
		if rightVec.Magnitude < 1e-3 then
			rightVec = Vector3.new(1, 0, 0)
		end
		rightVec = rightVec.Unit
		local basisCenter = centerVal
		GarageFolder:SetAttribute("DoorFacing", Vector3.new(forwardVec.X, 0, forwardVec.Z))
		return basisCenter, forwardVec, rightVec
	end

	local bindable = root:FindFirstChild("GetDoorBasis") :: BindableFunction?
	if not bindable then
		bindable = Instance.new("BindableFunction")
		bindable.Name = "GetDoorBasis"
		bindable.Parent = root
	end
	bindable.OnInvoke = function()
		return getDoorBasis()
	end

	local function applyDoor(opening: boolean)
		leftPanel:SetAttribute("IsOpen", opening)
		rightPanel:SetAttribute("IsOpen", opening)
		AnimateDoor(root, opening)
		lastDoorOpen = opening
		if RunService:IsStudio() and (root:GetAttribute("DEV_TRACE") == true) then
			print(("[Garage/Component] DoorIsOpen → %s"):format(opening and "OPEN" or "CLOSED"))
		end
	end

	local function ensureOwner(): number?
		local ownerAttr = root:GetAttribute("OwnerUserId")
		if typeof(ownerAttr) == "number" then
			return ownerAttr
		end
		if RunService:IsStudio() then
			local first = Players:GetPlayers()[1]
			if first then
				root:SetAttribute("OwnerUserId", first.UserId)
				return first.UserId
			end
		end
		return nil
	end

	-- Single source of truth: model-level DoorIsOpen drives animation
	root:GetAttributeChangedSignal("DoorIsOpen"):Connect(function()
		applyDoor(root:GetAttribute("DoorIsOpen") == true)
	end)

	-- Keep compatibility for legacy panel listeners
	leftPanel:GetAttributeChangedSignal("IsOpen"):Connect(function()
		local opening = (leftPanel:GetAttribute("IsOpen") == true)
		if root:GetAttribute("DoorIsOpen") ~= opening then
			root:SetAttribute("DoorIsOpen", opening)
		end
	end)

	applyDoor(root:GetAttribute("DoorIsOpen") == true)

	RunService.Heartbeat:Connect(function(dt)
		accum += dt
		if accum < CHECK_INTERVAL then
			return
		end
		accum = 0

		local ownerId = ensureOwner()
		if not ownerId then
			if lastDoorOpen then
				root:SetAttribute("DoorIsOpen", false)
			end
			return
		end

		local doorCenterResolved = ensureDoorCenter()
		if not doorCenterResolved then
			return
		end

		local owner = Players:GetPlayerByUserId(ownerId)
		local rootPart = owner and owner.Character and owner.Character.PrimaryPart
		if not rootPart then
			if lastDoorOpen then
				root:SetAttribute("DoorIsOpen", false)
			end
			return
		end

		local pos = rootPart.Position
		local dx = pos.X - doorCenterResolved.X
		local dz = pos.Z - doorCenterResolved.Z
		local dist = math.sqrt(dx * dx + dz * dz)
		if (not lastDoorOpen and dist <= OPEN_RADIUS) then
			root:SetAttribute("DoorIsOpen", true)
		elseif (lastDoorOpen and dist >= CLOSE_RADIUS) then
			root:SetAttribute("DoorIsOpen", false)
		end
	end)

	local handle = ensure(root, "GD_Handle", Vector3.new(0.5, 1.2, 0.5), basis(center - out * 2), { CanCollide = false, Transparency = 1 })
	-- Remove any legacy prompts under the handle
	for _, d in ipairs(handle:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			d:Destroy()
		end
	end

	local function frontZ(part: BasePart)
		return part.CFrame.Position.Z + part.Size.Z * 0.5
	end
	print(("[GarageV1] frontZ: back=%.3f left=%.3f right=%.3f roof=%.3f planeZ=%.3f")
		:format(frontZ(back), frontZ(leftPart), frontZ(rightPart), frontZ(roof), planeZ))

	-- === Diagnostics: precise distances to door plane (no geometry changes) ===
	local DoorPlane = require(script.Parent.Parent.Parent.Modules.DoorPlane)
	local planeDiag = DoorPlane.from(center, out)
	local function d(pt: Vector3): number
		return planeDiag.distance(pt)
	end
	local function partPos(name: string): Vector3?
		local inst = root:FindFirstChild(name, true)
		if inst and inst:IsA("BasePart") then return (inst :: BasePart).Position end
		return nil
	end
	local report = {}
	local labels = {
		"GD_FrontSpandrelL",
		"GD_FrontSpandrelR",
		"GD_FrontSpandrelHead",
		"GD_FloorUnified",
	}
	for _, label in ipairs(labels) do
		local p = partPos(label)
		if p then table.insert(report, string.format("%s=%.3f", label, d(p))) end
	end
	if RunService:IsStudio() then
		print("[GarageV1][plane-dist] " .. table.concat(report, "  "))
	end
	-- === end diagnostics ===

	-- Mount interior placeholders (hatch, repair, core, console, lockers)
	local okInterior, Interior = pcall(function()
		return require(script.Parent.Interior)
	end)
	local function basis(pos: Vector3)
		return CFrame.fromMatrix(pos, r, u, out)
	end
	if okInterior and type(Interior) == "table" and type(Interior.Mount) == "function" then
		Interior.Mount(root, {width = spec.width, height = spec.height, depth = spec.depth}, basis, center, r, u, inw, out)
	else
		if RunService:IsStudio() then
			warn("[Garage.Component] Interior.Mount not available; skipping interior placement")
		end
	end

	return function()
		if root and root.Parent then
			root:Destroy()
		end
	end
end

local ComponentModule = {}
if typeof(Garage.Mount) == 'function' then
	ComponentModule.Mount = Garage.Mount
else
	function ComponentModule.Mount(...)
		warn('[Garage.Component] Mount() not found; no-op export')
	end
end
return ComponentModule
