--!strict
local Remotes = {}

-- existing names kept; add monetization channels
Remotes.Manifest = {
    RobotCountChanged = { type = "event" },

    -- monetization events
    RequestActivateBooster = { type = "event" },   -- client -> server (intent)
    RequestEquipSkin       = { type = "event" },   -- client -> server (intent)
    RequestBuyWithShards   = { type = "function" } -- client -> server -> returns {ok, err}
}

-- very light validation (Studio-only toggle if you want)
function Remotes.validate(_name: string, _payload: any): boolean
    -- TODO: add schema checks per name
    return true
end

return Remotes
