# Production Audit – Robot Collectors

## 1. File Inventory (by runtime)
- **ServerScriptService.World**
  - `bootstrap.server.luau` – bootstraps spawn pad, runs `WorldBoot`, emits build banner.
  - `Spawn.luau` – helper module that ensures the baseplate and spawn pad exist.
  - `spawn_guard.server.luau` – early guard that double-checks spawn artifacts when Rojo/Studio order is unpredictable.
  - `TerrainLoader.server.luau` – generates plaza, paths, and zone anchors in workspace.
  - `WorldBoot.luau` – mounts/rehydrates `GD_Garage`, wires door animation, kicks the debug hooks (now DEBUG-gated) and invokes downstream builders.
  - `ResourceSpawner.server.luau` – per-player resource instancer (now with tag/thickness/radius guard).
  - `WorldInteract.server.luau` – attaches prompts/click detectors and handles depletion/respawn of resource nodes.
  - `CleanupResources.server.luau` – boot-time cleanup for disabled resources plus the garage-radius scrub.
  - `Garage/*` – Component (mount geometry & attributes), Interior (place console/pad assets), Fixup (optional geometry alignment), Animate (door panels), Shows/Hatch (cutscene), Debug (DEV dump heartbeat).
  - `AutoDoorManager.server.luau` – intentionally returns; Component now handles players near the door.
  - `ZoneTrigger.server.luau` – heartbeat-based zone proximity, fires zone change remotes.
  - `Remotes.server.luau` – ensures `RC_Remotes` + mission/hatch remotes exist.
- **ServerScriptService.services**
  - `ResourceService.server.luau` – authoritative resource totals, remotes, bindable bridges.
  - `MissionService.server.luau` – mission state, emits HUD events, listens for collection bindables.
- **ServerScriptService.Modules** (from `src/server_modules`)
  - `BuildGuard.luau` – single-run guard per boot tag.
  - `DoorPlane.luau` – geometric helper for garage door math.
  - `PadAudit.luau` – garage pad audit (now only active when DEBUG true).
  - `ProgressionService.luau` – stubbed level/unlock tracking.
  - `QuestService.luau` – quest progression state and unlock queries.
- **ReplicatedStorage.shared**
  - `config/GameConstants.luau` – consolidated toggles/constants (DEBUG flag, garage radius, thin tile height, legacy movement/economy values).
  - Other configs: `CollectConfig`, `Unlocks`, `MissionDefs`, `Quests`.
  - `ResourceDefs.luau` – per-resource visuals/light definitions.
- **StarterPlayerScripts** (`src/client`)
  - Client HUD/FX scripts (`Main`, `ResourceHUD`, `ResourceFX`, `MissionsHUD`, etc.) plus temporary debug watchers (already isolated client-side).
- **ServerStorage** (at runtime)
  - `ResourceTemplates` folder (optional) provides prefab models for `ResourceSpawner` to clone.
- **Workspace builders**
  - `TerrainLoader` (plaza + anchors) and `WorldBoot` (garage mount) populate workspace dynamically.

## 2. Boot Entry Points and Call Graph
1. **ServerScriptService.World.bootstrap** – requires `World.Spawn.ensure()`, then `World.WorldBoot.run()` and prints build summary.
2. **WorldBoot.run()**
   - Runs `BuildGuard.once("WorldBoot")` to avoid double mounts.
   - Ensures spawn location, logs garage online diagnostics.
   - Requires `Garage.Component` → mounts/rehydrates `GD_Garage`, then inside Component:
     - Calls `Garage.Interior.Mount` (places console/hatch assets).
     - Optionally runs `Garage.Fixup` when `FORCE_FIXUP` true.
     - Schedules the door proximity heartbeat and targeted locker cleanup.
   - DEBUG-only: calls `PadAudit.AuditOnce()` and (when DEBUG true) legacy paver traces (now removed).
3. **TerrainLoader.server.luau** – already executed as part of Rojo sync; ensures plaza/anchors prior to players.
4. **ResourceSpawner.server.luau**
   - Triggered on player join (`Players.PlayerAdded` deferred) and on `Progression:LevelChanged()`.
   - Cleans player resource bucket, clones/validates templates, enforces tag/thickness, rejects positions within `MIN_GARAGE_RADIUS`.
5. **WorldInteract.server.luau**
   - Scans workspace immediately if `RESOURCES_ENABLED`; attaches handlers to valid nodes.
   - Listens to `workspace.DescendantAdded` to cover late spawns.
