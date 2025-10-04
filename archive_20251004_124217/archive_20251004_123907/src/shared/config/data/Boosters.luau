--!strict
local Boosters = {}

-- All boosters are time-limited and QoL (no hard pay-to-win)
Boosters.Defs = {
    DoubleGearbits15  = { id="DoubleGearbits15",  kind="multiplier", stat="Gearbits", x=2,  durationSec=15*60, priceShards=50 },
    DoubleGearbits30  = { id="DoubleGearbits30",  kind="multiplier", stat="Gearbits", x=2,  durationSec=30*60, priceShards=90 },
    Luck15            = { id="Luck15",            kind="luck",       x=1.25,          durationSec=15*60,      priceShards=60 },
    Magnet15          = { id="Magnet15",          kind="radius",     addStuds=8,      durationSec=15*60,      priceShards=40 },
}

return Boosters
