# Robot Collectors: Rise of Gearhold

A sci-fi robot collection RPG for Roblox featuring an expansive universe of mechanical warriors, resource mining, strategic combat, and robot fusion systems.

## 🎮 Game Overview

**Robot Collectors: Rise of Gearhold** is building toward a Roblox-scale robot collection RPG. The current v3.4-LOOP-UX build focuses on a polished idle mining loop while the wider combat, fusion, and world content remain in planning. Use `docs/README.md` for hands-on setup instructions and keep this README as the product roadmap.

### 🔭 Project Scope & Roadmap
- **Near Term**: Deliver a polished core loop (mine → deposit → repeat) and a fully interactive garage where players hatch, repair, and customise robots.
- **Mid Term**: Expand the world with social hubs, distinct biome zones, and specialised robot roles tailored for harvesting, exploration, and cooperative chores.
- **Long Term**: Introduce robot-versus-robot encounters, competitive leagues, and ongoing live updates so the experience can sit alongside Roblox staples such as Pet Simulator.

### 🧭 Development Pillars
1. **Modular Architecture** – Server modules under `src/server_modules/` power the robot AI and will scale to future features (garages, PvP arenas, world bosses).
2. **Player Agency** – Every loop should reinforce customisation: assign roles, tweak load-outs, and watch the robots reflect those choices in gameplay.
3. **Social Stickiness** – The world should encourage collaboration, trading, and light-hearted competition so players have reasons to come back daily.

### 🔍 Current Loop Snapshot (v3.4)
- Three collector robots (Basic/Advanced/Elite) hatch through the operations console and upgrade the player's automated mining throughput.
- Robots navigate with frame-stepped `CFrame` updates guided by hover raycasts, mining on 0.8s ticks (see `src/shared/config/GameConstants.luau`) and returning cargo automatically via the state machine.
- The right-side console lists active robots, quick auto-assign buttons, "Assign nearest" helpers, and live resource health bars.
- Players can supplement income with manual mining inside a 10-stud radius using the same resource nodes.

### 🚀 Roadmap Highlights
- Expand the roster toward 50+ robots across Assault, Defender, Support, Scout, and Heavy archetypes.
- Unlock five themed zones with bespoke resources, quests, and late-game challenges.
- Layer in strategic combat, robot fusion crafting, and prestige-style progression to deepen long-term play.
- Build social hooks—trading, co-op arenas, seasonal events—to sustain daily retention.

## 🗺️ Zone Roadmap

*These five zones represent the long-term world plan. The current build ships a single mining yard while the art and quest content below remain in concept.*

### 1. Corepoint Station
- **Starting Zone** - The central hub for new collectors
- **Unlock Level:** 1
- **Features:** Basic robots, tutorial quests, fundamental resources
- **Notable Robots:** ScrapBot, ShieldBot, RepairDrone, SpeedRunner

### 2. Rustspire Yards
- **Industrial Zone** - Salvage yards and mechanical workshops
- **Unlock Level:** 10
- **Features:** Advanced materials, industrial robots, salvage operations
- **Notable Robots:** BlitzMech, GuardianMech, TankBot

### 3. Voltbay Arena
- **Combat Zone** - High-tech arena for elite battles
- **Unlock Level:** 25
- **Features:** Arena challenges, energy-based resources, plasma technology
- **Notable Robots:** PlasmaWarrior, FortressBot, DestroyerMech

### 4. Bytewind Market
- **Trading Hub** - Bustling marketplace for rare materials
- **Unlock Level:** 40
- **Features:** Exotic trading, data crystals, market challenges
- **Notable Robots:** MedicBot, StealthBot

### 5. Hollow Hex Core
- **End-Game Zone** - Mysterious core facility with ultimate challenges
- **Unlock Level:** 60
- **Features:** Ancient technology, legendary robots, core fragments
- **Notable Robots:** CommanderUnit, ApexTitan

## 🤖 Robot Types & Rarities

