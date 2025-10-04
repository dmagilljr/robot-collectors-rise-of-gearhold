--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local modulesFolder = ServerScriptService:WaitForChild("Modules")

local cachedGarageService: any? = nil

local function getGarageService()
if not cachedGarageService then
        print("[WorldService] requiring GarageService")
        cachedGarageService = require(modulesFolder:WaitForChild("GarageService"))
    end
    return cachedGarageService
end

local WorldService = {}

type RemoteDictionary = {[string]: RemoteEvent | RemoteFunction}
type GarageNotify = (status: string, payload: any?) -> ()

function WorldService.init(remotes: RemoteDictionary)
    local GarageService = getGarageService()
    print("[WorldService] init called", remotes and remotes.ToggleGarageDoor)
    if GarageService.init then
        GarageService.init(remotes)
    end
end

function WorldService.hatchRobot(player: Player, robotType: string, notify: GarageNotify)
    local GarageService = getGarageService()
    return GarageService.hatchRobot(player, robotType, notify)
end

return WorldService
