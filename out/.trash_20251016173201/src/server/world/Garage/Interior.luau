--!strict
print("[Interior] VERSION v2", os.time())
local RunService = game:GetService("RunService")

local Interior = {}

-- Mount signature matches Component's call pattern:
-- Interior.Mount(rootModel, spec, basisFn, center, r, u, inw, out)
function Interior.Mount(root: Instance, _spec, _basisFn, _center, _r, _u, _inw, _out)
	-- Prefer the provided root if it's a Model (fresh build path)
	local model: Model? = nil
	if root and root:IsA("Model") then
		model = root
	end

	-- Fallback to ModelRef under the Garage folder (existing/rehydrate path)
	if not model then
		local folder = script.Parent -- ServerScriptService/World/Garage
		local modelRef = folder:FindFirstChild("ModelRef")
		if not modelRef then
			modelRef = folder:FindFirstChildWhichIsA("ObjectValue")
		end
		if modelRef and modelRef:IsA("ObjectValue") then
			local v = (modelRef :: any).Value
			if v and typeof(v) == "Instance" and (v :: Instance):IsA("Model") then
				model = v
			end
		end
	end

	if not model then
		if RunService:IsStudio() then
			warn("[Garage.Interior] No model to operate on; skipping Interior.Mount")
		end
		return
	end

	-- Resolve basis from attributes on the live model or its folder
	local folder = script.Parent
	local dcAttr = model:GetAttribute("DoorCenter") or folder:GetAttribute("DoorCenter")
	local dfAttr = model:GetAttribute("DoorFacing") or folder:GetAttribute("DoorFacing")

	local doorCenter: Vector3
	if typeof(dcAttr) == "Vector3" then
		doorCenter = dcAttr
	else
		doorCenter = model:GetPivot().Position
	end

	local forwardRaw: Vector3
	if typeof(dfAttr) == "Vector3" then
		forwardRaw = dfAttr
	else
		forwardRaw = model:GetPivot().LookVector
	end

	-- Clamp forward to XZ so downstream math never inherits Y-tilt
	local forward = Vector3.new(forwardRaw.X, 0, forwardRaw.Z)
	if forward.Magnitude < 1e-3 then
		forward = Vector3.new(0, 0, 1)
	else
		forward = forward.Unit
	end
	local right = Vector3.new(-forward.Z, 0, forward.X)

	-- Delegate to Fixup if present (safe require)
	local ok, Fixup = pcall(function()
		return require(folder:FindFirstChild("Fixup"))
	end)
	if ok and type(Fixup) == "table" and type(Fixup.run) == "function" then
		Fixup.run(model, folder, { doorCenter = doorCenter, forward = forward, right = right })
	else
		if RunService:IsStudio() then
			warn("[Garage.Interior] Fixup not available; Interior did nothing")
		end
	end

	-- === Canonical interior items (independent of Fixup) ===
	local function ensurePart(parent: Instance, name: string, size: Vector3, cf: CFrame, props: {[string]: any}?): BasePart
		local p = parent:FindFirstChild(name, true)
		if not (p and p:IsA("BasePart")) then
			p = Instance.new("Part")
			p.Name = name
			p.Parent = parent
		end
		local bp = p :: BasePart
		bp.Anchored = true
		bp.Size = size
		bp.CFrame = cf
		if props then
			for k, v in pairs(props) do
				(bp :: any)[k] = v
			end
		end
		return bp
	end

	-- Derive base Y from floorTopY when available; otherwise pick highest floor top
	local baseY = model:GetAttribute("floorTopY")
	if typeof(baseY) ~= "number" then
		local maxTop = doorCenter.Y
		for _, inst in ipairs(model:GetDescendants()) do
			if inst:IsA("BasePart") and inst.Name:lower():find("floor") then
				local top = inst.Position.Y + inst.Size.Y * 0.5
				if top > maxTop then maxTop = top end
			end
		end
		baseY = maxTop
	end

	-- Helper to place by offsets (right/forward), with optional y offset
	local function place(name: string, size: Vector3, offR: number, offF: number, yOff: number?, props: {[string]: any}?)
		local pos = doorCenter + right * offR + forward * offF
		local y = (yOff and (baseY + yOff)) or baseY
		return ensurePart(model, name, size, CFrame.new(Vector3.new(pos.X, y, pos.Z)), props)
	end

	-- Visual presets
	local MAT = Enum.Material.SmoothPlastic

	-- Compute interior anchors from the unified floor extents (robust, independent of wall names)
	local floorPart  = model:FindFirstChild("GD_FloorUnified", true)
	local floorCF: CFrame
	local floorW: number
	local floorD: number
	if floorPart and floorPart:IsA("BasePart") then
	    local fp = floorPart :: BasePart
	    floorCF = fp.CFrame
	    floorW  = fp.Size.X
	    floorD  = fp.Size.Z
	else
	    -- Fallback: approximate using door basis
	    floorCF = CFrame.new(doorCenter)
	    floorW  = 12
	    floorD  = 12
	end

	-- Prefer true wall inner faces for anchors (safer than floor-only placement)
	local leftWall   = model:FindFirstChild("GD_Left",  true)
	local rightWall  = model:FindFirstChild("GD_Right", true)
	local backWall   = model:FindFirstChild("GD_Back",  true)

	-- Base center of the floor
	local fCenter = floorCF.Position

	-- Compute inner face points
	local function innerFace(wall: Instance?, normal: Vector3): Vector3?
	    if not (wall and wall:IsA("BasePart")) then return nil end
	    local w = wall :: BasePart
	    -- distance along the given normal to reach the inner face from center
	    local half = (math.abs(normal:Dot(right)) > 0.5) and (w.Size.X * 0.5) or (w.Size.Z * 0.5)
	    return w.Position + normal.Unit * half
	end

	local leftInner  = innerFace(leftWall,   right)     -- left wall faces +right
	local rightInner = innerFace(rightWall, -right)     -- right wall faces -right
	local backInner  = innerFace(backWall,   forward)   -- back wall faces +forward (toward door)

	-- Fallbacks from floor if any wall missing
	local leftEdge   = leftInner  or (fCenter - right * (floorW * 0.5))
	local rightEdge  = rightInner or (fCenter + right * (floorW * 0.5))
	local backEdge   = backInner  or (fCenter - forward * (floorD * 0.5))

	-- Safety margins inside the room
	local M_SIDE  = 0.6
	local M_BACK  = 2.0
	local MID_Z   = math.max(2.0, floorD * 0.55) -- mid/back depth in-room

	-- Final target positions (guaranteed inside using wall faces)
	-- Inset amounts account for each item's half-width plus side margin so nothing protrudes
	local LOCKER_HALF = 1.2 * 0.5   -- lockers size.X half
	local insetLockers = LOCKER_HALF + M_SIDE  -- 0.6 + 0.6 = 1.2
	local consolePos = backEdge  + forward * M_BACK                      -- centered near real back wall
	local hatchPos   = fCenter                                           -- dead center of the floor
	local lockersPos = rightEdge + (-right) * insetLockers + forward * M_BACK

	-- Build a multi-part console: wide desk + screen + keyboard + buttons
	local function basisCF(pos: Vector3)
		-- Construct a CFrame from right/up/forward at a world position
		local up = Vector3.new(0,1,0)
		return CFrame.fromMatrix(pos, right, up, forward)
	end

	local function buildConsole(rootModel: Model, pos: Vector3)
		local grp = rootModel:FindFirstChild("GD_Console")
		if not grp then
			grp = Instance.new("Model")
			grp.Name = "GD_Console"
			grp.Parent = rootModel
		end

		-- Dimensions
		local W  = 8.0   -- total width
		local D  = 3.0   -- desk depth
		local H  = 3.0   -- overall height to top shelf
		local t  = 0.2   -- panel thickness

		-- Colors
		local COL_FRAME  = Color3.fromRGB(68, 76, 85)
		local COL_TOP    = Color3.fromRGB(90, 98, 108)
		local COL_SCREEN = Color3.fromRGB(20, 24, 30)
		local COL_KEY    = Color3.fromRGB(180, 185, 195)
		local COL_BTN_R  = Color3.fromRGB(220, 70, 70)
		local COL_BTN_G  = Color3.fromRGB(70, 200, 120)
		local COL_BTN_B  = Color3.fromRGB(70, 140, 220)

		-- Utility to make a named child under the console model
		local function part(name: string, size: Vector3, cf: CFrame, props: {[string]: any}?)
			local p = grp:FindFirstChild(name)
			if not (p and p:IsA("BasePart")) then
				p = Instance.new("Part")
				p.Name = name
				p.Parent = grp
			end
			local bp = p :: BasePart
			bp.Anchored = true
			bp.Size = size
			bp.CFrame = cf
			bp.Material = Enum.Material.SmoothPlastic
			bp.CanCollide = false
			if props then
				for k,v in pairs(props) do (bp :: any)[k] = v end
			end
			return bp
		end

		-- Desk top slab
		local topPos = pos + Vector3.new(0, 1.0, 0)
		local topCF  = basisCF(topPos)
		local top    = part("Top", Vector3.new(W, t, D), topCF, {Color = COL_TOP})

		-- Side supports (left/right)
		local legH = 1.0
		local legW = 0.4
		local legD = D
		local legOffsetX = (W * 0.5 - legW * 0.5)
		part("LegL", Vector3.new(legW, legH, legD), basisCF(pos + right * (-legOffsetX) + Vector3.new(0, legH * 0.5, 0)), {Color = COL_FRAME})
		part("LegR", Vector3.new(legW, legH, legD), basisCF(pos + right * ( legOffsetX) + Vector3.new(0, legH * 0.5, 0)), {Color = COL_FRAME})

		-- Keyboard deck (slightly below top, in front)
		local kbDepth = 1.2
		local kbPos = topPos + forward * (-(D*0.5 - kbDepth*0.5) + 0.1) + Vector3.new(0, -0.25, 0)
		local kb    = part("Keyboard", Vector3.new(W*0.65, t, kbDepth), basisCF(kbPos), {Color = COL_FRAME})

		-- Simple key row blocks (3 rows)
		local keyRows = 3
		local keyCols = 10
		local keySize = Vector3.new(0.35, 0.1, 0.35)
		local startX = -((keyCols-1) * 0.4) * 0.5
		for r=1,keyRows do
			for c=1,keyCols do
				local kx = startX + (c-1)*0.4
				local kz = -0.2 + (r-1)*0.25
				part(string.format("Key_%d_%d", r, c), keySize, basisCF(kbPos + right * kx + forward * kz + Vector3.new(0, 0.06, 0)), {Color = COL_KEY})
			end
		end

		-- Button strip (3 colored buttons)
		local btnY = 0.08
		part("BtnR", Vector3.new(0.35, 0.12, 0.35), basisCF(kbPos + right * ( W*0.3) + Vector3.new(0, btnY, 0)), {Color = COL_BTN_R})
		part("BtnG", Vector3.new(0.35, 0.12, 0.35), basisCF(kbPos + right * ( W*0.35) + Vector3.new(0, btnY, 0)), {Color = COL_BTN_G})
		part("BtnB", Vector3.new(0.35, 0.12, 0.35), basisCF(kbPos + right * ( W*0.40) + Vector3.new(0, btnY, 0)), {Color = COL_BTN_B})

		-- Screen panel with slight tilt back
		local screenW = W*0.65
		local screenH = 2.2
		local screenT = 0.2
		local screenPos = topPos + forward * (-D*0.25) + Vector3.new(0, screenH*0.5 + 0.2, 0)
		local tilt = CFrame.Angles(math.rad(-15), 0, 0)
		local screenCF = basisCF(screenPos) * tilt
		local screen = part("Screen", Vector3.new(screenW, screenH, screenT), screenCF, {Color = COL_SCREEN})

		-- Add a subtle light glow from the screen
		local light = screen:FindFirstChildOfClass("PointLight")
		if not light then
			light = Instance.new("PointLight")
			light.Range = 10
			light.Brightness = 1.5
			light.Parent = screen
		end
		light.Color = Color3.fromRGB(120,170,255)

		return grp, screen
	end

	local consoleModel, consoleScreen = buildConsole(model, Vector3.new(consolePos.X, baseY, consolePos.Z))
	local hatch   = ensurePart(model, "HatchPad",   Vector3.new(3.0, 0.2, 3.0), CFrame.new(Vector3.new(hatchPos.X,   baseY + 0.1, hatchPos.Z)), {Material = MAT, Color = Color3.fromRGB(255,205,80)})
	-- Build a bank of lockers along the right wall: 8 units, spanning ~half the floor length from the back
	local function buildLockersBank(rootModel: Model, startPos: Vector3)
		local grp = rootModel:FindFirstChild("GD_Lockers")
		if not grp then
			grp = Instance.new("Model")
			grp.Name = "GD_Lockers"
			grp.Parent = rootModel
		end

		local function part(name: string, size: Vector3, cf: CFrame, color: Color3)
			local p = grp:FindFirstChild(name)
			if not (p and p:IsA("BasePart")) then
				p = Instance.new("Part")
				p.Name = name
				p.Parent = grp
			end
			local bp = p :: BasePart
			bp.Anchored = true
			bp.CanCollide = false
			bp.Size = size
			bp.CFrame = cf
			bp.Material = Enum.Material.SmoothPlastic
			bp.Color = color
			return bp
		end

		-- Locker dimensions (studs)
		local UNIT_LEN = 1.2   -- along forward (length of each locker)
		local UNIT_DEP = 0.6   -- into room (perpendicular from wall)
		local UNIT_HGT = 5.0
		local UNITS    = 8     -- 8 lockers spanning ~half wall length

		-- Move bank closer to back wall
		local START_BACK_OFFSET = 0.0  -- start flush with back wall

		local COL_BODY  = Color3.fromRGB(70, 90, 110)
		local COL_DOOR  = Color3.fromRGB(85, 105, 125)
		local COL_TRIM  = Color3.fromRGB(60, 75, 95)
		local COL_VENT  = Color3.fromRGB(55, 65, 80)
		local COL_HANDLE= Color3.fromRGB(200, 205, 210)

		-- Place bank starting from back wall going forward along the right wall, inset by side margin
		for i = 1, UNITS do
			local ofsF = (i-0.5) * UNIT_LEN + START_BACK_OFFSET
			local basePos = startPos + forward * ofsF + (-right) * (UNIT_DEP * 0.5)
			local cf = CFrame.fromMatrix(basePos, right, Vector3.new(0,1,0), forward)

			-- Cabinet body
			part(string.format("LockerBody_%02d", i), Vector3.new(UNIT_DEP, UNIT_HGT, UNIT_LEN), cf, COL_BODY)

			-- Two-door split per locker
			for d = 1, 2 do
				local doorH = (UNIT_HGT - 0.2) * 0.5
				local yOffset = (d == 1) and (doorH * 0.5 + 0.05) or (-doorH * 0.5 - 0.05)
				local doorPos = basePos + (-right) * (UNIT_DEP * 0.5 - 0.03) + Vector3.new(0, yOffset, 0)
				part(string.format("LockerDoor_%02d_%d", i, d), Vector3.new(0.1, doorH, UNIT_LEN - 0.05), CFrame.fromMatrix(doorPos, right, Vector3.new(0,1,0), forward), COL_DOOR)

				-- Vent slots (3 horizontal vents per door)
				for v = 1, 3 do
					local ventY = (d == 1) and (yOffset + 0.3 * v) or (yOffset - 0.3 * v)
					local ventPos = doorPos + forward * (UNIT_LEN * 0.3) + Vector3.new(0, ventY * 0.1, 0)
					part(string.format("LockerVent_%02d_%d_%d", i, d, v), Vector3.new(0.02, 0.05, UNIT_LEN * 0.4), CFrame.fromMatrix(ventPos, right, Vector3.new(0,1,0), forward), COL_VENT)
				end

				-- Handle for each door
				local handlePos = doorPos + Vector3.new(0, 0, 0)
				part(string.format("LockerHandle_%02d_%d", i, d), Vector3.new(0.05, 0.5, 0.05), CFrame.fromMatrix(handlePos + forward * 0.45, right, Vector3.new(0,1,0), forward), COL_HANDLE)
			end
		end

		-- End cap at the very back to finish the bank
		local capPos = startPos + forward * (START_BACK_OFFSET * 0.5)
		part("LockerEndCap_Back", Vector3.new(0.08, UNIT_HGT, 0.2), CFrame.fromMatrix(capPos, right, Vector3.new(0,1,0), forward), COL_TRIM)

		return grp
	end

	-- Start at back-right inner corner (right wall X, back wall Z), inset by side margin
	local lockersStart = Vector3.new(rightEdge.X, baseY + 2.5, backEdge.Z) + (-right) * M_SIDE
	local lockersModel = buildLockersBank(model, lockersStart)

	-- === Robot Spawn Pad: elevated circular pad + ramp to doors + ceiling laser ===
