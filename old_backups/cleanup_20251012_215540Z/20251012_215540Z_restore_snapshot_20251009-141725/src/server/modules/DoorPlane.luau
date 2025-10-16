--!strict
local DoorPlane = {}

export type Plane = {
	cf: CFrame,
	planeZ: number,
	right: Vector3,
	up: Vector3,
	inward: Vector3,
	outward: Vector3,
}

-- center = door plane center (world), facing = outward (+Z for mouth)
function DoorPlane.from(center: Vector3, facing: Vector3): Plane
	local cf = CFrame.lookAt(center, center + facing.Unit, Vector3.new(0,1,0))
	local right = cf.RightVector
	local up = cf.UpVector
	local outward = cf.LookVector
	local inward = -outward
	return { cf = cf, planeZ = cf.Position.Z, right = right, up = up, inward = inward, outward = outward }
end

return DoorPlane
