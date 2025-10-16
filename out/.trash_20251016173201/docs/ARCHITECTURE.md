

# Robot Collectors — Architecture (v0.6.0-alpha)

> **Scope:** Stable garage build with Hatch Show (Layer 1+2), placeholders in code, and clear swap points for Blender assets. This is the single source of truth for structure and naming.

---

## 1) High‑Level Overview
- **World/Garage** is the core scene layer: builds the shell, interior props, and interaction points.
- **World Systems** extend the plaza with TerrainLoader (geometry), ZoneTrigger (player presence), and WorldInteract (resource props).
- **ResourceService** tracks in-memory resource totals (Scrap/Energy) and synchronises with clients.
- **Shows** orchestrates cinematic beats (hatching timeline on the spawn pad).
- **Remotes** is the network bridge (UI ↔ server actions).
- **Client UI** opens/closes the command console, shows hatch banners, displays resource totals, and plays zone feedback.

**Core loop (current):** Hatch → Ceremony → Bot spawns → Collect resources → Deposit → (future) Missions/Rewards.

---

## 2) Directory Layout (authoritative)
```
src/
  client/
    CommandUI.client.luau            # Console UI (open/close, hatch button)
    ui/
      ZoneToast.client.luau          # Top-center toast on zone entry
      ZoneSFX.client.luau            # Ambient zone SFX transitions
      ResourceHUD.client.luau        # HUD for Scrap/Energy totals
  server/
    Remotes.server.luau              # RC_Remotes ensure + event wiring
    services/
      ResourceService.server.luau    # Central resource manager (Scrap/Energy, DepositAll)
  server/modules/                    # Shared helpers (DoorPlane, PartFactory, etc.)
  server/world/
    Garage/
      Component.luau                 # Builds shell, façade, unified floor
      Interior.luau                  # Console, Lockers, Spawn Pad (pad+ramps+rings+emitter)
      Shows/
        Hatch.luau                   # Hatch ceremony timeline (beam, rings, scan, capsule, bot)
      Spawn.luau                     # (if present) spawn helpers
    TerrainLoader.server.luau        # Builds plaza, anchors, and paths
    ZoneTrigger.server.luau          # Handles player proximity to zones
    WorldInteract.server.luau        # Collectible props and prompts
    WorldBoot.luau                   # Single-run guard; passes spec to Garage.Component
  shared/
    ResourceDefs.luau                # Resource definitions (name, color, amount)
```

---

## 3) Systems
### 3.1 Garage Shell (Component.luau)
- Builds walls (GD_Left/GD_Right/GD_Back), roof, front façade spandrels/head.
- Creates **GD_FloorUnified** (continuous floor inside back wall; no overhang).
- Publishes `ModelRef` (ObjectValue) → live model in `workspace` for other scripts.
- Gates Fixup (visual post-pass) behind attribute `FORCE_FIXUP` (default **off**).

### 3.2 Interior Props (Interior.luau)
- **GD_Console** (multi-part placeholder; Screen is SurfaceGui host; ProximityPrompt wires `OpenCommandUI`).
- **GD_Lockers** (multi-unit bank; now 8 units, doors & vents; starts flush at back-right).
- **GD_SpawnPad**: elevated circular pad + ramp toward doors + laser emitter, neon rings & rim; `LaserEnabled` attribute toggles beam.

### 3.3 World Systems (TerrainLoader / ZoneTrigger / WorldInteract)
- **TerrainLoader.server.luau** builds the plaza footprint, pads, walkways, and zone anchors (`ZoneAnchor_*`, `SpawnAnchor`).
- **ZoneTrigger.server.luau** registers anchors, tracks player proximity, and fires `ZoneChanged` to clients for HUD/SFX updates.
- **WorldInteract.server.luau** attaches ProximityPrompts to `ScrapPile_*` and `EnergyCrystal_*`, throttling collection via per-node cooldowns and forwarding to `ResourceService`.

### 3.4 Resource Service (ResourceService.server.luau)
- Ensures `RC_Remotes` (`CollectResource`, `DepositAll`, `ResourceDelta`, `ResourceSync`).
- Tracks per-player totals (`Scrap`, `Energy`) in memory; responds to collection and deposit events.
- Fires `ResourceSync` on join and `ResourceDelta` on every change; exposes Bindable bridges for other server systems.

### 3.5 Shows (Hatch.luau)
- Timeline (Layer 1+2):
  1. Pre‑flash rim → Beam on → Rings brighten
  2. **Scanner**: Billboard ring sweeps down & up (camera-perfect circle)
  3. **Capsule**: placeholder shells dissolve into emitter
  4. **Bot**: placeholder spawns, calibrates, slides down ramp
  5. Beam off → Rim settle pulse → `HatchFX` to client

