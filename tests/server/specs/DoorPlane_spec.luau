--!strict
local SSS = game:GetService("ServerScriptService")
local PF  = require(SSS.Modules.PartFactory)
local DoorPlane = require(SSS.Modules:WaitForChild("DoorPlane"))

local M = {}

function M.run()
	-- Given a door plane at (0,4,6) facing +Z
	local plane = DoorPlane.from(Vector3.new(0,4,6), Vector3.new(0,0,1))

	local function frontOffset(part: BasePart): number
		local rel = plane.cf:PointToObjectSpace(part.CFrame.Position)
		return rel.Z + part.Size.Z * 0.5
	end

	-- helper: place a part behind the plane by margin
	local function placeBehind(size: Vector3, margin: number): CFrame
		return plane.cf * CFrame.new(0, 0, -(size.Z * 0.5 + margin))
	end

	-- mock shell parts
	local root = Instance.new("Folder"); root.Name="SpecRoot"; root.Parent = workspace
	local margin = 0.05
	local roof = PF.ensure(root, "Roof", Vector3.new(8,0.5,12), placeBehind(Vector3.new(8,0.5,12), margin), {Transparency=1, CanCollide=false})
	local left = PF.ensure(root, "Left", Vector3.new(0.5,8,12), placeBehind(Vector3.new(0.5,8,12), margin), {Transparency=1, CanCollide=false})

	assert(frontOffset(roof) <= -margin + 1e-4, "roof front face on/over plane")
	assert(frontOffset(left) <= -margin + 1e-4, "left front face on/over plane")

	root:Destroy()
end

return M
