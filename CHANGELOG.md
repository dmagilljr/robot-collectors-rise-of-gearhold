# Changelog

## [Slice 4] Starter Robot Companion & Garage Hub (2025-12-09)

- Added `RobotService` to spawn a `StarterRobot` per player on the `RobotSpawnPad`.
- StarterRobot follows the player at a small offset using Heartbeat updates.
- Introduced `RobotBootstrap.server.luau` to ensure RobotService is loaded.
- Garage is now a code-built structure (`RC_Garage`) with:
  - Open front for easy access.
  - `RobotSpawnPad` in the center.
  - Interior `DepositTerminal` (vault) for depositing scrap.
  - `GarageConsole` that opens the Backpack Upgrade UI.

## [Slice 3] Backpack Upgrades

- Extended `BackpackService` with backpack levels and capacities.
- Added `StorageService.TrySpendBankScrap` to pay upgrade costs from banked scrap.
- Implemented upgrade RemoteEvents (`RC_UpgradeUpdate`, `RC_OpenUpgradeUI`, `RC_RequestUpgrade`).
- Added an Upgrade UI panel to show current level, capacity, next level, cost, and bank status.

## [Slice 2] Scrap, Backpack, Bank & HUD

- Implemented scrap nodes near spawn with click detectors.
- Added `BackpackService` and `StorageService` to track backpack vs bank scrap.
- Added `ResourceService` as a glue layer between world interactions and services.
- Implemented `RC_BackpackUpdate` and `RC_BankUpdate` remotes.
- Added a basic HUD showing Backpack Scrap and Bank Scrap.

## [Slice 1] World Boot & Terrain

- Implemented world boot chain:
  - `WorldBootstrap.server.luau` → `WorldBoot.module.luau` → `TerrainLoader.server.luau`.
- Generated flat test terrain and `RC_Spawn` part.
- Verified stable player spawning with no falling through the world.