### 3.6 Remotes (Remotes.server.luau)
- Ensures `RC_Remotes` folder + events: `OpenCommandUI`, `CloseCommandUI`, `HatchRobot`, `HatchFX`, `OpenMissionUI`, `ZoneChanged`.
- On `HatchRobot`:
  - Fires `CloseCommandUI` to player (close UI immediately)
  - Calls `HatchShow.run({...})` (server timeline)

### 3.7 Client UI
- **CommandUI.client.luau** listens for console open/close, forwards hatch requests.
- **ZoneToast.client.luau** displays a top-center toast on zone transitions.
- **ZoneSFX.client.luau** plays and fades ambient tracks per zone.
- **ResourceHUD.client.luau** shows live Scrap/Energy totals via `ResourceSync` / `ResourceDelta`.

---

## 4) Events & Feature Flags
**Attributes**
- `ServerScriptService/World/Garage` (folder):
  - `FORCE_FIXUP` (bool) → if true, applies visual alignment pass (dev only)
  - `DEV_TRACE` (bool) → verbose prints (dev only)
- `workspace/.../GD_SpawnPad` (model):
  - `LaserEnabled` (bool) → toggled during show

**RemoteEvents (RC_Remotes)**
- `OpenCommandUI` / `CloseCommandUI`
- `HatchRobot` (payload `{ rarity, name }`)
- `HatchFX` (client banner payload)
- `CollectResource` / `DepositAll` / `ResourceDelta` / `ResourceSync`
- `OpenMissionUI`
- `ZoneChanged`

---

## 5) Naming Conventions (stable)
- **Spawn Pad** model children: `Pad`, `RingTop`, `RingBottom`, `RimGlow`, `Ramp`, `LaserEmitter`, `ScanBillboardAnchor`, `ScanBillboard`.
- **Console**: `GD_Console/Top`, `Screen`, `Keyboard`, `Key_*`, `BtnR/G/B`.
- **Lockers**: `GD_Lockers/LockerBody_01..08`, `LockerDoor_##_1/2`, `LockerVent_##_d_v`, `LockerHandle_##_d`.
- **Facade**: `GD_FrontSpandrelL/R`, `GD_FrontSpandrelHead`, `GD_FrontHeader`.
- **Floor**: `GD_FloorUnified`.

These names are *contractual*—scripts and tweens use them.

---

## 6) TODO[BLENDER] Swap Points
- **Spawn Pad Torus** → replace `GD_SpawnPad/Pad` cylinder.
- **Laser Emitter** → replace `LaserEmitter` with modeled housing + lens.
- **Scanner Ring (optional)** → MeshPart torus (keep Billboard fallback).
- **Capsule Shards** → replace `ShellA/ShellB` placeholders.
- **Console** → replace multi-part with MeshParts; keep `Screen` for SurfaceGui.
- **Lockers** → replace procedural bank with MeshPart unit(s); keep names.
- **Doors** (future) → segmented MeshParts for smoother animation.

> When swapping, keep **names and pivots** identical to placeholders to avoid script changes.

---

## 7) Data Flow (runtime)
1. `WorldBoot` computes `spec` (origin, width, height, depth, facingXZ) → `Garage.Component.Mount(spec)`.
2. `TerrainLoader` builds plaza + anchors; `Component` builds shell & floor; publishes `ModelRef`.
3. `Interior` builds Console, Lockers, Spawn Pad (reads `ModelRef`).
4. `ZoneTrigger` watches player proximity and fires `ZoneChanged` → `ZoneToast` / `ZoneSFX`.
5. `WorldInteract` prompts call `CollectRequest` → `ResourceService` updates totals → clients receive `ResourceDelta` and HUD refresh.
6. Client opens console → `HatchRobot` (payload) → server closes UI + runs `HatchShow`.
7. `HatchShow` toggles pad FX, spawns placeholder bot, plays ceremony, sends `HatchFX` to client.

---

## 8) Recovery Anchors
- Known-good tag (set in RECOVERY.md): `v0.6.0-alpha-world-ready`.
- Minimal smoke test: red errors in Output must be zero; door opens; hatch show completes; resource prompts collect and deposit cleanly.

---

## 9) Next Layers (roadmap)
- **Mission Objectives:** Tie missions to collected resources and unlock progression.
- **Economy:** Reward curves, crafting blueprints, garage upgrades.
- **World Expansion:** Additional zones, resource variants, ambient NPCs.
