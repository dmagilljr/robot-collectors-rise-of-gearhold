--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local sharedFolder = ReplicatedStorage:FindFirstChild("shared") or ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	error("[BackpackService] shared folder missing in ReplicatedStorage")
end

local configFolder = sharedFolder:FindFirstChild("config")
if not configFolder then
	error("[BackpackService] shared/config folder missing in ReplicatedStorage.shared")
end

local InventoryConfigModule = configFolder:FindFirstChild("InventoryConfig")
if not InventoryConfigModule then
	error("[BackpackService] InventoryConfig missing at ReplicatedStorage/shared/config/InventoryConfig")
end

local InventoryConfig = require(InventoryConfigModule)

local RC_Remotes = ReplicatedStorage:FindFirstChild("RC_Remotes")
assert(RC_Remotes, "[BackpackService] RC_Remotes missing")

local BackpackUpdated = RC_Remotes:FindFirstChild("BackpackUpdated") :: RemoteEvent?
assert(BackpackUpdated and BackpackUpdated:IsA("RemoteEvent"), "[BackpackService] BackpackUpdated RemoteEvent missing")

type Counts = { [string]: number }
type Backpack = {
	slots: number,
	counts: Counts,
}

local BackpackService = {}
BackpackService.__index = BackpackService

-- Player → Backpack
local _bags: { [Player]: Backpack } = {}

local function _usedSlots(counts: Counts): number
	local used = 0
	for _, qty in pairs(counts) do
		if qty > 0 then
			used += 1
		end
	end
	return used
end

local function _emit(player: Player)
	local bag = _bags[player]
	if not bag then
		return
	end
	BackpackUpdated:FireClient(player, {
		slots = _usedSlots(bag.counts),
		total = bag.slots,
		counts = bag.counts,
	})
end

function BackpackService.Ensure(player: Player): Backpack
	local bag = _bags[player]
	if bag then
		return bag
	end
	bag = {
		slots = InventoryConfig.DEFAULT_SLOTS,
		counts = {},
	}
	_bags[player] = bag
	_emit(player)
	return bag
end

function BackpackService.Add(player: Player, resource: string, qty: number): boolean
	if qty <= 0 then
		return false
	end
	local bag = BackpackService.Ensure(player)
	local counts = bag.counts
	local currentlyUsed = _usedSlots(counts)
	local hasKey = (counts[resource] or 0) > 0
	if not hasKey and currentlyUsed >= bag.slots then
		return false -- no free slots for a new resource type
	end
	counts[resource] = math.clamp((counts[resource] or 0) + qty, 0, InventoryConfig.STACK_SIZE)
	_emit(player)
	return true
end

function BackpackService.TakeAll(player: Player): Counts
	local bag = BackpackService.Ensure(player)
	local out: Counts = {}
	for resource, amount in pairs(bag.counts) do
		out[resource] = amount
		bag.counts[resource] = 0
	end
	_emit(player)
	return out
end

function BackpackService.Get(player: Player): Backpack
	return BackpackService.Ensure(player)
end

function BackpackService.Upgrade(player: Player, delta: number): boolean
	local bag = BackpackService.Ensure(player)
	local target = math.clamp(bag.slots + delta, InventoryConfig.DEFAULT_SLOTS, InventoryConfig.MAX_SLOTS)
	if target ~= bag.slots then
		bag.slots = target
		_emit(player)
		return true
	end
	return false
end

Players.PlayerRemoving:Connect(function(player)
	_bags[player] = nil
end)

return BackpackService

