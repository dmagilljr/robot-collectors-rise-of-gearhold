--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ShopClient = {}

function ShopClient.buyBooster(id: string)
    local rf = Remotes:WaitForChild("RequestBuyWithShards")
    local result = rf:InvokeServer({ kind = "booster", id = id })
    return result
end

function ShopClient.buySkin(name: string)
    local rf = Remotes:WaitForChild("RequestBuyWithShards")
    local result = rf:InvokeServer({ kind = "skin", id = name })
    return result
end

function ShopClient.activateBooster(id: string)
    Remotes:WaitForChild("RequestActivateBooster"):FireServer(id)
end

function ShopClient.equipSkin(name: string)
    Remotes:WaitForChild("RequestEquipSkin"):FireServer(name)
end

return ShopClient
