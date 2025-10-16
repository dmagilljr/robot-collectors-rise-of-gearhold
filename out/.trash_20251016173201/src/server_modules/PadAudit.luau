--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("GameConstants"))

local PadAudit = {}

local function rootOwner(gd: Instance, inst: Instance): Instance
	local cur = inst
	local last = inst
	while cur and cur ~= gd and cur ~= workspace do
		last = cur
		cur = cur.Parent
	end
	return last
end

-- Audit small, thin, ground-ish parts in a wide box in front of the garage door
function PadAudit.AuditOnce()
    if not GameConstants.DEBUG then
        return
    end

	local gd = workspace:FindFirstChild("GD_Garage")
	if not (gd and gd:IsA("Model")) then
		warn("[PadAudit] GD_Garage not found")
		return
	end
	local door = gd:FindFirstChild("DoorPivot", true)
	if not (door and door:IsA("BasePart")) then
		warn("[PadAudit] DoorPivot not found")
		return
	end

	-- Very wide search region, forward of door (covers your screenshots)
	local center = door.Position + door.CFrame.LookVector * 14
	local region = workspace:GetPartBoundsInBox(CFrame.new(center), Vector3.new(120, 12, 120))

	print("========== [PadAudit] START ==========")
	local count = 0
	for _,p in ipairs(region) do
		if p:IsA("BasePart") then
			local thin   = (p.Size.Y <= 3.0)   -- allow up to 3 studs
			local small  = (math.max(p.Size.X, p.Size.Z) <= 12) -- include up to 12 stud tiles
			local ground = (math.abs(p.Position.Y) <= 3.0)  -- near ground plane
			if thin and small and ground then
				count += 1
				local owner = rootOwner(gd, p)
				local ownerName = owner and owner.Name or "(nil)"
				local mat = tostring(p.Material)
				local col = string.format("(%.0f,%.0f,%.0f)", p.Color.R*255, p.Color.G*255, p.Color.B*255)
				local tx  = string.format("%.2f", p.Transparency)
				local inGD = p:IsDescendantOf(gd) and "IN_GD" or "OUTSIDE"
				print(string.format(
					"[PadAudit] #%d  %-7s  sz=(%.2f,%.2f,%.2f)  y=%.2f  anc=%s  %s  mat=%s  col=%s  tx=%s  owner=%s  path=%s",
					count, p.ClassName, p.Size.X, p.Size.Y, p.Size.Z, p.Position.Y, tostring(p.Anchored),
					inGD, mat, col, tx, ownerName, p:GetFullName()
				))
			end
		end
	end
	if count == 0 then
		print("[PadAudit] No candidate parts found in 120x12x120 box")
	end
	print("========== [PadAudit] END ==========")
end

return PadAudit
