-- Robot Collectors: Robot Types Configuration
-- Defines all robot types and their properties

local RobotTypes = {
    Basic = {
        Name = "Basic Bot",
        Type = "Collector",
        Rarity = "Common",
        Cost = {Gearbits = 50},
        Color = Color3.fromRGB(150, 150, 150),
        Size = Vector3.new(2, 3, 1.5),
        Speed = 1,
        Efficiency = 1
    },
    Advanced = {
        Name = "Advanced Bot",
        Type = "Collector",
        Rarity = "Uncommon",
        Cost = {Gearbits = 25, IonShards = 15},
        Color = Color3.fromRGB(0, 255, 0),
        Size = Vector3.new(2.2, 3.2, 1.7),
        Speed = 1.2,
        Efficiency = 2
    },
    Elite = {
        Name = "Elite Bot",
        Type = "Collector",
        Rarity = "Rare",
        Cost = {Gearbits = 100, IonShards = 50, RareMetals = 10},
        Color = Color3.fromRGB(255, 215, 0),
        Size = Vector3.new(2.5, 3.5, 2),
        Speed = 1.5,
        Efficiency = 3
    }
}

return RobotTypes