--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local M = {} ; M.VERSION = "rc-remotes-"..tostring(os.time())

local function ensureFolder(name: string)
    local f = ReplicatedStorage:FindFirstChild(name)
    if not f then f = Instance.new("Folder"); f.Name = name; f.Parent = ReplicatedStorage end
    return f
end
local function ensureEvent(folder: Instance, name: string)
    if not folder:FindFirstChild(name) then Instance.new("RemoteEvent", folder).Name = name end
end

function M.init()
    local remotes = ensureFolder("Remotes")
    ensureEvent(remotes, "RC_ToggleGarageDoor")
    print("🔌 RC_RemoteSetup ready @", M.VERSION)
end

return M
