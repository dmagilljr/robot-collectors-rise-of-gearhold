--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local modulesFolder = ServerScriptService:WaitForChild("Modules")

local cachedPlayerManager: any? = nil

local function getPlayerManager()
    if not cachedPlayerManager then
        cachedPlayerManager = require(modulesFolder:WaitForChild("PlayerManager"))
    end
    return cachedPlayerManager
end

local PlayerService = {}
print("[Services] PlayerService module loaded")

type RobotAppearance = {[string]: any}

type RobotSummary = {
    uniqueId: string,
    robotType: string,
    nickname: string?,
    level: number,
    appearance: RobotAppearance?,
}

function PlayerService.initializePlayer(player: Player)
    local PlayerManager = getPlayerManager()
    PlayerManager.initializePlayer(player)
end

function PlayerService.cleanupPlayer(player: Player)
    local PlayerManager = getPlayerManager()
    PlayerManager.cleanupPlayer(player)
end

function PlayerService.getPlayerData(playerId: number)
    local PlayerManager = getPlayerManager()
    return PlayerManager.getPlayerData(playerId)
end

function PlayerService.updatePlayerCurrency(playerId: number, currencyType: string, amount: number)
    local PlayerManager = getPlayerManager()
    PlayerManager.updatePlayerCurrency(playerId, currencyType, amount)
end

function PlayerService.canAffordRobot(playerId: number, robotType: string): boolean
    local PlayerManager = getPlayerManager()
    return PlayerManager.canAffordRobot(playerId, robotType)
end

function PlayerService.purchaseRobot(playerId: number, robotType: string): boolean
    local PlayerManager = getPlayerManager()
    return PlayerManager.purchaseRobot(playerId, robotType)
end

function PlayerService.addRobotToPlayer(playerId: number, robotData: RobotSummary)
    local PlayerManager = getPlayerManager()
    PlayerManager.addRobotToPlayer(playerId, robotData)
end

function PlayerService.getRobotSummaries(playerId: number)
    local PlayerManager = getPlayerManager()
    return PlayerManager.getRobotSummaries(playerId)
end

function PlayerService.getRobotSummary(playerId: number, uniqueId: string)
    local PlayerManager = getPlayerManager()
    return PlayerManager.getRobotSummary(playerId, uniqueId)
end

function PlayerService.upgradeRobot(playerId: number, uniqueId: string)
    local PlayerManager = getPlayerManager()
    return PlayerManager.upgradeRobot(playerId, uniqueId)
end

function PlayerService.updateRobotAppearance(playerId: number, uniqueId: string, paletteId: string)
    local PlayerManager = getPlayerManager()
    return PlayerManager.updateRobotAppearance(playerId, uniqueId, paletteId)
end

function PlayerService.getAppearancePalette(paletteId: string)
    local PlayerManager = getPlayerManager()
    return PlayerManager.getAppearancePalette(paletteId)
end

return PlayerService
