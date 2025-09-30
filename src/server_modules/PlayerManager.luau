-- Robot Collectors: Player Data Management
-- Handles player data initialization, storage, and leaderstats

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("config")
local GameConstants = require(Config:WaitForChild("GameConstants"))

local RobotTypes = require(Config:WaitForChild("RobotTypes"))

local PlayerManager = {}
local playerData = {}

local function cloneTable(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function getLeaderstat(player, statName)
    local leaderstats = player:FindFirstChild("leaderstats")
    return leaderstats and leaderstats:FindFirstChild(statName) or nil
end

function PlayerManager.initializePlayer(player)
    if playerData[player.UserId] then
        return
    end

    playerData[player.UserId] = {
        Currency = cloneTable(GameConstants.STARTING_RESOURCES),
        Robots = {},
        Level = 1,
    }

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    for currencyName, startingValue in pairs(GameConstants.STARTING_RESOURCES) do
        local stat = Instance.new("IntValue")
        stat.Name = currencyName
        stat.Value = startingValue
        stat.Parent = leaderstats
    end

    local robotsStat = Instance.new("IntValue")
    robotsStat.Name = "Robots"
    robotsStat.Value = 0
    robotsStat.Parent = leaderstats

    print("✅ Player", player.Name, "initialized with starting resources")
end

function PlayerManager.cleanupPlayer(player)
    local playerId = player.UserId
    if playerData[playerId] then
        playerData[playerId] = nil
    end
end

function PlayerManager.getPlayerData(playerId)
    return playerData[playerId]
end

function PlayerManager.updatePlayerCurrency(playerId, currencyType, amount)
    local data = playerData[playerId]
    if data and data.Currency[currencyType] then
        data.Currency[currencyType] += amount

        local player = Players:GetPlayerByUserId(playerId)
        if player then
            local stat = getLeaderstat(player, currencyType)
            if stat then
                stat.Value = data.Currency[currencyType]
            end
        end
    end
end

function PlayerManager.canAffordRobot(playerId, robotType)
    local data = playerData[playerId]
    if not data then
        return false
    end

    local robotConfig = RobotTypes[robotType]
    if not robotConfig then
        return false
    end

    for currencyType, amount in pairs(robotConfig.Cost) do
        if (data.Currency[currencyType] or 0) < amount then
            return false
        end
    end

    return true
end

function PlayerManager.purchaseRobot(playerId, robotType)
    local data = playerData[playerId]
    if not data then
        return false
    end

    local robotConfig = RobotTypes[robotType]
    if not robotConfig then
        return false
    end

    for currencyType, amount in pairs(robotConfig.Cost) do
        PlayerManager.updatePlayerCurrency(playerId, currencyType, -amount)
    end

    return true
end

function PlayerManager.addRobotToPlayer(playerId, robotData)
    local data = playerData[playerId]
    if data then
        table.insert(data.Robots, robotData)

        local player = Players:GetPlayerByUserId(playerId)
        if player then
            local stat = getLeaderstat(player, "Robots")
            if stat then
                stat.Value = #data.Robots
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    PlayerManager.initializePlayer(player)
end)

return PlayerManager
