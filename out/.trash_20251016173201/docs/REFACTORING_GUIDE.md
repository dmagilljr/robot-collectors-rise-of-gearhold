# Refactoring Guide — Garage v0.4.0

## Model-Attribute Door Control
- **Single source**: `GD_Garage:SetAttribute("DoorIsOpen", true/false)`.
- `Component.luau` listens on `DoorIsOpen` and animates; panel attrs are mirrored for debug.
- `AutoDoorManager` only flips the **model** attribute; never calls `animate()` directly.

## Owner-Only Proximity
- Strict: doors open only for the player whose `OwnerUserId` matches.
- No whitelist/friends access in this version.
## Façade & Door Depth
- Front spandrels are **collidable**; doors sit **behind** the wall at a fixed baseline depth (no z-fighting).
- Roof/side/back front faces are placed **behind** the door plane (frontZ < planeZ).

## Duplicates & Boot Guards
- `WorldBoot` skips mounting if a garage already exists (PlotManager mounts in live shards).
- Keep **one** `PlotManager` script; never two.

