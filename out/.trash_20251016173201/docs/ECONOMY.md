

# Economy & Missions Layer — Design Document (v0.6.0 Plan)

> **Purpose:** Define the resource economy and asynchronous mission system that will extend the current garage gameplay into a full retention loop.

---

## 1) Core Gameplay Loop (Stage 2)
**Current Loop:** Hatch → Watch → Done  
**Expanded Loop:** Hatch → Deploy → Earn → Upgrade → Hatch again.

### 1.1 Mission Flow
1. Player opens **Mission Console** in the garage.
2. Assign available robots to missions (1–3 slots by default).
3. Robots leave for a set time; mission runs **asynchronously (offline)**.
4. Player returns later → collects rewards → resources feed back into upgrades.

---

## 2) Mission Types & Duration
| Type | Duration | Example Goal | Base Rewards | Bonus Chance |
|------|-----------|---------------|---------------|---------------|
| **Scouting** | 5–10 min | Explore nearby ruins | Scrap + Components | Map Fragment |
| **Harvesting** | 30–60 min | Mine energy cores | Energy + Rare Parts | 2× Yield (premium booster) |
| **Combat Ops** | 1–2 hr | Defeat rogue drones | Alloy + XP | Epic Blueprint |
| **Engineering** | 4–6 hr | Repair derelict bots | Circuits + Robot XP | Hatch Speed Buff |
| **Expedition** | 8–12 hr | Deep sector exploration | Mixed | Legendary Part |

> Missions continue while the player is offline. Each robot can only run one mission at a time.

---

## 3) Currency & Resource Economy
| Resource | Source | Usage | Monetization Hook |
|-----------|---------|--------|--------------------|
| **Scrap** | Common missions | Craft base upgrades | Starter packs / double yields |
| **Energy** | Harvesting, events | Hatch robots, run missions | Energy refills (premium) |
| **Components** | Engineering, combat | Craft advanced robots | Premium “Component Crates” |
| **Nanite Credits (💠)** | Rare drops / in-app | Speed boosters, rarity upgrades | Primary premium currency |

---

## 4) Reward Curves (Preliminary)
- **Short missions:** High frequency, low value → dopamine hits.
- **Medium missions:** Moderate reward + rare drops.
- **Long missions:** Guaranteed high reward + possible Legendary item.

| Mission Length | Reward Multiplier | XP Weight | Drop Chance (Rare) |
|----------------|-------------------|------------|--------------------|
| < 15 min | ×1.0 | ×1 | 2% |
| 15–60 min | ×1.5 | ×2 | 5% |
| 1–3 hr | ×2.0 | ×3 | 10% |
| 3–8 hr | ×3.0 | ×5 | 15% |
| > 8 hr | ×4.0 | ×8 | 20% |

---

## 5) Progression Systems
- **Garage Upgrades:** Unlock extra mission slots, speed up hatching.
- **Robot Levels:** Gain XP from missions → increases yield multiplier.
- **Blueprint Research:** Combine Components + Scrap to create new robot types.
- **Events:** Weekly missions with double rewards or special parts.

---

## 6) Monetization Framework
| Feature | Description | Example Product |
|----------|--------------|-----------------|
| **Mission Slots** | Free = 2; unlock up to 5 with Nanite Credits | “Mission Bay Upgrade” (💠100) |
| **Speed Boosters** | Instantly complete active mission | “Quantum Accelerator” (💠10 per use) |
| **Energy Refills** | Restore Energy to keep missions running | “Energy Core Refill” (💠5) |
| **Premium Robots** | Exclusive hatch types / seasonal | “Omega Series Capsule” (💠250) |
| **Garage Cosmetics** | Lighting, skins, holograms | “Elite Bay Theme” (💠75) |

---

## 7) Implementation Notes
- **Server:** Tracks mission state table `{ playerId, robotId, missionType, startTime, duration, rewards }`.
- **Client:** UI shows mission slots, timers, claim buttons.
- **Persistence:** Use DataStore2 or MemoryStore for mission tracking.
- **Timers:** Computed from `os.time()`; claim triggers `MissionComplete` remote.

### Example Data Schema
```lua
Mission = {
  id = "GUID",
  playerId = "UserId",
  robotId = "RobotGUID",
  type = "CombatOps",
  startTime = os.time(),
  duration = 7200, -- seconds
  rewards = {
    scrap = 250,
    components = 3,
    rarity = "rare",
  }
}
```

---

## 8) Future Expansion Hooks
- **Faction Missions:** Unlock advanced contracts tied to player alignment.
- **Co‑op Tasks:** Group missions where multiple players contribute robots.
- **Mini‑Games:** Quick optional interactions to influence mission success.
- **Leaderboard Integration:** Track total missions completed and resources earned.

---

## 9) TODO / Placeholder Notes
- **TODO[UI]:** Build Mission Console placeholder (blue Part + SurfaceGui).
- **TODO[SERVER]:** Add MissionService module with async timers.
- **TODO[DATA]:** Store mission table in DataStore2 (key = playerId).
- **TODO[BLENDER]:** Future model for console terminal & holographic projection.

---

**Next Milestone:** v0.6.0 — “Mission Console Prototype” (deployable missions + resource rewards).
