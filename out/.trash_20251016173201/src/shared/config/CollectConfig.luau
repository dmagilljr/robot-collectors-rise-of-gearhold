--!strict
-- File: CollectConfig.luau
-- v0.6.0-alpha — Per-resource depletion & respawn config (data only)

-- Stacks = how many successful clicks to fully deplete a node.
-- RespawnSec = how long after 0 stacks before the node reappears.
-- ScaleMin = the smallest visual scale fraction at 1 stack remaining.

local CollectConfig = {
	Scrap     = { Stacks = 5, RespawnSec = 25, ScaleMin = 0.35 },
	Energy    = { Stacks = 6, RespawnSec = 30, ScaleMin = 0.40 },
	Components = { Stacks = 5, RespawnSec = 28, ScaleMin = 0.45 },
	RareMetal  = { Stacks = 4, RespawnSec = 40, ScaleMin = 0.50 },
}

return CollectConfig
