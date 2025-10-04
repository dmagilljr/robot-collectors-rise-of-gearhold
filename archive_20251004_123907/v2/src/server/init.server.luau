--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local INIT_VERSION = "init-"..tostring(os.time())

local World = ServerScriptService:WaitForChild("World")
local RemoteSetup = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("RemoteSetup"))
RemoteSetup.init()

local GarageReset = require(World:WaitForChild("GarageReset"))
print("🤖 v2 Server Starting", INIT_VERSION)

-- Defer GarageReset until after any other setup scripts
task.delay(0.5, function()
    print("⏩ v2 Running GarageReset.run()")
    local ok, err = pcall(function() GarageReset.run() end)
    if not ok then warn("[v2 INIT] GarageReset.run error:", err) end
end)
