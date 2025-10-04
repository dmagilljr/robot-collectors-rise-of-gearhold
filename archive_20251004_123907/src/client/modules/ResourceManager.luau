-- Robot Collectors: Resource Management System
-- Handles resource display updates and leaderstats monitoring

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local ResourceManager = {}

function ResourceManager.updateResourceDisplay(labels)
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        local gearbits = leaderstats:FindFirstChild("Gearbits")
        local ionShards = leaderstats:FindFirstChild("IonShards")
        local rareMetals = leaderstats:FindFirstChild("RareMetals")
        local crystals = leaderstats:FindFirstChild("Crystals")

        if gearbits then
            labels.gearbits.Text = "⚙️ Gearbits: " .. gearbits.Value
        end
        if ionShards then
            labels.ionShards.Text = "⚡ Ion Shards: " .. ionShards.Value
        end
        if rareMetals then
            labels.rareMetals.Text = "🥇 Rare Metals: " .. rareMetals.Value
        end
        if crystals then
            labels.crystals.Text = "💎 Crystals: " .. crystals.Value
        end
    end
end

function ResourceManager.connectLeaderstats(updateCallback)
    local function connectStats()
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat:IsA("IntValue") then
                    stat.Changed:Connect(updateCallback)
                end
            end
        end
    end

    connectStats()

    Player.ChildAdded:Connect(function(child)
        if child.Name == "leaderstats" then
            for _, stat in pairs(child:GetChildren()) do
                if stat:IsA("IntValue") then
                    stat.Changed:Connect(updateCallback)
                end
            end
        end
    end)
end

return ResourceManager