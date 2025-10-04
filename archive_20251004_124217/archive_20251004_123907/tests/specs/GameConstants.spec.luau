return function(TestEZ)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Config = Shared:WaitForChild("config")
    local GameConstants = require(Config:WaitForChild("GameConstants"))

    TestEZ.describe("GameConstants", function()
        TestEZ.it("includes crystal currency in starting resources", function()
            TestEZ.expect(GameConstants.STARTING_RESOURCES.Crystals).toEqual(0)
        end)

        TestEZ.it("maps resource types to currencies consistently", function()
            local mapping = GameConstants.RESOURCE_TO_CURRENCY
            TestEZ.expect(mapping.Gearbit).toEqual("Gearbits")
            TestEZ.expect(mapping["Ion Shard"]).toEqual("IonShards")
            TestEZ.expect(mapping["Rare Metal"]).toEqual("RareMetals")
            TestEZ.expect(mapping.Crystal).toEqual("Crystals")
        end)
    end)
end
