-- Robot Collectors: Remote Events Setup
-- Creates and manages all RemoteEvents for client-server communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteSetup = {}

local REMOTE_DEFINITIONS = {
    "HatchRobot",
    "SetRobotState",
    "ManualMine",
    "AssignRobotToResource",
    "GarageStatus",
}

local function ensureRemote(folder, name)
    local remote = folder:FindFirstChild(name)
    if remote then
        return remote
    end

    remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = folder
    return remote
end

function RemoteSetup.createRemotes()
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end

    local remotes = {}
    for _, remoteName in ipairs(REMOTE_DEFINITIONS) do
        remotes[remoteName] = ensureRemote(remotesFolder, remoteName)
    end

    return remotes
end

function RemoteSetup.getRemotes()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local remotes = {}

    for _, remoteName in ipairs(REMOTE_DEFINITIONS) do
        remotes[remoteName] = remotesFolder:WaitForChild(remoteName)
    end

    return remotes
end

return RemoteSetup
