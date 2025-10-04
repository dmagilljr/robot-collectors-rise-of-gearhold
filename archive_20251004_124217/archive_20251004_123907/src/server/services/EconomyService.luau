--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaveService = require(script.Parent.SaveService)
local Boosters = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("data"):WaitForChild("Boosters"))
local _Currencies = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("data"):WaitForChild("Currencies"))

local EconomyService = {}
print("[Services] EconomyService module loaded")

local function now(): number
    return os.time()
end

function EconomyService.getData(player: Player)
    return SaveService.loadPlayerData(player.UserId)
end

function EconomyService.addCurrency(player: Player, currencyId: string, amount: number)
    local data = SaveService.loadPlayerData(player.UserId)
    local cur = data.currencies
    if cur[currencyId] == nil then cur[currencyId] = 0 end
    cur[currencyId] += amount
    SaveService.savePlayerData(player.UserId, data)
    return true
end

function EconomyService.trySpendIonShards(player: Player, cost: number): (boolean, string?)
    local data = SaveService.loadPlayerData(player.UserId)
    if (data.currencies.IonShards or 0) < cost then
        return false, "NOT_ENOUGH_SHARDS"
    end
    data.currencies.IonShards -= cost
    SaveService.savePlayerData(player.UserId, data)
    return true
end

function EconomyService.activateBooster(player: Player, boosterId: string): (boolean, string?)
    local def = Boosters.Defs[boosterId]
    if not def then return false, "UNKNOWN_BOOSTER" end
    local data = SaveService.loadPlayerData(player.UserId)
    local ok, err = EconomyService.trySpendIonShards(player, def.priceShards)
    if not ok then return false, err end
    local expiresAt = now() + def.durationSec
    table.insert(data.boosters, { id = boosterId, expiresAt = expiresAt })
    SaveService.savePlayerData(player.UserId, data)
    return true
end

function EconomyService.consumeActiveBoost(player: Player, stat: string): number
    local data = SaveService.loadPlayerData(player.UserId)
    local t = now()
    local mult = 1
    for _, b in ipairs(data.boosters) do
        if b.expiresAt > t then
            local def = Boosters.Defs[b.id]
            if def and def.kind == "multiplier" and def.stat == stat then
                mult *= def.x
            end
        end
    end
    return mult
end

return EconomyService
