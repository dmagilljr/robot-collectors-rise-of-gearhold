# Robot Collectors: Rise of Gearhold

**Version:** v3.4-LOOP-UX
**Date:** 2025-09-29
**Platform:** Roblox Studio + Rojo 7.5.1

## 🎮 Overview

Robot Collectors: Rise of Gearhold is an idle/incremental game where players hatch robot companions that automatically mine resources. The focus is on relaxed, automated gameplay with minimal player interaction required.

## ✨ Key Features

- **Automated Mining**: Robots mine resources every 5 seconds when set to "auto_mining" mode
- **Multiple Robot Types**: Basic (50⚙️), Advanced (25⚙️ + 15⚡), Elite (100⚙️ + 50⚡ + 10🥇)
- **Resource Management**: Three currencies - Gearbits, Ion Shards, Rare Metals
- **Smart Robot AI**: Robots stay within platform boundaries and move realistically
- **Modern Development**: Built with Rojo 7.5.1 for automated code sync

## 🏗️ World Layout

- **Large Ground Platform**: 120x120 stud grass platform prevents robots from falling
- **Spawn Platform**: 20x20 stud metal platform for player spawning
- **Mining Zones**: 4 colored zones for different resource types
- **Boundary Walls**: Keep gameplay contained within the area

## 🤖 Robot Behavior

### States
- **Following**: Robot follows the player around spawn area
- **Auto-Mining**: Robot moves randomly within 50 studs of center, generates resources

### AI System
- Movement updates every 0.1 seconds
- Robots automatically return to center if they go beyond boundaries
- Alignment-based movement using `AlignPosition`/`AlignOrientation`

## 💰 Resource Generation

**Auto-Mining Rate**: Every 5 seconds per robot
- **Gearbits**: 10-25 per robot per cycle
- **Ion Shards**: 2-5 per robot per cycle
- **Rare Metals**: 0-2 per robot per cycle (only with 3+ robots)

## 🔧 Technical Stack

- **Roblox Studio**: Game development environment
- **Rojo 7.5.1**: External code synchronization tool
- **Luau**: Modern scripting language (.luau files)
- **Task Library**: Modern coroutine handling with task.spawn()
- **RemoteEvents**: Client-server communication

## 📁 Project Structure

```
Robot-Collectors-Rise-of-Gearhold/
├── src/
│   ├── client/                # StarterPlayerScripts + UI modules
│   │   ├── init.client.luau
│   │   └── modules/
│   ├── server/                # Server entry point + workspace setup
│   │   ├── init.server.luau
│   │   └── workspace-setup.server.luau
│   ├── server_modules/        # RemoteSetup, PlayerManager, RobotManager
│   └── shared/
│       └── config/            # GameConstants, RobotTypes
├── docs/                      # Setup guide, API reference, changelog
├── tests/                     # TestEZ runner + specs
├── sounds/                    # Audio stubs
├── Robot-Collectors.rbxlx     # Roblox place file
└── default.project.json       # Rojo 7.5.1 configuration
```

## 🚀 Quick Start

1. **Start Rojo Server**: Run `rojo serve --port 34877` in project directory
2. **Open Roblox Studio**: Open `Robot-Collectors.rbxlx`
3. **Connect Rojo Plugin**: Connect to `localhost:34877`
4. **Play Test**: Click Play to test the game
5. **Hatch Robots**: Use the bottom UI to hatch robots
6. **Toggle Mining**: Use the right panel to set robots to auto-mining

## 🎯 Gameplay Loop

1. **Start** with 1000 Gearbits, 50 Ion Shards, 0 Rare Metals
2. **Hatch** your first Basic robot (50 Gearbits)
3. **Set to Auto-Mining** using the robot management panel
4. **Watch Resources Grow** automatically every 5 seconds
5. **Hatch More Robots** as you earn more Gearbits/Ion Shards
6. **Upgrade** to Advanced (25⚙️ + 15⚡) and Elite (100⚙️ + 50⚡ + 10🥇) robots for better efficiency

## 🐛 Known Issues

All major issues have been resolved as of v3.1:
- ✅ Robot movement AI working correctly
- ✅ Platform boundary system prevents falling
- ✅ Clean workspace creation (no duplicates)
- ✅ Responsive UI with proper button feedback
- ✅ Automated resource generation

## 📊 Version History

- **v3.1-SYNC-TEST**: Fixed robot AI, platform system, and UI responsiveness
- **v3.0-modern**: Complete rewrite for Rojo 7.5.1 compatibility
- **v2.x**: Legacy versions with mining system issues
