--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local INIT_VERSION = "v3-init-"..tostring(os.time())
print("🤖 v3 Server Starting", INIT_VERSION)

local World = ServerScriptService:WaitForChild("World")
local RC_RemoteSetup = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("RC_RemoteSetup"))
RC_RemoteSetup.init()

local RC_GarageReset = require(World:WaitForChild("RC_GarageReset"))

-- run after other setup has a chance to spawn stuff
task.delay(0.4, function()
    print("⏩ v3 running RC_GarageReset.run()")
    local ok, err = pcall(function() RC_GarageReset.run() end)
    if not ok then warn("[v3 INIT] RC_GarageReset.run error:", err) end
end)
