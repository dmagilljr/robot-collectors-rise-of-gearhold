--!strict

local M = {}

-- Production toggles ---------------------------------------------------------
M.DEBUG = false

-- World geometry safeguards --------------------------------------------------
M.MIN_GARAGE_RADIUS = 120
M.THIN_TILE_Y_MAX = 1.25
M.GARAGE_DEFAULT_DOOR_CENTER = Vector3.new(0, 8, -46)

-- Legacy gameplay tuning -----------------------------------------------------
M.MOVEMENT_TICK = 0.1 -- seconds
M.MINING_TICK = 0.8 -- seconds
M.CENTER_POS = Vector3.new(0, 0, 0)
M.BOUNDARY_RADIUS = 50
M.GEARBITS_PER_TICK = { min = 10, max = 25 }
M.IONSHARDS_PER_TICK = { min = 2, max = 5 }
M.RAREMETALS_PER_TICK = { min = 0, max = 2 }

return M
