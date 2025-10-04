--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local function getServices()
    local services = _G.RC_Services
    if services and services.EconomyService and services.SaveService then
        return services
    end
    return nil
end

local BuyFn = RemotesFolder:WaitForChild("RequestBuyWithShards")
BuyFn.OnServerInvoke = function(player, payload)
    local services = getServices()
    if not services then
        return { ok = false, err = "SERVICES_UNAVAILABLE" }
    end
    local Economy = services.EconomyService
    if type(payload) ~= "table" then
        return { ok = false, err = "BAD_PAYLOAD" }
    end

    local kind = payload.kind
    local id = payload.id
    if typeof(id) ~= "string" then
        return { ok = false, err = "BAD_ID" }
    end

    if kind == "booster" then
        local ok, err = Economy.activateBooster(player, id)
        return { ok = ok, err = err }
    elseif kind == "skin" then
        local Skins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("data"):WaitForChild("RobotSkins"))
        local def = Skins.Data[id]
        if not def then
            return { ok = false, err = "UNKNOWN_SKIN" }
        end
        local ok, err = services.EconomyService.trySpendIonShards(player, def.priceShards)
        if not ok then
            return { ok = false, err = err }
        end
        local data = services.SaveService.loadPlayerData(player.UserId)
        data.skinsOwned[id] = true
        services.SaveService.savePlayerData(player.UserId, data)
        return { ok = true }
    else
        return { ok = false, err = "UNKNOWN_KIND" }
    end
end

local ActivateBooster = RemotesFolder:WaitForChild("RequestActivateBooster")
ActivateBooster.OnServerEvent:Connect(function(player, boosterId)
    local services = getServices()
    if typeof(boosterId) ~= "string" then
        return
    end
    if services then
        services.EconomyService.activateBooster(player, boosterId)
    end
end)

local EquipSkin = RemotesFolder:WaitForChild("RequestEquipSkin")
EquipSkin.OnServerEvent:Connect(function(player, skinName)
    local services = getServices()
    if typeof(skinName) ~= "string" then
        return
    end
    if not services then
        return
    end
    local data = services.SaveService.loadPlayerData(player.UserId)
    if data.skinsOwned[skinName] then
        data.lastEquippedSkin = skinName
        services.SaveService.savePlayerData(player.UserId, data)
    end
end)
