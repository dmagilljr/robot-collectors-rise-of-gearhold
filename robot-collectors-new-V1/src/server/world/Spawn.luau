--!strict
local Spawn = {}

function Spawn.ensure()
	-- Baseplate
	local plate = workspace:FindFirstChild("RC_Baseplate") :: BasePart?
	if not plate then
		plate = Instance.new("Part")
		plate.Name = "RC_Baseplate"
		plate.Parent = workspace
		plate.Anchored = true
		plate.Material = Enum.Material.Slate
		plate.Size = Vector3.new(512, 1, 512)
	end
	plate.CFrame = CFrame.new(0, 0.5, 0)

	-- Spawn pad
	local spawn = workspace:FindFirstChild("RC_Spawn") :: SpawnLocation?
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "RC_Spawn"
		spawn.Parent = workspace
	end
	spawn.Anchored = true
	spawn.Neutral  = true
	spawn.Enabled  = true
	spawn.Size     = Vector3.new(6, 1, 6)
	spawn.BrickColor = BrickColor.new("Medium stone grey")
	spawn.CFrame   = CFrame.new(0, 3.5, -12)

	print("[Spawn] ensured baseplate & spawn @", os.time())
end

return Spawn
