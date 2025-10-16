--!strict
-- File: MissionDefs.luau
-- v0.6.0-alpha — Data-only mission configuration (shared)
-- Purpose:
--   Centralize mission archetypes, length bands, multipliers, and presets.
--   Kept pure (no side effects). Import from server/client as needed.
-- Notes:
--   - Values mirror ECONOMY.md (Stage 2 plan): short/medium/long bands with reward multipliers.
--   - Tuning should happen here; game code reads, never hard-codes.

export type LengthBand = "SHORT" | "MEDIUM" | "LONG" | "XL" | "XXL"

export type CollectPreset = {
	id: string,
	kind: "collect",
	resourceType: string,
	target: number,
	length: LengthBand,
	-- Calculated guidance for UI/economy; server may override on award
	rewardHint: { scrap: number?, energy: number?, components: number? },
	dropHint: { rarePct: number }, -- UI hint only
}

local MissionDefs = {}

-- ============================================================================
-- Length bands (seconds) and reward multipliers (relative guidance)
-- ============================================================================
MissionDefs.LengthBands = {
	-- ECONOMY.md: <15m, 15–60m, 1–3h, 3–8h, >8h
	SHORT =   { minSec = 5 * 60,   maxSec = 10 * 60,  rewardMult = 1.0,  xpWeight = 1, rarePct = 0.02 },
	MEDIUM =  { minSec = 30 * 60,  maxSec = 60 * 60,  rewardMult = 1.5,  xpWeight = 2, rarePct = 0.05 },
	LONG =    { minSec = 60 * 60,  maxSec = 3 * 3600, rewardMult = 2.0,  xpWeight = 3, rarePct = 0.10 },
	XL =      { minSec = 3 * 3600, maxSec = 8 * 3600, rewardMult = 3.0,  xpWeight = 5, rarePct = 0.15 },
	XXL =     { minSec = 8 * 3600, maxSec = 12* 3600, rewardMult = 4.0,  xpWeight = 8, rarePct = 0.20 },
}

-- ============================================================================
-- Base reward hints by resource type (per collected unit at SHORT band)
-- Server-side economy should compute real payouts; this is UI/config guidance.
-- ============================================================================
MissionDefs.BaseUnitRewards = {
	Scrap = { scrap = 1, energy = 0, components = 0 },
	Energy = { scrap = 0, energy = 1, components = 0 },
	Components = { scrap = 0, energy = 0, components = 1 },
}

-- Optional color hints for HUD/FX mapping (shared)
MissionDefs.ResourceColors = {
	Scrap = Color3.fromRGB(225, 170, 80),
	Energy = Color3.fromRGB(120, 205, 255),
	Components = Color3.fromRGB(200, 200, 220),
}

-- ============================================================================
-- Helpers
-- ============================================================================

local function clampLengthKey(length: LengthBand): LengthBand
	if MissionDefs.LengthBands[length] ~= nil then
		return length
	end
	return "SHORT"
end

local function deepcopyTbl<T>(t: T): T
	local out: any = {}
	for k, v in pairs(t :: any) do
		if type(v) == "table" then
			out[k] = deepcopyTbl(v)
		else
			out[k] = v
		end
	end
	return out
end

local function rewardHintFor(resourceType: string, units: number, length: LengthBand)
	local base = MissionDefs.BaseUnitRewards[resourceType]
	if not base then
		-- Fallback: treat as scrap-equivalent for hinting
		base = MissionDefs.BaseUnitRewards.Scrap
	end
	local len = MissionDefs.LengthBands[clampLengthKey(length)]
	local mult = len and len.rewardMult or 1.0
	local hint = {
		scrap = math.floor((base.scrap or 0) * units * mult + 0.5),
		energy = math.floor((base.energy or 0) * units * mult + 0.5),
		components = math.floor((base.components or 0) * units * mult + 0.5),
	}
	return hint, len.rarePct
end

-- Factory: build a Collect mission preset (data only)
function MissionDefs.makeCollectPreset(resourceType: string, target: number, length: LengthBand): CollectPreset
	length = clampLengthKey(length)
	local reward, rarePct = rewardHintFor(resourceType, target, length)
	local id = string.format("Collect_%s_%d_%s", tostring(resourceType), target, length)
	return {
		id = id,
		kind = "collect",
		resourceType = resourceType,
		target = target,
		length = length,
		rewardHint = reward,
		dropHint = { rarePct = rarePct },
	}
end

-- ============================================================================
-- Presets (MVP examples used by onboarding/tutorial)
-- ============================================================================

MissionDefs.Presets = {
	CollectScrap5_SHORT = MissionDefs.makeCollectPreset("Scrap", 5, "SHORT"),
	CollectEnergy10_MEDIUM = MissionDefs.makeCollectPreset("Energy", 10, "MEDIUM"),
}

-- Convenience accessor (returns deep copy so callers can mutate safely)
function MissionDefs.getPreset(key: string): CollectPreset?
	local p = MissionDefs.Presets[key]
	if not p then return nil end
	return deepcopyTbl(p)
end

return MissionDefs
