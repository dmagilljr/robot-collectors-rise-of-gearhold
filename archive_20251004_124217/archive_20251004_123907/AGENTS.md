# Repository Guidelines

## Project Structure & Module Organization
Core gameplay scripts live under `src/` with `client/` for UI and player-facing logic, `server/` for entry scripts, `server_modules/` for Remote/Player/Robot systems (synced into `ServerScriptService/Modules`), and `shared/` for configuration such as `config/RobotTypes.luau`. Roblox place assets reside in `Robot-Collectors.rbxlx`, and reference material—setup, API, change history—is in `docs/`. Sounds and raw assets stay in `sounds/`. Aim for scalable module boundaries so future world zones, garage systems, and PvP arenas can slot in without rewrites.

## Build, Test, and Development Commands
Start Rojo from the project root with `rojo serve --port 34877` (Studio plugin connected) to sync scripts from `src/`. Generate an offline build with `rojo build --output Robot-Collectors.dev.rbxlx` before sharing large changes. Use `rojo sourcemap` when tracing a synced instance back to its source file. Keep the loop reproducible: hatch a bot, auto-mine, deposit, and return to idle each time you touch robot logic.

## Coding Style & Naming Conventions
Write Luau with four-space indentation and UTF-8 ASCII comments. Modules and classes use `PascalCase` (`RobotManager.luau`), while locals, remotes, and state tables are `camelCase` (e.g., `playerData`, `manualMineEvent`). Keep RemoteEvents under `ReplicatedStorage/Remotes`, configuration in `src/shared/config`, and build new gameplay on the modular `init.server.luau` stack. Structure code with future scale in mind (robot garage, personalization, combat), keeping APIs small and composable.

## Testing Guidelines
Automated tests are nascent; lean on Roblox Studio’s Play Solo / Team Test modes. After syncing via Rojo, run the loop end-to-end: hatch → auto assign → mine → deposit → return to idle. verify the garage (when present) for hatch/repair/customize flows. Use logging switches or TestEZ stubs in `ServerScriptService/Tests` for module-level checks; note gaps in docs so future contributors can script regression suites as the project matures.

## Commit & Pull Request Guidelines
The repository currently lacks commit history, so adopt short, present-tense commit subjects (≈60 characters). Mention affected modules, highlight testing performed (loop steps, garage checks), and attach screenshots or clips for UI changes. PRs should describe gameplay impact, tag related docs/assets, and call out any data or balance edits (`RobotTypes`, `GameConstants`). Favor small, reviewable increments that bring the polished loop and garage closer to production quality.

## Project Vision & Milestones
- **Vision**: Roblox-scale experience with polished loops, an extensible world, and customizable/fightable robots. Compete with titles like Pet Simulator by offering endless progression and social hooks.
- **Near-term goals**: deliver a stable core loop (mine → deposit → repeat) and a garage for hatching, repairing, and outfitting robots. Focus on UX polish, audio/VFX feedback, and clean assignments.
- **Mid-term goals**: expand the world with interactable zones, specialized robot roles, and light robot-vs-robot encounters. Maintain modular boundaries so new content bolts on cleanly.
- **Long-term goals**: persistent progression (datastores), monetization-friendly systems, large social hubs, and customizable robot build battles.
