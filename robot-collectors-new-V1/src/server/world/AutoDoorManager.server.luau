--!strict
local Players = game:GetService("Players")

local OPEN_DIST  = 16.0
local CLOSE_DIST = 22.0
local TICK       = 0.20

-- DEV only: adopt nearest player if OwnerUserId missing (Studio)
local DEV_ALLOW_AUTO_ADOPT = true  -- TODO pre-launch: set false

local function looksLikeGarage(m: Instance): boolean
	if not m:IsA("Model") then return false end
	if m.Name == "GD_Garage" or m.Name:match("^GD_Garage_") then return true end
	if typeof(m:GetAttribute("OwnerUserId")) == "number" then return true end
	return false
end

local function getPanels(g: Model): (BasePart?, BasePart?)
	return g:FindFirstChild("GD_DoorL", true) :: BasePart?, g:FindFirstChild("GD_DoorR", true) :: BasePart?
end

local function setDoorOnModel(g: Model, opening: boolean)
	if (g:GetAttribute("DoorIsOpen") == true) ~= opening then
		g:SetAttribute("DoorIsOpen", opening)
	end
end

local function nearestPlayerTo(pos: Vector3): Player?
	local best, bestD
	for _,plr in ipairs(Players:GetPlayers()) do
		local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			local d = (hrp.Position - pos).Magnitude
			if not bestD or d < bestD then best, bestD = plr, d end
		end
	end
	return best
end

local function resolveOwner(g: Model): Player?
	local uid = g:GetAttribute("OwnerUserId")
	if typeof(uid) == "number" then
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr.UserId == uid then return plr end
		end
	end
	if DEV_ALLOW_AUTO_ADOPT then
		local centerAttr = g:GetAttribute("DoorCenter")
		local center = typeof(centerAttr)=="Vector3" and centerAttr or nil
		if not center then
			local l,r = getPanels(g)
			if l and r then center = (l.CFrame.Position + r.CFrame.Position)*0.5 end
		end
		if center then
			local n = nearestPlayerTo(center)
			if n then
				g:SetAttribute("OwnerUserId", n.UserId)
				print(("[AutoDoor] dev-adopted %s(%d) for %s"):format(n.Name, n.UserId, g.Name))
				return n
			end
		end
	end
	return nil
end

local tracked: {[Model]: boolean} = {}
local lastState: {[Model]: boolean} = {}

task.spawn(function()
	print("[AutoDoorManager] running: owner-only proximity for all garages in this shard")
	while true do
		for _,inst in ipairs(workspace:GetChildren()) do
			if looksLikeGarage(inst) then
				local g = inst :: Model
				local left,right = getPanels(g)
				if not (left and right) then continue end

				local owner = resolveOwner(g)
				if not owner then continue end

				local hrp = owner.Character and owner.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not hrp then continue end

				local centerAttr = g:GetAttribute("DoorCenter")
				local center = typeof(centerAttr)=="Vector3" and centerAttr or ((left.CFrame.Position + right.CFrame.Position)*0.5)

				local d = (hrp.Position - center).Magnitude
				local opening = nil
				if d < OPEN_DIST then opening = true
				elseif d > CLOSE_DIST then opening = false end

				if opening ~= nil then
					if not tracked[g] then
						print(("[AutoDoor] tracking %s owner=%s dist=%.1f"):format(g.Name, owner.Name, d))
						tracked[g] = true
					end
					if lastState[g] ~= opening then
						setDoorOnModel(g, opening)
						lastState[g] = opening
						print(("[AutoDoor] %s → %s (dist=%.1f)"):format(g.Name, opening and "OPEN" or "CLOSE", d))
					end
				end
			end
		end
		task.wait(TICK)
	end
end)
