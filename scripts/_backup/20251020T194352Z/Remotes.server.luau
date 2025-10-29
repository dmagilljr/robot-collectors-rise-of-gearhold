--!strict
-- Remotes.server.luau
-- Ensures core RemoteEvents are available to clients/scripts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VERSION = "1.0.0"
print(string.format("[Remotes] VERSION %s", VERSION))

local folder = ReplicatedStorage:FindFirstChild("RC_Remotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "RC_Remotes"
    folder.Parent = ReplicatedStorage
end

local function ensureRemote(name: string): RemoteEvent
    local existing = folder:FindFirstChild(name)
    if existing and existing:IsA("RemoteEvent") then
        return existing
    end
    if existing then
        existing:Destroy()
    end
    local evt = Instance.new("RemoteEvent")
    evt.Name = name
    evt.Parent = folder
    return evt
end

ensureRemote("OpenCommandUI")
ensureRemote("CloseCommandUI")
ensureRemote("OpenMissionUI")
ensureRemote("HatchRobot")
ensureRemote("HatchFX")
ensureRemote("ZoneChanged")

-- CollectResource and other economy remotes are created inside ResourceService; this script
-- just guarantees the folder and non-economy remotes exist.
