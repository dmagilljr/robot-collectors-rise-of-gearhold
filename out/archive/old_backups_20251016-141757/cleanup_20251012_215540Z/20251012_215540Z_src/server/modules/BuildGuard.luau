--!strict
local BuildGuard = {}

-- Prevents double builds in a session. Returns true only on first call per tag.
function BuildGuard.once(tag: string): boolean
	local key = "BUILT_" .. tag
	if workspace:GetAttribute(key) then
		return false
	end
	workspace:SetAttribute(key, true)
	return true
end

return BuildGuard
