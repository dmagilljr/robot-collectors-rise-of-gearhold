# Project Scope — Current Milestones

## Done (v0.4.0)
- Solid garage shell with collidable façade; doors slide behind the wall.
- Proximity door control (owner-only) via model attribute `DoorIsOpen`.
- PlotManager Studio fallback; one garage per shard in dev.
- Interior placeholders (hatch/repair/core/console/lockers) snapped to floor.

## Next
- PlotManager (live): strict `OwnerUserId`, DataStore-backed `{shardId, plotIndex}`.
- AutoDoorManager: STRICT owner-only; no friends/whitelist.
- Command Console: hook prompts → basic UI.
- Personal theming: apply palette/material overrides per player on mount.
- Hub/Activities: hub queue → Teleport to Arena/Resource Zones.
