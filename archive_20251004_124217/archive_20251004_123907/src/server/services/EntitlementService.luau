--!strict
local Players = game:GetService("Players")
local SaveService = require(script.Parent.SaveService)

local EntitlementService = {}
print("[Services] EntitlementService module loaded")

-- permanent entitlements (e.g., +Inventory, AutoHatch, +1 Active Robot)
local Known = {
    AutoHatch = true,
    ExtraInventory = true,
    PlusOneActiveRobot = true,
}

function EntitlementService.has(player: Player, name: string): boolean
    if not Known[name] then return false end
    local data = SaveService.loadPlayerData(player.UserId)
    return data.entitlements[name] == true
end

function EntitlementService.grant(player: Player, name: string)
    if not Known[name] then return end
    local data = SaveService.loadPlayerData(player.UserId)
    data.entitlements[name] = true
    SaveService.savePlayerData(player.UserId, data)
end

return EntitlementService
