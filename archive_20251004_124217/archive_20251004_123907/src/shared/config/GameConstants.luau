--!strict

-- Robot Collectors: Game Constants
-- Centralized configuration for game mechanics

local GameConstants = {
    -- Loop cadence (seconds)
    MOVEMENT_TICK = 0.1, -- frame-step movement interval
    MINING_TICK = 0.8, -- auto-mining tick per robot

    -- World & bounds
    CENTER_POS = Vector3.new(0, 0, 0),
    BOUNDARY_RADIUS = 50, -- robots stay within this XZ radius

    -- Economy baseline (kept alongside per-resource tables)
    GEARBITS_PER_TICK = {min = 10, max = 25},
    IONSHARDS_PER_TICK = {min = 2, max = 5},
    RAREMETALS_PER_TICK = {min = 0, max = 2}, -- only if 3+ robots

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
        GARAGE_DOOR_OPEN = "rbxassetid://139398416216012",
        GARAGE_DOOR_CLOSE = "rbxassetid://139398416216012",
        GARAGE_STEAM = "",
        GARAGE_READY_CHIME = "",
        GARAGE_STATUS_START = "",
        GARAGE_STATUS_FAIL = "",
        GARAGE_UPGRADE_CHIME = "",
        GARAGE_APPEARANCE_WHOOSH = "",
    },

    GARAGE_HOME_POSITION = Vector3.new(28, 0, -6),

    GARAGE_UPGRADES = {
        MaxLevel = 5,
        SpeedBonusPerLevel = 0.09,
        EfficiencyBonusPerLevel = 0.25,
        CostPerLevel = {
            [2] = {Gearbits = 150, IonShards = 10},
            [3] = {Gearbits = 260, IonShards = 24, RareMetals = 4},
            [4] = {Gearbits = 420, IonShards = 40, RareMetals = 12},
            [5] = {Gearbits = 650, IonShards = 65, RareMetals = 24, Crystals = 6},
        },
    },

    GARAGE_APPEARANCE = {
        Palettes = {
            {
                Id = "StormSteel",
                Name = "Storm Steel",
                PrimaryColor = Color3.fromRGB(120, 130, 150),
                AccentColor = Color3.fromRGB(90, 200, 255),
                VisorColor = Color3.fromRGB(90, 235, 255),
                RequiresLevel = 1,
            },
            {
                Id = "SolarFlare",
                Name = "Solar Flare",
                PrimaryColor = Color3.fromRGB(210, 140, 70),
                AccentColor = Color3.fromRGB(255, 190, 90),
                VisorColor = Color3.fromRGB(255, 120, 60),
                RequiresLevel = 2,
                Cost = {IonShards = 10},
            },
            {
                Id = "Nebula",
                Name = "Nebula",
                PrimaryColor = Color3.fromRGB(90, 65, 150),
                AccentColor = Color3.fromRGB(150, 110, 255),
                VisorColor = Color3.fromRGB(120, 255, 240),
                RequiresLevel = 3,
                Cost = {IonShards = 18, Crystals = 2},
            },
            {
                Id = "Midnight",
                Name = "Midnight Alloy",
                PrimaryColor = Color3.fromRGB(40, 45, 60),
                AccentColor = Color3.fromRGB(90, 120, 255),
                VisorColor = Color3.fromRGB(0, 205, 255),
                RequiresLevel = 4,
                Cost = {RareMetals = 12, Crystals = 4},
            },
        },
    },
    ENABLE_LOD = true,
}

GameConstants.MOVEMENT_UPDATE_INTERVAL = GameConstants.MOVEMENT_TICK
GameConstants.ROBOT_MINING_INTERVAL = GameConstants.MINING_TICK
GameConstants.MAX_ROBOT_DISTANCE = GameConstants.BOUNDARY_RADIUS

return GameConstants
