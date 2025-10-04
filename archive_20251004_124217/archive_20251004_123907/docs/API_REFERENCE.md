# API Reference

**Updated for v3.3 – Modular Server Stack**

## Project Structure Overview
- **ServerScriptService/Server (`src/server/init.server.luau`)** – boots the modular runtime, queues RemoteEvents until modules sync, and starts the robot movement loop.
- **ServerScriptService/Modules (`src/server_modules/`)**
  - `RemoteSetup.luau` – guarantees core RemoteEvents exist and returns references.
  - `PlayerManager.luau` – player data, leaderstats, currency updates, and cleanup on leave.
  - `RobotManager.luau` – robot spawning, state machine, motion controller, and mining rewards.
- **ReplicatedStorage/Shared (`src/shared/`)** – configuration modules (`config/GameConstants.luau`, `config/RobotTypes.luau`).
- **StarterPlayer/StarterPlayerScripts (`src/client/`)** – client entry, UI, and robot targeting helpers.

## RemoteEvents

### HatchRobot
- **Path:** `ReplicatedStorage.Remotes.HatchRobot`
- **Direction:** Client ➜ Server
- **Parameters:** `(string robotType, number? amount = 1)`
- **Behavior:** Validates currency via `PlayerManager`, deducts costs, spawns robots through `RobotManager`, then updates leaderstats and robot count.

```lua
remotes.HatchRobot:FireServer("Basic", 1)
remotes.HatchRobot:FireServer("Advanced", 2)
```

### SetRobotState
- **Path:** `ReplicatedStorage.Remotes.SetRobotState`
- **Direction:** Client ➜ Server
- **Parameters:** `(string robotId8, string newState)` where `newState` is `"following"` or `"auto_mining"`.
- **Behavior:** Updates the robot state machine; when entering auto-mine the robot selects/uses a target resource and caches the player’s current home position.

```lua
remotes.SetRobotState:FireServer(robotId, "auto_mining")
remotes.SetRobotState:FireServer(robotId, "following")
```

### AssignRobotToResource
- **Path:** `ReplicatedStorage.Remotes.AssignRobotToResource`
- **Direction:** Client ➜ Server
- **Parameters:** `(string robotId8, Instance resourcePart)`
- **Behavior:** Forces the specified robot to mine the provided resource, resetting its cargo and state timers. The operations console now fires this remote automatically when the player chooses one of the quick assignment buttons (Gearbit/Ion Shard/Rare Metal/Crystal) or the “Assign nearest …” action.

### ManualMine
- **Path:** `ReplicatedStorage.Remotes.ManualMine`
- **Direction:** Client ➜ Server
- **Parameters:** `(Instance resourcePart)`
- **Behavior:** Applies a single mining hit if the player is within range, shrinks or destroys the node, and awards currency using `GameConstants.MINING_AMOUNTS` and `RESOURCE_TO_CURRENCY` mappings.

## Data Structures

### Player Data (Server)
```lua
{
    Currency = {
        Gearbits = 1000,
        IonShards = 50,
        RareMetals = 0,
        Crystals = 0,
    },
    Robots = {
        {
            Type = "Basic",
            Name = "Basic Bot",
            Rarity = "Common",
            Level = 1,
            UniqueId = "503eb038-..."
        },
    },
    Level = 1,
}
```

### Robot Workspace Representation
```
Basic Bot_503eb038 (Folder)
├── RobotBody (Part)
├── RobotHead (Part)
├── Owner (ObjectValue)            -- Player reference
├── RobotState (StringValue)       -- "following" | "auto_mining"
├── UniqueId (StringValue)         -- Full GUID
├── TargetResource (ObjectValue)   -- Assigned resource part (optional)
└── Attributes
    ├── RobotType (string)
    ├── TaskState (string)         -- idle | seeking | travel | mining | return
    ├── CargoAmount (number)
    ├── CargoCurrency (string)
    ├── HomePosition (Vector3)
    ├── MiningTimer (number)
    └── LastUpdate (number)
```

## Key Server Functions

### `PlayerManager.initializePlayer(player)`
Creates leaderstats, seeds starting currency, and registers player data.

### `PlayerManager.updatePlayerCurrency(userId, currencyType, delta)`
Mutates the stored data and mirrors the result to leaderstats.

### `RobotManager.spawnRobot(robotType, player)`
Builds a new robot folder, applies attributes, and returns serializable robot metadata.

### `RobotManager.setRobotState(robotId, newState, player)`
Transitions the robot state machine, resetting timers and home position when auto-mining begins.

### `RobotManager.assignRobotToResource(robotId, resource, player)`
Pins a robot to a specific resource, clears previous cargo, and pushes the state machine into `travel`.

### `RobotManager.updateRobotMovement()`
Invoked every `GameConstants.MOVEMENT_UPDATE_INTERVAL` seconds; advances each robot through the state machine, moves bodies toward targets, processes drilling ticks, and deposits rewards when returning home.

## Client Helpers
- **`updateResourceDisplay()`** – syncs GUI counters with leaderstats (Gearbits, Ion Shards, Rare Metals, Crystals).
- **`updateRobotList()`** – rebuilds the mining menu, showing state toggles, targeting buttons, and live status text.
- **`RobotUIManager.getTargetingRobot()` / `setTargetingRobot()`** – manage client-side targeting workflow for manual assignments.

## Game Constants (Selected)
- `ROBOT_HEIGHT` – Y offset used for robot placement.
- `ROBOT_TRAVEL_SPEED` – base studs per second per robot (scaled by robot config `Speed`).
- `ROBOT_MINING_INTERVAL` – seconds between mining ticks.
- `ROBOT_RETURN_DISTANCE` – proximity required to trigger deposit when returning home.
- `MOVEMENT_UPDATE_INTERVAL` – scheduler interval for robot movement updates (0.1 seconds).
- `MINING_AMOUNTS` / `RESOURCE_TO_CURRENCY` – define min/max yields per resource type and the resulting currency mapping.

## Currency Flow Summary
1. Manual mining or robots apply damage to resource nodes.
2. When health reaches zero the node is destroyed by the server.
3. Rewards are pushed through `PlayerManager.updatePlayerCurrency`, ensuring leaderstats stay in sync.
4. Robots reset to `seeking` (if still in auto-mine) and repeat the loop until instructed otherwise.
