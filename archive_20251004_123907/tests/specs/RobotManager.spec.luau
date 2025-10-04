return function(TestEZ)
    local ServerScriptService = game:GetService("ServerScriptService")
    local modulesFolder = ServerScriptService:WaitForChild("Modules")
    local RobotManager = require(modulesFolder:WaitForChild("RobotManager"))

    local createdContainer: Folder?

    local function createContainer()
        createdContainer = Instance.new("Folder")
        createdContainer.Name = "RobotManagerSpecResources"
        createdContainer.Parent = workspace
    end

    local function clearContainer()
        if createdContainer then
            createdContainer:Destroy()
            createdContainer = nil
        end
    end

    local function createResource(name: string, position: Vector3, resourceType: string?)
        assert(createdContainer, "Container must exist before creating resources")
        local part = Instance.new("Part")
        part.Name = name
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(2, 2, 2)
        part.Position = position
        part.Parent = createdContainer

        if resourceType then
            local typeValue = Instance.new("StringValue")
            typeValue.Name = "ResourceType"
            typeValue.Value = resourceType
            typeValue.Parent = part
        end

        return part
    end

    TestEZ.describe("RobotManager resource search", function()
        TestEZ.beforeEach(function()
            clearContainer()
            createContainer()
        end)

        TestEZ.afterEach(function()
            clearContainer()
        end)

        TestEZ.it("returns nil when no resources exist", function()
            local found = RobotManager.findNearestResource(Vector3.new(0, 0, 0), 50)
            TestEZ.expect(found).toEqual(nil)
        end)

        TestEZ.it("returns closest resource regardless of type", function()
            local nearResource = createResource("Resource_Gearbit_A", Vector3.new(5, 0, 0), "Gearbit")
            createResource("Resource_Gearbit_B", Vector3.new(15, 0, 0), "Gearbit")

            local found = RobotManager.findNearestResource(Vector3.new(0, 0, 0), 50)
            TestEZ.expect(found).toEqual(nearResource)
        end)

        TestEZ.it("filters by resource type when requested", function()
            createResource("Resource_Gearbit_A", Vector3.new(5, 0, 0), "Gearbit")
            local ionResource = createResource("Resource_IonShard_A", Vector3.new(7, 0, 0), "Ion Shard")

            local found = RobotManager.findNearestResourceOfType(Vector3.new(0, 0, 0), 50, "Ion Shard")
            TestEZ.expect(found).toEqual(ionResource)
        end)

        TestEZ.it("respects the provided max distance", function()
            createResource("Resource_Gearbit_A", Vector3.new(12, 0, 0), "Gearbit")

            local found = RobotManager.findNearestResource(Vector3.new(0, 0, 0), 10)
            TestEZ.expect(found).toEqual(nil)
        end)
    end)
end
