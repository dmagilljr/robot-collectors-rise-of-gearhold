# Changelog

## v0.6.0-alpha — World Expansion & Resource System
- Added TerrainLoader (plaza, anchors, paths).
- Added ZoneTrigger (ZoneAnchor detection, ZoneChanged event).
- Added ResourceService with Scrap/Energy tracking.
- Added WorldInteract with collection prompts.
- Added client ResourceHUD + ZoneToast + ZoneSFX.
- Updated default.project.json to prevent double world mapping.
- Deferred world diagnostics in WorldBoot.
- Tag: `v0.6.0-alpha-world-ready`.

## v0.5.1 — Clean Structure & Unified Console
- **Cleanup:** Removed duplicate and legacy folders from parent directories.
- **Project Consolidation:** Confirmed only `robot-collectors-new-V1` remains as the live project.
- **Archives:** All previous backups moved safely to `/old_backups/`.
- **Code:** Deleted redundant `MissionUI.client.luau` and removed Mission Console placeholder from `Interior.luau`.
- **UI:** Unified Command Console with tabs: *Hatch*, *Missions*, *Repair*, and *Design*.
- **Validation:** Game tested; no regressions detected.
- **Git:** Repository verified with correct `.git` placement.
- **Tag:** `v0.5.1-clean-structure` (post-cleanup stable build).

## v0.5.0 — Garage & Hatch Show Stable
- **Garage Restoration:** shell, façade, unified floor fully aligned; no back overhang.
- **Interior Props:** console (multi-part with prompt), lockers (8 units, flush at back-right wall).
- **Spawn Pad:** circular pad + ramp toward door; neon rings + rim glow; `LaserEnabled` toggle.
- **Ceiling Laser:** emitter cylinder placeholder; beam active during hatching.
- **Hatch Show (Layers 1–2):**
  - Layer 1: Beam activation, ring pulse, placeholder robot spawn, ramp exit, banner.
  - Layer 2: Pre-flash, scanning **BillboardGui** ring, dissolving capsule shells, settle pulse.
- **Console Prompt:** Updated to "Open Console (Hatch • Repair • Design)"; closes instantly on click.
- **Remotes:** `CloseCommandUI` event added; HatchRobot triggers it before ceremony.
- **Client:** Added `CloseCommandUI` listener; hatch UI now closes immediately.
- **TODO[BLENDER]:** Torus pad, emitter housing, capsule shards, console MeshParts, locker MeshParts.
- **Tag:** `v0.5.0-garage-show-stable` (documented recovery point).

## v0.4.0 — Proximity Door + Single-Garage Baseline
- Door control moved to model attribute **`DoorIsOpen`**; `Component` animates from it.
- **AutoDoorManager** toggles `DoorIsOpen` by proximity (open <16, close >22 studs).
- Bi-parting doors slide **behind** the façade; front spandrels are **collidable**.
- Roof lifted (+0.12) and garage scaled to flagship size by default (W16/H14/D34).
- **PlotManager** Studio fallback (no DataStore) mounts exactly one garage; sets `OwnerUserId`.
- **WorldBoot** skips mounting if PlotManager already did (no duplicates).
- Interior placeholders snap to floor top (no floating props).

**Pre-launch TODOs**
- Set `DEV_ALLOW_AUTO_ADOPT=false` in AutoDoorManager and require strict `OwnerUserId`.
- Publish place; enable “Studio Access to API Services” for DataStore tests.
- Cap **plots per shard** (12–16) and **server max players** (24–30); turn on StreamingEnabled.
