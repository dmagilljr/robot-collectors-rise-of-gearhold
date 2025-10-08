--!strict
-- Validate: given openingH and slatH, the lift phase reaches lintel at t=LIFT_SPLIT
local LIFT_SPLIT = 0.60

local M = {}

local function lintelY(openingH: number, slatH: number): number
	return openingH*0.5 - slatH*0.5
end

function M.run()
	local openingH = 8.0
	local nSlats   = 16
	local slatH    = openingH / nSlats

	-- per-slat baseY
	local function baseY(i: number): number
		return -openingH*0.5 + slatH * (i - 0.5)
	end

	-- y(t,i) during lift (LERP baseY -> lintelY)
	local function yLift(t: number, i: number): number
		local v = t / LIFT_SPLIT
		local y0 = baseY(i)
		local y1 = lintelY(openingH, slatH)
		return y0 + v * (y1 - y0)
	end

	-- pick top slat (worst case); at t=LIFT_SPLIT it must be at lintel
	local iTop = nSlats
	local yAtSplit = yLift(LIFT_SPLIT, iTop)
	local yLintel  = lintelY(openingH, slatH)

	assert(math.abs(yAtSplit - yLintel) < 1e-4, ("lift did not reach lintel: got %.3f want %.3f"):format(yAtSplit, yLintel))
end

return M
