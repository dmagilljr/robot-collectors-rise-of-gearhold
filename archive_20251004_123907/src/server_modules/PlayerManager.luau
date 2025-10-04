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

local function copyAppearance(appearance)
    if not appearance then
        return nil
    end
    local copy = {}
    for key, value in pairs(appearance) do
        copy[key] = value
    end
    return copy
end

local function formatCost(costs)
    local segments = {}
    for currency, amount in pairs(costs) do
        table.insert(segments, string.format("%s:%d", currency, amount))
    end
    return table.concat(segments, ", ")
end

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
        robotData.Level = robotData.Level or 1
        robotData.Appearance = copyAppearance(robotData.Appearance)
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

local function getRobotEntry(playerId, uniqueId)
    local data = playerData[playerId]
    if not data then
        return nil, nil, nil
    end

    for index, robot in ipairs(data.Robots) do
        if robot.UniqueId == uniqueId then
            return robot, index, data
        end
    end

    return nil, nil, data
end

local function hasCurrency(data, costs)
    for currencyType, amount in pairs(costs) do
        if (data.Currency[currencyType] or 0) < amount then
            return false
        end
    end
    return true
end

local function applyCosts(playerId, data, costs)
    for currencyType, amount in pairs(costs) do
        PlayerManager.updatePlayerCurrency(playerId, currencyType, -amount)
    end
end

local function serializeRobot(robot)
    local appearance = robot.Appearance and copyAppearance(robot.Appearance) or nil
    return {
        uniqueId = robot.UniqueId,
        shortId = string.sub(robot.UniqueId, 1, 8),
        name = robot.Name,
        type = robot.Type,
        rarity = robot.Rarity,
        level = robot.Level or 1,
        appearance = appearance,
    }
end

function PlayerManager.getRobotSummaries(playerId)
    local data = playerData[playerId]
    if not data then
        return {}
    end

    local summaries = {}
    for _, robot in ipairs(data.Robots) do
        table.insert(summaries, serializeRobot(robot))
    end
    return summaries
end

function PlayerManager.getRobotSummary(playerId, uniqueId)
    local robot = getRobotEntry(playerId, uniqueId)
    if not robot then
        return nil
    end
    return serializeRobot(robot)
end

function PlayerManager.upgradeRobot(playerId, uniqueId)
    local upgradeConfig = GameConstants.GARAGE_UPGRADES or {}
    local robot, _, data = getRobotEntry(playerId, uniqueId)
    if not (robot and data) then
        return false, "Robot not found"
    end

    local currentLevel = robot.Level or 1
    local maxLevel = upgradeConfig.MaxLevel or 1
    if currentLevel >= maxLevel then
        return false, "Robot already at max level"
    end

    local nextLevel = currentLevel + 1
    local costs = upgradeConfig.CostPerLevel and upgradeConfig.CostPerLevel[nextLevel]
    if not costs then
        return false, "No upgrade path for this level"
    end

    if not hasCurrency(data, costs) then
        return false, "Not enough resources"
    end

    applyCosts(playerId, data, costs)
    robot.Level = nextLevel

    local player = Players:GetPlayerByUserId(playerId)
    print(string.format("🚀 %s upgraded %s to level %d (cost: %s)", player and player.Name or tostring(playerId), robot.Name, robot.Level, formatCost(costs)))
    return true, serializeRobot(robot), costs
end

function PlayerManager.updateRobotAppearance(playerId, uniqueId, paletteId)
    local appearanceConfig = GameConstants.GARAGE_APPEARANCE or {}
    local palettes = appearanceConfig.Palettes or {}

    local palette
    for _, entry in ipairs(palettes) do
        if entry.Id == paletteId then
            palette = entry
            break
        end
    end

    if not palette then
        return false, "Appearance option unavailable"
    end

    local robot, _, data = getRobotEntry(playerId, uniqueId)
    if not robot or not data then
        return false, "Robot not found"
    end

    local requiredLevel = palette.RequiresLevel or 1
    if (robot.Level or 1) < requiredLevel then
        return false, string.format("Requires level %d", requiredLevel)
    end

    if palette.Cost and not hasCurrency(data, palette.Cost) then
        return false, "Not enough resources"
    end

    robot.Appearance = {
        PaletteId = palette.Id,
        PrimaryColor = palette.PrimaryColor,
        AccentColor = palette.AccentColor,
        VisorColor = palette.VisorColor,
    }

    if palette.Cost then
        applyCosts(playerId, data, palette.Cost)
    end

    local player = Players:GetPlayerByUserId(playerId)
    if palette.Cost then
        print(string.format("🎨 %s applied palette %s to %s (cost: %s)", player and player.Name or tostring(playerId), palette.Name, robot.Name, formatCost(palette.Cost)))
    else
        print(string.format("🎨 %s applied palette %s to %s", player and player.Name or tostring(playerId), palette.Name, robot.Name))
    end

    return true, serializeRobot(robot)
end

function PlayerManager.getAppearancePalette(paletteId)
    local appearanceConfig = GameConstants.GARAGE_APPEARANCE or {}
    local palettes = appearanceConfig.Palettes or {}
    for _, entry in ipairs(palettes) do
        if entry.Id == paletteId then
            return entry
        end
    end
    return nil
end

Players.PlayerAdded:Connect(function(player)
    PlayerManager.initializePlayer(player)
end)

return PlayerManager
