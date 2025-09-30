# Code Refactoring Guide

## Overview

The Robot Collectors codebase has been refactored from monolithic files to a modular, industry-standard structure. This document outlines the changes made and the new architecture.

## Before vs After

### Before Refactoring
```
src/
├── client/
│   └── init.client.luau (800+ lines)
├── server/
│   ├── init.server.luau (900+ lines)
│   └── workspace-setup.server.luau
└── shared/
```

### After Refactoring
```
src/
├── client/
│   ├── init.client.luau
│   └── modules/ (future client modules)
├── server/
│   ├── init.server.luau
│   └── workspace-setup.server.luau
├── server_modules/
│   ├── RemoteSetup.luau
│   ├── PlayerManager.luau
│   └── RobotManager.luau
├── shared/
│   ├── config/
│   │   ├── RobotTypes.luau
│   │   └── GameConstants.luau
│   ├── types/ (for future type definitions)
│   └── utils/ (for future utility functions)
└── workspace-setup.server.luau
```

## New Modular Architecture

### Shared Configuration (`src/shared/config/`)

#### `RobotTypes.luau`
- Centralizes all robot type definitions
- Defines costs, colors, sizes, speed, and efficiency
- Easily extensible for new robot types

#### `GameConstants.luau`
- All game constants in one place
- Starting resources, movement settings, mining amounts
- Resource types and spawning parameters

### Server Modules (`src/server_modules/`)

#### `RemoteSetup.luau`
- Creates and manages all RemoteEvents
- Provides getRemotes() for client access
- Centralizes client-server communication setup

#### `PlayerManager.luau`
- Handles all player data operations
- Manages leaderstats and currency
- Player initialization and robot purchasing logic

#### `RobotManager.luau`
- Robot creation and spawning
- Robot model generation
- Robot state management and resource assignment

### Entry Point (`src/server/init.server.luau`)
- Boots the modular server stack
- Waits for `ServerScriptService/Modules` to sync before wiring handlers
- Queues RemoteEvent traffic during startup to avoid race conditions
- Starts the robot movement loop once modules load

## Benefits of Refactoring

### 1. **Maintainability**
- Each module has a single responsibility
- Easy to locate and modify specific functionality
- Reduced coupling between systems

### 2. **Testability**
- Individual modules can be tested in isolation
- Clear interfaces between components
- Easier to mock dependencies

### 3. **Scalability**
- Easy to add new robot types in RobotTypes.luau
- New features can be added as separate modules
- Configuration changes don't require code changes

### 4. **Collaboration**
- Multiple developers can work on different modules
- Reduced merge conflicts
- Clear ownership of components

### 5. **Industry Standards**
- Follows modern Luau/Roblox development patterns
- Consistent with enterprise software practices
- Easier for new developers to understand

## Migration Path

### Current State
- Modular server (`init.server.luau`) is the active entry point.
- Legacy monolith has been archived as `init-legacy.server.luau.disabled` for reference.
- Server modules now live under `ServerScriptService/Modules` (synced from `src/server_modules/`).

### Next Steps
1. Finish migrating any client calls that still expect the legacy RemoteEvents.
2. Expand coverage in `src/server_modules/` (e.g., datastore persistence, upgrades).
3. Populate `src/shared/types/` and `src/shared/utils/` to formalize shared helpers.
4. Replace temporary debug logging with TestEZ assertions under `ServerScriptService/Tests`.
5. Continue iterating on robot animations/UI now that the state machine is authoritative.

## Configuration Changes

### `default.project.json`
Updated to include new folder structure:
```json
{
  "ReplicatedStorage": {
    "Shared": {
      "Config": {"$path": "src/shared/config"},
      "Types": {"$path": "src/shared/types"},
      "Utils": {"$path": "src/shared/utils"}
    }
  },
  "ServerScriptService": {
    "Server": {"$path": "src/server"},
    "Modules": {"$className": "Folder", "$path": "src/server_modules"},
    "Tests": {"$path": "tests"}
  }
}
```

## Usage Examples

### Adding a New Robot Type
```lua
-- In src/shared/config/RobotTypes.luau
Legendary = {
    Name = "Legendary Bot",
    Type = "Collector",
    Rarity = "Legendary",
    Cost = {Gearbits = 1000, IonShards = 500, RareMetals = 100},
    Color = Color3.fromRGB(255, 0, 255),
    Size = Vector3.new(3, 4, 2.5),
    Speed = 2.0,
    Efficiency = 5
}
```

### Modifying Game Constants
```lua
-- In src/shared/config/GameConstants.luau
STARTING_RESOURCES = {
    Gearbits = 2000,  -- Increased from 1000
    IonShards = 100,  -- Increased from 50
    RareMetals = 5    -- Increased from 0
}
```

### Adding New Remote Events
```lua
-- In src/server_modules/RemoteSetup.luau
local upgradeRobotEvent = Instance.new("RemoteEvent")
upgradeRobotEvent.Name = "UpgradeRobot"
upgradeRobotEvent.Parent = remotes
```

## File Responsibilities

### Server Modules
- **RemoteSetup**: Client-server communication
- **PlayerManager**: Player data, currency, leaderstats
- **RobotManager**: Robot lifecycle, AI, movement

### Shared Config
- **RobotTypes**: Robot definitions and properties
- **GameConstants**: All game configuration values

### Entry Points
- **init.server.luau**: Modular server coordination (queues remotes while modules sync)
- **workspace-setup.server.luau**: World/environment setup

This modular structure makes the codebase more professional, maintainable, and ready for future expansion.
