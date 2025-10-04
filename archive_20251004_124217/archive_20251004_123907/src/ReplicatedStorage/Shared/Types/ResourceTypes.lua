--!strict

export type ResourceTier = "Common" | "Uncommon" | "Rare" | "Epic"

export type DropTable = {
	[string]: number,
}

export type ResourceDefinition = {
	id: string,
	name: string,
	tier: ResourceTier,
	maxHitPoints: number,
	respawnTime: number,
	dropTable: DropTable,
	icon: string?,
}

export type SpawnTableEntry = {
	resourceId: string,
	weight: number,
}

export type SpawnTableDefinition = {
	id: string,
	entries: {SpawnTableEntry},
}

export type ResourceTypesModule = {
	Tiers: {ResourceTier},
	Definitions: {[string]: ResourceDefinition},
	SpawnTables: {[string]: SpawnTableDefinition},
}

local ResourceTypes = {} :: ResourceTypesModule

ResourceTypes.Tiers = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
}

ResourceTypes.Definitions = {
	Quartz = {
		id = "Quartz",
		name = "Quartz Crystal",
		tier = "Common",
		maxHitPoints = 120,
		respawnTime = 25,
		dropTable = {
			QuartzShard = 1.0,
		},
		icon = "rbxassetid://13159238425",
	},
	Ionite = {
		id = "Ionite",
		name = "Ionite Ore",
		tier = "Uncommon",
		maxHitPoints = 180,
		respawnTime = 40,
		dropTable = {
			IonShard = 0.85,
			ScrapMetal = 0.35,
		},
		icon = "rbxassetid://13159238644",
	},
	Nebulite = {
		id = "Nebulite",
		name = "Nebulite Cluster",
		tier = "Rare",
		maxHitPoints = 260,
		respawnTime = 65,
		dropTable = {
			NebuliteDust = 0.65,
			IonShard = 0.25,
		},
		icon = "rbxassetid://13159238812",
	},
	Aetherstone = {
		id = "Aetherstone",
		name = "Aetherstone Core",
		tier = "Epic",
		maxHitPoints = 340,
		respawnTime = 90,
		dropTable = {
			AetherFragment = 0.55,
			NebuliteDust = 0.35,
		},
		icon = "rbxassetid://13159239102",
	},
}

ResourceTypes.SpawnTables = {
	StarterField = {
		id = "StarterField",
		entries = {
			{resourceId = "Quartz", weight = 65},
			{resourceId = "Ionite", weight = 25},
			{resourceId = "Nebulite", weight = 10},
		},
	},
	CrystalCavern = {
		id = "CrystalCavern",
		entries = {
			{resourceId = "Ionite", weight = 45},
			{resourceId = "Nebulite", weight = 35},
			{resourceId = "Aetherstone", weight = 20},
		},
	},
}

return ResourceTypes
