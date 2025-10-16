--!strict
-- ResourceService.server.luau
-- Basic server-side resource tracking for Robot Collectors.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local shared = ReplicatedStorage:WaitForChild("shared")

local RESOURCE_TYPES = {
	Scrap = true,
	Energy = true,
}

-- Ensure shared RemoteEvent folder
local remoteFolder = ReplicatedStorage:FindFirstChild("RC_Remotes")
if not remoteFolder then
	remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "RC_Remotes"
	remoteFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name: string): RemoteEvent
	local remote = remoteFolder:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end
	if remote then
		remote:Destroy()
	end
	local evt = Instance.new("RemoteEvent")
	evt.Name = name
	evt.Parent = remoteFolder
	return evt
end

local collectRemote = ensureRemote("CollectResource")
local depositRemote = ensureRemote("DepositAll")
local deltaRemote = ensureRemote("ResourceDelta")
local syncRemote = ensureRemote("ResourceSync")

type ResourceState = {
	Scrap: number,
	Energy: number,
}

local resourceByUser: {[number]: ResourceState} = {}

local function cloneState(state: ResourceState): ResourceState
	return {
		Scrap = state.Scrap,
		Energy = state.Energy,
	}
end

local function getStateFor(player: Player): ResourceState
	local userId = player.UserId
	local existing = resourceByUser[userId]
	if existing then
		return existing
	end
	local fresh = { Scrap = 0, Energy = 0 }
	resourceByUser[userId] = fresh
	return fresh
end

local function sendSync(player: Player)
	local state = getStateFor(player)
	syncRemote:FireClient(player, cloneState(state))
end

local function sendDelta(player: Player, payload: {[string]: any})
	deltaRemote:FireClient(player, payload)
end

local function signalMissionCollect(player: Player, resourceType: string, amount: number)
	local evt = ServerStorage:FindFirstChild("RC_ServerCollected")
	if evt and evt:IsA("BindableEvent") then
		evt:Fire(player, resourceType, amount)
	end
end

local function handleCollect(player: Player, resourceType: string, amount: number?)
	if typeof(resourceType) ~= "string" or not RESOURCE_TYPES[resourceType] then
		warn(string.format("[ResourceService] Ignoring collect with invalid resource '%s' from %s", tostring(resourceType), player.Name))
		return
	end
	if typeof(amount) ~= "number" or amount <= 0 then
		warn(string.format("[ResourceService] Ignoring collect with invalid amount '%s' from %s", tostring(amount), player.Name))
		return
	end

	local state = getStateFor(player)
	local before = state[resourceType] or 0
	state[resourceType] = before + amount
	print(string.format("[ResourceService] %s collected %s %.2f (total=%.2f)", player.Name, resourceType, amount, state[resourceType]))

	sendDelta(player, {
		type = resourceType,
		delta = amount,
		totals = cloneState(state),
	})

	signalMissionCollect(player, resourceType, amount)
end

collectRemote.OnServerEvent:Connect(function(player: Player, resourceType: string, amount: number?)
	local ok, err = pcall(handleCollect, player, resourceType, amount)
	if not ok then
		warn("[ResourceService] Collect handler failed:", err)
	end
end)

local function handleDepositAll(player: Player)
	local state = getStateFor(player)
	local deposited = cloneState(state)

	if deposited.Scrap == 0 and deposited.Energy == 0 then
		print(string.format("[ResourceService] %s tried to deposit with empty inventory", player.Name))
		return
	end

	state.Scrap = 0
	state.Energy = 0
	print(string.format("[ResourceService] %s deposited Scrap=%.2f Energy=%.2f", player.Name, deposited.Scrap, deposited.Energy))

	sendDelta(player, {
		type = "DepositAll",
		delta = -(deposited.Scrap + deposited.Energy),
		deposited = deposited,
		totals = cloneState(state),
		message = string.format("Deposited Scrap=%d, Energy=%d", deposited.Scrap, deposited.Energy),
	})
	sendSync(player)
end

depositRemote.OnServerEvent:Connect(function(player: Player)
	local ok, err = pcall(handleDepositAll, player)
	if not ok then
		warn("[ResourceService] Deposit handler failed:", err)
	end
end)

local collectBridge = Instance.new("BindableEvent")
collectBridge.Name = "CollectRequest"
collectBridge.Parent = script
collectBridge.Event:Connect(function(player: Player, resourceType: string, amount: number?)
	local ok, err = pcall(handleCollect, player, resourceType, amount)
	if not ok then
		warn("[ResourceService] Collect bridge failed:", err)
	end
end)

local depositBridge = Instance.new("BindableEvent")
depositBridge.Name = "DepositRequest"
depositBridge.Parent = script
depositBridge.Event:Connect(function(player: Player)
	local ok, err = pcall(handleDepositAll, player)
	if not ok then
		warn("[ResourceService] Deposit bridge failed:", err)
	end
end)

local function onPlayerAdded(player: Player)
	getStateFor(player)
	print(string.format("[ResourceService] Tracking resources for %s (%d)", player.Name, player.UserId))
	task.defer(sendSync, player)
end

local function onPlayerRemoving(player: Player)
	local userId = player.UserId
	resourceByUser[userId] = nil
	print(string.format("[ResourceService] Released resources for %s (%d)", player.Name, userId))
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

print("[ResourceService] Initialized")
