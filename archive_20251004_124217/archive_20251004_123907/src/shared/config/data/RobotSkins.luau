--!strict
local RobotSkins = {}

RobotSkins.Catalog = {
    -- cosmetic-only; no stats
    "NeoCyan",
    "Obsidian",
    "Aurora",
}

-- map skin -> cosmetic data (placeholder)
RobotSkins.Data = {
    NeoCyan  = { rarity="Rare",  particles=true,  priceShards=120 },
    Obsidian = { rarity="Epic",  particles=false, priceShards=90  },
    Aurora   = { rarity="Legend",particles=true,  priceShards=200 },
}

return RobotSkins
