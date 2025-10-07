--!strict
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

export type Spec = { origin: Vector3, width: number, height: number, depth: number, facing: Vector3 }

function Garage.Mount(spec: Spec): () -> ()
	local root = Instance.new("Model")
	root.Name = "GD_Garage"
	root.Parent = workspace

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

	local COLOR_METAL = Color3.fromRGB(60, 70, 80)
	local COLOR_FLOOR = Color3.fromRGB(35, 38, 45)
	local PROPS_SOLID = { Material = Enum.Material.Metal, Color = COLOR_METAL, Transparency = 0 }

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

	local floorCenter = center + u * (0.1 - spec.height * 0.5) + inw * ((SHELL_D - GAP) * 0.5 + FRONT_MARGIN)
	ensure(root, "GD_FloorInterior", Vector3.new(SHELL_W, 0.2, math.max(0.1, SHELL_D - GAP)), basis(floorCenter), { Material = Enum.Material.Metal, Color = COLOR_FLOOR, Transparency = 0 })

	ensure(root, "GD_Threshold", Vector3.new(spec.width, 0.2, GAP), basis(center + u * (0.1 - spec.height * 0.5) + inw * (GAP * 0.5)), { CanCollide = false, Transparency = 1, Material = Enum.Material.SmoothPlastic })

	ensure(root, "GD_ApronOutside", Vector3.new(spec.width + 2, 0.2, 2), basis(center + u * (0.1 - spec.height * 0.5) + out * 1.0), { Material = Enum.Material.Metal, Color = COLOR_FLOOR })

	local FBACK = 0.08
	local JTHK, LTHK, FDEP = 0.12, 0.12, 0.35
	ensure(root, "GD_FrameJambL", Vector3.new(JTHK, spec.height + 0.05, FDEP), basis(center + r * (-spec.width * 0.5 + JTHK * 0.5 + 0.02) + inw * FBACK), { Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false })
	ensure(root, "GD_FrameJambR", Vector3.new(JTHK, spec.height + 0.05, FDEP), basis(center + r * (spec.width * 0.5 - JTHK * 0.5 - 0.02) + inw * FBACK), { Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false })
	ensure(root, "GD_FrameLintel", Vector3.new(spec.width + 0.05, LTHK, FDEP), basis(center + u * (spec.height * 0.5 + 0.02) + inw * FBACK), { Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false })

	-- Front header cap just behind the door plane (visual fascia)
	ensure(root, "GD_FrontHeader", Vector3.new(spec.width + 0.8, 0.4, 0.6),
		basis(center + u * (spec.height * 0.5 + 0.25) + inw * 0.10),
		{ Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = false }
	)

	-- Front spandrels (solid façade around the doorway). These sit just behind the plane and do NOT collide.
	local SP_DEPTH = 0.22
	local gap = 0.02  -- tiny visual gap around the door
	local leftSpandrelW  = (SHELL_W - spec.width) * 0.5 - gap
	local rightSpandrelW = leftSpandrelW
	if leftSpandrelW < 0 then leftSpandrelW = 0 end
	if rightSpandrelW < 0 then rightSpandrelW = 0 end
	-- Left spandrel
	ensure(root, "GD_FrontSpandrelL", Vector3.new(math.max(0.01, leftSpandrelW), spec.height, SP_DEPTH),
		basis(center + r * (-(spec.width * 0.5 + leftSpandrelW * 0.5 + gap)) + inw * (FBACK + 0.02)),
		{Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = true}
	)
	-- Right spandrel
	ensure(root, "GD_FrontSpandrelR", Vector3.new(math.max(0.01, rightSpandrelW), spec.height, SP_DEPTH),
		basis(center + r * ( (spec.width * 0.5 + rightSpandrelW * 0.5 + gap)) + inw * (FBACK + 0.02)),
		{Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = true}
	)
	-- Head spandrel (above the door)
	ensure(root, "GD_FrontSpandrelHead", Vector3.new(spec.width, 0.16, SP_DEPTH),
		basis(center + u * (spec.height * 0.5 - 0.08) + inw * (FBACK + 0.02)),
		{Material = Enum.Material.Metal, Color = COLOR_METAL, CanCollide = true}
	)

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

	local animConnL: RBXScriptConnection? = nil
	local animConnR: RBXScriptConnection? = nil
	local function animate(opening: boolean)
		if animConnL then animConnL:Disconnect(); animConnL=nil end
		if animConnR then animConnR:Disconnect(); animConnR=nil end
		local startT, endT = opening and 0 or 1, opening and 1 or 0
		local uL = Instance.new("NumberValue"); uL.Name = "uL"; uL.Value = startT; uL.Parent = leftPanel
		local uR = Instance.new("NumberValue"); uR.Name = "uR"; uR.Value = startT; uR.Parent = rightPanel
		if opening then leftPanel.CanCollide=false; rightPanel.CanCollide=false end
		animConnL = RunService.Heartbeat:Connect(function() leftPanel.CFrame  = leftCF(uL.Value)  end)
		animConnR = RunService.Heartbeat:Connect(function() rightPanel.CFrame = rightCF(uR.Value) end)
		local info = TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		TweenService:Create(uL, info, {Value=endT}):Play()
		TweenService:Create(uR, info, {Value=endT}):Play()
		task.delay(1.05, function()
			if animConnL then animConnL:Disconnect(); animConnL=nil end
			if animConnR then animConnR:Disconnect(); animConnR=nil end
			uL:Destroy(); uR:Destroy()
			leftPanel.CanCollide  = not opening
			rightPanel.CanCollide = not opening
		end)
	end

	local handle = ensure(root, "GD_Handle", Vector3.new(0.5, 1.2, 0.5), basis(center - out * 2), { CanCollide = false, Transparency = 1 })
	for _, d in ipairs(handle:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			d:Destroy()
		end
	end
	local pp = Instance.new("ProximityPrompt")
	pp.ObjectText = "Garage Access"
	pp.ActionText = "Toggle Door"
	pp.KeyboardKeyCode = Enum.KeyCode.F
	pp.HoldDuration = 0
	pp.MaxActivationDistance = 18
	pp.RequiresLineOfSight = false
	pp.Parent = handle
	pp.Triggered:Connect(function()
		local opening = (leftPanel:GetAttribute("IsOpen") ~= true)
		leftPanel:SetAttribute("IsOpen", opening)
		rightPanel:SetAttribute("IsOpen", opening)
		animate(opening)
	end)

	local function frontZ(part: BasePart)
		return part.CFrame.Position.Z + part.Size.Z * 0.5
	end
	print(("[GarageV1] frontZ: back=%.3f left=%.3f right=%.3f roof=%.3f planeZ=%.3f")
		:format(frontZ(back), frontZ(leftPart), frontZ(rightPart), frontZ(roof), planeZ))

	return function()
		if root and root.Parent then
			root:Destroy()
		end
	end
end

return Garage
