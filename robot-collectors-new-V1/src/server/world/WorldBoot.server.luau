--!strict
local BuildGuard = require(game:GetService("ServerScriptService").Modules.BuildGuard)
local Garage     = require(script.Parent.Garage.Component)
local Spawn = require(script.Parent:WaitForChild("Spawn")) -- ModuleScript (Spawn.luau)

local SSS = game:GetService("ServerScriptService")
-- WorldBoot: mounts world components exactly once. Must be required as a ModuleScript by init.server

local WorldBoot = {}

-- Wait for an Instance under workspace by name (with timeout, seconds)
local function waitForWorkspaceChild(name: string, timeout: number?): Instance?
	timeout = timeout or 5
	local t0 = os.clock()
	local inst = workspace:FindFirstChild(name)
	while not inst and (os.clock() - t0) < timeout do
		task.wait(0.1)
		inst = workspace:FindFirstChild(name)
	end
	return inst
end

function WorldBoot.run()
	local cnt = (workspace:GetAttribute("WB_BUILD_COUNT") or 0) + 1
	workspace:SetAttribute("WB_BUILD_COUNT", cnt)
	print("[WorldBoot] RUN count=", cnt)

	if not BuildGuard.once("WorldBoot") then
		warn("[WorldBoot] already ran; skipping")
		return
	end

	local okSpawn, errSpawn = pcall(function()
		Spawn.ensure()
	end)
	if not okSpawn then
		warn("[WorldBoot] Spawn.ensure() failed:", errSpawn)
	else
		print("[WorldBoot] Spawn ensured")
	end

	-- Verify spawn artifacts exist before continuing
	local base = waitForWorkspaceChild("RC_Baseplate", 5)
	local pad  = waitForWorkspaceChild("RC_Spawn", 5)
	if not base or not pad then
		warn("[WorldBoot] Spawn artifacts missing after ensure(); retrying once…", base, pad)
		pcall(function() Spawn.ensure() end)
		base = waitForWorkspaceChild("RC_Baseplate", 3)
		pad  = waitForWorkspaceChild("RC_Spawn", 3)
	end
	if base and pad then
		print(string.format("[WorldBoot] Spawn ready  base@%s  pad@%s", tostring((base :: BasePart).Position), tostring((pad :: BasePart).Position)))
		if (base :: BasePart).Anchored ~= true then warn("[WorldBoot] RC_Baseplate not anchored — fixing"); (base :: BasePart).Anchored = true end
		if (pad  :: BasePart).Anchored ~= true then warn("[WorldBoot] RC_Spawn not anchored — fixing"); (pad  :: BasePart).Anchored  = true end
	else
		warn("[WorldBoot] Spawn artifacts still missing; players may fall until Spawn.ensure() succeeds.")
	end

	local okGarage, unmountOrErr = pcall(function()
		return Garage.Mount({
			origin = Vector3.new(24,0,12),
			width  = 8.0,
			height = 8.0,
			depth  = 14.0,
			facing = Vector3.zAxis(),
		})
	end)
	if not okGarage then
		warn("[WorldBoot] Garage.Mount failed:", unmountOrErr)
	else
		local _unmount = unmountOrErr
	end

	print(("🌍 WorldBoot ACTIVE %d"):format(os.time()))
end

return WorldBoot
