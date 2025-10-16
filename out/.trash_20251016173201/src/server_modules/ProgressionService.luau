--!strict
-- ProgressionService — minimal player level tracking + unlock check (ModuleScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("shared")

local Unlocks = require(shared:WaitForChild("config"):WaitForChild("Unlocks"))

local levels: {[number]: number} = {}

local LevelChanged = Instance.new("BindableEvent")
LevelChanged.Name = "LevelChanged"

local function getLevel(p: Player): number
	return levels[p.UserId] or 1
end

local function setLevel(p: Player, lv: number)
	lv = math.max(1, math.floor(lv))
	levels[p.UserId] = lv
	LevelChanged:Fire(p, lv)
end

local function isLevelUnlocked(p: Player, resourceType: string): boolean
	local rule = Unlocks.resources[resourceType]
	if not rule then return false end
	return getLevel(p) >= (rule.minLevel or 1)
end

local M = {}
function M:GetLevel(p: Player) return getLevel(p) end
function M:SetLevel(p: Player, lv: number) setLevel(p, lv) end
function M:IsLevelUnlocked(p: Player, resourceType: string) return isLevelUnlocked(p, resourceType) end
function M:LevelChanged() return LevelChanged.Event end

Players.PlayerAdded:Connect(function(p) levels[p.UserId] = levels[p.UserId] or 1 end)
Players.PlayerRemoving:Connect(function(p) levels[p.UserId] = nil end)

return M
