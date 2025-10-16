--!strict
-- Bootstrap order (non-blocking):
-- 1) (Optional) trust server scripts to ensure RC_Remotes (00_spawns_and_remotes / Remotes.server)
-- 2) Ensure baseplate + RC_Spawn so players never fall
-- 3) Require and run WorldBoot (mounts the garage)

local SSS = game:GetService("ServerScriptService")

-- 2) Spawn (tolerate Studio timing)
local function requireWorldSpawn(timeout: number)
	local world = SSS:WaitForChild("World", timeout)
	local mod   = world and world:WaitForChild("Spawn", timeout)
	assert(world, "World missing")
	assert(mod and mod:IsA("ModuleScript"), "World.Spawn missing or not a ModuleScript")
	return require(mod)
end

do
	local ok, modOrErr = pcall(requireWorldSpawn, 10)
	if ok then
		local Spawn = modOrErr
		local good, err = pcall(function() return Spawn.ensure() end)
		if not good then warn("[bootstrap] Spawn.ensure threw:", err) end
	else
		warn("[bootstrap] could not require World.Spawn:", modOrErr)
	end
end

-- 3) WorldBoot
local function requireWorldBoot(timeout: number)
	local world = SSS:WaitForChild("World", timeout)
	local wb    = world and world:WaitForChild("WorldBoot", timeout)
	assert(world, "World missing")
	assert(wb and wb:IsA("ModuleScript"), "World.WorldBoot missing or not a ModuleScript")
	return require(wb)
end

do
	local ok, modOrErr = pcall(requireWorldBoot, 10)
	if ok and type(modOrErr) == "table" and type(modOrErr.run) == "function" then
		print("[bootstrap] running WorldBoot.run()")
		local good, err = pcall(modOrErr.run)
		if not good then warn("[bootstrap] WorldBoot.run() threw:", err) end
	else
		warn("[bootstrap] could not require/run WorldBoot:", modOrErr)
	end
end

print("🤖 server init:", os.time())
