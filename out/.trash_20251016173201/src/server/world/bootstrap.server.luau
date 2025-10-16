--!strict
-- Bootstrap order (non-blocking):
-- 1) (Optional) trust server scripts to ensure RC_Remotes (00_spawns_and_remotes / Remotes.server)
-- 2) Ensure baseplate + RC_Spawn so players never fall
-- 3) Require and run WorldBoot (mounts the garage)

local SSS = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("GameConstants"))

-- 2) Spawn (tolerate Studio timing)
local function requireWorldSpawn(timeout: number)
	local world = SSS:WaitForChild("World", timeout)
	local mod   = world and world:WaitForChild("Spawn", timeout)
	assert(world, "World missing")
	assert(mod and mod:IsA("ModuleScript"), "World.Spawn missing or not a ModuleScript")
	return require(mod)
end

do
	local ok, modOrErr = pcall(requireWorldSpawn, 10)
	if ok then
		local Spawn = modOrErr
		local good, err = pcall(function() return Spawn.ensure() end)
		if not good then warn("[bootstrap] Spawn.ensure threw:", err) end
	else
		warn("[bootstrap] could not require World.Spawn:", modOrErr)
	end
end

-- 3) WorldBoot
local function requireWorldBoot(timeout: number)
	local world = SSS:WaitForChild("World", timeout)
	local wb    = world and world:WaitForChild("WorldBoot", timeout)
	assert(world, "World missing")
	assert(wb and wb:IsA("ModuleScript"), "World.WorldBoot missing or not a ModuleScript")
	return require(wb)
end

do
    local ok, modOrErr = pcall(requireWorldBoot, 10)
    if ok and type(modOrErr) == "table" and type(modOrErr.run) == "function" then
        if GameConstants.DEBUG then
            print("[bootstrap] running WorldBoot.run()")
        end
        local good, err = pcall(modOrErr.run)
        if not good then warn("[bootstrap] WorldBoot.run() threw:", err) end
    else
        warn("[bootstrap] could not require/run WorldBoot:", modOrErr)
    end
end

do
    local worldFolder = SSS:FindFirstChild("World")
    local resourcesEnabled = worldFolder and worldFolder:GetAttribute("RESOURCES_ENABLED") == true
    print(string.format("[BOOT] RC build: DEBUG=%s, MIN_GARAGE_RADIUS=%d, resources enabled=%s",
        tostring(GameConstants.DEBUG), GameConstants.MIN_GARAGE_RADIUS, tostring(resourcesEnabled)))
end

if not GameConstants.DEBUG then
    return
end

if GameConstants.DEBUG then
    print("🤖 server init:", os.time())
end

-- ==== DEBUG: WatchNewParts (temporary; server-side) ========================
-- Goal now: catch ANY thin ground-ish part near the garage door (even without tags/prompts),
-- and also log whenever a "ResourceNode" tag or a ProximityPrompt gets attached later.
do
	local flag = script:FindFirstChild("_WATCH_NEW_PARTS_STARTED")
	if not flag then
		flag = Instance.new("BoolValue")
		flag.Name = "_WATCH_NEW_PARTS_STARTED"
		flag.Value = true
		flag.Parent = script

        local CollectionService = game:GetService("CollectionService")

        local function isThinGround(part: BasePart): boolean
            return part.Size.Y <= GameConstants.THIN_TILE_Y_MAX and part.Position.Y <= 2.2
		end

		local function isCharacterPart(inst: Instance): boolean
			local m = inst:FindFirstAncestorOfClass("Model")
			return m and m:FindFirstChildOfClass("Humanoid") ~= nil
		end

		-- Area directly in front of the garage door (x within ±14, z between -52 and -30)
		local function nearDoor(part: BasePart): boolean
			local p = part.Position
			return math.abs(p.X) <= 14 and p.Z >= -52 and p.Z <= -30
		end

		-- Log helper
		local function logPart(prefix: string, part: BasePart)
            print(string.format(
                "%s %s  sz=(%.2f,%.2f,%.2f)  y=%.2f  path=%s",
                prefix,
                part.ClassName,
                part.Size.X, part.Size.Y, part.Size.Z,
                part.Position.Y,
                part:GetFullName()
            ))
		end

		-- 1) Live: any NEW near-door thin BasePart (excluding character pieces)
		workspace.DescendantAdded:Connect(function(obj)
			if not obj:IsA("BasePart") then return end
			if isCharacterPart(obj) then return end
			if not isThinGround(obj) then return end
			if not nearDoor(obj) then return end
			logPart("[WATCH] ThinNearDoor+", obj)
		end)

		-- 2) Tag attach: when anything gets "ResourceNode" later, log the instance
		pcall(function()
			local conn = CollectionService:GetInstanceAddedSignal("ResourceNode")
			conn:Connect(function(inst)
				if inst:IsA("BasePart") then
					logPart("[WATCH] TagAdd:ResourceNode", inst)
				end
			end)
		end)

		-- 3) Prompt attach: if a ProximityPrompt is inserted under a near-door thin BasePart later
		workspace.DescendantAdded:Connect(function(inst)
			if not inst:IsA("ProximityPrompt") then return end
			local p = inst:FindFirstAncestorWhichIsA("BasePart")
			if not p then return end
			if isCharacterPart(p) then return end
			if not isThinGround(p) then return end
			if not nearDoor(p) then return end
			logPart("[WATCH] PromptAdd→Parent", p)
		end)

		-- 4) One-shot sweep AFTER boot to catch already-present rogue parts
		task.defer(function()
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and not isCharacterPart(obj) and isThinGround(obj) and nearDoor(obj) then
					logPart("[WATCH] ThinNearDoor@boot", obj)
				end
			end
			print("🛰️ [WATCH] ACTIVE (server/world/bootstrap) — broad: thin near-door parts, tag adds, prompt adds")
		end)
	end
end
-- ==== /DEBUG ===============================================================
