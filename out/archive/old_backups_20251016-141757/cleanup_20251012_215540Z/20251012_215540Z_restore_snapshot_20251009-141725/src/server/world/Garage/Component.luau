--!strict
-- Minimal, safe garage Component with Mount(spec)

export type Spec = {
	origin: Vector3,
	width: number,
	height: number,
	depth: number,
	facing: Vector3,
}

local function ensure(parent: Instance, name: string, size: Vector3, cf: CFrame, props: {[string]: any}?): BasePart
	local part = parent:FindFirstChild(name) :: BasePart?
	if not part then
		part = Instance.new("Part")
		part.Name = name
		part.Parent = parent
	end
	part.Anchored = true
	part.Size = size
	part.CFrame = cf
	if props then
		for k, v in pairs(props) do
			(part :: any)[k] = v
		end
	end
	return part
end

local Component = {}

function Component.Mount(spec: Spec): () -> ()
	local root = Instance.new("Model")
	root.Name = "GD_Garage"
	root.Parent = workspace

	local center = spec.origin + Vector3.new(0, spec.height * 0.5, spec.depth * 0.5)
	local outward = spec.facing.Unit
	local inward = -outward
	local up = Vector3.new(0, 1, 0)
	local right = up:Cross(inward).Unit

	right = right.Magnitude > 0 and right or Vector3.new(1, 0, 0)

	root:SetAttribute("DoorCenter", center)
	root:SetAttribute("DoorFacing", outward)

	local PLANE_MARGIN = 0.05
	local SHELL_W = spec.width + 8
	local SHELL_H = math.max(spec.height + 1.2, 8)
	local SHELL_D = math.max(spec.depth, spec.width + 6)
	local WALL_T = 0.5

	local function basis(pos: Vector3)
		return CFrame.fromMatrix(pos, right, up, outward)
	end

	ensure(root, "GD_Back", Vector3.new(SHELL_W, SHELL_H - WALL_T, WALL_T),
		basis(center + inward * (SHELL_D - WALL_T * 0.5 + PLANE_MARGIN) + up * ((SHELL_H - WALL_T) * 0.5)),
		{Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 80, 90), CanCollide = true})
	ensure(root, "GD_Left", Vector3.new(WALL_T, SHELL_H, SHELL_D),
		basis(center + inward * (SHELL_D * 0.5 + PLANE_MARGIN) + up * (SHELL_H * 0.5) + right * (-SHELL_W * 0.5 + WALL_T * 0.5)),
		{Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 80, 90), CanCollide = true})
	ensure(root, "GD_Right", Vector3.new(WALL_T, SHELL_H, SHELL_D),
		basis(center + inward * (SHELL_D * 0.5 + PLANE_MARGIN) + up * (SHELL_H * 0.5) + right * (SHELL_W * 0.5 - WALL_T * 0.5)),
		{Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 80, 90), CanCollide = true})
	ensure(root, "GD_Roof", Vector3.new(SHELL_W, WALL_T, SHELL_D),
		basis(center + inward * (SHELL_D * 0.5 + PLANE_MARGIN) + up * ((SHELL_H - WALL_T) * 0.5)),
		{Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 80, 90), CanCollide = true})

	local FBACK = PLANE_MARGIN + 0.03
	ensure(root, "GD_FrontSpandrelHead", Vector3.new(spec.width + 0.16, 0.36, 0.22),
		basis(center + up * (spec.height * 0.5 - 0.36 * 0.75) + inward * (FBACK + 0.03)),
		{Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 80, 90), CanCollide = true})

	local gapH = (SHELL_H - spec.height) * 0.5
	if gapH > 0.02 then
		local fillH = math.max(0.40, gapH + 0.02)
		ensure(root, "GD_FrontFillerUpper", Vector3.new(spec.width + 0.16, fillH, 0.22),
			basis(center + up * (spec.height * 0.5 + fillH * 0.5) + inward * (FBACK + 0.035)),
			{Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 80, 90), CanCollide = true})
	end

	print("[Garage.Component] shell placed; DoorCenter=", center)

	return function()
		if root and root.Parent then
			root:Destroy()
		end
	end
end

return Component
