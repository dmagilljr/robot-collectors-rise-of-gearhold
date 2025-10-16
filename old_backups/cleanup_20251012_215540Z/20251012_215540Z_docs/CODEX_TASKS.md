# CODEX_TASKS.md
This file contains the ordered execution steps for Codex edits.  
Always run tasks **one at a time** with `docs/CODEX_BASELINE.txt` as context.

---

## Step 1 – Services Layer
- Create `src/server/services/{RobotService,PlayerService,WorldService,EconomyService}.luau`
- Wrap existing `server_modules` (RobotManager, PlayerManager, etc) with thin delegations.
- Expose as `_G.RC_Services` in `init.server.luau`.

---

## Step 2 – Config-Driven Game Data
- Add `src/shared/config/data/{Robots,Zones,Currencies,UITheme}.luau`.
- Move hardcoded costs/rates from managers/UI to configs.
- Keep `GameConstants.luau` only for timing/physics.

---

## Step 3 – Remote Manifest + Validation
- Add `src/shared/remotes/Remotes.luau` listing all remotes.
- Update `RemoteSetup.luau` to create them.
- Use `Remotes.validate` in Studio.

---

## Step 4 – UI Architecture Cleanup
- Add `Taskbar.luau` and `ModalManager.luau`.
- Consolidate side panels into `GarageUI`, `HatchUI`, `AssignUI` modals.
- Bind hotkeys G/H/A; ESC closes modal.

---

## Step 5 – Performance Scheduler
- Replace per-robot while loops with a single Heartbeat scheduler in `RobotManager.luau`.
- Accumulators: `moveAcc` vs `mineAcc` vs `dt`.

---

## Step 6 – Idempotent World Setup
- Update `workspace-setup.server.luau`.
- `ensure(modelName, builderFn)` utility.
- Orient Expansion sign to CENTER.
- Keep one GarageConsole; snap parts to offsets.

---

## Step 7 – Smoke Tests with TestEZ
- Add `tests/server/{init_spec,remotes_spec,mining_spec}.luau`.
- Add `tests/run.server.luau` runner.

---

## Step 8 – Persistence Seam
- Add `SaveService.luau` (in-memory).
- Integrate into `PlayerService`.
- Replace direct leaderstat writes with SaveService-backed state.

---

## Step 9 – Metrics Hooks
- Add `Metrics.luau` with counters (sessions, hatches, TTFB).
- Print summary on Studio shutdown.

---

## Step 10 – UI Systemization
- Add `Theme.luau` and `UIFactory.luau`.
- Update Garage/Hatch/Assign UIs to use UIFactory buttons/cards.

---

## Step 11 – Anti-Abuse
- Add `RateLimiter.luau`.
- Wrap hatch/assign/economy remotes.

---

## Step 12 – Dev/Build Scripts
- Add `scripts/dev_rojo.sh` (`rojo serve --port 34877`).
- Add `scripts/build_place.sh` (`rojo build --output Robot-Collectors.dev.rbxlx`).
- Document in README.

---
