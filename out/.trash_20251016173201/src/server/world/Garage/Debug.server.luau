--!strict
local folder = script.Parent  -- ServerScriptService/World/Garage
local RunService = game:GetService("RunService")
local function round(x) return math.floor(x*100+0.5)/100 end

local function dump(msg: string) print("[Garage.Debug] " .. msg) end

local function getModel(): Model?
	local ref = folder:FindFirstChild("ModelRef")
	if ref and ref:IsA("ObjectValue") then
		local m = (ref :: any).Value
		if m and m:IsA("Model") then return m end
	end
	return nil
end

local function getDoorBasis()
	local bf = folder:FindFirstChild("GetDoorBasis")
	if bf and bf:IsA("BindableFunction") then
		local dc, fwd, rgt = (bf :: any):Invoke()
		if typeof(dc)=="Vector3" and typeof(fwd)=="Vector3" and typeof(rgt)=="Vector3" then
			local f = Vector3.new(fwd.X,0,fwd.Z); if f.Magnitude < 1e-3 then return nil end
			f = f.Unit
			local r = Vector3.new(-f.Z,0,f.X)
			return dc, f, r
		end
	end
	return nil
end

local function partInfo(p: BasePart): string
	local s = p.Size; local c = p.CFrame.Position
	return string.format("%s  size(%.2f,%.2f,%.2f)  pos(%.2f,%.2f,%.2f)",
		p:GetFullName(), s.X, s.Y, s.Z, round(c.X), round(c.Y), round(c.Z))
end

local function nearDoorPlane(p: BasePart, dc: Vector3, forward: Vector3): number
	local v = p.Position - dc
	return math.abs(v.X*forward.X + v.Z*forward.Z)
end

local function runDump()
	if folder:GetAttribute("DEV_DUMP") ~= true then return end
	local model = getModel()
	if not model then dump("ModelRef missing."); return end

	local doorBasis = getDoorBasis() or {}
	local dc, fwd, rgt = doorBasis[1], doorBasis[2], doorBasis[3]
	if dc then
		dump(string.format("DoorCenter=(%.2f,%.2f,%.2f)", round(dc.X), round(dc.Y), round(dc.Z)))
	else
		dump("GetDoorBasis unavailable.")
	end

	local count = 0
	local floors = {}
	local bestWall: BasePart? = nil
	local bestScore = math.huge

	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") then
			count += 1
			local p = inst :: BasePart
			if p.Name:lower():find("floor") then table.insert(floors, p) end
			if dc and fwd then
				local d = nearDoorPlane(p, dc, fwd)
				local thin = math.min(p.Size.X, p.Size.Z)
				local score = d + thin*0.25
				if score < bestScore then bestScore = score; bestWall = p end
			end
		end
	end

	dump("Parts total: " .. count)
	if bestWall then dump("Likely front wall → " .. partInfo(bestWall)) end
	if #floors > 0 then
		dump("Floors detected:")
		for _, f in ipairs(floors) do dump("  " .. partInfo(f)) end
	end

	folder:SetAttribute("DEV_DUMP", false)
end

RunService.Heartbeat:Connect(function()
	runDump()
end)
