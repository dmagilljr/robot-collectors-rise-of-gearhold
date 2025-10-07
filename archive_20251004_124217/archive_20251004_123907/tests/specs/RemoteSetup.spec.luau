return function(TestEZ)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")
    local modulesFolder = ServerScriptService:WaitForChild("Modules")
    local RemoteSetup = require(modulesFolder:WaitForChild("RemoteSetup"))

    TestEZ.describe("RemoteSetup.createRemotes", function()
        TestEZ.it("creates remotes once and reuses instances", function()
            local existing = ReplicatedStorage:FindFirstChild("Remotes")
            if existing then
                existing:Destroy()
            end

            local first = RemoteSetup.createRemotes()
            local second = RemoteSetup.createRemotes()

            TestEZ.expect(first.HatchRobot).toBeInstanceOf("RemoteEvent")
            TestEZ.expect(first.HatchRobot).toEqual(second.HatchRobot)
            TestEZ.expect(first.AssignRobotToResource).toEqual(second.AssignRobotToResource)
            TestEZ.expect(first.GarageStatus).toBeInstanceOf("RemoteEvent")
            TestEZ.expect(first.GarageStatus).toEqual(second.GarageStatus)
        end)
    end)
end
