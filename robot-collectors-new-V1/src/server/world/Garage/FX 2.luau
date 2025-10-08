--!strict
local FX = {}

-- Attach a small rim light (PointLight) to a dummy Part (Transparency=1)
function FX.ensureRimLight(parent: Instance, cframe: CFrame, brightness: number, range: number, color: Color3): BasePart
	local n = parent:FindFirstChild("GD_RimLight") :: BasePart?
	if not n then
		n = Instance.new("Part"); n.Name = "GD_RimLight"; n.Parent = parent
		n.Anchored = true; n.CanCollide = false; n.Transparency = 1; n.Size = Vector3.new(0.2,0.2,0.2)
		local L = Instance.new("PointLight"); L.Name="Light"; L.Parent = n
	end
	n.CFrame = cframe
	local L = (n:FindFirstChild("Light") :: PointLight?) or Instance.new("PointLight", n)
	L.Brightness = brightness; L.Range = range; L.Color = color
	return n
end

-- Optionally place a thin neon strip (for edge accent)
function FX.ensureNeonStrip(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): BasePart
	local s = parent:FindFirstChild(name) :: BasePart?
	if not s then
		s = Instance.new("Part"); s.Name = name; s.Parent = parent
	end
	s.Anchored = true; s.CanCollide = false; s.Material = Enum.Material.Neon; s.Color = color
	s.Size = size; s.CFrame = cf
	return s
end

-- Simple light pulse over duration (seconds); pass in a PointLight
function FX.pulse(light: PointLight, maxB: number, dur: number)
	local base = light.Brightness
	local t0 = os.clock()
	local con; con = game:GetService("RunService").Heartbeat:Connect(function()
		local t = os.clock() - t0
		if t >= dur then light.Brightness = base; con:Disconnect(); return end
		local a = math.sin(t * math.pi) -- up then down
		light.Brightness = base + (maxB - base) * a
	end)
end

return FX
