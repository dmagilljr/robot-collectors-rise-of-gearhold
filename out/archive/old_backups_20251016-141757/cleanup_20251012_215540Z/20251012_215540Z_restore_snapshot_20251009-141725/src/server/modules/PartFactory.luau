--!strict
local PF = {}

export type Props = {
	Material: Enum.Material?,
	Color: Color3?,
	CanCollide: boolean?,
	Transparency: number?,
	Name: string?,
}

function PF.ensure(parent: Instance, name: string, size: Vector3, cf: CFrame, props: Props?): BasePart
	local p = parent:FindFirstChild(name) :: BasePart?
	if not p then
		p = Instance.new("Part")
		p.Name = name
		p.Parent = parent
	end
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	if props then
		if props.Material ~= nil then p.Material = props.Material end
		if props.Color ~= nil then p.Color = props.Color end
		if props.CanCollide ~= nil then p.CanCollide = props.CanCollide end
		if props.Transparency ~= nil then p.Transparency = props.Transparency end
	end
	return p
end

return PF
