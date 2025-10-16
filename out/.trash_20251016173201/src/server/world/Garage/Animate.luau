--!strict
local TweenService = game:GetService("TweenService")

local ANIM_INFO = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function playTween(part: BasePart, target: CFrame)
	if not target then return end
	TweenService:Create(part, ANIM_INFO, { CFrame = target }):Play()
end

return function(garage: Model, open: boolean)
	local left = garage:FindFirstChild("GD_DoorL") :: BasePart?
	local right = garage:FindFirstChild("GD_DoorR") :: BasePart?
	if not (left and right) then
		return
	end

	local attrName = open and "OpenCF" or "ClosedCF"
	local leftTarget = left:GetAttribute(attrName)
	local rightTarget = right:GetAttribute(attrName)
	if typeof(leftTarget) ~= "CFrame" or typeof(rightTarget) ~= "CFrame" then
		return
	end

	left.CanCollide = not open
	right.CanCollide = not open

	playTween(left, leftTarget)
	playTween(right, rightTarget)

	garage:SetAttribute("DoorAnimState", open and "OPEN" or "CLOSED")
end