local function buildSpawnPad(rootModel: Model, centerPos: Vector3)
    if script:GetAttribute("DISABLE_CYLINDER_PADS") then return end
		local grp = rootModel:FindFirstChild("GD_SpawnPad")
		if not grp then
			grp = Instance.new("Model")
			grp.Name = "GD_SpawnPad"
			grp.Parent = rootModel
		end

		local function addPart(name: string, className: string): BasePart
			local p = grp:FindFirstChild(name)
			if not (p and p:IsA("BasePart")) then
				local newInst = Instance.new(className)
				newInst.Name = name
				newInst.Parent = grp
				p = newInst
			end
			local bp = p :: BasePart
			bp.Anchored = true
			bp.Material = Enum.Material.SmoothPlastic
			bp.CanCollide = false
			return bp
		end

		-- Dimensions
		local PAD_R   = 3.0   -- radius
		local PAD_H   = 0.4   -- thickness
		local ELEV    = 0.6   -- raise pad above floor
		local RAMP_L  = 4.0   -- ramp length toward door
		local RAMP_W  = PAD_R * 1.6

		-- Pad (Cylinder) — vertical orientation
		local pad = addPart("Pad", "Part")
		pad.Shape = Enum.PartType.Cylinder
		pad.Size  = Vector3.new(PAD_H, PAD_R*2, PAD_R*2) -- X is cylinder axis; rotate to stand up
		pad.Color = Color3.fromRGB(90, 98, 108)
		-- Stand the cylinder upright (axis Y) by rotating 90° around Z
		local padCF = basisCF(Vector3.new(centerPos.X, baseY + ELEV + PAD_H*0.5, centerPos.Z)) * CFrame.Angles(0, 0, math.rad(90))
		pad.CFrame = padCF
		pad.CanCollide = true

		-- Accent glow: top & bottom rings just outside pad radius + rim glow
		local RING_RAD = PAD_R * 2.15  -- slightly larger than pad so it shows all around
		local function makeRing(name: string, yOffset: number)
			local r = addPart(name, "Part")
			r.Shape = Enum.PartType.Cylinder
			r.Size  = Vector3.new(0.06, RING_RAD, RING_RAD)
			r.Color = Color3.fromRGB(120,170,255)
			r.Material = Enum.Material.Neon
			r.CFrame = padCF * CFrame.new(0, yOffset, 0)
			return r
		end
		local ringTop    = makeRing("RingTop",    PAD_H * 0.55)
		local ringBottom = makeRing("RingBottom", -PAD_H * 0.55)
		-- Thin rim glow exactly at the pad edge
		local rim = addPart("RimGlow", "Part")
		rim.Shape = Enum.PartType.Cylinder
		rim.Size  = Vector3.new(0.02, PAD_R*2.02, PAD_R*2.02)
		rim.Color = Color3.fromRGB(120,170,255)
		rim.Material = Enum.Material.Neon
		rim.CFrame = padCF

		-- Ramp toward doors (tilted rectangular slab)
		local ramp = addPart("Ramp", "Part")
		local rise = ELEV
		local run  = RAMP_L
		local angle = math.atan2(rise, run) -- tilt around right axis
		ramp.Size  = Vector3.new(RAMP_W, 0.25, RAMP_L)
		ramp.Color = Color3.fromRGB(68, 76, 85)
		-- Position: starts at floor near door, rises to pad edge
		local rampMid = centerPos + forward * (PAD_R + RAMP_L*0.5)
		local rampCF  = basisCF(Vector3.new(rampMid.X, baseY + ELEV*0.5, rampMid.Z)) * CFrame.Angles(angle, 0, 0)
		ramp.CFrame = rampCF
		ramp.CanCollide = true

		-- Ceiling laser emitter directly above pad
		local roof = rootModel:FindFirstChild("GD_Roof", true)
		local roofY: number
		if roof and roof:IsA("BasePart") then
			roofY = (roof :: BasePart).Position.Y - (roof :: BasePart).Size.Y*0.5 - 0.05
		else
			roofY = baseY + 6.5
		end

		local emitter = addPart("LaserEmitter", "Part")
		emitter.Shape = Enum.PartType.Cylinder
		emitter.Size  = Vector3.new(0.3, PAD_R*1.2, PAD_R*1.2)
		emitter.Color = Color3.fromRGB(55, 65, 75)
		emitter.CFrame = basisCF(Vector3.new(centerPos.X, roofY, centerPos.Z)) * CFrame.Angles(0, 0, math.rad(90))

		-- Beam from emitter to pad center (attachments)
		local topAtt = emitter:FindFirstChild("TopAttachment")
		if not topAtt then
			topAtt = Instance.new("Attachment")
			topAtt.Name = "TopAttachment"
			topAtt.Parent = emitter
		end
		local bottomAtt = pad:FindFirstChild("BottomAttachment")
		if not bottomAtt then
			bottomAtt = Instance.new("Attachment")
			bottomAtt.Name = "BottomAttachment"
			bottomAtt.Parent = pad
		end

		local beam = grp:FindFirstChild("LaserBeam")
		if not (beam and beam:IsA("Beam")) then
			beam = Instance.new("Beam")
			beam.Name = "LaserBeam"
			beam.Parent = grp
			local beamObj = beam :: Beam
			beamObj.Attachment0 = topAtt :: Attachment
			beamObj.Attachment1 = bottomAtt :: Attachment
			beamObj.Width0 = 0.15
			beamObj.Width1 = 0.15
			beamObj.LightEmission = 0.7
			beamObj.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(120,170,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(180,60,255)) }
			beamObj.Transparency = NumberSequence.new(1) -- hidden by default
		end

		local beamObj: Beam = (grp:FindFirstChild("LaserBeam") :: Beam)

		-- Expose a simple toggle via attribute: set LaserEnabled=true to show the beam
		local function updateBeam()
			local enabled = (grp:GetAttribute("LaserEnabled") == true)
			beamObj.Transparency = enabled and NumberSequence.new(0) or NumberSequence.new(1)
		end
		updateBeam()
		grp:GetAttributeChangedSignal("LaserEnabled"):Connect(updateBeam)

		return grp
	end

	-- Place spawn pad at floor center, with ramp facing the doors
	local spawnPad = buildSpawnPad(model, fCenter)
	-- === end Robot Spawn Pad ===


	-- Wire ConsolePad to open Command UI via RemoteEvent when approached
	local function ensurePrompt(part: BasePart, actionText: string)
		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then
			prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = actionText
			prompt.ObjectText = "Garage Console"
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Parent = part
		end
		return prompt
	end

	local prompt = ensurePrompt(consoleScreen, "Open Console (Hatch • Missions • Repair • Design)")
	prompt.Triggered:Connect(function(player: Player)
		local RS = game:GetService("ReplicatedStorage")
		local folder = RS:FindFirstChild("RC_Remotes")
		if folder and folder:IsA("Folder") then
			local evt = folder:FindFirstChild("OpenCommandUI")
			if evt and evt:IsA("RemoteEvent") then
				evt:FireClient(player)
			end
		end
	end)
	-- === end canonical interior items ===
end

return Interior
