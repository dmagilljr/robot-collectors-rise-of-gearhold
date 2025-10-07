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
    return Garage.Mount({
      origin = Vector3.new(24,0,12),
      width  = 8.0,
      height = 8.0,
      depth  = 14.0,
      facing = Vector3.new(0,0,1),
    })
  end)
  if not okGarage then
    warn("[WorldBoot] Garage.Mount failed:", unmountOrErr)
  end

  print(("🌍 WorldBoot ACTIVE %d"):format(os.time()))
end

return WorldBoot
