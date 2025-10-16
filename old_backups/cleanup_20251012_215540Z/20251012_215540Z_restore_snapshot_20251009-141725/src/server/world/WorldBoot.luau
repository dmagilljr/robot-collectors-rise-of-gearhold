--!strict
-- WorldBoot: robustly require World.Garage.Component and mount the garage
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local function getGarageModule(timeout: number): ModuleScript
	local world = SSS:WaitForChild("World", timeout)
	assert(world, "World missing under ServerScriptService")

	print("[WorldBoot] waiting for World/Garage …")
	local garage = world:WaitForChild("Garage", timeout)
	assert(garage and garage:IsA("Folder"), "World.Garage missing or not a Folder")

	print("[WorldBoot] waiting for Garage/Component ModuleScript …")
	local comp = garage:WaitForChild("Component", timeout)
	assert(comp and comp:IsA("ModuleScript"), "World.Garage.Component missing or not a ModuleScript")

	return comp :: ModuleScript
end

local WorldBoot = {}

function WorldBoot.run()
	print(("🌍 WorldBoot ACTIVE %d"):format(os.time()))
	local comp = getGarageModule(10)
	local okReq, GarageOrErr = pcall(function() return require(comp) end)
	assert(okReq, ("require(World.Garage.Component) failed: %s"):format(tostring(GarageOrErr)))
	local Garage = GarageOrErr
	assert(type(Garage)=="table" and type(Garage.Mount)=="function", "Garage.Component must return a table with Mount()")

	-- default placement
	local origin = Vector3.new(0,0,-52)
	local facing = Vector3.new(0,0,1)

	local _unmount = Garage.Mount({
		origin = origin,
		width  = 16.0,
		height = 14.0,
		depth  = 34.0,
		facing = facing,
	})

	-- Studio convenience: mark owner for proximity (strict in live)
	local plr = Players:GetPlayers()[1]
	local g = workspace:FindFirstChild("GD_Garage")
	if g and plr then
		g.Name = "GD_Garage_"..plr.UserId
		g:SetAttribute("OwnerUserId", plr.UserId)
		print("[WorldBoot] owner set to", plr.UserId, plr.Name)
	end
end

return WorldBoot
