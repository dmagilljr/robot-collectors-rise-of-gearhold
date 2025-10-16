--!strict
-- 00_spawns_and_remotes.server.luau
-- Unconditional safety net: ensure RC_Remotes and a shared spawn/baseplate at server boot.

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")

-- Remotes folder + events (server-owned)
local remotes = RS:FindFirstChild("RC_Remotes") :: Folder?
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "RC_Remotes"
	remotes.Parent = RS
end
local function ensureEvent(name: string): RemoteEvent
	local ev = remotes:FindFirstChild(name) :: RemoteEvent?
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = remotes
	end
	return ev
end
ensureEvent("OpenCommandUI")
ensureEvent("HatchRobot")
ensureEvent("HatchFX")
print("[SpawnFix] RC_Remotes ready (OpenCommandUI, HatchRobot, HatchFX)")

-- Baseplate
local base = WS:FindFirstChild("RC_Baseplate") :: Part?
if not base then
	base = Instance.new("Part")
	base.Name = "RC_Baseplate"
	base.Size = Vector3.new(512, 1, 512)
	base.Anchored = true
	base.Material = Enum.Material.Concrete
	base.CFrame = CFrame.new(0, 0.5, 0)
	base.Parent = WS
end

-- Shared spawn pad
local pad = WS:FindFirstChild("RC_Spawn") :: SpawnLocation?
if not pad then
	pad = Instance.new("SpawnLocation")
	pad.Name = "RC_Spawn"
	pad.Size = Vector3.new(6, 1, 6)
	pad.Neutral, pad.Enabled = true, true
	pad.Anchored = true
	pad.BrickColor = BrickColor.new("Medium stone grey")
	pad.CFrame = CFrame.new(0, 3.5, -12)
	pad.Parent = WS
end

print(("[SpawnFix] ensured base@%s spawn@%s")
	:format(tostring(base.CFrame.Position), tostring(pad.CFrame.Position)))
