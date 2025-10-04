# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Robot Collectors: Rise of Gearhold is a Roblox idle collection game featuring automated robot miners that collect resources. The project uses Rojo for external file synchronization and follows a modular architecture.

## Development Commands

### Starting Development
```bash
rojo serve --port 34877
```
The game uses Rojo for syncing code to Roblox Studio. Multiple background Rojo processes may be running - this is normal during development.

### Project Structure
Uses Rojo with `default.project.json` mapping:
- `src/server/` → ServerScriptService
- `src/client/` → StarterPlayer.StarterPlayerScripts
- `src/shared/` → ReplicatedStorage

## Architecture Overview

### Modular Design (v3.1-MODULAR)
The codebase follows industry-standard modular patterns:

**Server Architecture:**
- `init.server.luau` - Main server entry point (currently active implementation)
- `modules/RemoteSetup.luau` - RemoteEvent management
- `modules/PlayerManager.luau` - Player data and currency
- `modules/RobotManager.luau` - Robot lifecycle and AI (modular version)

**Client Architecture:**
- `init.client.luau` - Main client entry point (currently active)
- `modules/GuiManager.luau` - UI creation and layout
- `modules/InputManager.luau` - Mouse input and mining interactions
- `modules/RobotUIManager.luau` - Robot list and management UI
- `modules/ResourceManager.luau` - Resource display updates

**Shared Configuration:**
- `shared/config/RobotTypes.luau` - Robot definitions and stats
- `shared/config/GameConstants.luau` - Game balance and mechanics

### Game Systems

**Robot AI System:**
- Robots spawn in "auto_mining" state and automatically seek resources
- Movement uses frame-stepped `CFrame` target updates with hover raycasts to hold robots above the ground plane
- Distance calculations use X-Z only to prevent Y-axis teleporting issues
- Robots switch between "following", "auto_mining", and manual target assignment

**Resource System:**
- 4 resource types: Gearbit (cyan), Ion Shard (purple), Rare Metal (gold), Crystal (white)
- Each resource type has unique mining sounds (rbxassetid references)
- Resources shrink as they're depleted and respawn based on target counts
- Value-based spawning system maintains resource balance

**Physics Considerations:**
- Robots reposition directly via CFrame and keep hover height via downward raycasts
- Assemblies stay welded/massless to avoid physics drift; velocity is reset each frame
- Fixed hover offsets prevent robots from falling through platforms

## Critical Implementation Details

### Robot Movement Issues
If robots appear stuck or don't move:
1. Check BodyPosition MaxForce values (should be 20000+)
2. Verify robots spawn with "auto_mining" state, not "following"
3. Ensure movement update loop is running every 2 seconds

### Sound System
Mining sounds are resource-specific:
- Gearbit: rbxassetid://119775049787068
- Ion Shard: rbxassetid://127568947930414
- Rare Metal: rbxassetid://131285685848776
- Crystal: rbxassetid://98933401010439

### Resource Management
Resources use persistent tracking via ResourceType StringValues and are positioned using X-Z coordinates only to prevent movement issues.

## Development Workflow

### Making Changes
1. Edit files in `src/` directory structure
2. Rojo automatically syncs to Studio
3. Test in Roblox Studio play mode
4. Robot behavior can be debugged via server console output

### Adding New Features
- Robot types: Update `shared/config/RobotTypes.luau`
- Game balance: Modify `shared/config/GameConstants.luau`
- Client UI: Add to appropriate module in `client/modules/`
- Server logic: Extend modules in `server_modules/` or main `init.server.luau`

## Known Issues & Patterns

### Physics Debugging
- High physics forces (20000+) required for multi-part robots
- robots position logged as "current: X Z" in movement updates
- Distance issues typically stem from Y-axis calculations

### Modular vs Monolithic
- Active server entry: `init.server.luau` (modular with RemoteEvent queue).
- Legacy monolith retained as `init-legacy.server.luau.disabled` for reference only.
- Client runs `init.client.luau`; modular client modules are staged under `client/modules/` for future expansion.

### Sound Asset Loading
- Use only verified rbxassetid references
- Test sound loading in Studio before implementing
- Fallback to rbxassetid://12221967 for generic sounds

## Game Balance Configuration

All game constants centralized in `shared/config/GameConstants.luau`:
- Starting resources, mining distances, movement speeds
- Resource spawn rates and maximum counts
- Mining reward amounts per resource type

Robot progression defined in `shared/config/RobotTypes.luau` with costs, stats, and efficiency ratings.
