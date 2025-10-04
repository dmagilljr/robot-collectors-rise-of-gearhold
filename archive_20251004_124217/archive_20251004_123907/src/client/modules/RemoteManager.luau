-- Robot Collectors: Remote Event Management System
-- Handles all client-side remote event access and communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = {}

function RemoteManager.getRemotes()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    return {
        HatchRobot = Remotes:WaitForChild("HatchRobot"),
        SetRobotState = Remotes:WaitForChild("SetRobotState"),
        ManualMine = Remotes:WaitForChild("ManualMine"),
        AssignRobotToResource = Remotes:WaitForChild("AssignRobotToResource")
    }
end

return RemoteManager