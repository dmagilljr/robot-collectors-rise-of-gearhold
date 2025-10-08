--!strict
-- Sliding segmented door for "alien defense bay" look.
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

export type DoorSpec = {
	width: number,
	height: number,
	nPanels: number,
	center: Vector3,          -- world center of opening plane
	right: Vector3,           -- plane basis vectors
	up: Vector3,
	outward: Vector3,         -- (+Z)
	inward: Vector3,          -- (−Z)
	parent: Instance,
	color: Color3,
	depth: number?,           -- panel thickness (studs), default 0.3
}

local DoorPanels = {}

local function cf(pos: Vector3, r: Vector3, u: Vector3, o: Vector3): CFrame
	return CFrame.fromMatrix(pos, r, u, o)
end

function DoorPanels.Build(spec: DoorSpec): Model
	local depth = spec.depth or 0.30
	local door = Instance.new("Model"); door.Name = "GD_DoorPanels"; door.Parent = spec.parent

	-- Create N horizontal panels that slide up as a sheet then tuck in by a small inward offset
	local n = math.max(2, spec.nPanels)
	local hPer = spec.height / n
	for i = 1, n do
		local p = Instance.new("Part")
		p.Name = string.format("Panel_%02d", i)
		p.Size = Vector3.new(spec.width, hPer, depth)
		p.Material = Enum.Material.Metal
		p.Color = spec.color
		p.Anchored = true
		p.CanCollide = true
		local y = -spec.height*0.5 + hPer*(i-0.5)
		p.CFrame = cf(spec.center + spec.up*y - spec.outward*0.05, spec.right, spec.up, spec.outward)
		p.Parent = door
	end

	return door
end

function DoorPanels.Animate(door: Model, spec: DoorSpec, opening: boolean)
	-- Panels move as a sheet: lift to lintel, then tuck slightly inward
	local n = spec.nPanels
	local hPer = spec.height / n
	local lintelY =  spec.height*0.5 - hPer*0.5

	local function targetCF(t: number, i: number): CFrame
		local baseY = -spec.height*0.5 + hPer*(i-0.5)
		local split = 0.65
		if t <= split then
			-- lift sheet
			local v = t/split
			local y = baseY + v*(lintelY - baseY)
			return cf(spec.center + spec.up*y - spec.outward*0.05, spec.right, spec.up, spec.outward)
		else
			-- small inward tuck
			local c = (t - split)/(1-split)
			local y = lintelY + 0.05*c
			local back = 0.35*c
			return cf(spec.center + spec.up*y + spec.inward*back - spec.outward*0.05, spec.right, spec.up, spec.outward)
		end
	end

	local conns: {RBXScriptConnection} = {}
	local drivers: {NumberValue} = {}

	local function clear()
		for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		for _,v in ipairs(drivers) do pcall(function() v:Destroy() end) end
		table.clear(conns); table.clear(drivers)
	end

	local parts: {BasePart} = {}
	for i = 1, n do
		parts[i] = door:FindFirstChild(string.format("Panel_%02d", i)) :: BasePart
	end
	if not opening then table.sort(parts, function(a,b) return a.Name > b.Name end) end

	local duration, stagger = 1.1, 0.05
	local startT, endT = (opening and 0 or 1), (opening and 1 or 0)

	-- collider policy
	if opening then for _,s in ipairs(parts) do s.CanCollide = false end end

	for i,s in ipairs(parts) do
		s.CFrame = targetCF(startT, i)
		local u = Instance.new("NumberValue"); u.Name="u"; u.Value=startT; u.Parent = s
		table.insert(drivers, u)
		table.insert(conns, RunService.Heartbeat:Connect(function()
			s.CFrame = targetCF(u.Value, i)
		end))
		local info = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, (i-1)*stagger)
		TweenService:Create(u, info, {Value = endT}):Play()
	end

	task.delay(duration + (#parts*stagger) + 0.05, function()
		for _,s in ipairs(parts) do s.CanCollide = not opening end
		clear()
	end)
end

return DoorPanels
