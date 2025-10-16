--!strict
-- spawn_guard.server.luau
-- Runs automatically under ServerScriptService/Server.
-- Guarantees RC_Baseplate + RC_Spawn exist even if WorldBoot/Spawn hasn't run yet.

local WAIT_TIMEOUT = 10

local function ensureBaseplateAndSpawn()
	-- Baseplate
	local plate = workspace:FindFirstChild("RC_Baseplate") :: BasePart?
	if not plate then
		plate = Instance.new("Part")
		plate.Name = "RC_Baseplate"
		plate.Parent = workspace
		plate.Anchored = true
		plate.Material = Enum.Material.Slate
		plate.Size = Vector3.new(512, 1, 512)
		plate.CFrame = CFrame.new(0, 0.5, 0)
	end

	-- Spawn pad
	local spawn = workspace:FindFirstChild("RC_Spawn") :: SpawnLocation?
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "RC_Spawn"
		spawn.Parent = workspace
		spawn.Anchored = true
		spawn.Neutral  = true
		spawn.Enabled  = true
		spawn.Size     = Vector3.new(6,1,6)
		spawn.CFrame   = CFrame.new(0, 3.5, -12)
	end

	print(string.format("[spawn_guard] ensured base@%s spawn@%s", tostring((plate :: BasePart).Position), tostring((spawn :: BasePart).Position)))
end

local function loadWorldSpawn()
	local sss = game:GetService("ServerScriptService")
	local world = sss:FindFirstChild("World")
	if not world then
		world = sss:WaitForChild("World", WAIT_TIMEOUT)
	end
	if not world then
		error(("ServerScriptService.World missing after %.1fs"):format(WAIT_TIMEOUT))
	end
	local spawnMod = world:FindFirstChild("Spawn")
	if not spawnMod then
		spawnMod = world:WaitForChild("Spawn", WAIT_TIMEOUT)
	end
	if not spawnMod or not spawnMod:IsA("ModuleScript") then
		error("World.Spawn missing or not a ModuleScript")
	end
	local Spawn = require(spawnMod)
	if type(Spawn) ~= "table" or type(Spawn.ensure) ~= "function" then
		error("Spawn module invalid (no ensure())")
	end
	return Spawn
end

-- Try to call World/Spawn.ensure(); if that fails, fallback to local ensure.
local function tryWorldSpawnFirst()
	local ok, result = pcall(loadWorldSpawn)
	if ok then
		local ensured, err = pcall(result.ensure)
		if ensured then
			print("[spawn_guard] World.Spawn.ensure() executed")
			return true
		end
		warn("[spawn_guard] Spawn.ensure() threw; falling back:", err)
	else
		warn("[spawn_guard] require(World.Spawn) failed; falling back:", result)
	end
	ensureBaseplateAndSpawn()
	return false
end

-- Defer one tick so Rojo can materialize SSS/World on slow starts
task.defer(function()
	tryWorldSpawnFirst()
	-- If the World/Spawn path worked, double-check the artifacts still exist:
	if not workspace:FindFirstChild("RC_Baseplate") or not workspace:FindFirstChild("RC_Spawn") then
		warn("[spawn_guard] artifacts missing after World.Spawn; ensuring locally")
		ensureBaseplateAndSpawn()
	end
end)
