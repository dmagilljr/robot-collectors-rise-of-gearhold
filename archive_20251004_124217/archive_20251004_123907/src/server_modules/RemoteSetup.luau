-- Robot Collectors: Remote Events Setup
-- Creates and manages all RemoteEvents for client-server communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteSetup = {}

local REMOTE_EVENTS = {
    "HatchRobot",
    "SetRobotState",
    "ManualMine",
    "AssignRobotToResource",
    "GarageStatus",
    "GarageConsole",
    "RobotCountChanged",
    "RequestActivateBooster",
    "RequestEquipSkin",
    "ToggleGarageDoor",
}

local REMOTE_FUNCTIONS = {
    "RequestBuyWithShards",
}

local function ensureEvent(folder, name)
    local remote = folder:FindFirstChild(name)
    if remote then
        return remote
    end
    remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = folder
    return remote
end

local function ensureFunction(folder, name)
    local remote = folder:FindFirstChild(name)
    if remote then
        return remote
    end
    remote = Instance.new("RemoteFunction")
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

    ensureEvent(remotesFolder, "ToggleGarageDoor")

    local remotes = {}
    for _, remoteName in ipairs(REMOTE_EVENTS) do
        remotes[remoteName] = ensureEvent(remotesFolder, remoteName)
    end
    for _, remoteName in ipairs(REMOTE_FUNCTIONS) do
        remotes[remoteName] = ensureFunction(remotesFolder, remoteName)
    end

    return remotes
end

function RemoteSetup.init()
    return RemoteSetup.createRemotes()
end

function RemoteSetup.getRemotes()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local remotes = {}

    for _, remoteName in ipairs(REMOTE_EVENTS) do
        remotes[remoteName] = remotesFolder:WaitForChild(remoteName)
    end
    for _, remoteName in ipairs(REMOTE_FUNCTIONS) do
        remotes[remoteName] = remotesFolder:WaitForChild(remoteName)
    end

    return remotes
end

return RemoteSetup
