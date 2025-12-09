

# Robot Collectors

This repo currently contains the **design and planning** for the game *Robot Collectors*.
All previous implementation has been intentionally removed so the game can be rebuilt
cleanly from scratch.

## Current State

- ✅ Game design docs retained (scope, world, systems, loops)
- ✅ Old/failed implementations removed
- ✅ No active Luau source code under `src/` yet
- ✅ Ready for a fresh, minimal scaffold

Folders:

- `docs/` – game design documents
- `.github/`, `.vscode/` – editor/CI setup and automation hooks
- `ROBOT_COLLECTORS.rbxlx` – current Roblox place file
- `world.rbxm` – world model (if used)
- `default.project.json` – Rojo project mapping (will be used again once src/ is recreated)

The `src/` tree will be recreated as part of the new implementation.

## Design Docs

See:

- `docs/ROBOT_COLLECTORS_GDD.md` – core game design
- `docs/ARCHITECTURE.md` – high-level systems and world structure
- `docs/PROJECT_RESET_STATUS.md` – summary of the reset and next steps

## Next Steps for Implementation

1. Create a fresh `src/` scaffold (server, shared, client) based on the design docs.
2. Implement a minimal "spawn → collect → deposit" loop.
3. Reintroduce world zones, garage, missions, and UI **incrementally**, always matching the
   design docs.

## Why the Reset?

The previous implementation accumulated a lot of experimental systems (especially around
the garage) that became harder to fix than to replace. This reset keeps the **vision** and
**design**, while discarding the implementation debt so development can move forward sanely.

## Quick Run

- Use Rojo to sync `default.project.json` into a Roblox Studio place.
- Press **Play**:
  1. Walk out to the scrap field and click scrap piles to fill your backpack.
  2. When your backpack is full (or whenever you want), walk into the garage.
  3. Inside the garage:
     - Use the **DepositTerminal** to move Backpack Scrap → Bank Scrap.
     - Use the **GarageConsole** to open the **Backpack Upgrade** panel.
  4. A **StarterRobot** will spawn on the RobotSpawnPad and follow your character as you move.

## Current Vertical Slice

- **World Boot**
  - `WorldBootstrap` → `WorldBoot` → `TerrainLoader` generate a flat test world and `RC_Spawn`.

- **Scrap & Banking**
  - Scrap nodes with limited charges spawn near the spawn.
  - Backpack vs Bank scrap tracked via `BackpackService` and `StorageService`.
  - Deposit terminal (now inside the garage) handles Backpack → Bank transfers.
  - HUD shows Backpack and Bank values, and Backpack capacity when known.

- **Backpack Upgrades**
  - Backpack levels and capacity are upgradable using banked scrap.
  - Upgrade UI is opened via the GarageConsole.

- **Garage Hub**
  - Simple code-built garage that houses:
    - DepositTerminal (vault)
    - GarageConsole
    - RobotSpawnPad

- **Starter Robot**
  - A StarterRobot spawns on the RobotSpawnPad per player and follows them around.
  - No harvesting or combat logic yet – this is the first step toward the robot systems described in the GDD.

<!--
Git setup (run these in your terminal, not in Roblox):

# Initialize git in this repo
git init

# Add all files and commit the current vertical slice
git add .
git commit -m "Slice 4: starter robot + garage hub"

# Create a new GitHub repository (via the GitHub UI) with no auto-initialization.
# Then connect and push:

git remote add origin https://github.com/YOUR-USER/robot-collectors.git
git branch -M main
git push -u origin main

# Optional: tag this checkpoint
git tag slice-4-starter-robot
git push origin slice-4-starter-robot
-->
