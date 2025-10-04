--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local modulesFolder = ServerScriptService:WaitForChild("Modules")

local cachedRobotManager: any? = nil

local function getRobotManager()
    if not cachedRobotManager then
        cachedRobotManager = require(modulesFolder:WaitForChild("RobotManager"))
    end
    return cachedRobotManager
end

local RobotService = {}
print("[Services] RobotService module loaded")

function RobotService.spawnRobot(...)
    local RobotManager = getRobotManager()
    return RobotManager.spawnRobot(...)
end

function RobotService.setRobotState(robotId: string, newState: string, player: Player)
    local RobotManager = getRobotManager()
    return RobotManager.setRobotState(robotId, newState, player)
end

function RobotService.assignRobotToResource(robotId: string, resourceNode: Instance, player: Player)
    local RobotManager = getRobotManager()
    return RobotManager.assignRobotToResource(robotId, resourceNode, player)
end

function RobotService.applyUpgrade(uniqueId: string, newLevel: number, player: Player)
    local RobotManager = getRobotManager()
    return RobotManager.applyUpgrade(uniqueId, newLevel, player)
end

function RobotService.applyAppearance(uniqueId: string, appearance: any, player: Player)
    local RobotManager = getRobotManager()
    return RobotManager.applyAppearance(uniqueId, appearance, player)
end

function RobotService.startMovementUpdates()
    local RobotManager = getRobotManager()
    RobotManager.startMovementUpdates()
end

function RobotService.despawnRobotsForPlayer(player: Player)
    local RobotManager = getRobotManager()
    RobotManager.despawnRobotsForPlayer(player)
end

return RobotService
