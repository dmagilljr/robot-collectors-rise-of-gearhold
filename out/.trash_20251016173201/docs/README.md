# Robot Collectors — Documentation Index

## Quick Links
- **CHANGELOG.md** – version notes (see v0.4.0 proximity baseline)
- **CODEX_BASELINE.txt** – rules for Codex edits + VERIFY template
- **ASSET_PIPELINE.md** – asset workflow and budgets
- **STYLE.md** – visual style (materials/lighting/palette)
- **SETUP_GUIDE.md** – Rojo + Studio + DS tips
- **REFACTORING_GUIDE.md** – garage architecture (model attrs)
- **PROJECT_SCOPE.md** – milestones & roadmap

---

## Current Code Layout (Rojo)
```

  src/
    server/
      world/
        WorldBoot.luau                 # guards against duplicate mounts
        PlotManager.server.luau        # assign plots (12–16), mount garage, personal respawn
        AutoDoorManager.server.luau    # owner-only proximity → DoorIsOpen on model
        Garage/
          Component.luau               # façade + bi-parting doors; animates from DoorIsOpen
          Interior.luau                # hatch/repair/core/console/lockers placeholders
    client/
      Main.client.luau                 # client banner
```

---

## Door Control (v0.4.0)
- Server flips **`GD_Garage:SetAttribute("DoorIsOpen", true/false)`** by proximity.
- `Component.luau` listens on the **model attribute** and calls `animate()`; panel attrs are synced for debug.
- Manual **F** prompt is disabled by default.

---

## Personal Plots & Shards (Option B)
- Each shard hosts **12–16** garages (owners) + visitors up to server cap (24–30).
- `PlotManager` mounts one garage per owner; sets `OwnerUserId` and personal spawn pad.
- Visitors spawn at a public pad; owner-only AutoDoor opens their doors by proximity.

---

## Studio vs Live
- **Studio fallback**: PlotManager logs “DataStore unavailable” and still mounts one garage; sets `OwnerUserId`.
- **Live**: publish the place; enable *Studio Access to API Services* when testing DS.

---

## Pre-launch Checklist
- [ ] `DEV_ALLOW_AUTO_ADOPT=false` in AutoDoorManager.
- [ ] Place published; DS enabled for test; StreamingEnabled = true.
- [ ] Server cap set (24–30), plots per shard (12–16).
- [ ] Verify `[AutoDoor] … → OPEN/CLOSE` logs and actual animation.


# Robot Collectors — Master Documentation Index

> **Current Version:** v0.5.0 (Garage + Hatch Show Stable)  
> **Recovery Tag:** `v0.5.0-garage-show-stable`

---

## 📁 Core Documentation
- [ARCHITECTURE.md](./ARCHITECTURE.md) — System hierarchy, component map, and Blender swap points.  
- [RECOVERY.md](./RECOVERY.md) — Rollback guide, smoke test, and verification procedures.  
- [CHANGELOG.md](./CHANGELOG.md) — Version history and stable tags.  
- [ECONOMY.md](./ECONOMY.md) — Resource and mission economy design (Stage 2).  
- [ASSET_PIPELINE.md](./ASSET_PIPELINE.md) — Blender workflow, budgets, and import guide.  
- [PROJECT_SCOPE.md](./PROJECT_SCOPE.md) — Roadmap and milestones.  
- [STYLE.md](./STYLE.md) — Visual design, palette, and materials.  
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) — Developer setup, Rojo sync, and Studio configuration.  
- [REFACTORING_GUIDE.md](./REFACTORING_GUIDE.md) — Standards for Lua modules and code cleanup.

---

## 🧩 Key Systems (v0.5.0)
**Garage**  
- Shell, façade, and unified floor (no overhang).  
- Interior: console, lockers, and spawn pad with ramp, neon rings, and emitter.  

**Hatch Show**  
- Beam/ring ceremony with Billboard scanner and dissolving capsule.  
- Placeholder bot materializes and slides down ramp.  

**Remotes**  
- Handles Open/Close UI events and HatchRobot → HatchShow bridge.  

**Client UI**  
- Command Console open/close + hatch trigger (instant-close behavior).  

**TODO[BLENDER]**  
- Torus pad, emitter housing, capsule shards, console & lockers MeshParts.

---

## 🗓️ Development Phases
| Phase | Version | Focus | Status |
|--------|----------|--------|--------|
| 0.5.x | Garage + Hatch Show | ✅ Stable |
| 0.6.x | Mission Console & Resource Economy | 🚧 In Design |
| 0.7.x | Robot Customization & Crafting | Planned |
| 0.8.x | Exploration & Factions | Planned |

---

## 🧱 Codebase Map
```

  src/
    server/
      world/
        WorldBoot.luau                 # Guards against duplicate mounts
        PlotManager.server.luau        # Assign plots, mount garages, personal respawn
        AutoDoorManager.server.luau    # Owner-only proximity → DoorIsOpen on model
        Garage/
          Component.luau               # Façade + doors, animates DoorIsOpen
          Interior.luau                # Console, lockers, spawn pad, FX placeholders
          Shows/
            Hatch.luau                 # Hatch ceremony timeline
    client/
      CommandUI.client.luau            # Console UI (open/close, hatch)
      Main.client.luau                 # Client banner
```

---

## ⚙️ Maintenance Checklist
- [ ] Tag each verified stable build (`v0.5.x`, `v0.6.x`, etc.)  
- [ ] Update CHANGELOG.md and RECOVERY.md  
- [ ] Run smoke test before merge (see RECOVERY.md)  
- [ ] Replace TODO[BLENDER] placeholders as assets arrive  

---

## 🧭 Reference & Legacy
- `_legacy/CODEX_BASELINE.txt` — Deprecated Codex rule set (archived).  
- `_legacy/AI_Workflow.md` — Early workflow documentation (archived).

---

*This document serves as the single entry point for all project references, technical documentation, and recovery procedures.*