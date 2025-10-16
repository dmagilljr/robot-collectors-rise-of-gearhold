--!strict
local DoorPlane = {}

export type Plane = {
	cf: CFrame,
	right: Vector3,
	up: Vector3,
	inward: Vector3,
	outward: Vector3,
	planeDot: number,
	distance: (Vector3) -> number,
}

-- center = door plane center (world), facing = outward (+Z for mouth)
function DoorPlane.from(center: Vector3, facing: Vector3): Plane
	local outward = Vector3.new(facing.X, 0, facing.Z).Unit
	local cf = CFrame.lookAt(center, center + outward, Vector3.new(0,1,0))
	local right = cf.RightVector
	local up = cf.UpVector
	local inward = -outward
	-- compute plane equation parameters
	local dot = center:Dot(outward)
	local function distance(pt: Vector3): number
		return math.abs((pt:Dot(outward)) - dot)
	end
	return {
		cf = cf,
		right = right,
		up = up,
		inward = inward,
		outward = outward,
		planeDot = dot,
		distance = distance,
	}
end

return DoorPlane
