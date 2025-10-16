local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local function nearDoor(p: BasePart): boolean
	local pos = p.Position
	return math.abs(pos.X) <= 14 and pos.Z >= -52 and pos.Z <= -30
end

local function isThinGround(p: BasePart): boolean
	return p.Size.Y <= 1.5 and p.Position.Y <= 2.2
end

local function chain(inst: Instance): string
	local names, cur = {}, inst
	while cur and cur ~= Workspace do
		table.insert(names, 1, cur.Name)
		cur = cur.Parent
	end
	return "Workspace." .. table.concat(names, ".")
end

task.defer(function()
	local killed = 0
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("BasePart") then
			local name = string.lower(d.Name)
			local looksScrap = string.find(name, "scrap") ~= nil
			local tagged = false
			pcall(function()
				tagged = CollectionService:HasTag(d, "ResourceNode")
			end)
			if (looksScrap or tagged) and isThinGround(d) and nearDoor(d) then
				print(("[SCRAP-HOTFIX] DELETE %s path=%s sz=(%.2f,%.2f,%.2f) y=%.2f tagged=%s"):format(
					d.ClassName,
					chain(d),
					d.Size.X,
					d.Size.Y,
					d.Size.Z,
					d.Position.Y,
					tostring(tagged)
				))
				d:Destroy()
				killed += 1
			end
		end
	end
	print(("[SCRAP-HOTFIX] DONE removed=%d"):format(killed))
end)
