# Development Log

# Session: 2025-09-30 - Garage Integration & Status Remotes

## Goals
- Connect the garage hatch flow to the operations console with status messaging.
- Surface quick hatch actions and ensure hatch requests acknowledge success/failure.

## Changes
- Added a `GarageStatus` remote channel and updated `GarageService` to signal hatch start/completion/failure while refunding on error.
- Expanded the client garage UI to track busy state, respond to server statuses, and reuse menu definitions after failures.
- Embedded garage controls into the operations console with live status text, quick hatch buttons, and automatic robot roster refreshes.
- Hooked leaderstats/resource updates into the quick hatch availability checks and refreshed RemoteSetup specs for the new remote.
- Layered drill loop audio plus garage steam/door rumble effects so hatch sequences feel grounded.
- Resolved the garage prompt closing immediately after release; the hatch menu now stays open until you walk away or leave the console.
- Disabled placeholder Marketplace sound IDs (set via `GameConstants.AUDIO`) to eliminate 403 errors until bespoke assets are uploaded.
- Smoothed the garage rollout path so freshly-hatched robots travel down the walkway instead of popping out the roof.
- Garage menu now shows current balances for Gearbits/Ion Shards/etc. and highlights whether you can afford each blueprint.
- Garage rollout now spawns bots at the interior waypoint, filters the shell/door from hover checks, and hands off to a “garage greeting” state so units roll out, pause in front of the player, then transition into follow without bouncing.
- Garage door rebuilt as segmented roll-up slats with synchronized lighting/rumble; door now slides upward instead of swinging through the bay so players aren’t knocked back during hatch.

## Follow-up
- Layer drill/garage VFX and audio cues now that hatch status callbacks exist.
- Consider broadcasting a dedicated "ready" event once rollout tweens finish for richer UI feedback.

## Session: 2025-09-29 - Align-Powered Movement & Ops Console Polish

### Goals
- Retire the BodyPosition/BodyVelocity mover and replace it with Roblox's modern alignment constraints.
- Ship the streamlined operations console that pairs with the new state machine.

### Changes
- Swapped each robot's `Motion` folder to `AlignPosition`/`AlignOrientation`, keeping chassis upright while smoothing travel speed ramps.
- Tuned `GameConstants.MOVEMENT_UPDATE_INTERVAL` to 0.1s and tweaked robot travel speeds for faster drill cadence without jitter.
- Updated `RobotManager` helpers to prewarm mover attachments, toggle drill FX via attributes, and respect the new cooldown/return states.
- Rebuilt the right-side console: compact robot cards, four-button auto-assign strip, "Assign nearest" helpers, and health bars for quick reads.

### Follow-up
- Animate drilling VFX to match the new `DrillActive` flag and add audio layering.
- Port the garage UI onto the same module pattern so hatch/repair/go-to-field can reuse the console buttons.
- Replace remaining `print` debugging in `RobotManager` with TestEZ specs under `ServerScriptService/Tests` once the loop stabilises.

## Session: 2025-09-27 - Complete Project Rebuild for Rojo 7.5.1

### Initial State
- Found incompatible Rojo versions (Plugin 7.5.1 vs CLI 0.5.4)
- Game had issues with robots falling off platforms and unresponsive UI
- User explicitly required latest supported versions

### Major Changes Made

#### 1. Rojo Version Compatibility Fix
- **Problem**: Rojo plugin 7.5.1 incompatible with CLI 0.5.4
- **Solution**: Located existing Rojo 7.5.1 installation at `/usr/local/bin/rojo`
- **Result**: Full compatibility achieved

#### 2. Complete Project Recreation
- **Approach**: Fresh start with clean file structure
- **Changes**:
  - Created modern `default.project.json` for Rojo 7.5.1
  - Converted all scripts to `.luau` file extensions
  - Replaced deprecated `spawn()` with `task.spawn()`
  - Organized RemoteEvents in proper folder structure

#### 3. Platform System Overhaul
- **Problem**: Robots falling off small platforms
- **Solution**: Created massive 120x120 stud ground platform
- **Components**:
  - Ground platform (120x120x4 studs, grass material)
  - Spawn platform (20x20x2 studs, metal, on top)
  - Mining zones positioned on ground level
  - Boundary walls for containment

#### 4. Robot AI System Redesign
- **Movement System**: Physics-based using BodyPosition/BodyVelocity
- **Boundary Logic**: Robots stay within 50 studs of center
- **States**: "following" (follows player) and "auto_mining" (random movement)
- **Safety**: Automatic return to center if robots go out of bounds
- **Debug Output**: Added comprehensive logging for troubleshooting

#### 5. Resource Generation System
- **Automation**: Resources generated every 5 seconds per auto-mining robot
- **Scaling**: More robots = more resources
- **Balance**:
  - Gearbits: 10-25 per robot
  - Ion Shards: 2-5 per robot
  - Rare Metals: 0-2 per robot (only with 3+ robots)

#### 6. UI/UX Improvements
- **Responsive Buttons**: Fixed hanging/freezing hatch buttons
- **Visual Feedback**: Non-blocking button flash animations
- **Real-time Updates**: Live resource display updates
- **Robot Management**: Toggle between following/mining modes

#### 7. Code Architecture
- **Separation of Concerns**:
  - `init.server.luau`: Core game logic, robot AI, resource generation
  - `workspace-setup.server.luau`: World creation and environment setup
  - `init.client.luau`: UI, user interactions, visual updates
- **Modern Practices**:
  - Task-based coroutines
  - Proper RemoteEvent organization
  - Comprehensive error handling

### Bug Fixes Applied

1. **Terrain Destruction Error**: Excluded Terrain from workspace cleanup
2. **Leaderstats Timing**: Fixed client accessing leaderstats before creation
3. **Duplicate Workspace**: Removed conflicting workspace creation
4. **Robot Movement**: Added debug output to track movement issues
5. **Button Responsiveness**: Made visual feedback non-blocking

### Testing Results

✅ **Server Startup**: Clean initialization with proper workspace creation
✅ **Robot Hatching**: Basic and Advanced robots spawn correctly
✅ **Resource Generation**: Automated earning every 5 seconds
✅ **Robot State Changes**: Toggle between following/auto-mining works
✅ **Platform Stability**: Large platform prevents falling
✅ **UI Responsiveness**: Buttons respond immediately
✅ **Rojo Sync**: Automatic code synchronization working

### Current Status

**Game is fully functional as an idle/incremental game:**
- Players start with 1000 Gearbits
- Can hatch robots that automatically mine resources
- Simple, relaxing gameplay with minimal interaction required
- Modern development workflow with Rojo 7.5.1

### Next Possible Enhancements

- Additional robot types (Elite robots implemented but not tested)
- Upgrade system for existing robots
- Achievement/milestone system
- Save/load player progress
- More mining zones with different resource yields
- Robot automation improvements (pathfinding to specific zones)

### Development Environment

- **Roblox Studio**: Latest version
- **Rojo**: 7.5.1 (CLI and plugin)
- **Language**: Luau with modern syntax
- **Sync Port**: localhost:34877
- **Project Structure**: Organized src/ folder with client/server separation
