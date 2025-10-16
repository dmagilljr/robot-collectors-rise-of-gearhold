

# Robot Collectors — World Blueprint (v0.6.0 Design)

> **Purpose:** Define the playable world outside the garage, outlining the hub, zones, and progression structure that expand gameplay beyond the player’s base.

---

## 1) Overview

The world expands from the player's **Garage Base**, creating a progression path of exploration, collection, and combat.

### Core Themes
- **Industrial Ruins**: Abandoned manufacturing yards, scrapyards, and power fields.
- **Automation and Exploration**: Robots gather, repair, and fight while players manage missions and resources.
- **Progression Through Expansion**: Unlock new sectors and upgrade your garage to reach distant areas.

---

## 2) Layout Summary

| Zone | Type | Description | Unlock Level | Key Gameplay |
|------|------|--------------|---------------|---------------|
| **Garage Base (Tier 0)** | Safe Zone | Player spawn area with garage, mission console, resource terminal. | Default | Hatch, missions, resource deposit |
| **Scrapyard (Tier 1)** | Resource Zone | Broken bots, rusted conveyor belts, scattered loot piles. | After first mission | Collect scrap + energy cores |
| **Power Fields (Tier 2)** | Hazard Zone | Volatile energy crystals, lightning hazards, mining opportunities. | Unlock after 3 missions | Harvest high-energy materials |
| **Ruined City (Tier 3)** | Exploration Zone | Collapsed skyscrapers, rare components, wandering drones. | Unlock via blueprint research | Explore, discover lore, find rare loot |
| **Orbital Gate (Tier 4)** | Event Zone | Teleporter hub to distant systems (future expansions). | Late-game | Multiplayer co-op missions |

---

## 3) Zone Map (Concept Grid)

```
                    [T4] Orbital Gate
                           ↑
        [T3] Ruined City ← [T2] Power Fields → [T1] Scrapyard
                           ↓
                    [T0] Garage Base
```

### Distance Layout
- Each zone connects via a **main path** with branching exploration routes.
- Terrain transitions gradually — industrial → wild energy → urban decay → high-tech portal.

---

## 4) Environment & Props

| Element | Description | Interaction |
|----------|--------------|--------------|
| **Terrain Mesh** | Layered industrial ground with ridges and paths. | Walkable / collectible areas |
| **Resource Nodes** | Scrap piles, energy crystals, broken drones. | Gatherable / triggers missions |
| **NPC Terminals** | Holographic guides that introduce missions. | Dialogue + mission start |
| **Ambient Props** | Pipes, containers, flickering lights, cables, drone debris. | Aesthetic depth |
| **Lighting Tone** | Early morning haze, cold industrial lighting with sparks. | Sets mood / readability |
| **Soundscape** | Machinery hum, wind, distant thunder, radio chatter. | Immersion |

---

## 5) Player Flow

1. **Spawn** at Garage Base → collect resources nearby.
2. **Start missions** from console → missions send robots into other zones.
3. **Unlock new zones** as robots return with rare components.
4. **Build and upgrade** garage structures and expand outward.
5. **Enter active exploration** later (Ruined City + Orbital Gate).

---

## 6) Gameplay Integration Plan

| System | Connection |
|--------|-------------|
| **Mission Service** | Missions reference resource collection and exploration events in other zones. |
| **Resource System** | Collectible props tie into inventory and crafting economy. |
| **Crafting / Design** | Unlock new robots via Ruined City discoveries. |
| **Combat / AI** | Introduce rogue drones at Tier 2+ as obstacles for robots. |
| **Base Upgrades** | Expanding garage visually reflects player progress. |

---

## 7) Technical Implementation Notes

- **Terrain**: Procedural or hand-sculpted mesh; use `StreamingEnabled`.
- **Spawn Anchors**: Each zone anchored by `ZoneAnchor_<Tier>` for teleport/transition scripts.
- **Lighting Regions**: Different lighting per zone (`LightingService` + zone triggers).
- **Music / SoundService**: Dynamic soundtrack layers depending on zone.

---

## 8) Expansion Hooks

| Feature | Description | Release Target |
|----------|--------------|----------------|
| **Faction Missions** | Competing AI groups offer special contracts. | v0.7.0 |
| **Co-op Events** | Shared world events in Orbital Gate. | v0.8.0 |
| **Robot Housing** | Display bots inside garage courtyard. | v0.6.x |
| **Dynamic Weather** | Random storms and dust events. | Future Patch |

---

## 9) Development Order

1. **Phase 1:** Terrain + Zone Anchors  
2. **Phase 2:** Resource Node Placement + Gathering UI  
3. **Phase 3:** Mission Integration with World Props  
4. **Phase 4:** Lighting / FX Pass  
5. **Phase 5:** Add ambient NPCs and narrative holograms  

---

### ✅ Outcome
This document defines the framework for the game world. It ensures future development (missions, exploration, crafting, combat) align spatially and thematically with the central garage loop.

> **Implemented Systems (v0.6.0-alpha):**  
> • Base plaza, paths, and zone anchors.  
> • Zone entry detection (ZoneTrigger + toast + SFX).  
> • Collectible Scrap/Energy props with working ResourceService and HUD.  
> • Next phase: mission objectives tied to resource totals and zone unlock progression.
