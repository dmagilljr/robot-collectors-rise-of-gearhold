--!strict
local Currencies = {}

-- Primary soft currency (always earnable)
Currencies.Gearbits = {
    id = "Gearbits",
    symbol = "⚙️",
    earnable = true,
    premium = false,
}

-- Premium currency with small daily earn + purchasable packs
Currencies.IonShards = {
    id = "IonShards",
    symbol = "⚡",
    earnable = true,   -- small drip via dailies/achievements
    premium = true,
}

-- Progression/late-game (crafting, prestige sinks)
Currencies.RareMetals = { id = "RareMetals", symbol = "🥇", earnable = true, premium = false }
Currencies.Crystals   = { id = "Crystals",   symbol = "💎", earnable = true, premium = false }

return Currencies
