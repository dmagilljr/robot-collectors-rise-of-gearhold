--!strict
local BuildGuard = require(game:GetService("ServerScriptService").Modules.BuildGuard)
local Spawn      = require(script.Parent:WaitForChild("Spawn"))
local Garage     = require(script.Parent.Garage.Component)

local WorldBoot = {}

function WorldBoot.run()
  if not BuildGuard.once("WorldBoot") then
    warn("[WorldBoot] already ran; skipping")
    return
  end
  -- spawn
  local okSpawn, errSpawn = pcall(function() Spawn.ensure() end)
  if not okSpawn then
    warn("[WorldBoot] Spawn.ensure() failed:", errSpawn)
  else
    print("[WorldBoot] Spawn ensured")
  end

  -- verify artifacts
  local base = workspace:FindFirstChild("RC_Baseplate")
  local pad  = workspace:FindFirstChild("RC_Spawn")
  print("[WorldBoot] Spawn ready  base@", base and (base :: BasePart).Position, " pad@", pad and (pad :: BasePart).Position)

  -- garage
	local okGarage, unmountOrErr = pcall(function()
	-- If a garage already exists (PlotManager mounted it), skip mounting here
	local existing = workspace:FindFirstChild("GD_Garage") or (function()
		for _,m in ipairs(workspace:GetChildren()) do
			if m:IsA("Model") and m.Name:match("^GD_Garage") then return m end
		end
		return nil
	end)()
	if existing then
		print("[WorldBoot] garage already present; skipping mount (PlotManager likely handled it)")
	else
		-- Auto-place the garage relative to RC_Spawn so it’s visible right away
		local DIST = 40         -- ~“20 steps”; adjust 30..60 to taste
		local s = workspace:FindFirstChild("RC_Spawn") :: SpawnLocation?
		local origin, facing
		if s then
			local spawnPos = s.CFrame.Position
			local fwd      = s.CFrame.LookVector.Unit
			origin = Vector3.new(spawnPos.X, 0, spawnPos.Z) + fwd * DIST
			-- Make the garage face the player: outward = (spawn - origin)
			local look = (spawnPos - origin)
			if look.Magnitude < 1e-3 then
				facing = Vector3.new(0,0,1)         -- fallback
			else
				facing = look.Unit
			end
			print(("[WorldBoot] placing garage: origin=%s facingDir=%s spawn=%s dist=%.1f")
				:format(tostring(origin), tostring(facing), tostring(spawnPos), DIST))
		else
			-- Fallback to previous fixed location if RC_Spawn not found
			origin = Vector3.new(24,0,12)
			facing = Vector3.new(0,0,1)
			warn("[WorldBoot] RC_Spawn not found; using fallback garage origin")
		end

		local _unmount = Garage.Mount({
			origin = origin,
			width  = 16.0,
			height = 14.0,
			depth  = 34.0,
			facing = facing,
		})
	end
	end)
  if not okGarage then
    warn("[WorldBoot] Garage.Mount failed:", unmountOrErr)
  end

  print(("🌍 WorldBoot ACTIVE %d"):format(os.time()))
end

return WorldBoot
