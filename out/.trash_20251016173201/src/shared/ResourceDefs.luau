--!strict

-- Resource visual + UX definitions
-- Backwards-compatible: existing code can keep using `display`, `amount`, `color`.
-- New fields drive look/feel without hard-coding per-node logic.

local ResourceDefs = {
	Scrap = {
		display = "Scrap",
		amount = 1,
		color = Color3.fromRGB(110, 100, 90),

		-- Visual identity
		materialPrimary = Enum.Material.Metal,
		light = {
			color = Color3.fromRGB(255, 180, 90),
			range = 8,
			brightness = 0.8,
			pulse = true,
		},

		-- FX routing (to be consumed by ResourceFX / SFX systems)
		idleFX = "ScrapIdle",       -- small sparks / dust motes
		collectSFX = "ScrapCollect", -- metallic clank
	},

	Energy = {
		display = "Energy",
		amount = 1,
		color = Color3.fromRGB(90, 230, 210),

		materialPrimary = Enum.Material.Neon,
		light = {
			color = Color3.fromRGB(120, 205, 255),
			range = 12,
			brightness = 1.8,
			pulse = true,
		},

		idleFX = "EnergyIdle",       -- faint shimmer / tiny shards
		collectSFX = "EnergyCollect", -- soft zap
	},

	Components = {
		display = "Components",
		amount = 1,
		color = Color3.fromRGB(200, 200, 220),

		materialPrimary = Enum.Material.Metal,
		materialSecondary = Enum.Material.Glass, -- if the model uses multiple parts
		light = {
			color = Color3.fromRGB(200, 220, 255),
			range = 9,
			brightness = 0.9,
			pulse = false,
		},

		idleFX = "ComponentIdle",       -- faint servo blink / small sparks
		collectSFX = "ComponentCollect", -- servo click
	},
}

return ResourceDefs
