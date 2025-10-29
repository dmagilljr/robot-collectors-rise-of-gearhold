--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local servicesFolder = ServerScriptService:FindFirstChild("Services")
assert(servicesFolder, "[StorageService] Services folder missing under ServerScriptService")

local RC_Remotes = ReplicatedStorage:FindFirstChild("RC_Remotes")
assert(RC_Remotes, "[StorageService] RC_Remotes missing")

local RequestStorageView = RC_Remotes:FindFirstChild("RequestStorageView") :: RemoteFunction?
local OpenStorageUI = RC_Remotes:FindFirstChild("OpenStorageUI") :: RemoteEvent?
local DepositAll = RC_Remotes:FindFirstChild("DepositAll") :: RemoteEvent?

assert(RequestStorageView and RequestStorageView:IsA("RemoteFunction"), "[StorageService] RequestStorageView RemoteFunction missing")
assert(OpenStorageUI and OpenStorageUI:IsA("RemoteEvent"), "[StorageService] OpenStorageUI RemoteEvent missing")
assert(DepositAll and DepositAll:IsA("RemoteEvent"), "[StorageService] DepositAll RemoteEvent missing")

local BackpackService = require(servicesFolder:WaitForChild("BackpackService"))

type Counts = { [string]: number }

local StorageService = {}
StorageService.__index = StorageService

local _storage: { [Player]: Counts } = {}

local function _getStore(player: Player): Counts
	local stash = _storage[player]
	if not stash then
		stash = {}
		_storage[player] = stash
	end
	return stash
end

DepositAll.OnServerEvent:Connect(function(player: Player)
	local stash = _getStore(player)
	local grabbed = BackpackService.TakeAll(player)
	for resource, amount in pairs(grabbed) do
		if amount > 0 then
			stash[resource] = (stash[resource] or 0) + amount
		end
	end
end)

RequestStorageView.OnServerInvoke = function(player: Player)
	local stash = _getStore(player)
	local bag = BackpackService.Get(player)
	local usedSlots = 0
	for _, qty in pairs(bag.counts) do
		if qty > 0 then
			usedSlots += 1
		end
	end

	return {
		storage = stash,
		backpack = {
			slots = bag.slots,
			used = usedSlots,
			counts = bag.counts,
		},
	}
end

Players.PlayerRemoving:Connect(function(player)
	_storage[player] = nil
end)

return StorageService

