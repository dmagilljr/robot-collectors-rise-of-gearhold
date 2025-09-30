-- Robot Collectors: Game Constants
-- Centralized configuration for game mechanics

local GameConstants = {
    -- Starting player resources
    STARTING_RESOURCES = {
        Gearbits = 1000,
        IonShards = 50,
        RareMetals = 0,
        Crystals = 0,
    },

    -- Robot movement settings
    ROBOT_HEIGHT = 3.4,
    MAX_ROBOT_DISTANCE = 50,
    FOLLOW_DISTANCE = 8,
    FOLLOW_MIN_RADIUS = 3,
    FOLLOW_REACHED_RADIUS = 2,
    MOVEMENT_SPEED = 8,
    ROBOT_TRAVEL_SPEED = 5,
    MINING_DISTANCE = 5,
    ROBOT_RETURN_DISTANCE = 6,
    ROBOT_HOVER_OFFSET = 1.4,
    HOVER_RAYCAST_HEIGHT = 50,
    AUTO_MINE_SEARCH_RADIUS = 60,
    ROBOT_MINING_INTERVAL = 0.8,
    ROBOT_RESEEK_DELAY = 1.5,
    ROBOT_IDLE_FOLLOW_DELAY = 4,

    -- Player mining settings
    MANUAL_MINING_DISTANCE = 10,

    -- Resource generation settings
    RESOURCE_GENERATION_INTERVAL = 5,
    MOVEMENT_UPDATE_INTERVAL = 0.1,
    UI_UPDATE_INTERVAL = 1,

    -- Resource spawning
    MAX_RESOURCES = 25,
    MIN_RESOURCE_DISTANCE = 15,
    MAX_RESOURCE_DISTANCE = 45,

    -- Resource types
    RESOURCE_TYPES = {
        {Color = Color3.fromRGB(0, 212, 255), Name = "Gearbit"},
        {Color = Color3.fromRGB(150, 0, 255), Name = "Ion Shard"},
        {Color = Color3.fromRGB(255, 215, 0), Name = "Rare Metal"},
        {Color = Color3.fromRGB(255, 255, 255), Name = "Crystal"}
    },

    -- Mining amounts
    MINING_AMOUNTS = {
        Gearbit = {min = 2, max = 5},
        ["Ion Shard"] = {min = 1, max = 3},
        ["Rare Metal"] = {min = 1, max = 2},
        Crystal = {min = 1, max = 1}
    },

    RESOURCE_TO_CURRENCY = {
        Gearbit = "Gearbits",
        ["Ion Shard"] = "IonShards",
        ["Rare Metal"] = "RareMetals",
        Crystal = "Crystals",
    },

    AUDIO = {
        -- Configure with uploaded sound asset IDs or leave blank to disable.
        DRILL_LOOP = "",
        GARAGE_RUMBLE = "",
        GARAGE_DOOR_OPEN = "",
        GARAGE_DOOR_CLOSE = "",
        GARAGE_STEAM = "",
    },

    GARAGE_HOME_POSITION = Vector3.new(18, 0, 5),
}

return GameConstants
