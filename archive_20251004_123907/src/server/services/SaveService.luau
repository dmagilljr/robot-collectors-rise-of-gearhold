--!strict
-- In-memory stub; swap to Datastores later
local SaveService = {}
print("[Services] SaveService module loaded")
local _store: {[number]: any} = {}

function SaveService.loadPlayerData(userId: number): any
    _store[userId] = _store[userId] or {
        currencies = { Gearbits = 1000, IonShards = 50, RareMetals = 0, Crystals = 0 },
        boosters = {},        -- [{id, expiresAt}]
        skinsOwned = {},      -- { [skinName]=true }
        entitlements = {},    -- gamepass-style flags
    }
    return _store[userId]
end

function SaveService.savePlayerData(userId: number, data: any)
    _store[userId] = data
end

return SaveService
