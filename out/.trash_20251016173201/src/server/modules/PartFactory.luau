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
	-- Reuse only if an existing child with this name is a BasePart.
	local existing = parent:FindFirstChild(name)
	if existing and not existing:IsA("BasePart") then
		-- A non-BasePart occupies this name; replace it deterministically.
		existing:Destroy()
		existing = nil
	end

	local p = (existing :: BasePart?) or Instance.new("Part")
	if p.Parent == nil then
		p.Name = name
		p.Parent = parent
	end

	-- Deterministic transform
	p.Anchored = true
	p.Size = size
	p.CFrame = cf

	-- Apply props if provided (explicit-only to avoid surprising changes)
	if props then
		if props.Material ~= nil then p.Material = props.Material end
		if props.Color ~= nil then p.Color = props.Color end
		if props.CanCollide ~= nil then p.CanCollide = props.CanCollide end
		if props.Transparency ~= nil then p.Transparency = props.Transparency end
	end

	return p
end

return PF
