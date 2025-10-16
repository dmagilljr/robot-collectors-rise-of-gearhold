-- WatchNewParts.server.luau  (temporary diagnostic, auto-runs on server boot)
local CollectionService = game:GetService("CollectionService")

local function isThin(part: BasePart): boolean
	return part.Size.Y <= 1.5 and part.Position.Y <= 2.0
end

workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		local tagged = CollectionService:HasTag(obj, "ResourceNode")
		if isThin(obj) or tagged then
			print(string.format(
				"[WATCH] Added %s  size=(%.2f,%.2f,%.2f)  y=%.2f  tagged=%s  path=%s",
				obj.ClassName,
				obj.Size.X, obj.Size.Y, obj.Size.Z,
				obj.Position.Y,
				tostring(tagged),
				obj:GetFullName()
			))
		end
	end
end)

print("🛰️ [WATCH] ACTIVE (server) — logging new thin parts + ResourceNodes")
