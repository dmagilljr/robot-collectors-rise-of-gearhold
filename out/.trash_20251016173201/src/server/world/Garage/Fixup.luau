--!strict
print("[Fixup] VERSION v3", os.time())
print("[Fixup] VERSION v2", os.time())
local RunService = game:GetService("RunService")

local FRONT_WALL_THICK = 0.4
local CEILING_CLEAR    = 7.5
local ROOM_HALF_WIDTH  = 8.0
local FRONT_WALL_INSET = 0.01 -- small inset to avoid z-fighting

local function xz(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function trace(folder: Instance, msg: string)
	if folder:GetAttribute("DEV_TRACE") == true then
		print(('[Garage.Fixup] %s'):format(msg))
	end
end

local function ensurePart(parent: Instance, name: string, size: Vector3, color: Color3): BasePart
	local existing = parent:FindFirstChild(name, true)
	if existing and existing:IsA("BasePart") then
		existing.Anchored = true
		existing.CanCollide = true
		return existing
	end
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Anchored = true
	part.CanCollide = true
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Parent = parent
	return part
end

local function placeAt(part: BasePart, origin: Vector3, right: Vector3, fwd: Vector3, offR: number, offF: number, y: number)
	local pos = origin + right * offR + fwd * offF
	part.CFrame = CFrame.new(Vector3.new(pos.X, y, pos.Z))
end

local function findFrontWallByGeometry(model: Model, dc: Vector3, fwd: Vector3): BasePart?
	local best: BasePart? = nil
	local bestScore = math.huge
	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") then
			local part = inst :: BasePart
			local v = part.Position - dc
			local d = math.abs(v.X * fwd.X + v.Z * fwd.Z)
			local thin = math.min(part.Size.X, part.Size.Z)
			-- Name bias: prefer obvious façade pieces
			local name = part.Name:lower()
			local nameBias = 0
			if name:find("front") or name:find("spandrel") or name:find("facade") then
				nameBias = -0.5
			end
			local score = d + thin * 0.25 + nameBias
			if score < bestScore then
				bestScore = score
				best = part
			end
		end
	end
	return best
end

local function unifyFloors(model: Model)
	local floors = {}
	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") then
			local name = inst.Name:lower()
			if name:find("floor") or name:find("deck") or name:find("slab") then
				table.insert(floors, inst :: BasePart)
			end
		end
	end
	if #floors < 2 then
		return
	end
	local base = floors[1]
	for i = 2, #floors do
		local f = floors[i]
		f.Material = base.Material
		f.Color = base.Color
	end
end

local Fixup = {}

function Fixup.run(model: Model, folder: Instance, basis: {doorCenter: Vector3, forward: Vector3, right: Vector3})
	if not model or not model:IsA("Model") then
		return
	end
	-- Explicit opt-in: only run when FORCE_FIXUP=true on the Garage folder
	if folder:GetAttribute("FORCE_FIXUP") ~= true then
		trace(folder, "Fixup skipped (FORCE_FIXUP not set)")
		return
	end
	local doorCenter = basis.doorCenter
	local forward = xz(basis.forward).Unit
	local right = xz(basis.right).Unit

	do
		local wall = findFrontWallByGeometry(model, doorCenter, forward)
		if wall then
			wall.Anchored = true
			wall.CanCollide = true
			-- Project current center to the door plane and keep existing orientation
			local curPos = wall.CFrame.Position
			local signedDist = (curPos - doorCenter).X * forward.X + (curPos - doorCenter).Z * forward.Z
			local newPos = curPos - forward * signedDist + forward * (-FRONT_WALL_INSET)
			local xAxis = wall.CFrame.XVector
			local yAxis = wall.CFrame.YVector
			local zAxis = wall.CFrame.ZVector
			wall.CFrame = CFrame.fromMatrix(newPos, xAxis, yAxis, zAxis)
			trace(folder, "Front wall aligned to plane: " .. wall:GetFullName())
		else
			trace(folder, "No front wall candidate found")
		end
	end

	unifyFloors(model)

	local baseY = model:GetAttribute("floorTopY")
	if typeof(baseY) ~= "number" then
		-- Derive from detected floor parts: pick the highest top surface
		local maxTop = doorCenter.Y
		for _, inst in ipairs(model:GetDescendants()) do
			if inst:IsA("BasePart") and inst.Name:lower():find("floor") then
				local top = inst.Position.Y + inst.Size.Y * 0.5
				if top > maxTop then
					maxTop = top
				end
			end
		end
		baseY = maxTop
	end
	-- Disabled thin ground pads that were spawning brown tiles outside garage
	-- placeAt(ensurePart(model, "ConsolePad", Vector3.new(2.5, 0.2, 2.5), Color3.fromRGB(80, 160, 255)), doorCenter, right, forward, 0.0, -3.0, baseY)
	-- placeAt(ensurePart(model, "HatchPad", Vector3.new(3.0, 0.2, 3.0), Color3.fromRGB(255, 205, 80)), doorCenter, right, forward, -3.5, -6.0, baseY + 0.1)
	placeAt(ensurePart(model, "RepairBench", Vector3.new(3.0, 1.0, 1.5), Color3.fromRGB(120, 120, 120)), doorCenter, right, forward, 3.5, -6.0, baseY + 0.5)
	placeAt(ensurePart(model, "Lockers", Vector3.new(1.2, 5.0, 0.6), Color3.fromRGB(70, 90, 110)), doorCenter, right, forward, ROOM_HALF_WIDTH - 0.8, -3.0, baseY + 2.5)
	trace(folder, "Pads placed")
end

return Fixup
