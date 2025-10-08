--!strict
-- Alien bunker visual style
local StyleAlien = {}

-- Core palette (HSV makes hue-shifts easy later)
StyleAlien.colors = {
	wallGlass = Color3.fromHSV(0.58, 0.30, 0.40), -- teal-gray glass
	hoodMetal = Color3.fromHSV(0.60, 0.15, 0.75), -- cool steel
	railMetal = Color3.fromHSV(0.60, 0.15, 0.65),
	doorMetal = Color3.fromHSV(0.58, 0.10, 0.95), -- pale steel
	neon      = Color3.fromHSV(0.58, 0.70, 1.00), -- alien blue
	accent    = Color3.fromHSV(0.12, 0.70, 1.00), -- warm amber accent
	floor     = Color3.fromRGB(35, 38, 45),
}

StyleAlien.materials = {
	wallGlass = Enum.Material.Glass,
	metal     = Enum.Material.Metal,
	floor     = Enum.Material.Slate,
	neon      = Enum.Material.Neon,
}

-- Small geometric “language” tweaks
StyleAlien.geo = {
	fasciaDepth   = 0.38,
	revealDepth   = 0.42,
	jambThickness = 0.12,
	lintelThk     = 0.12,
	fasciaBack    = 0.08, -- behind door plane
	topTaper      = 0.07, -- 7% inward taper on the roof edge
}

-- Light defaults
StyleAlien.light = {
	rimBrightness = 1.2,
	rimRange      = 12,
	rimTint       = Color3.fromHSV(0.58, 0.70, 1.00),
}

return StyleAlien