6. **CleanupResources.server.luau**
   - Runs once at boot; if resources disabled, deletes all tagged/named resources.
   - Always removes prompt-bearing slabs near the door apron and any node within the garage radius.
7. **MissionService/ResourceService** continue responding to collect/deposit events once nodes exist.

## 3. Redundancies / Legacy Artifacts
- Removed duplicate `src/server/ResourceSpawner.server.luau` (old version not referenced by Rojo).
- Deleted unused `RemoteSetup.luau` module; no code referenced it.
- Default Rojo mapping now only exposes `World`, `services`, and `Modules`; stray root scripts (`src/server/bootstrap.server.luau`, `spawn_guard.server.luau`, etc.) remain in repo for reference but are not synced.
- WorldBoot previously contained three overlapping cleanup passes (debug tile removal, robust scrub, temp trace). These are now removed in production builds; rely on `CleanupResources` instead.

## 4. Debug / Temporary Code
- `GameConstants.DEBUG` gates all server-side diagnostics:
  - bootstrap "WATCH" listener block only attaches when DEBUG true.
  - `PadAudit.AuditOnce()` is now inert unless DEBUG.
  - WorldBoot prints and the GD_Lockers removal log only surface in DEBUG.
  - WorldInteract and ResourceSpawner logs & warnings respect DEBUG flag.
- Client debug scripts (e.g., `DebugPaverWatch`, `ClickProbe`) remain client-only; they require manual enablement in Studio.

## 5. Config & Flags Affecting Spawns
- `GameConstants.DEBUG` (default **false**) – enables all watch/audit logging.
- `GameConstants.MIN_GARAGE_RADIUS = 120` – authoritative radius used by ResourceSpawner, CleanupResources, WorldInteract.
- `GameConstants.THIN_TILE_Y_MAX = 1.25` – uniform thin-part threshold for template vetting and debug tools.
- `GameConstants.GARAGE_DEFAULT_DOOR_CENTER` – fallback vector when garage DoorCenter attribute missing.
- `RESOURCES_ENABLED` attribute (on ServerScriptService.World or individual scripts) – toggles ResourceSpawner/WorldInteract; read by ResourceService and CleanupResources.
- `REQUIRE_RESOURCE_TAG` attribute (WorldInteract script) – defaults true; restricts handler attachment to tagged nodes.
- `KEEP_LOCKERS` attribute (World folder) – opt-out for locker removal.
- `FORCE_FIXUP` attribute (World/Garage folder) – forces Garage.Fixup alignment.

## 6. Risk Items
- **Template Hygiene** – ResourceSpawner still trusts `ResourceTemplates` contents; untagged or thin models are now filtered, but malformed models without a BasePart primary can still sneak through (we parent them but cannot reposition childless models).
- **Tag Dependency** – WorldInteract depends on `ResourceNode` tags (or explicit attributes) to detect valid nodes. Missing tags disable collection even if nodes spawn.
- **Late Spawns** – External scripts (tests/plugins) that clone nodes after CleanupResources runs must still tag & position them outside the 120-stud radius to avoid silent destruction.
- **Locker Removal** – GD_Lockers auto-delete unless `KEEP_LOCKERS` set; reintroducing new locker variants should revisit this guard.

## 7. Actionable Plan
1. **Finalize Server Tree** – Retire or archive the unused legacy scripts under `src/server` once validated; they are no longer mapped by Rojo.
2. **Constants as Source of Truth** – Continue reading garage radius / thin tile thresholds from `GameConstants`. Any future tooling should update that module instead of duplicating literals.
3. **Debug Harness** – Enable `GameConstants.DEBUG` only in Studio when running PadAudit or WATCH listeners; keep production builds silent.
4. **Cleanup Ownership** – Rely exclusively on `CleanupResources` for node removal. WorldBoot keeps only the targeted locker fix; additional cleans should live in CleanupResources if needed.
5. **Template QA** – Audit `ServerStorage/ResourceTemplates` to ensure every prefab carries the `ResourceNode` tag, valid `PrimaryPart`, and thickness above `THIN_TILE_Y_MAX`.
6. **Monitoring** – Watch boot output `[BOOT] RC build: DEBUG=false, MIN_GARAGE_RADIUS=120, resources enabled=<value>` to confirm deployment configuration.
7. **Pending Verification** – Confirm no other services rely on the old `RemoteSetup` module or root scripts before deleting the files from version control; document migrations in release notes.

With these adjustments the project is ready for production sync: one authoritative cleanup path, shared constants, and all diagnostics safely behind the DEBUG toggle.
