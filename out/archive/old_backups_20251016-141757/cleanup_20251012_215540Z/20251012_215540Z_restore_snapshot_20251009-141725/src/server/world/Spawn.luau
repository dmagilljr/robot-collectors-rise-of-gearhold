--!strict
local M = {}
function M.ensure()
	local Workspace = game:GetService("Workspace")
	-- base
	local base = Workspace:FindFirstChild("RC_Baseplate") :: Part?
	if not base then
		base = Instance.new("Part")
		base.Name = "RC_Baseplate"
		base.Size = Vector3.new(512, 1, 512)
		base.Anchored = true
		base.Material = Enum.Material.Concrete
		base.CFrame = CFrame.new(0, 0.5, 0)
		base.Parent = Workspace
	end
	-- spawn
	local pad = Workspace:FindFirstChild("RC_Spawn") :: SpawnLocation?
	if not pad then
		pad = Instance.new("SpawnLocation")
		pad.Name = "RC_Spawn"
		pad.Size = Vector3.new(6, 1, 6)
		pad.Neutral, pad.Enabled = true, true
		pad.Anchored = true
		pad.BrickColor = BrickColor.new("Medium stone grey")
		pad.CFrame = CFrame.new(0, 3.5, -12)
		pad.Parent = Workspace
	end
	print(("[World.Spawn] ensured base@%s spawn@%s"):format(
		tostring(base.CFrame.Position), tostring(pad.CFrame.Position)))
end
return M
