--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ResourceTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("ResourceTypes"))
type ResourceDefinition = ResourceTypes.ResourceDefinition
type NodeState = {instance: BasePart, definition: ResourceDefinition, hitPoints: number, respawnJob: thread?}
local SPAWN_TAG = "ResourceSpawn"
local nodes: {[BasePart]: NodeState} = {}
local listeners: {RBXScriptConnection} = {}
local running = false
local function log(message: string, ...: any)
	print(string.format("[ResourceSystem] " .. message, ...))
end

local function pickFromTable(tableId: string): ResourceDefinition?
	local tableDef = ResourceTypes.SpawnTables[tableId]
	if not tableDef then return nil end
	local total = 0
	for _, entry in ipairs(tableDef.entries) do total += entry.weight end
	if total <= 0 then return nil end
	local roll, sum = math.random(1, total), 0
	for _, entry in ipairs(tableDef.entries) do
		sum += entry.weight
		if roll <= sum then return ResourceTypes.Definitions[entry.resourceId] end
	end
	return nil
end
local function resolveDefinition(spawn: BasePart): ResourceDefinition?
	local direct = spawn:GetAttribute("ResourceId")
	if typeof(direct) == "string" then return ResourceTypes.Definitions[direct] end
	local tableId = spawn:GetAttribute("ResourceTableId")
	if typeof(tableId) == "string" then return pickFromTable(tableId) end
	return nil
end
local function setAttributes(part: BasePart, def: ResourceDefinition, hp: number, active: boolean)
	for key, value in pairs({
		ResourceId = def.id,
		ResourceTier = def.tier,
		ResourceHitPoints = hp,
		ResourceMaxHitPoints = def.maxHitPoints,
		ResourceRespawnTime = def.respawnTime,
		ResourceActive = active,
	}) do
		part:SetAttribute(key, value)
	end
	part.Transparency = active and 0 or 1
	part.CanCollide = active; part.CanTouch = active
end
local function activate(state: NodeState)
	state.hitPoints = state.definition.maxHitPoints
	if state.respawnJob then
		task.cancel(state.respawnJob); state.respawnJob = nil
	end
	setAttributes(state.instance, state.definition, state.hitPoints, true)
	log("Spawned %s", state.definition.id)
end
local function scheduleRespawn(state: NodeState)
	if state.respawnJob then
		task.cancel(state.respawnJob)
	end
	setAttributes(state.instance, state.definition, 0, false)
	local delaySeconds = state.definition.respawnTime
	state.respawnJob = task.delay(delaySeconds, function()
		state.respawnJob = nil
		activate(state)
	end)
	log("Despawned %s, respawn in %d", state.definition.id, delaySeconds)
end
local function register(spawn: BasePart)
	local definition = resolveDefinition(spawn)
	if not definition then
		warn(string.format("No resource definition for %s", spawn:GetFullName()))
		return
	end
	nodes[spawn] = {instance = spawn, definition = definition, hitPoints = definition.maxHitPoints, respawnJob = nil}
	activate(nodes[spawn])
end
local function unregister(spawn: BasePart)
	local state = nodes[spawn]
	if not state then
		return
	end
	if state.respawnJob then
		task.cancel(state.respawnJob)
	end
	nodes[spawn] = nil
	log("Removed %s", spawn:GetFullName())
end
local ResourceSystem = {}
function ResourceSystem.start(): ()
	if running then
		return
	end
	running = true
	for _, instance in CollectionService:GetTagged(SPAWN_TAG) do
		if instance:IsA("BasePart") then
			register(instance)
		end
	end
	listeners = {
		CollectionService:GetInstanceAddedSignal(SPAWN_TAG):Connect(function(instance: Instance)
			if running and instance:IsA("BasePart") then
				register(instance)
			end
		end),
		CollectionService:GetInstanceRemovedSignal(SPAWN_TAG):Connect(function(instance: Instance)
			if instance:IsA("BasePart") then
				unregister(instance)
			end
		end),
	}
	log("Resource system started")
end
function ResourceSystem.stop(): ()
	if not running then
		return
	end
	running = false
    for _, connection in ipairs(listeners) do
        connection:Disconnect()
    end
    listeners = {}
    for spawn, _ in pairs(nodes) do
        unregister(spawn)
    end
	log("Resource system stopped")
end
function ResourceSystem.applyDamage(spawn: BasePart, amount: number): number
	local state = nodes[spawn]
	if not state or amount <= 0 or state.hitPoints <= 0 then
		return 0
	end
	state.hitPoints = math.max(state.hitPoints - amount, 0)
	setAttributes(spawn, state.definition, state.hitPoints, state.hitPoints > 0)
	if state.hitPoints <= 0 then
		scheduleRespawn(state)
	end
	return state.hitPoints
end
function ResourceSystem.getNodeState(spawn: BasePart): NodeState?
	return nodes[spawn]
end
return ResourceSystem
