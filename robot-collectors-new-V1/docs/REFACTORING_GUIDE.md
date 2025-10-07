## Componentized World (New)
- **WorldBoot.server.luau** mounts scene components exactly once.
- **Spawn.luau (ModuleScript)** guarantees baseplate & spawn before anything else.
- **Garage/Component.luau** builds shell/door relative to a canonical DoorPlane, using PartFactory.ensure; door is a sheet roll-up (lift→translate) with a clear collision policy.