*Shipped today:* Basic, Advanced, and Elite collector robots (see `src/shared/config/RobotTypes.luau`).

*Planned expansion:* 
- **Assault:** High damage dealers with offensive capabilities
- **Defender:** Tank units with high health and protective abilities
- **Support:** Utility robots with healing and buff abilities
- **Scout:** Fast units with mobility and reconnaissance skills
- **Heavy:** Massive units with devastating area-of-effect attacks

*Rarity targets:* Common, Uncommon, Rare, Epic, Legendary—drop rates to be tuned once the broader roster enters testing.

## ⚙️ Game Systems (Planned)

### Mining System
- Discover and extract valuable ores from each zone
- Upgrade mining equipment and improve efficiency
- Rare materials unlock advanced crafting options
- Zone-specific resources with varying difficulty levels

### Combat System
- Turn-based strategic battles with tactical depth
- Robot abilities with cooldowns and energy costs
- Formation strategies and team composition
- Experience gain for participating robots

### Fusion System
- Combine two robots to create more powerful variants
- Success rates based on robot compatibility and levels
- Possibility of rarity upgrades through successful fusion
- Fusion history tracking for lineage systems

### Experience & Leveling
- Player progression unlocks new zones and features
- Individual robot leveling improves stats and abilities
- Quest completion provides substantial experience rewards
- Combat victories grant experience to participating robots

## 🎯 Controls & UI

*Live today*: The right-side operations console manages robot states and assignments, while the hatch panel spawns Basic/Advanced/Elite bots. Resource counters auto-sync with leaderstats.

*Keyboard shortcuts (planned)*
- **I** - Toggle Inventory
- **H** - Toggle Hatching Interface
- **M** - Toggle Mining Interface
- **B** - Toggle Battle Interface
- **Q** - Toggle Quest Log

*UI roadmap*
- **Inventory System:** Manage your robot collection with filtering and sorting
- **Expanded Hatching Station:** Acquire new robots from future zones
- **Advanced Mining Interface:** Coordinate multi-zone resource collection
- **Combat HUD:** Manage battles and use robot abilities
- **Quest Tracker:** Monitor objectives and claim rewards

## 📁 Project Structure

```
Robot-Collectors-Rise-of-Gearhold/
├── src/
│   ├── client/                # StarterPlayerScripts + GUI/controllers
│   │   ├── init.client.luau
│   │   └── modules/
│   ├── server/                # Server entry point & workspace scaffolding
│   │   ├── init.server.luau
│   │   └── workspace-setup.server.luau
│   ├── server_modules/        # RemoteSetup, PlayerManager, RobotManager
│   └── shared/
│       └── config/            # GameConstants, RobotTypes
├── docs/                      # Setup guide, API reference, changelog
├── tests/                     # TestEZ runner + specs
├── sounds/                    # Audio stubs
├── Robot-Collectors.rbxlx     # Studio place for quick playtests
└── default.project.json       # Rojo 7.5.1 project mapping
```

## 🛠️ Development Setup

### Prerequisites
- Roblox Studio 2024+
- Basic knowledge of Lua scripting
- Understanding of Roblox development workflow

### Installation
1. Clone or download this repository.
2. Install Roblox Studio and Rojo 7.5.1 (CLI + Studio plugin) as described in `docs/SETUP_GUIDE.md`.
3. From the project root run `rojo serve --port 34877`.
4. Open `Robot-Collectors.rbxlx` in Studio, connect the Rojo plugin to `localhost:34877`, then press Play.

### Configuration
- Adjust loop timing and economy values in `src/shared/config/GameConstants.luau`.
- Loop and economy timing are defined in `GameConstants.luau`; avoid hard-coding waits in scripts.
- Extend the robot catalogue in `src/shared/config/RobotTypes.luau`.
- Additional data modules (zones, quests, combat loadouts) will land with future milestones and follow the same shared-config pattern.

## 🎮 Gameplay Progression

*Design roadmap note: progression beats below outline the intended beta journey; the current prototype covers the Corepoint mining yard only.*

