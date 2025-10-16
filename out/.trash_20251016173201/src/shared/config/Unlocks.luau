--!strict
-- Unlocks.luau — resource unlock rules (quests + min levels) and zone spawn tables

return {
  resources = {
    Scrap = {
      quest = "TUTORIAL_01",
      minLevel = 1,
      zones = { "T0_GarageBase", "T1_Scrapyard" },
    },
    Energy = {
      quest = "TUTORIAL_02",
      minLevel = 3,
      zones = { "T2_PowerFields" },
    },
    Components = {
      quest = "ENGINEER_01",
      minLevel = 4,
      zones = { "T1_Scrapyard", "T3_RuinedCity" },
    },
    RareMetal = {
      quest = "SCOUT_02",
      minLevel = 6,
      zones = { "T3_RuinedCity" },
    },
  },

  -- Desired counts per zone (per-player instance spawns)
  spawn = {
    T0_GarageBase = { Scrap = 8 },
    T1_Scrapyard  = { Scrap = 10, Components = 2 },
    T2_PowerFields= { Energy = 8 },
    T3_RuinedCity = { Components = 6, RareMetal = 3 },
  },
}
