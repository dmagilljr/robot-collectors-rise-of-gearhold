--!strict
-- Quests.luau — tutorial + early progression quests (minimal MVP)

export type Step = {
  id: string,
  type: "collect" | "action",
  resource: string?,
  amount: number?,
  key: string?,
}

export type Quest = {
  id: string,
  name: string,
  steps: { Step },
}

local Quests: { [string]: Quest } = {
  TUTORIAL_01 = {
    id = "TUTORIAL_01",
    name = "Welcome to the Yard",
    steps = {
      { id = "COLLECT_SCRAP_3", type = "collect", resource = "Scrap", amount = 3 },
      { id = "DEPOSIT_RESOURCES", type = "action", key = "DepositAll" },
    },
  },
  TUTORIAL_02 = {
    id = "TUTORIAL_02",
    name = "Power Fields",
    steps = {
      { id = "COLLECT_ENERGY_5", type = "collect", resource = "Energy", amount = 5 },
    },
  },
  ENGINEER_01 = {
    id = "ENGINEER_01",
    name = "Spare Parts",
    steps = {
      { id = "COLLECT_COMPONENTS_5", type = "collect", resource = "Components", amount = 5 },
    },
  },
  SCOUT_02 = {
    id = "SCOUT_02",
    name = "Rare Finds",
    steps = {
      { id = "COLLECT_RAREMETAL_4", type = "collect", resource = "RareMetal", amount = 4 },
    },
  },
}

return Quests