### Early Game (Levels 1-15)
- Learn basic mechanics in Corepoint Station
- Collect your first robots through hatching
- Complete tutorial quests and mining operations
- Unlock Rustspire Yards for advanced challenges

### Mid Game (Levels 15-40)
- Master combat strategies and robot fusion
- Explore Voltbay Arena for elite competitions
- Build diverse robot teams for different challenges
- Accumulate resources for major upgrades

### Late Game (Levels 40+)
- Access Bytewind Market for rare trading opportunities
- Challenge the mysterious Hollow Hex Core
- Collect legendary robots like CommanderUnit and ApexTitan
- Master all game systems for ultimate efficiency

## 🔧 Customization Options

*These flows are planned for the garage milestone; hooks and config stubs exist, but the UI is still under construction.*

### Adding New Robots
1. Extend `src/shared/config/RobotTypes.luau` with new entries (costs, visuals, efficiency stats).
2. Use `GameConstants` to tune hatch requirements or introduce new currencies as needed.
3. Validate remote handlers in `src/server_modules/RobotManager.luau` to ensure new attributes sync through the state machine.

### Creating New Zones *(roadmap)*
1. Introduce a shared `ZoneConfig` module (to be created under `src/shared/config/`) describing spawn points, rewards, and unlock levels.
2. Expand `workspace-setup.server.luau` to generate environment props driven by that config.
3. Wire future zone-specific mining logic through `RobotManager` task states.

### Expanding Quest System *(roadmap)*
1. Define quest descriptors in an upcoming `src/shared/config/QuestConfig.luau` module.
2. Build a `QuestManager` server module to orchestrate objectives and rewards.
3. Add client UI modules for tracking progress and claiming loot.

## 📊 Game Balance

*Balance numbers below serve as design targets. Only the core mining loop is tuned in the live build.*

### Currency Economy
- **Gearbits:** Primary currency earned through activities
- **Ion Shards:** Premium currency for special purchases
- Balanced earning rates prevent inflation
- Multiple spending options maintain currency value

### Robot Power Scaling
- Linear base stat growth with exponential costs
- Rarity provides multiplicative bonuses
- Fusion offers alternative progression paths
- Level caps prevent excessive power differences

## 🐛 Known Issues & Solutions

### Common Issues
- **Robot not appearing after hatching:** Check inventory filter settings
- **Mining not working:** Ensure sufficient mining power for zone
- **Fusion failing repeatedly:** Check robot levels and compatibility
- **UI not responding:** Try closing and reopening interface

### Performance Optimization
- Inventory displays are paginated for large collections
- Battle calculations are optimized for real-time performance
- Mining operations use efficient update cycles
- UI elements are loaded on-demand when needed

## 🔮 Future Updates

### Planned Features
- **Guild System:** Team up with other players for cooperative challenges
- **Robot Customization:** Visual and stat modifications for collected robots
- **Seasonal Events:** Limited-time zones and exclusive robot variants
- **Achievement System:** Comprehensive tracking of player accomplishments
- **Advanced PvP:** Player vs. player combat tournaments and rankings

### Community Requested Features
- **Robot Trading:** Direct player-to-player robot exchanges
- **Base Building:** Customizable headquarters for robot storage
- **Daily Challenges:** Rotating objectives with special rewards
- **Leaderboards:** Global and friend-based competition rankings

## 📞 Support & Community

### Getting Help
- Check this README for common solutions
- Review code comments for technical details
- Test systems individually to isolate issues
- Use Roblox Studio debugging tools for troubleshooting

### Contributing
- Follow existing code structure and naming conventions
- Test all changes thoroughly before implementation
- Document new features and system modifications
- Maintain backward compatibility when possible

## 📄 License

This project is created for educational and entertainment purposes. Feel free to modify and expand upon the codebase for your own Roblox development projects.

---

**Robot Collectors: Rise of Gearhold** - Where mechanical warfare meets strategic collection in an epic sci-fi adventure!
