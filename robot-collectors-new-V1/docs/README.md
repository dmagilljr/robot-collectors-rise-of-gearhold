# Robot Collectors – Documentation Index

This folder contains the canonical project docs.

## Quick Links
- **CODEX_BASELINE.txt** – rules for all Codex edits
- **ASSET_PIPELINE.md** – asset workflow (models, textures, LOD, budgets)
- **STYLE.md** – visual style & materials (UI and world-look)
- **SETUP_GUIDE.md** – Rojo setup, Studio steps
- **REFACTORING_GUIDE.md** – how we moved to componentized world
- **PROJECT_SCOPE.md** – what we’re building next

---
## Current Code Layout (Rojo)
robot-collectors-new-V1/
default.project.json
src/
server/
init.server.luau            # defers WorldBoot.run()
modules/                    # BuildGuard / PartFactory / DoorPlane / utils
world/
WorldBoot.server.luau     # mounts components once
Spawn.luau                # Spawn.ensure()
Garage/
Component.luau          # clubhouse (door-plane anchored, sheet door)
client/
Main.client.luau
shared/                       # constants/types later
---
## Apply Order (Server)

1. `WorldBoot.run()`
2. `Spawn.ensure()` → baseplate & spawn
3. `Garage.Mount(spec)` → garage shell & door

---
## Debug Signals (Runtime Proofs)

Expect to see these lines in Studio Output on a clean boot:

- `[Spawn] ensured baseplate & spawn @ <timestamp>`
- `[Garage] frontZ check: back/left/right/roof < planeZ`
- `[Garage] Slats built: N slatH = DOOR_H / N`
- `[Garage] Hood created @Y=... Z=...`
- `[Garage] Doorway unblocked / restored` during open/close tests

These confirm geometry anchoring and collision policy are correct.

---
## Notes for Contributors

- One-file Codex prompts only, with a VERIFY block that prints the file.
- Rojo map: all runtime code must live under `robot-collectors-new-V1/src/...`.
- Avoid editing from Studio except for debug snippets.
- After a verified write: `git add -p && git commit -m "checkpoint"`.

## Glossary

| Term | Description |
|------|-------------|
| **WorldBoot**      | Master loader; runs once on server start. |
| **Spawn.ensure()** | Creates the spawn pad & baseplate safely. |
| **Garage.Mount()** | Instantiates the player clubhouse. |
| **DoorPlane**      | Canonical plane/axes for door geometry. |
| **PartFactory**    | Central utility for idempotent part creation. |
| **BuildGuard**     | Prevents double builds in a session. |

## Verification Checklist

- World spawns cleanly on boot
- Door-plane parts build once (no duplicates)
- You can walk inside after opening (no blockers)
- Geometry proofs match output
- Output ends with `[GarageDemo] ready (styled walls/door/floor + lighting)`

