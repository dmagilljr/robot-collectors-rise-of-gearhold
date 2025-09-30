# Changelog

## v3.4-LOOP-UX (2025-09-29)

### ✨ Highlights
- Swapped robot navigation to `AlignPosition`/`AlignOrientation`, preventing hatch jitter and keeping chassis upright.
- Tightened movement constants (speed, update interval, mining cadence) for smoother glides and faster drill ticks.
- Rebuilt the operations console with compact cards, a four-button auto-assign strip, and a concise status panel—no more nested targeting toggles.
- Added quick “Assign nearest …” helper and health bars so resource choices are readable at a glance.

### 📌 Next
- Flesh out the garage (hatch/repair/customise) loop to complement the mining workflow.
- Introduce automated regression tests for robot assignments once the garage stabilises.

---

## v3.3-MODULAR REFINEMENTS (2025-09-28)

### 🚀 Highlights
- Promoted `init.server.luau` as the active modular entry point with RemoteEvent queuing during Rojo startup.
- Moved the server-side modules into `ServerScriptService/Modules` (sourced from `src/server_modules/`) so Studio always sees the live managers.
- Extended `RobotManager` with a deterministic state machine: robots now cache home positions, move via step-based motion, mine on timed ticks, and deposit gearbits before reseeking.
- Expanded shared constants (`ROBOT_TRAVEL_SPEED`, faster `MOVEMENT_UPDATE_INTERVAL`) to tune robot motion.
- Refreshed contributor docs (API reference, refactoring guide, setup guide, AGENTS) to match the new layout and workflows.

### 🛠️ Follow-up
- Replace temporary debug output in `RobotManager` with assertions in `ServerScriptService/Tests`.
- Animate robot drilling and polish the mining UI based on the new behavior loop.

---

## v3.1-MODULAR (2025-09-28)

### 🔧 Critical Bug Fixes
- **Fixed mining sound**: Changed from `impact_water.mp3` (crashing waves) to `impact_generic.mp3` with pitch 0.7 for proper pickaxe-on-stone thunk sound
- **Fixed robot disappearing**: Resolved robot teleporting/disappearing when assigned to resources by fixing distance calculation to use only X-Z coordinates instead of 3D distance
- **Fixed resource Y positioning**: Resources now maintain consistent Y positions when shrinking, preventing robots from following moving targets

### 🏗️ Architecture Refactoring
- **Modular code structure**: Refactored 900+ line monolithic files into focused, industry-standard modules
- **Centralized configuration**: Moved all game constants and robot types to shared config files
- **Separation of concerns**: Each module now has a single, clear responsibility
- **Complete client refactoring**: Client code now follows the same modular architecture as server

### 📁 New File Structure
```
src/
├── server/
│   ├── init.server.luau (modular entry point)
│   └── workspace-setup.server.luau
├── server_modules/
│   ├── RemoteSetup.luau
│   ├── PlayerManager.luau
│   └── RobotManager.luau
├── client/
│   ├── init.client.luau (client entry point)
│   └── modules/
│       ├── GuiManager.luau
│       ├── RemoteManager.luau
│       ├── ResourceManager.luau
│       ├── RobotUIManager.luau
│       └── InputManager.luau
└── shared/
    └── config/
        ├── RobotTypes.luau
        └── GameConstants.luau
```

### 🎮 Gameplay Improvements
- **Distance-based mining**: Players can only mine resources within 10 studs
- **Improved robot targeting**: Robots now properly stay at assigned resources until depleted
- **Fixed robot movement**: Robots maintain proper Y=5 positioning and don't fall through platforms

### 📚 Documentation Updates
- **New REFACTORING_GUIDE.md**: Complete guide to the new modular architecture
- **Updated API_REFERENCE.md**: Reflects new project structure
- **Updated SETUP_GUIDE.md**: Includes information about modular development
- **New CHANGELOG.md**: This file!

### 🔧 Technical Improvements
- **Modular imports**: Clean module dependency system
- **Configuration-driven**: Easy to modify game values without code changes
- **Maintainable codebase**: Industry-standard patterns for professional development
- **Scalable architecture**: Easy to add new features and robot types

### 🎯 Module Responsibilities

#### Server Modules
- **RemoteSetup**: Manages all RemoteEvent creation and access
- **PlayerManager**: Handles player data, currency, and leaderstats
- **RobotManager**: Robot creation, spawning, state management, and assignment

#### Client Modules
- **GuiManager**: All UI element creation and layout management
- **RemoteManager**: Client-side remote event access and communication
- **ResourceManager**: Resource display updates and leaderstats monitoring
- **RobotUIManager**: Robot list display and robot management UI
- **InputManager**: Mouse clicks, mining, and robot targeting

#### Shared Configuration
- **RobotTypes**: All robot type definitions (Basic, Advanced, Elite)
- **GameConstants**: All game configuration values and constants

### 🐛 Bug Fixes Detail

#### Robot Disappearing Issue
**Problem**: Robots would move to resources but then disappear or teleport around
**Root Cause**: 3D distance calculation between robots (Y=5) and shrinking resources (Y=0.6→0.2) resulted in distances of 283+ studs
**Solution**: Changed distance calculation to only consider X-Z coordinates: `math.sqrt((currentPos.X - resourcePos.X)^2 + (currentPos.Z - resourcePos.Z)^2)`

#### Mining Sound Issue
**Problem**: Mining sound was high-pitched and sounded like crashing waves
**Root Cause**: Using `impact_water.mp3` with pitch 0.3
**Solution**: Changed to `impact_generic.mp3` with pitch 0.7 for proper thunk sound

#### Resource Y Positioning
**Problem**: Resources moved their Y position as they shrunk, causing robot pathfinding issues
**Root Cause**: `resourceNode.Position = Vector3.new(resourceNode.Position.X, newSize / 2, resourceNode.Position.Z)`
**Solution**: Commented out Y position updates to keep resources at fixed Y positions

### 💻 Development Improvements
- **Reduced code duplication**: Shared constants eliminate magic numbers
- **Type safety preparation**: Structure ready for type definitions
- **Testing readiness**: Modular structure enables unit testing
- **Team development**: Multiple developers can work on different modules

### 🔄 Migration Status
- ✅ Server modules created and functional
- ✅ Shared configuration extracted
- ✅ Project structure updated
- ✅ Documentation updated
- ✅ Client refactoring completed
- ✅ Modular architecture fully implemented
- ⏳ Full migration to modular version (pending testing)

### 🚀 Performance Improvements
- **Cleaner imports**: Modules only load what they need
- **Better memory management**: Focused module lifecycle
- **Optimized lookups**: Centralized configuration reduces repeated computations

### 📈 Benefits Achieved
1. **Maintainability**: 80-line entry point vs 900+ line monolith
2. **Extensibility**: Adding new robot types now takes 10 lines in config
3. **Debugging**: Clear module boundaries make issues easier to isolate
4. **Collaboration**: Team can work on different modules simultaneously
5. **Industry Standard**: Follows modern Luau/Roblox development practices

---

## v3.0-MODERN (Previous)
- Original monolithic implementation
- Basic robot collection and mining mechanics
- Initial UI and resource system
- Mining zone assignment system

---

## Future Roadmap
- [ ] Animate drilling/tread motion and add VFX/audio layers for robots
- [ ] Redesign the mining console UI around the new state machine
- [ ] Harden persistence (datastore saves, offline currency accrual)
- [ ] Expand shared type definitions/utilities for cross-module reuse
- [ ] Grow automated coverage in `ServerScriptService/Tests`
