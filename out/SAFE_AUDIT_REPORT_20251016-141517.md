# Safe Repo Audit Report
Generated: 2025-10-16T14:15:17

## Summary
- Files scanned: 689
- Whitelisted: 161
- Rojo-mapped: 50
- Unclassified: 478

## Rojo Roots (valid/missing)
- ReplicatedStorage/shared -> src/shared (exists)
- ServerScriptService/Modules -> src/server_modules (exists)
- ServerScriptService/World -> src/server/world (exists)
- ServerScriptService/services -> src/server/services (exists)
- StarterPlayer/StarterPlayerScripts -> src/client (exists)

## File Classification
- Whitelisted samples: .github/workflows/ci.yml, .gitignore, .selene/roblox.toml, AGENTS.local.md, AUDIT_REPORT.md ...
- Rojo-mapped samples: src/client/ClickProbe.client.luau, src/client/CommandUI.client.luau, src/client/DebugPaverWatch.client.luau, src/client/DumpScrap.client.luau, src/client/HatchFX.client.luau ...
- Unclassified samples: ROBOT_COLLECTORS.rbxlx, ROBOT_COLLECTORS.rbxlx.lock, default.project.json, old_backups/V1_conflicts/default.project.json, old_backups/V1_snapshot_20251016-171507/.github/workflows/ci.yml ...

## Duplicate Files
- sha1 da39a3ee5e6b4b0d3255bfef95601890afd80709 (36 files, 0 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/.keep
  - old_backups/V1_snapshot_20251016-171507/src/server/.keep
  - old_backups/V1_snapshot_20251016-171507/src/server_modules/.keep
  - old_backups/V1_snapshot_20251016-171507/src/shared/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/client/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/shared/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep 2
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/world/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server_modules/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/docs_audit.txt
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep 2
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep 2
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/client/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/shared/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep 2
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/world/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server_modules/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/docs_audit.txt
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep 2
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep 2
- sha1 0aa42448469988cbc538511487d3f2fb7b0f91ca (12 files, 1243 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec 2.luau
  - old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec 2.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec 2.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec.luau
  - old_backups/checkpoint_20251016-175936/src/server/tests/specs/DoorPlane_spec 2.luau
  - old_backups/checkpoint_20251016-175936/src/server/tests/specs/DoorPlane_spec.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec 2.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec.luau
  - src/server/tests/specs/DoorPlane_spec 2.luau
  - src/server/tests/specs/DoorPlane_spec.luau
- sha1 deb9f011f38dd9de99b157e85441390cc7f5983a (12 files, 974 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec 2.luau
  - old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec 2.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec 2.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec.luau
  - old_backups/checkpoint_20251016-175936/src/server/tests/specs/PathSampler_spec 2.luau
  - old_backups/checkpoint_20251016-175936/src/server/tests/specs/PathSampler_spec.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec 2.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec.luau
  - src/server/tests/specs/PathSampler_spec 2.luau
  - src/server/tests/specs/PathSampler_spec.luau
- sha1 99e4783d1ad4fd2730943d653cccc841a4d8721c (10 files, 72 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_server_banner.server.luau
  - old_backups/V1_snapshot_20251016-171507/src/server/zzz_server_banner.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_server_banner.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/zzz_server_banner.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/zzz_server_banner.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/zzz_server_banner.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/zzz_server_banner.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/zzz_server_banner.server.luau
  - src/server/world/zzz_server_banner.server.luau
  - src/server/zzz_server_banner.server.luau
- sha1 f9228788bbef39696666a77f7a29bd1d6f1f94d7 (10 files, 2713 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/spawn_guard.server.luau
  - old_backups/V1_snapshot_20251016-171507/src/server/world/spawn_guard.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/spawn_guard.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/spawn_guard.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/spawn_guard.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/spawn_guard.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/spawn_guard.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/spawn_guard.server.luau
  - src/server/spawn_guard.server.luau
  - src/server/world/spawn_guard.server.luau
- sha1 e37df97276db2585a59431039dbdacd1962c192a (9 files, 160 bytes)
  - .gitignore
  - old_backups/V1_conflicts/.gitignore
  - old_backups/V1_snapshot_20251016-171507/.gitignore
  - old_backups/V1_snapshot_20251016-175624/.gitignore
  - old_backups/checkpoint_20251016-175936/.gitignore
  - old_backups/checkpoint_20251016-175936/old_backups/V1_conflicts/.gitignore
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/.gitignore
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-175624/.gitignore
  - old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/.gitignore
- sha1 a001cfd8da0d0b2cf789dd3c91ad44729268c76a (8 files, 604 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_mount_diag.server.luau
  - old_backups/V1_snapshot_20251016-171507/src/server/zzz_mount_diag.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_mount_diag.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/zzz_mount_diag.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/zzz_mount_diag.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/zzz_mount_diag.server.luau
  - src/server/world/zzz_mount_diag.server.luau
  - src/server/zzz_mount_diag.server.luau
- sha1 c03d30121637fa190a2c9a31ea171bd65bd06820 (8 files, 615 bytes)
  - old_backups/V1_conflicts/default.project.json
  - old_backups/V1_snapshot_20251016-171507/default.project.json
  - old_backups/V1_snapshot_20251016-175624/default.project.json
  - old_backups/checkpoint_20251016-175936/default.project.json.bak
  - old_backups/checkpoint_20251016-175936/old_backups/V1_conflicts/default.project.json
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/default.project.json
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-175624/default.project.json
  - old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/default.project.json
- sha1 ee298e5411ce72e392b40947f630a1e49cddbbee (7 files, 1162 bytes)
  - old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/Robot-Collectors-v2.rbxlx
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/Robot-Collectors-v3.rbxlx
  - old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/Robot-Collectors-v2.rbxlx
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/Robot-Collectors-v3.rbxlx
- sha1 083240df21aa3944d59b5e207837254088e165be (6 files, 88 bytes)
  - .selene/roblox.toml
  - old_backups/V1_snapshot_20251016-171507/.selene/roblox.toml
  - old_backups/checkpoint_20251016-175936/.selene/roblox.toml
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/.selene/roblox.toml
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml
  - old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml
- sha1 22a07c922b287d543c2cf4f2d082d749b1929c96 (6 files, 1686 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/bootstrap.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/bootstrap.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/bootstrap.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/bootstrap.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/bootstrap.server.luau
  - src/server/bootstrap.server.luau
- sha1 3fdb4ddcab578b0ad34b263eada2c354595010d2 (6 files, 591 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/HatchFX.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/HatchFX.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/HatchFX.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/HatchFX.client.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/HatchFX.client.luau
  - src/client/HatchFX.client.luau
- sha1 58bdaeee9558649aa129098546955938180d1c6c (6 files, 706 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup 2.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup 2.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup.luau
  - old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau
- sha1 6cb92faa72cfc0fafc0d2fc6badddb2705b77946 (6 files, 339 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server_modules/BuildGuard.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/BuildGuard.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/BuildGuard.luau
  - old_backups/checkpoint_20251016-175936/src/server_modules/BuildGuard.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/BuildGuard.luau
  - src/server_modules/BuildGuard.luau
- sha1 c4bf77cb2a0ed61e2d02dc836e58aa7f3714e2ef (6 files, 1286 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/tests/TestRunner.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/TestRunner.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/TestRunner.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/tests/TestRunner.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/TestRunner.server.luau
  - src/server/tests/TestRunner.server.luau
- sha1 f702a05a350a3a6baa54992a6bb38e2b3e5af132 (6 files, 927 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Spawn.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Spawn.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Spawn.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Spawn.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Spawn.luau
  - src/server/world/Spawn.luau
- sha1 01563dfde449e280f4348556a72af2ebe3df651b (4 files, 843 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/shared/config/Unlocks.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/Unlocks.luau
  - old_backups/checkpoint_20251016-175936/src/shared/config/Unlocks.luau
  - src/shared/config/Unlocks.luau
- sha1 01678b9679b7a6093b3390a605650aff4ac03781 (4 files, 5803 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/MissionService.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/MissionService.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/MissionService.server.luau
  - src/server/MissionService.server.luau
- sha1 09ca488b85545e37936d160851cf40f3e6f5e0cd (4 files, 4218 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/modules/ResourceFX.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/modules/ResourceFX.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/modules/ResourceFX.client.luau
  - src/client/modules/ResourceFX.client.luau
- sha1 09dec1dea2785962109a7cecb9bd6e83a08cffee (4 files, 1140 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/shared/config/Quests.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/Quests.luau
  - old_backups/checkpoint_20251016-175936/src/shared/config/Quests.luau
  - src/shared/config/Quests.luau
- sha1 0d27162321081fd8d74f09eb3d28ac3f7bcadcef (4 files, 15998 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/WorldInteract.server.luau
  - src/server/world/WorldInteract.server.luau
- sha1 0f442e2de67b8c366da2fde796badc456d221385 (4 files, 5513 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/bootstrap.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/bootstrap.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/bootstrap.server.luau
  - src/server/world/bootstrap.server.luau
- sha1 1134b7647f0e22c4248e92442dd1b47da306bad4 (4 files, 954 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Animate.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Animate.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Garage/Animate.luau
  - src/server/world/Garage/Animate.luau
- sha1 13855dc11107df06a1d1cae66bbac078361d16ab (4 files, 3187 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server_modules/QuestService.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/QuestService.luau
  - old_backups/checkpoint_20251016-175936/src/server_modules/QuestService.luau
  - src/server_modules/QuestService.luau
- sha1 139ec2b8c04b013ce2b01f14991e989df0f84ec1 (4 files, 8394 bytes)
  - old_backups/V1_snapshot_20251016-171507/world.rbxm
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/world.rbxm
  - old_backups/checkpoint_20251016-175936/world.rbxm
  - world.rbxm
- sha1 1db1be852d5b4a2d136599ef30814081f4339585 (4 files, 853 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server_modules/DoorPlane.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/DoorPlane.luau
  - old_backups/checkpoint_20251016-175936/src/server_modules/DoorPlane.luau
  - src/server_modules/DoorPlane.luau
- sha1 1e43d947ded58f36ee3f565c6701f43bc69da798 (4 files, 178 bytes)
  - old_backups/V1_snapshot_20251016-171507/stylua.toml
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/stylua.toml
  - old_backups/checkpoint_20251016-175936/stylua.toml
  - stylua.toml
- sha1 1f483580820fde6960e19cf600660cc0f12c2762 (4 files, 20134 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Interior.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Interior.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Garage/Interior.luau
  - src/server/world/Garage/Interior.luau
- sha1 1fd8bdda6042c892636ff86d4c702fc26086893e (4 files, 7257 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/ResourceSpawner.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/ResourceSpawner.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/ResourceSpawner.server.luau
  - src/server/world/ResourceSpawner.server.luau
- sha1 2f8122b584b24ddf416b32c5bb7379bc44934cb6 (4 files, 418 bytes)
  - docs/ASSET_PIPELINE.md
  - old_backups/V1_snapshot_20251016-171507/docs/ASSET_PIPELINE.md
  - old_backups/checkpoint_20251016-175936/docs/ASSET_PIPELINE.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/ASSET_PIPELINE.md
- sha1 313c107d71ee48486b9928e83b7c0b17d1bf0a02 (4 files, 5343 bytes)
  - docs/README.md
  - old_backups/V1_snapshot_20251016-171507/docs/README.md
  - old_backups/checkpoint_20251016-175936/docs/README.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/README.md
- sha1 338869c86499a4b634b32f4c53106385cd2b4ada (4 files, 8013 bytes)
  - docs/ARCHITECTURE.md
  - old_backups/V1_snapshot_20251016-171507/docs/ARCHITECTURE.md
  - old_backups/checkpoint_20251016-175936/docs/ARCHITECTURE.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/ARCHITECTURE.md
- sha1 386020bcbe66ec400f2f8a1a2ae54590277f43f2 (4 files, 623 bytes)
  - docs/STYLE.md
  - old_backups/V1_snapshot_20251016-171507/docs/STYLE.md
  - old_backups/checkpoint_20251016-175936/docs/STYLE.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/STYLE.md
- sha1 3dd7afb7012d9c33c902b7726fd38614b5461ff2 (4 files, 9457 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/WorldBoot.luau
  - src/server/world/WorldBoot.luau
- sha1 3e4b8a7a023afde8861c24882c3409b09103b87b (4 files, 3814 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/CleanupResources.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/CleanupResources.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/CleanupResources.server.luau
  - src/server/world/CleanupResources.server.luau
- sha1 3e87f4efef3a2ccca911f0614bf62a9d50931813 (4 files, 4821 bytes)
  - docs/ECONOMY.md
  - old_backups/V1_snapshot_20251016-171507/docs/ECONOMY.md
  - old_backups/checkpoint_20251016-175936/docs/ECONOMY.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/ECONOMY.md
- sha1 41c37171a6a94984a9de9005286912d1f264c09c (4 files, 2382 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/ui/ResourceHUD.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/ui/ResourceHUD.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/ui/ResourceHUD.client.luau
  - src/client/ui/ResourceHUD.client.luau
- sha1 485a2a4b484a310e7f8bf46bdf4a3cc92b636c39 (4 files, 2235 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Remotes.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Remotes.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Remotes.server.luau
  - src/server/world/Remotes.server.luau
- sha1 49856e1a3f713dc879dc5308ad13dcf57264e5e2 (4 files, 244 bytes)
  - old_backups/V1_snapshot_20251016-171507/selene.toml
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/selene.toml
  - old_backups/checkpoint_20251016-175936/selene.toml
  - selene.toml
- sha1 4b96e2b50ea2bad5a9e4af36478ff5646a73346f (4 files, 1570 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/Remotes.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/Remotes.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/Remotes.server.luau
  - src/server/Remotes.server.luau
- sha1 4c760cfc957e06c089e5a49784d5603ed2259a6d (4 files, 1177 bytes)
  - docs/CLEANUP_ACTIONS.md
  - old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_ACTIONS.md
  - old_backups/checkpoint_20251016-175936/docs/CLEANUP_ACTIONS.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_ACTIONS.md
- sha1 4e6cc4c29f40949a47aadf87816d8cb3bd53818c (4 files, 5508 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/services/ResourceService.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/services/ResourceService.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/services/ResourceService.server.luau
  - src/server/services/ResourceService.server.luau
- sha1 559125923db96fb6fa56d3bbca7bbdc4c3203508 (4 files, 20892 bytes)
  - docs/CLEANUP_REPORT.md
  - old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_REPORT.md
  - old_backups/checkpoint_20251016-175936/docs/CLEANUP_REPORT.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_REPORT.md
- sha1 5a956514a4af61a150073b7c3f8cbfc1a7d7cb6d (4 files, 708 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/Main.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/Main.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/Main.client.luau
  - src/client/Main.client.luau
- sha1 5b59945e7977399b4c6a675385bb9a7814cadc5b (4 files, 3739 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/ZoneTrigger.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/ZoneTrigger.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/ZoneTrigger.server.luau
  - src/server/world/ZoneTrigger.server.luau
- sha1 5ee1dc8a57f6558699ca3387faf3bca9f1607eff (4 files, 2797 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/ZoneToast.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/ZoneToast.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/ZoneToast.client.luau
  - src/client/ZoneToast.client.luau
- sha1 63a909328d2e8cebd8e10661969300e24d112349 (4 files, 2928 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/PROJECT_SCOPE.md
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_SCOPE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/PROJECT_SCOPE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_SCOPE.md
- sha1 63de80727c12f6c6c97807d930aa54e0fe67e06c (4 files, 655 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/shared/config/GameConstants.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/GameConstants.luau
  - old_backups/checkpoint_20251016-175936/src/shared/config/GameConstants.luau
  - src/shared/config/GameConstants.luau
- sha1 66135e66d6b9da232f3c3ee593045448f4e57e07 (4 files, 5048 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/TerrainLoader.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/TerrainLoader.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/TerrainLoader.server.luau
  - src/server/world/TerrainLoader.server.luau
- sha1 66a71d5e01c0102a5f871485de33b1490d286861 (4 files, 934 bytes)
  - docs/AI_Workflow.md
  - old_backups/V1_snapshot_20251016-171507/docs/AI_Workflow.md
  - old_backups/checkpoint_20251016-175936/docs/AI_Workflow.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/AI_Workflow.md
- sha1 66b49faf5f8311a2295242728f483a6382140450 (4 files, 6084 bytes)
  - docs/RECOVERY.md
  - old_backups/V1_snapshot_20251016-171507/docs/RECOVERY.md
  - old_backups/checkpoint_20251016-175936/docs/RECOVERY.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/RECOVERY.md
- sha1 6b8a27da4b34f7e13832a177b2fa510854f8ad2d (4 files, 3138 bytes)
  - docs/CHANGELOG.md
  - old_backups/V1_snapshot_20251016-171507/docs/CHANGELOG.md
  - old_backups/checkpoint_20251016-175936/docs/CHANGELOG.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CHANGELOG.md
- sha1 6b90e50f4db528dd915bcbe9028070f88a24fc23 (4 files, 1124 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/modules/PartFactory.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/modules/PartFactory.luau
  - old_backups/checkpoint_20251016-175936/src/server/modules/PartFactory.luau
  - src/server/modules/PartFactory.luau
- sha1 6c15376a67a657c8e7776691d30df8772810e1a8 (4 files, 9179 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/services/MissionService.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/services/MissionService.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/services/MissionService.server.luau
  - src/server/services/MissionService.server.luau
- sha1 6d1f55d135995a4be87607454d6c14fc26a7e85a (4 files, 682 bytes)
  - docs/PROJECT_SCOPE.md
  - old_backups/V1_snapshot_20251016-171507/docs/PROJECT_SCOPE.md
  - old_backups/checkpoint_20251016-175936/docs/PROJECT_SCOPE.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/PROJECT_SCOPE.md
- sha1 70799f3d5326e669021d3d9cd31adcebed4a6264 (4 files, 680 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server 2.luau
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server 2.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server.luau
- sha1 7e26ffe0850c7391e9fc8599f40ea3c08cbf703f (4 files, 1340 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server_modules/ProgressionService.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/ProgressionService.luau
  - old_backups/checkpoint_20251016-175936/src/server_modules/ProgressionService.luau
  - src/server_modules/ProgressionService.luau
- sha1 82d971b85b257e2cce8213328571e2114841640b (4 files, 4693 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/shared/config/MissionDefs.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/MissionDefs.luau
  - old_backups/checkpoint_20251016-175936/src/shared/config/MissionDefs.luau
  - src/shared/config/MissionDefs.luau
- sha1 86652bf79074d924501fb33e1e7f5082b94736a3 (4 files, 15726 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau.bak_20251016-114925
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau.bak_20251016-114925
  - old_backups/checkpoint_20251016-175936/src/server/world/WorldInteract.server.luau.bak_20251016-114925
  - src/server/world/WorldInteract.server.luau.bak_20251016-114925
- sha1 9d8f251f44a6d8e527e0151da71ae761d6286da3 (4 files, 5017 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Fixup.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Fixup.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Garage/Fixup.luau
  - src/server/world/Garage/Fixup.luau
- sha1 9e8e26391ea07e6d73093719cc9cbaf7d63cb9ba (4 files, 2338 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CODEX_TASKS.md
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_TASKS.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CODEX_TASKS.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_TASKS.md
- sha1 a7eb39cd552d4321b28caef6c26f36ba71765f31 (4 files, 3741 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/STYLE.md
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/STYLE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/STYLE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/STYLE.md
- sha1 a83e2f13dc99ebc6de28400b153ccc9d4a38c375 (4 files, 80 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/AutoDoorManager.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/AutoDoorManager.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/AutoDoorManager.server.luau
  - src/server/world/AutoDoorManager.server.luau
- sha1 b7b7389d29fd0c8cdff92c8f4fa946ee13268397 (4 files, 522 bytes)
  - .github/workflows/ci.yml
  - old_backups/V1_snapshot_20251016-171507/.github/workflows/ci.yml
  - old_backups/checkpoint_20251016-175936/.github/workflows/ci.yml
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/.github/workflows/ci.yml
- sha1 baccd60cdade0a7b7e93868cfaf142de511a4635 (4 files, 830 bytes)
  - docs/SETUP_GUIDE.md
  - old_backups/V1_snapshot_20251016-171507/docs/SETUP_GUIDE.md
  - old_backups/checkpoint_20251016-175936/docs/SETUP_GUIDE.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/SETUP_GUIDE.md
- sha1 bfc314d82ed2643b4bd4bee6781f6bd1031c3e45 (4 files, 2312 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server_modules/PadAudit.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/PadAudit.luau
  - old_backups/checkpoint_20251016-175936/src/server_modules/PadAudit.luau
  - src/server_modules/PadAudit.luau
- sha1 c51b5415bd28b9b42852a0b6c1112aeb7e981f18 (4 files, 7 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/modules/.keep
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/modules/.keep
  - old_backups/checkpoint_20251016-175936/src/server/modules/.keep
  - src/server/modules/.keep
- sha1 c5a9804574ab32a526d49b30d09690b0d9e5be64 (4 files, 2573 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Debug.server.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Debug.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Garage/Debug.server.luau
  - src/server/world/Garage/Debug.server.luau
- sha1 c70da092b275c05c1c73dbdd2eed5d80310998b4 (4 files, 4401 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/ui/RightDock.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/ui/RightDock.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/ui/RightDock.client.luau
  - src/client/ui/RightDock.client.luau
- sha1 c780f54e641837ba6e22d5fd5e660bcfda9b55fc (4 files, 616 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/shared/config/CollectConfig.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/CollectConfig.luau
  - old_backups/checkpoint_20251016-175936/src/shared/config/CollectConfig.luau
  - src/shared/config/CollectConfig.luau
- sha1 c8ff7a6694565216549a6b65be5b4881d43f81d6 (4 files, 860 bytes)
  - docs/REFACTORING_GUIDE.md
  - old_backups/V1_snapshot_20251016-171507/docs/REFACTORING_GUIDE.md
  - old_backups/checkpoint_20251016-175936/docs/REFACTORING_GUIDE.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/REFACTORING_GUIDE.md
- sha1 c9631f643f256bf585d274d9374f10ad72d077ce (4 files, 9523 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau.bak_20251016-114919
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau.bak_20251016-114919
  - old_backups/checkpoint_20251016-175936/src/server/world/WorldBoot.luau.bak_20251016-114919
  - src/server/world/WorldBoot.luau.bak_20251016-114919
- sha1 ce030a085136eba79016482b5b3552343dc72b9c (4 files, 8668 bytes)
  - AUDIT_REPORT.md
  - old_backups/V1_snapshot_20251016-171507/AUDIT_REPORT.md
  - old_backups/checkpoint_20251016-175936/AUDIT_REPORT.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/AUDIT_REPORT.md
- sha1 cfbceb45f304c36c25afcd2e699256cdbeda87f2 (4 files, 5253 bytes)
  - docs/WORLD_BLUEPRINT.md
  - old_backups/V1_snapshot_20251016-171507/docs/WORLD_BLUEPRINT.md
  - old_backups/checkpoint_20251016-175936/docs/WORLD_BLUEPRINT.md
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/WORLD_BLUEPRINT.md
- sha1 d205cbd6783332a212c5ae92d73c77178c2d2f28 (4 files, 9 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1-darwin.tar.gz
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1.zip
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1-darwin.tar.gz
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1.zip
- sha1 d2aba44a04b8072c782c15283ddef7c0399dcfea (4 files, 9162 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Shows/Hatch.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Shows/Hatch.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Garage/Shows/Hatch.luau
  - src/server/world/Garage/Shows/Hatch.luau
- sha1 d5df9aa7a9e3e52506dbe7cd73a6806ca32cfed4 (4 files, 4077 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/ASSET_PIPELINE.md
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/ASSET_PIPELINE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/ASSET_PIPELINE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/ASSET_PIPELINE.md
- sha1 e6288df051a5d2916536c2b575a648b5582dd178 (4 files, 845 bytes)
  - docs/CODEX_BASELINE.txt
  - old_backups/V1_snapshot_20251016-171507/docs/CODEX_BASELINE.txt
  - old_backups/checkpoint_20251016-175936/docs/CODEX_BASELINE.txt
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CODEX_BASELINE.txt
- sha1 e8d61a5ec718a81e205111987e29b286203ae009 (4 files, 6826 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/modules/MissionsHUD.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/modules/MissionsHUD.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/modules/MissionsHUD.client.luau
  - src/client/modules/MissionsHUD.client.luau
- sha1 f24aef36c17e74da5091937532487aad91db2337 (4 files, 20813 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Component.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Component.luau
  - old_backups/checkpoint_20251016-175936/src/server/world/Garage/Component.luau
  - src/server/world/Garage/Component.luau
- sha1 f5ae46b34bf8105a826d435cab541a60ec4cf01e (4 files, 8011 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/client/CommandUI.client.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/CommandUI.client.luau
  - old_backups/checkpoint_20251016-175936/src/client/CommandUI.client.luau
  - src/client/CommandUI.client.luau
- sha1 f85635780bfc7efbabbf2f8c2d658507fcb96ed8 (4 files, 3961 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CODEX_BASELINE.txt
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_BASELINE.txt
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CODEX_BASELINE.txt
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_BASELINE.txt
- sha1 f8823c5162b45677b8344dd0a32cba6fcf37d79b (4 files, 1486 bytes)
  - old_backups/V1_snapshot_20251016-171507/src/shared/ResourceDefs.luau
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/ResourceDefs.luau
  - old_backups/checkpoint_20251016-175936/src/shared/ResourceDefs.luau
  - src/shared/ResourceDefs.luau
- sha1 fa605d9a0e0ba9db04e72ce994c52afe670d80be (4 files, 2593 bytes)
  - old_backups/V1_snapshot_20251016-171507/sourcemap.json
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/sourcemap.json
  - old_backups/checkpoint_20251016-175936/sourcemap.json
  - sourcemap.json
- sha1 ff793e351b33eaefabdb3c5bf34d2be5876ca2fe (4 files, 976 bytes)
  - old_backups/checkpoint_20251016-175936/src/ServerScriptService/RunOnce.server.luau
  - old_backups/checkpoint_20251016-175936/src/server/RunOnce.server.luau
  - src/ServerScriptService/RunOnce.server.luau
  - src/server/RunOnce.server.luau
- sha1 fef2a6bcc33ff334b9cf0803b20b9a815dbac375 (3 files, 111 bytes)
  - old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock
  - old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock
  - old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx.lock
- sha1 030f1b12b34f42396af1f26a5facdaad60724106 (2 files, 2086 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ReplicatedStorage/Shared/Types/ResourceTypes.lua
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ReplicatedStorage/Shared/Types/ResourceTypes.lua
- sha1 06c4348c5269111071e5a4d255436e5ab63378b2 (2 files, 156 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/README.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/README.md
- sha1 082277eca3147f16b1b573a446ad0e9c8f201b41 (2 files, 668 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Currencies.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Currencies.luau
- sha1 096f6d65af6227fe38c16160811b368d466631ce (2 files, 507 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/DumpScrap.server.luau
  - src/server/DumpScrap.server.luau
- sha1 0c754f2bd767d80fd76b31ef856955494bac65f3 (2 files, 5673 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/REFACTORING_GUIDE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/REFACTORING_GUIDE.md
- sha1 0e21bceec4281484ac4887d35d6f6143a74d130c (2 files, 2749 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/HideResourceOverlays.server.luau
  - src/server/HideResourceOverlays.server.luau
- sha1 0e2f82c70f52f382c86ad200cd107d865dacad68 (2 files, 80 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/Main.client.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/Main.client.luau
- sha1 125a1917ea8ed1349d7bfbfdbb34ed772a5e9e3d (2 files, 2166 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RemoteSetup.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RemoteSetup.luau
- sha1 129ffc94ed82e00fac9290c7304c90b1f5e4c85c (2 files, 1578 bytes)
  - old_backups/checkpoint_20251016-175936/src/shared/utils/ResourceGuards.luau
  - src/shared/utils/ResourceGuards.luau
- sha1 1380511f1be50900128d35508f2aabb603838535 (2 files, 929 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/GameConstants.spec.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/GameConstants.spec.luau
- sha1 142a000513806130f6ada7edd704cab3b31cadab (2 files, 4577 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/world/GarageReset.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/world/GarageReset.server.luau
- sha1 14b0eddbd63a338fe54512cfa15ad0d6ce6d4e09 (2 files, 868 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EntitlementService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EntitlementService.luau
- sha1 14e693b1b1f710093d6f802367b1098856003961 (2 files, 1066 bytes)
  - LICENSE
  - old_backups/checkpoint_20251016-175936/LICENSE
- sha1 174d529576b13207567d4b17972bb5a6aaa42cda (2 files, 603 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/DoorPlane.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/DoorPlane.luau
- sha1 196880f822f965ca3825754139422440ebc68d79 (2 files, 4185 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/HatchUI.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/HatchUI.luau
- sha1 1baa0afc5fbc301760600df9a96e6e00935d3a82 (2 files, 86 bytes)
  - old_backups/checkpoint_20251016-175936/package.json
  - package.json
- sha1 1e0467524ddb06a07af105c56454e1c238d14f44 (2 files, 14054 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init.server.luau
- sha1 21e8cba9bbb6b175bf86d2c9221b4e74737ce2c8 (2 files, 1061 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/WorldService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/WorldService.luau
- sha1 22f765e6afa1a7d654cc4d5bc3c2763d604f3df0 (2 files, 7835 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/ART_BRIEF.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/ART_BRIEF.md
- sha1 23aabf2b123dac6b6bfb4173791c87d9fa90ec3f (2 files, 7620 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GuiManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GuiManager.luau
- sha1 25d0d85039c1b25156815b4c0269a8dace51f35c (2 files, 599 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/Remotes.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/Remotes.server.luau
- sha1 2ebf1500c20316db5dcc47bc71e69e2e66fb4372 (2 files, 1802 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/WorldBoot.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/WorldBoot.luau
- sha1 2f7495dac31d46afa7e682a02198ede5d115bbe3 (2 files, 84147 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.json
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.json
- sha1 312184971b42b55c0dec7e4f835ec2eb69172252 (2 files, 43103 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init-legacy.server.luau.disabled
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init-legacy.server.luau.disabled
- sha1 359f80f89fbdb74c1a4b9dce8ad506302465ab05 (2 files, 5495 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/Taskbar.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/Taskbar.luau
- sha1 36c440994da9caa4f55ab751725d9475458ff718 (2 files, 649 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestRunner.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestRunner.luau
- sha1 37620f3d43e8891e41fe549ee7ab3b0e07cffd6f (2 files, 4866 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CLAUDE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CLAUDE.md
- sha1 3b46e21c8ffe9fa3fa71d1e740c10f0388d76aae (2 files, 721 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/RECOVERY_REPORT.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/RECOVERY_REPORT.md
- sha1 3e654aba36dee65361c35e203c8d0dece6dbdc14 (2 files, 2831 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/PlayerService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/PlayerService.luau
- sha1 40cbf458f4ca926d0b0f04b373e494532a49a3b5 (2 files, 988 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/RobotTypes.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/RobotTypes.luau
- sha1 40d03750a2e8dd013c0d45a0161bf09d4e91772b (2 files, 3947 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/util/LODService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/util/LODService.luau
- sha1 40ed99e6d473180092eac0a1c157462a7d326330 (2 files, 17855 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RobotUIManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RobotUIManager.luau
- sha1 4580326006ac738a0d308360c5fc47dbc7b58284 (2 files, 9429 bytes)
  - old_backups/checkpoint_20251016-175936/tools/cleanup_actions.py
  - tools/cleanup_actions.py
- sha1 45a996686e7e8bce97e9a5cab7f7c3aef51c3e9a (2 files, 2574 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/EconomyHandlers.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/EconomyHandlers.server.luau
- sha1 468e4bc570d4e5e1563bffa58d0792e3ff8f106f (2 files, 507 bytes)
  - old_backups/checkpoint_20251016-175936/src/client/DumpScrap.client.luau
  - src/client/DumpScrap.client.luau
- sha1 49e0b7bb5ae016ee79853459bf1fd38b221d42cc (2 files, 530 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/default.project.json
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/default.project.json
- sha1 4e2c0560cec75369ff77e555d82e5e6a308da2e6 (2 files, 753 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/default.project.json
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/default.project.json
- sha1 4fcbeb63bc36513ce57e10eb8242a42ab62e4499 (2 files, 8739 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GarageUI.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GarageUI.luau
- sha1 50bed82ef23f687e904f427352cf8f1e651854f2 (2 files, 440298 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/223549__captainvince__industrial-garage-door-storage-gate-open.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/223549__captainvince__industrial-garage-door-storage-gate-open.wav
- sha1 515d1ae64a2ca203149888de0a6d26456daf03f8 (2 files, 41878 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_ion_shard.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_ion_shard.wav
- sha1 51d7f15ec3cea9e30437d8cc4e2b2f499cc01db8 (2 files, 48518 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_rare_metal.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_rare_metal.wav
- sha1 5bab4d0f3329831929c8bd69ee19b9606a6422ec (2 files, 6398 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/AssignUI.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/AssignUI.luau
- sha1 5c08ecce73fb2cfd33d7ad05042e0e4340426923 (2 files, 4613 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/README.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/README.md
- sha1 5cbdbe06bb05b2c2cf6de7f1484347716d2d46ef (2 files, 2933 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RobotManager.spec.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RobotManager.spec.luau
- sha1 5e44797539c35039a6439f251186f1caf2b77004 (2 files, 754 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/PartFactory.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/PartFactory.luau
- sha1 61400e5c16685d3d079e4e6aacd9e9dfffea009d (2 files, 3292 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Garage/Component.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Garage/Component.luau
- sha1 6448a4a2acd96d5f4f10de0f774cb10a354dcb88 (2 files, 206 bytes)
  - README.md
  - old_backups/checkpoint_20251016-175936/README.md
- sha1 6607451aa2059d618572968a23e4dfeeefb6fcb5 (2 files, 644 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Boosters.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Boosters.luau
- sha1 6644801720d85fb8ec5d0fe72c36d1f6a5f3d2da (2 files, 60358 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/GarageService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/GarageService.luau
- sha1 67641767cd7c2cf9d3dda0bbfec05c56a310b845 (2 files, 753 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/default.project.json
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/default.project.json
- sha1 6b5a9f18b20082a0173932443f016be7cf3c5cb4 (2 files, 1999 bytes)
  - old_backups/checkpoint_20251016-175936/src/client/HideResourceOverlays.client.luau
  - src/client/HideResourceOverlays.client.luau
- sha1 6d78dbc65fb3e28619857cc1c34dc3e76955b470 (2 files, 34 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/init.server.luau
  - src/server/init.server.luau
- sha1 724392b890c5593f407ed90d23eeb9c94af77b46 (2 files, 2650 bytes)
  - old_backups/checkpoint_20251016-175936/scripts/_util_rojo.py
  - scripts/_util_rojo.py
- sha1 72f1778a1618f73b728f77e2598a50420bb6bd3e (2 files, 1769 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/RogueGroundKiller.server.luau
  - src/server/RogueGroundKiller.server.luau
- sha1 74250256314dc714e5ef46e8df7196d086315b9d (2 files, 1597 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/00_spawns_and_remotes.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/00_spawns_and_remotes.server.luau
- sha1 763dbd503f861658ad4e96c1eedffa7a6d589baa (2 files, 750 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/WatchNewParts.server.luau
  - src/server/WatchNewParts.server.luau
- sha1 77e070c866bea53fa03cfb3a15e8fe207cb2e598 (2 files, 606 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RemoteManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RemoteManager.luau
- sha1 7c4ee2a36ff80d8e489268909f87478d58479c78 (2 files, 55970 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/workspace-setup.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/workspace-setup.server.luau
- sha1 816f5db05c4258eacbc95543535846f1434d61e3 (2 files, 2433 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/ScrapTerminator.server.luau
  - src/server/ScrapTerminator.server.luau
- sha1 862631155e1fde8a4aacf134581595224be36420 (2 files, 827 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/_bootstrap.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/_bootstrap.luau
- sha1 86ae9c8519ae1e45a2509c47167585cdba942cec (2 files, 26068 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageDoctor.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageDoctor.luau
- sha1 8a430b24fd1197c047a3bb2e884a3a18ffc95802 (2 files, 221 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/types/README.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/types/README.md
- sha1 8aa2e40e4fd672b6f0c809a2dc29342c64348c45 (2 files, 76 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau
  - old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau
- sha1 8dd5514f103d903c0dd6723f4a547b566e818848 (2 files, 1845 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ResourceManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ResourceManager.luau
- sha1 8fd6f0df2cb410650bfadb2d0bd1c01d268bcd35 (2 files, 1930 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/.gitignore
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/.gitignore
- sha1 90b0ab5dfa0c00c98b1baf6f1afffb95aa14ab7a (2 files, 3908 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ModalManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ModalManager.luau
- sha1 930077c779753e7dcf3cb25ac371b8b9064a27b3 (2 files, 10408 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageReset.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageReset.server.luau
- sha1 94704eee9e556b691459fa49cc640da1fdf04db3 (2 files, 1121 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RemoteSetup.spec.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RemoteSetup.spec.luau
- sha1 971113d6913babc66eac8fc9471245d1b2eef004 (2 files, 176 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/utils/README.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/utils/README.md
- sha1 9a2c14cf344f7aa0c1ac4bc12a44cb9dca3253eb (2 files, 71 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/.gitignore
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/.gitignore
- sha1 9a78e3a042337f4a832fb982436871478029fc8a (2 files, 1408556 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/ambient_hum.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/ambient_hum.wav
- sha1 9d077c3c2e99d092869232fab36feb1f10fd58ba (2 files, 1715 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/RobotService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/RobotService.luau
- sha1 9d80129fe7deba5421b7e5346dbcf8aefd829f68 (2 files, 15309 bytes)
  - old_backups/checkpoint_20251016-175936/scripts/full_manifest.py
  - scripts/full_manifest.py
- sha1 a02576dd7384fce6cddfb057c1d675144adeb470 (2 files, 1037 bytes)
  - AGENTS.local.md
  - old_backups/checkpoint_20251016-175936/AGENTS.local.md
- sha1 a2ed99661dc07916538ae26ed7af8030735d3513 (2 files, 6619 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/SETUP_GUIDE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/SETUP_GUIDE.md
- sha1 a330182ad5ac02fbc9e7f40e1c8a2338ef2195e6 (2 files, 3391 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/AGENTS.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/AGENTS.md
- sha1 a8eee0fd73c32ff24ab8e46e363e5b0d0f14780e (2 files, 19326 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.md
- sha1 a99de0789406f761bda4937c0ae28689e39756cd (2 files, 2687 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/CommandUI.client.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/CommandUI.client.luau
- sha1 ad0b179f2245feb4dc25b28a35c2024ae6456e73 (2 files, 2516 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/UIFactory.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/UIFactory.luau
- sha1 ae03e6214aec8c0caa019d48316c63b330dacac1 (2 files, 1297 bytes)
  - old_backups/checkpoint_20251016-175936/src/server/ScrapHotfix.server.luau
  - src/server/ScrapHotfix.server.luau
- sha1 af699ad512e2ca287a7b4256dccd85b7f2e748b4 (2 files, 8948 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/PlayerManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/PlayerManager.luau
- sha1 b1f14e63600201ad69ada59bac660b35f88b3b11 (2 files, 212 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/README.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/README.md
- sha1 b27eb65b7009e067585479e7a37839ef4813f76e (2 files, 272082 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/29538__mikehirst__garage-door-opening.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/29538__mikehirst__garage-door-opening.wav
- sha1 b30e8bb39ff109c33cf327ca829009f0e08ee3e3 (2 files, 653 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/SaveService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/SaveService.luau
- sha1 b5344e38facce7ea4e44b10b418a7284a4a8e17e (2 files, 1076 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/_readme_and_license.txt
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/_readme_and_license.txt
- sha1 b73cdccbf84de0ee607aa3eff2533c13f7fa27c7 (2 files, 8438 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CHANGELOG.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CHANGELOG.md
- sha1 b7b5fcf8c067ad3e42870bab85cd49f2a8e35692 (2 files, 4946 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/GameConstants.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/GameConstants.luau
- sha1 bcedd0fa0d4c541c5c462a329dbdb0503be510e2 (2 files, 669 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server_modules/RemoteSetup.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server_modules/RemoteSetup.luau
- sha1 bd5ae41d016b82477857d0be3c364f0e1d58814c (2 files, 426 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/RobotSkins.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/RobotSkins.luau
- sha1 c12ac59444ee6625881cccc99782d98bc0080cb4 (2 files, 1332 bytes)
  - old_backups/checkpoint_20251016-175936/src/client/ClickProbe.client.luau
  - src/client/ClickProbe.client.luau
- sha1 c3f6839c9fe318a2909f2014b5567ce72c5db7f3 (2 files, 11567 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/DEVELOPMENT_LOG.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/DEVELOPMENT_LOG.md
- sha1 c9fc443f3b4872b5c44de8d79e06faca866430e4 (2 files, 6146 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init.client.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init.client.luau
- sha1 cca89c7e5ddb8ea8cab5664ae42892410acaf824 (2 files, 1439 bytes)
  - old_backups/checkpoint_20251016-175936/src/client/NukeNearDoor.client.luau
  - src/client/NukeNearDoor.client.luau
- sha1 cefb6f362ef71b260dc3a7b317fc99b96c22be11 (2 files, 16902 bytes)
  - old_backups/checkpoint_20251016-175936/tools/cleanup_project.py
  - tools/cleanup_project.py
- sha1 d03c5e241066e183786c705f0622dbbf20ba8c05 (2 files, 318 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_src/server/modules/BuildGuard.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_src/server/modules/BuildGuard.luau
- sha1 d15470c27e748b5e02cafd5bae9cdf4201a3901c (2 files, 861 bytes)
  - PROJECT_TREE.txt
  - old_backups/checkpoint_20251016-175936/PROJECT_TREE.txt
- sha1 d244b4ef857cf782b200b5aa917d5508c35e0232 (2 files, 19203 bytes)
  - old_backups/checkpoint_20251016-175936/tools/scan_project.py
  - tools/scan_project.py
- sha1 d58570d7b0513d06d625b8c2367f7b0af46ccf48 (2 files, 12645 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/README.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/README.md
- sha1 d6ccec6c831e469079e11c2d994f131db6b2b4fe (2 files, 4685 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ServerStorage/Server/Systems/Resources/ResourceSystem.lua
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ServerStorage/Server/Systems/Resources/ResourceSystem.lua
- sha1 d8dcb65a93a4d7320cc143f33977093a5f435eb1 (2 files, 678 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server_modules/RC_RemoteSetup.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server_modules/RC_RemoteSetup.luau
- sha1 d9288800fe68ad71e78b5ed4c3bdb322d2f4382f (2 files, 1890 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestEZ.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestEZ.luau
- sha1 d9723f386de8ec2eb03d206980e88547c85d57bd (2 files, 949 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/GarageDoorBootstrap.server.luau.disabled
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/GarageDoorBootstrap.server.luau.disabled
- sha1 db0d7f4539dc1a81570a4507dbd796b3ed38c891 (2 files, 38652 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_gearbit.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_gearbit.wav
- sha1 dec1293e331cf7211fb03ec11da20416e5987679 (2 files, 2540 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init-refactored.client.luau.disabled
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init-refactored.client.luau.disabled
- sha1 e270ed0c1d8f933fe506e7bac46029f106b9f648 (2 files, 785 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ShopClient.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ShopClient.luau
- sha1 e2b5bd16027088b9613395fd926547d680e0244d (2 files, 2391 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EconomyService.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EconomyService.luau
- sha1 e4a2b3eda35f8ee39cd466dc47c126c7dfe2c32a (2 files, 357 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/Theme.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/Theme.luau
- sha1 e8225a71ab45c7350470c06743a7c82b027a7d43 (2 files, 3598 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/UIStyle.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/UIStyle.luau
- sha1 e8409b85da742706a64c774d65ac6578d19a48e2 (2 files, 703 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/init.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/init.server.luau
- sha1 ea184d346cbcc594d931f3301726abbee8fa65b7 (2 files, 51642 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_crystal.wav
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_crystal.wav
- sha1 eb44587f5802e5fb09dac05a86517bd9cd6ea7c4 (2 files, 5633 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/world/RC_GarageReset.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/world/RC_GarageReset.server.luau
- sha1 f55b130672334e74b1763af4d077b8e0b9246b74 (2 files, 627 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/Remotes.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/Remotes.luau
- sha1 f649824d0e90821d23e77b950bfe031e8861666b (2 files, 1478 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/Robot-Collectors.rbxlx
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/Robot-Collectors.rbxlx
- sha1 f65bb9deefca9c97ae488bbe2b91738e4d303098 (2 files, 34 bytes)
  - old_backups/checkpoint_20251016-175936/src/client/init.client.luau
  - src/client/init.client.luau
- sha1 f720ecf63ba06d31a9b83924d60dd89ff42e5129 (2 files, 1587 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/LightingProfile.server.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/LightingProfile.server.luau
- sha1 f835881f15de6f120e487529e6238fbc44551b37 (2 files, 3387 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/InputManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/InputManager.luau
- sha1 f97fbb29c7d8e2303945368f8031e3be8b131cd6 (2 files, 43323 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RobotManager.luau
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RobotManager.luau
- sha1 f9a9fe729d8618fd7dffadfef9c4bf6fa1e8a8ee (2 files, 1925 bytes)
  - old_backups/checkpoint_20251016-175936/src/client/DebugPaverWatch.client.luau
  - src/client/DebugPaverWatch.client.luau
- sha1 fdc469f4a49057196275141c16be1bd5c4c167e4 (2 files, 45 bytes)
  - old_backups/checkpoint_20251016-175936/src/shared/Hello.luau
  - src/shared/Hello.luau
- sha1 fdc5adbb9f669374530611f95552e48258c36a79 (2 files, 6000 bytes)
  - old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/API_REFERENCE.md
  - old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/API_REFERENCE.md

## Legacy Buckets (matches)
- old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx
- old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock
- old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx
- old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock
- old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml
- old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau
- old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau
- old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx
- old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx.lock
- old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/.gitignore
- old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/default.project.json
- old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml
- old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau
- old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau

## Proposed Actions (commented commands)
# echo "Review duplicate group da39a3ee5e6b4b0d3255bfef95601890afd80709: old_backups/V1_snapshot_20251016-171507/src/client/.keep, old_backups/V1_snapshot_20251016-171507/src/server/.keep, old_backups/V1_snapshot_20251016-171507/src/server_modules/.keep, old_backups/V1_snapshot_20251016-171507/src/shared/.keep, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/.keep, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/.keep, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/.keep, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/client/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/shared/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep 2, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/world/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server_modules/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/docs_audit.txt, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep 2, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep 2, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/client/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/shared/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/client/.keep 2, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server/world/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/src/server_modules/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/docs_audit.txt, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/.keep 2, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/shared/.keep 2"
# echo "Review duplicate group 0aa42448469988cbc538511487d3f2fb7b0f91ca: old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec 2.luau, old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec 2.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/DoorPlane_spec.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec 2.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec.luau, old_backups/checkpoint_20251016-175936/src/server/tests/specs/DoorPlane_spec 2.luau, old_backups/checkpoint_20251016-175936/src/server/tests/specs/DoorPlane_spec.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec 2.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/DoorPlane_spec.luau, src/server/tests/specs/DoorPlane_spec 2.luau, src/server/tests/specs/DoorPlane_spec.luau"
# echo "Review duplicate group deb9f011f38dd9de99b157e85441390cc7f5983a: old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec 2.luau, old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec 2.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/specs/PathSampler_spec.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec 2.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec.luau, old_backups/checkpoint_20251016-175936/src/server/tests/specs/PathSampler_spec 2.luau, old_backups/checkpoint_20251016-175936/src/server/tests/specs/PathSampler_spec.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec 2.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/specs/PathSampler_spec.luau, src/server/tests/specs/PathSampler_spec 2.luau, src/server/tests/specs/PathSampler_spec.luau"
# echo "Review duplicate group 99e4783d1ad4fd2730943d653cccc841a4d8721c: old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_server_banner.server.luau, old_backups/V1_snapshot_20251016-171507/src/server/zzz_server_banner.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_server_banner.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/zzz_server_banner.server.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/zzz_server_banner.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/zzz_server_banner.server.luau, old_backups/checkpoint_20251016-175936/src/server/zzz_server_banner.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/zzz_server_banner.server.luau, src/server/world/zzz_server_banner.server.luau, src/server/zzz_server_banner.server.luau"
# echo "Review duplicate group f9228788bbef39696666a77f7a29bd1d6f1f94d7: old_backups/V1_snapshot_20251016-171507/src/server/spawn_guard.server.luau, old_backups/V1_snapshot_20251016-171507/src/server/world/spawn_guard.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/spawn_guard.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/spawn_guard.server.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/spawn_guard.server.luau, old_backups/checkpoint_20251016-175936/src/server/spawn_guard.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/spawn_guard.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/spawn_guard.server.luau, src/server/spawn_guard.server.luau, src/server/world/spawn_guard.server.luau"
# echo "Review duplicate group e37df97276db2585a59431039dbdacd1962c192a: .gitignore, old_backups/V1_conflicts/.gitignore, old_backups/V1_snapshot_20251016-171507/.gitignore, old_backups/V1_snapshot_20251016-175624/.gitignore, old_backups/checkpoint_20251016-175936/.gitignore, old_backups/checkpoint_20251016-175936/old_backups/V1_conflicts/.gitignore, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/.gitignore, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-175624/.gitignore, old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/.gitignore"
# echo "Review duplicate group a001cfd8da0d0b2cf789dd3c91ad44729268c76a: old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_mount_diag.server.luau, old_backups/V1_snapshot_20251016-171507/src/server/zzz_mount_diag.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/zzz_mount_diag.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/zzz_mount_diag.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/zzz_mount_diag.server.luau, old_backups/checkpoint_20251016-175936/src/server/zzz_mount_diag.server.luau, src/server/world/zzz_mount_diag.server.luau, src/server/zzz_mount_diag.server.luau"
# echo "Review duplicate group c03d30121637fa190a2c9a31ea171bd65bd06820: old_backups/V1_conflicts/default.project.json, old_backups/V1_snapshot_20251016-171507/default.project.json, old_backups/V1_snapshot_20251016-175624/default.project.json, old_backups/checkpoint_20251016-175936/default.project.json.bak, old_backups/checkpoint_20251016-175936/old_backups/V1_conflicts/default.project.json, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/default.project.json, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-175624/default.project.json, old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/default.project.json"
# echo "Review duplicate group ee298e5411ce72e392b40947f630a1e49cddbbee: old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/Robot-Collectors-v2.rbxlx, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/Robot-Collectors-v3.rbxlx, old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/Robot-Collectors-v2.rbxlx, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/Robot-Collectors-v3.rbxlx"
# echo "Review duplicate group 083240df21aa3944d59b5e207837254088e165be: .selene/roblox.toml, old_backups/V1_snapshot_20251016-171507/.selene/roblox.toml, old_backups/checkpoint_20251016-175936/.selene/roblox.toml, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/.selene/roblox.toml, old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml, old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml"
# echo "Review duplicate group 22a07c922b287d543c2cf4f2d082d749b1929c96: old_backups/V1_snapshot_20251016-171507/src/server/bootstrap.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/bootstrap.server.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/bootstrap.server.luau, old_backups/checkpoint_20251016-175936/src/server/bootstrap.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/bootstrap.server.luau, src/server/bootstrap.server.luau"
# echo "Review duplicate group 3fdb4ddcab578b0ad34b263eada2c354595010d2: old_backups/V1_snapshot_20251016-171507/src/client/HatchFX.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/HatchFX.client.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/HatchFX.client.luau, old_backups/checkpoint_20251016-175936/src/client/HatchFX.client.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/HatchFX.client.luau, src/client/HatchFX.client.luau"
# echo "Review duplicate group 58bdaeee9558649aa129098546955938180d1c6c: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup 2.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup 2.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server_modules/RemoteSetup.luau, old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau"
# echo "Review duplicate group 6cb92faa72cfc0fafc0d2fc6badddb2705b77946: old_backups/V1_snapshot_20251016-171507/src/server_modules/BuildGuard.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/BuildGuard.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/BuildGuard.luau, old_backups/checkpoint_20251016-175936/src/server_modules/BuildGuard.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/BuildGuard.luau, src/server_modules/BuildGuard.luau"
# echo "Review duplicate group c4bf77cb2a0ed61e2d02dc836e58aa7f3714e2ef: old_backups/V1_snapshot_20251016-171507/src/server/tests/TestRunner.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/tests/TestRunner.server.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/TestRunner.server.luau, old_backups/checkpoint_20251016-175936/src/server/tests/TestRunner.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/tests/TestRunner.server.luau, src/server/tests/TestRunner.server.luau"
# echo "Review duplicate group f702a05a350a3a6baa54992a6bb38e2b3e5af132: old_backups/V1_snapshot_20251016-171507/src/server/world/Spawn.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Spawn.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Spawn.luau, old_backups/checkpoint_20251016-175936/src/server/world/Spawn.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Spawn.luau, src/server/world/Spawn.luau"
# echo "Review duplicate group 01563dfde449e280f4348556a72af2ebe3df651b: old_backups/V1_snapshot_20251016-171507/src/shared/config/Unlocks.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/Unlocks.luau, old_backups/checkpoint_20251016-175936/src/shared/config/Unlocks.luau, src/shared/config/Unlocks.luau"
# echo "Review duplicate group 01678b9679b7a6093b3390a605650aff4ac03781: old_backups/V1_snapshot_20251016-171507/src/server/MissionService.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/MissionService.server.luau, old_backups/checkpoint_20251016-175936/src/server/MissionService.server.luau, src/server/MissionService.server.luau"
# echo "Review duplicate group 09ca488b85545e37936d160851cf40f3e6f5e0cd: old_backups/V1_snapshot_20251016-171507/src/client/modules/ResourceFX.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/modules/ResourceFX.client.luau, old_backups/checkpoint_20251016-175936/src/client/modules/ResourceFX.client.luau, src/client/modules/ResourceFX.client.luau"
# echo "Review duplicate group 09dec1dea2785962109a7cecb9bd6e83a08cffee: old_backups/V1_snapshot_20251016-171507/src/shared/config/Quests.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/Quests.luau, old_backups/checkpoint_20251016-175936/src/shared/config/Quests.luau, src/shared/config/Quests.luau"
# echo "Review duplicate group 0d27162321081fd8d74f09eb3d28ac3f7bcadcef: old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/WorldInteract.server.luau, src/server/world/WorldInteract.server.luau"
# echo "Review duplicate group 0f442e2de67b8c366da2fde796badc456d221385: old_backups/V1_snapshot_20251016-171507/src/server/world/bootstrap.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/bootstrap.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/bootstrap.server.luau, src/server/world/bootstrap.server.luau"
# echo "Review duplicate group 1134b7647f0e22c4248e92442dd1b47da306bad4: old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Animate.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Animate.luau, old_backups/checkpoint_20251016-175936/src/server/world/Garage/Animate.luau, src/server/world/Garage/Animate.luau"
# echo "Review duplicate group 13855dc11107df06a1d1cae66bbac078361d16ab: old_backups/V1_snapshot_20251016-171507/src/server_modules/QuestService.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/QuestService.luau, old_backups/checkpoint_20251016-175936/src/server_modules/QuestService.luau, src/server_modules/QuestService.luau"
# echo "Review duplicate group 139ec2b8c04b013ce2b01f14991e989df0f84ec1: old_backups/V1_snapshot_20251016-171507/world.rbxm, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/world.rbxm, old_backups/checkpoint_20251016-175936/world.rbxm, world.rbxm"
# echo "Review duplicate group 1db1be852d5b4a2d136599ef30814081f4339585: old_backups/V1_snapshot_20251016-171507/src/server_modules/DoorPlane.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/DoorPlane.luau, old_backups/checkpoint_20251016-175936/src/server_modules/DoorPlane.luau, src/server_modules/DoorPlane.luau"
# echo "Review duplicate group 1e43d947ded58f36ee3f565c6701f43bc69da798: old_backups/V1_snapshot_20251016-171507/stylua.toml, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/stylua.toml, old_backups/checkpoint_20251016-175936/stylua.toml, stylua.toml"
# echo "Review duplicate group 1f483580820fde6960e19cf600660cc0f12c2762: old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Interior.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Interior.luau, old_backups/checkpoint_20251016-175936/src/server/world/Garage/Interior.luau, src/server/world/Garage/Interior.luau"
# echo "Review duplicate group 1fd8bdda6042c892636ff86d4c702fc26086893e: old_backups/V1_snapshot_20251016-171507/src/server/world/ResourceSpawner.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/ResourceSpawner.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/ResourceSpawner.server.luau, src/server/world/ResourceSpawner.server.luau"
# echo "Review duplicate group 2f8122b584b24ddf416b32c5bb7379bc44934cb6: docs/ASSET_PIPELINE.md, old_backups/V1_snapshot_20251016-171507/docs/ASSET_PIPELINE.md, old_backups/checkpoint_20251016-175936/docs/ASSET_PIPELINE.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/ASSET_PIPELINE.md"
# echo "Review duplicate group 313c107d71ee48486b9928e83b7c0b17d1bf0a02: docs/README.md, old_backups/V1_snapshot_20251016-171507/docs/README.md, old_backups/checkpoint_20251016-175936/docs/README.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/README.md"
# echo "Review duplicate group 338869c86499a4b634b32f4c53106385cd2b4ada: docs/ARCHITECTURE.md, old_backups/V1_snapshot_20251016-171507/docs/ARCHITECTURE.md, old_backups/checkpoint_20251016-175936/docs/ARCHITECTURE.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/ARCHITECTURE.md"
# echo "Review duplicate group 386020bcbe66ec400f2f8a1a2ae54590277f43f2: docs/STYLE.md, old_backups/V1_snapshot_20251016-171507/docs/STYLE.md, old_backups/checkpoint_20251016-175936/docs/STYLE.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/STYLE.md"
# echo "Review duplicate group 3dd7afb7012d9c33c902b7726fd38614b5461ff2: old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau, old_backups/checkpoint_20251016-175936/src/server/world/WorldBoot.luau, src/server/world/WorldBoot.luau"
# echo "Review duplicate group 3e4b8a7a023afde8861c24882c3409b09103b87b: old_backups/V1_snapshot_20251016-171507/src/server/world/CleanupResources.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/CleanupResources.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/CleanupResources.server.luau, src/server/world/CleanupResources.server.luau"
# echo "Review duplicate group 3e87f4efef3a2ccca911f0614bf62a9d50931813: docs/ECONOMY.md, old_backups/V1_snapshot_20251016-171507/docs/ECONOMY.md, old_backups/checkpoint_20251016-175936/docs/ECONOMY.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/ECONOMY.md"
# echo "Review duplicate group 41c37171a6a94984a9de9005286912d1f264c09c: old_backups/V1_snapshot_20251016-171507/src/client/ui/ResourceHUD.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/ui/ResourceHUD.client.luau, old_backups/checkpoint_20251016-175936/src/client/ui/ResourceHUD.client.luau, src/client/ui/ResourceHUD.client.luau"
# echo "Review duplicate group 485a2a4b484a310e7f8bf46bdf4a3cc92b636c39: old_backups/V1_snapshot_20251016-171507/src/server/world/Remotes.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Remotes.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/Remotes.server.luau, src/server/world/Remotes.server.luau"
# echo "Review duplicate group 49856e1a3f713dc879dc5308ad13dcf57264e5e2: old_backups/V1_snapshot_20251016-171507/selene.toml, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/selene.toml, old_backups/checkpoint_20251016-175936/selene.toml, selene.toml"
# echo "Review duplicate group 4b96e2b50ea2bad5a9e4af36478ff5646a73346f: old_backups/V1_snapshot_20251016-171507/src/server/Remotes.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/Remotes.server.luau, old_backups/checkpoint_20251016-175936/src/server/Remotes.server.luau, src/server/Remotes.server.luau"
# echo "Review duplicate group 4c760cfc957e06c089e5a49784d5603ed2259a6d: docs/CLEANUP_ACTIONS.md, old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_ACTIONS.md, old_backups/checkpoint_20251016-175936/docs/CLEANUP_ACTIONS.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_ACTIONS.md"
# echo "Review duplicate group 4e6cc4c29f40949a47aadf87816d8cb3bd53818c: old_backups/V1_snapshot_20251016-171507/src/server/services/ResourceService.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/services/ResourceService.server.luau, old_backups/checkpoint_20251016-175936/src/server/services/ResourceService.server.luau, src/server/services/ResourceService.server.luau"
# echo "Review duplicate group 559125923db96fb6fa56d3bbca7bbdc4c3203508: docs/CLEANUP_REPORT.md, old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_REPORT.md, old_backups/checkpoint_20251016-175936/docs/CLEANUP_REPORT.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CLEANUP_REPORT.md"
# echo "Review duplicate group 5a956514a4af61a150073b7c3f8cbfc1a7d7cb6d: old_backups/V1_snapshot_20251016-171507/src/client/Main.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/Main.client.luau, old_backups/checkpoint_20251016-175936/src/client/Main.client.luau, src/client/Main.client.luau"
# echo "Review duplicate group 5b59945e7977399b4c6a675385bb9a7814cadc5b: old_backups/V1_snapshot_20251016-171507/src/server/world/ZoneTrigger.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/ZoneTrigger.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/ZoneTrigger.server.luau, src/server/world/ZoneTrigger.server.luau"
# echo "Review duplicate group 5ee1dc8a57f6558699ca3387faf3bca9f1607eff: old_backups/V1_snapshot_20251016-171507/src/client/ZoneToast.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/ZoneToast.client.luau, old_backups/checkpoint_20251016-175936/src/client/ZoneToast.client.luau, src/client/ZoneToast.client.luau"
# echo "Review duplicate group 63a909328d2e8cebd8e10661969300e24d112349: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/PROJECT_SCOPE.md, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_SCOPE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/PROJECT_SCOPE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_SCOPE.md"
# echo "Review duplicate group 63de80727c12f6c6c97807d930aa54e0fe67e06c: old_backups/V1_snapshot_20251016-171507/src/shared/config/GameConstants.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/GameConstants.luau, old_backups/checkpoint_20251016-175936/src/shared/config/GameConstants.luau, src/shared/config/GameConstants.luau"
# echo "Review duplicate group 66135e66d6b9da232f3c3ee593045448f4e57e07: old_backups/V1_snapshot_20251016-171507/src/server/world/TerrainLoader.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/TerrainLoader.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/TerrainLoader.server.luau, src/server/world/TerrainLoader.server.luau"
# echo "Review duplicate group 66a71d5e01c0102a5f871485de33b1490d286861: docs/AI_Workflow.md, old_backups/V1_snapshot_20251016-171507/docs/AI_Workflow.md, old_backups/checkpoint_20251016-175936/docs/AI_Workflow.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/AI_Workflow.md"
# echo "Review duplicate group 66b49faf5f8311a2295242728f483a6382140450: docs/RECOVERY.md, old_backups/V1_snapshot_20251016-171507/docs/RECOVERY.md, old_backups/checkpoint_20251016-175936/docs/RECOVERY.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/RECOVERY.md"
# echo "Review duplicate group 6b8a27da4b34f7e13832a177b2fa510854f8ad2d: docs/CHANGELOG.md, old_backups/V1_snapshot_20251016-171507/docs/CHANGELOG.md, old_backups/checkpoint_20251016-175936/docs/CHANGELOG.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CHANGELOG.md"
# echo "Review duplicate group 6b90e50f4db528dd915bcbe9028070f88a24fc23: old_backups/V1_snapshot_20251016-171507/src/server/modules/PartFactory.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/modules/PartFactory.luau, old_backups/checkpoint_20251016-175936/src/server/modules/PartFactory.luau, src/server/modules/PartFactory.luau"
# echo "Review duplicate group 6c15376a67a657c8e7776691d30df8772810e1a8: old_backups/V1_snapshot_20251016-171507/src/server/services/MissionService.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/services/MissionService.server.luau, old_backups/checkpoint_20251016-175936/src/server/services/MissionService.server.luau, src/server/services/MissionService.server.luau"
# echo "Review duplicate group 6d1f55d135995a4be87607454d6c14fc26a7e85a: docs/PROJECT_SCOPE.md, old_backups/V1_snapshot_20251016-171507/docs/PROJECT_SCOPE.md, old_backups/checkpoint_20251016-175936/docs/PROJECT_SCOPE.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/PROJECT_SCOPE.md"
# echo "Review duplicate group 70799f3d5326e669021d3d9cd31adcebed4a6264: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server 2.luau, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server 2.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/init.server.luau"
# echo "Review duplicate group 7e26ffe0850c7391e9fc8599f40ea3c08cbf703f: old_backups/V1_snapshot_20251016-171507/src/server_modules/ProgressionService.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/ProgressionService.luau, old_backups/checkpoint_20251016-175936/src/server_modules/ProgressionService.luau, src/server_modules/ProgressionService.luau"
# echo "Review duplicate group 82d971b85b257e2cce8213328571e2114841640b: old_backups/V1_snapshot_20251016-171507/src/shared/config/MissionDefs.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/MissionDefs.luau, old_backups/checkpoint_20251016-175936/src/shared/config/MissionDefs.luau, src/shared/config/MissionDefs.luau"
# echo "Review duplicate group 86652bf79074d924501fb33e1e7f5082b94736a3: old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau.bak_20251016-114925, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldInteract.server.luau.bak_20251016-114925, old_backups/checkpoint_20251016-175936/src/server/world/WorldInteract.server.luau.bak_20251016-114925, src/server/world/WorldInteract.server.luau.bak_20251016-114925"
# echo "Review duplicate group 9d8f251f44a6d8e527e0151da71ae761d6286da3: old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Fixup.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Fixup.luau, old_backups/checkpoint_20251016-175936/src/server/world/Garage/Fixup.luau, src/server/world/Garage/Fixup.luau"
# echo "Review duplicate group 9e8e26391ea07e6d73093719cc9cbaf7d63cb9ba: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CODEX_TASKS.md, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_TASKS.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CODEX_TASKS.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_TASKS.md"
# echo "Review duplicate group a7eb39cd552d4321b28caef6c26f36ba71765f31: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/STYLE.md, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/STYLE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/STYLE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/STYLE.md"
# echo "Review duplicate group a83e2f13dc99ebc6de28400b153ccc9d4a38c375: old_backups/V1_snapshot_20251016-171507/src/server/world/AutoDoorManager.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/AutoDoorManager.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/AutoDoorManager.server.luau, src/server/world/AutoDoorManager.server.luau"
# echo "Review duplicate group b7b7389d29fd0c8cdff92c8f4fa946ee13268397: .github/workflows/ci.yml, old_backups/V1_snapshot_20251016-171507/.github/workflows/ci.yml, old_backups/checkpoint_20251016-175936/.github/workflows/ci.yml, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/.github/workflows/ci.yml"
# echo "Review duplicate group baccd60cdade0a7b7e93868cfaf142de511a4635: docs/SETUP_GUIDE.md, old_backups/V1_snapshot_20251016-171507/docs/SETUP_GUIDE.md, old_backups/checkpoint_20251016-175936/docs/SETUP_GUIDE.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/SETUP_GUIDE.md"
# echo "Review duplicate group bfc314d82ed2643b4bd4bee6781f6bd1031c3e45: old_backups/V1_snapshot_20251016-171507/src/server_modules/PadAudit.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server_modules/PadAudit.luau, old_backups/checkpoint_20251016-175936/src/server_modules/PadAudit.luau, src/server_modules/PadAudit.luau"
# echo "Review duplicate group c51b5415bd28b9b42852a0b6c1112aeb7e981f18: old_backups/V1_snapshot_20251016-171507/src/server/modules/.keep, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/modules/.keep, old_backups/checkpoint_20251016-175936/src/server/modules/.keep, src/server/modules/.keep"
# echo "Review duplicate group c5a9804574ab32a526d49b30d09690b0d9e5be64: old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Debug.server.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Debug.server.luau, old_backups/checkpoint_20251016-175936/src/server/world/Garage/Debug.server.luau, src/server/world/Garage/Debug.server.luau"
# echo "Review duplicate group c70da092b275c05c1c73dbdd2eed5d80310998b4: old_backups/V1_snapshot_20251016-171507/src/client/ui/RightDock.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/ui/RightDock.client.luau, old_backups/checkpoint_20251016-175936/src/client/ui/RightDock.client.luau, src/client/ui/RightDock.client.luau"
# echo "Review duplicate group c780f54e641837ba6e22d5fd5e660bcfda9b55fc: old_backups/V1_snapshot_20251016-171507/src/shared/config/CollectConfig.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/config/CollectConfig.luau, old_backups/checkpoint_20251016-175936/src/shared/config/CollectConfig.luau, src/shared/config/CollectConfig.luau"
# echo "Review duplicate group c8ff7a6694565216549a6b65be5b4881d43f81d6: docs/REFACTORING_GUIDE.md, old_backups/V1_snapshot_20251016-171507/docs/REFACTORING_GUIDE.md, old_backups/checkpoint_20251016-175936/docs/REFACTORING_GUIDE.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/REFACTORING_GUIDE.md"
# echo "Review duplicate group c9631f643f256bf585d274d9374f10ad72d077ce: old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau.bak_20251016-114919, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/WorldBoot.luau.bak_20251016-114919, old_backups/checkpoint_20251016-175936/src/server/world/WorldBoot.luau.bak_20251016-114919, src/server/world/WorldBoot.luau.bak_20251016-114919"
# echo "Review duplicate group ce030a085136eba79016482b5b3552343dc72b9c: AUDIT_REPORT.md, old_backups/V1_snapshot_20251016-171507/AUDIT_REPORT.md, old_backups/checkpoint_20251016-175936/AUDIT_REPORT.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/AUDIT_REPORT.md"
# echo "Review duplicate group cfbceb45f304c36c25afcd2e699256cdbeda87f2: docs/WORLD_BLUEPRINT.md, old_backups/V1_snapshot_20251016-171507/docs/WORLD_BLUEPRINT.md, old_backups/checkpoint_20251016-175936/docs/WORLD_BLUEPRINT.md, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/WORLD_BLUEPRINT.md"
# echo "Review duplicate group d205cbd6783332a212c5ae92d73c77178c2d2f28: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1-darwin.tar.gz, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1.zip, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1-darwin.tar.gz, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/rojo-7.5.1.zip"
# echo "Review duplicate group d2aba44a04b8072c782c15283ddef7c0399dcfea: old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Shows/Hatch.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Shows/Hatch.luau, old_backups/checkpoint_20251016-175936/src/server/world/Garage/Shows/Hatch.luau, src/server/world/Garage/Shows/Hatch.luau"
# echo "Review duplicate group d5df9aa7a9e3e52506dbe7cd73a6806ca32cfed4: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/ASSET_PIPELINE.md, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/ASSET_PIPELINE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/ASSET_PIPELINE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/ASSET_PIPELINE.md"
# echo "Review duplicate group e6288df051a5d2916536c2b575a648b5582dd178: docs/CODEX_BASELINE.txt, old_backups/V1_snapshot_20251016-171507/docs/CODEX_BASELINE.txt, old_backups/checkpoint_20251016-175936/docs/CODEX_BASELINE.txt, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/docs/CODEX_BASELINE.txt"
# echo "Review duplicate group e8d61a5ec718a81e205111987e29b286203ae009: old_backups/V1_snapshot_20251016-171507/src/client/modules/MissionsHUD.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/modules/MissionsHUD.client.luau, old_backups/checkpoint_20251016-175936/src/client/modules/MissionsHUD.client.luau, src/client/modules/MissionsHUD.client.luau"
# echo "Review duplicate group f24aef36c17e74da5091937532487aad91db2337: old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Component.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/server/world/Garage/Component.luau, old_backups/checkpoint_20251016-175936/src/server/world/Garage/Component.luau, src/server/world/Garage/Component.luau"
# echo "Review duplicate group f5ae46b34bf8105a826d435cab541a60ec4cf01e: old_backups/V1_snapshot_20251016-171507/src/client/CommandUI.client.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/client/CommandUI.client.luau, old_backups/checkpoint_20251016-175936/src/client/CommandUI.client.luau, src/client/CommandUI.client.luau"
# echo "Review duplicate group f85635780bfc7efbabbf2f8c2d658507fcb96ed8: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CODEX_BASELINE.txt, old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_BASELINE.txt, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CODEX_BASELINE.txt, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/CODEX_BASELINE.txt"
# echo "Review duplicate group f8823c5162b45677b8344dd0a32cba6fcf37d79b: old_backups/V1_snapshot_20251016-171507/src/shared/ResourceDefs.luau, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/src/shared/ResourceDefs.luau, old_backups/checkpoint_20251016-175936/src/shared/ResourceDefs.luau, src/shared/ResourceDefs.luau"
# echo "Review duplicate group fa605d9a0e0ba9db04e72ce994c52afe670d80be: old_backups/V1_snapshot_20251016-171507/sourcemap.json, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/sourcemap.json, old_backups/checkpoint_20251016-175936/sourcemap.json, sourcemap.json"
# echo "Review duplicate group ff793e351b33eaefabdb3c5bf34d2be5876ca2fe: old_backups/checkpoint_20251016-175936/src/ServerScriptService/RunOnce.server.luau, old_backups/checkpoint_20251016-175936/src/server/RunOnce.server.luau, src/ServerScriptService/RunOnce.server.luau, src/server/RunOnce.server.luau"
# echo "Review duplicate group fef2a6bcc33ff334b9cf0803b20b9a815dbac375: old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock, old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock, old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx.lock"
# echo "Review duplicate group 030f1b12b34f42396af1f26a5facdaad60724106: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ReplicatedStorage/Shared/Types/ResourceTypes.lua, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ReplicatedStorage/Shared/Types/ResourceTypes.lua"
# echo "Review duplicate group 06c4348c5269111071e5a4d255436e5ab63378b2: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/README.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/README.md"
# echo "Review duplicate group 082277eca3147f16b1b573a446ad0e9c8f201b41: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Currencies.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Currencies.luau"
# echo "Review duplicate group 096f6d65af6227fe38c16160811b368d466631ce: old_backups/checkpoint_20251016-175936/src/server/DumpScrap.server.luau, src/server/DumpScrap.server.luau"
# echo "Review duplicate group 0c754f2bd767d80fd76b31ef856955494bac65f3: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/REFACTORING_GUIDE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/REFACTORING_GUIDE.md"
# echo "Review duplicate group 0e21bceec4281484ac4887d35d6f6143a74d130c: old_backups/checkpoint_20251016-175936/src/server/HideResourceOverlays.server.luau, src/server/HideResourceOverlays.server.luau"
# echo "Review duplicate group 0e2f82c70f52f382c86ad200cd107d865dacad68: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/Main.client.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/Main.client.luau"
# echo "Review duplicate group 125a1917ea8ed1349d7bfbfdbb34ed772a5e9e3d: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RemoteSetup.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RemoteSetup.luau"
# echo "Review duplicate group 129ffc94ed82e00fac9290c7304c90b1f5e4c85c: old_backups/checkpoint_20251016-175936/src/shared/utils/ResourceGuards.luau, src/shared/utils/ResourceGuards.luau"
# echo "Review duplicate group 1380511f1be50900128d35508f2aabb603838535: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/GameConstants.spec.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/GameConstants.spec.luau"
# echo "Review duplicate group 142a000513806130f6ada7edd704cab3b31cadab: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/world/GarageReset.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server/world/GarageReset.server.luau"
# echo "Review duplicate group 14b0eddbd63a338fe54512cfa15ad0d6ce6d4e09: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EntitlementService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EntitlementService.luau"
# echo "Review duplicate group 14e693b1b1f710093d6f802367b1098856003961: LICENSE, old_backups/checkpoint_20251016-175936/LICENSE"
# echo "Review duplicate group 174d529576b13207567d4b17972bb5a6aaa42cda: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/DoorPlane.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/DoorPlane.luau"
# echo "Review duplicate group 196880f822f965ca3825754139422440ebc68d79: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/HatchUI.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/HatchUI.luau"
# echo "Review duplicate group 1baa0afc5fbc301760600df9a96e6e00935d3a82: old_backups/checkpoint_20251016-175936/package.json, package.json"
# echo "Review duplicate group 1e0467524ddb06a07af105c56454e1c238d14f44: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init.server.luau"
# echo "Review duplicate group 21e8cba9bbb6b175bf86d2c9221b4e74737ce2c8: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/WorldService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/WorldService.luau"
# echo "Review duplicate group 22f765e6afa1a7d654cc4d5bc3c2763d604f3df0: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/ART_BRIEF.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/ART_BRIEF.md"
# echo "Review duplicate group 23aabf2b123dac6b6bfb4173791c87d9fa90ec3f: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GuiManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GuiManager.luau"
# echo "Review duplicate group 25d0d85039c1b25156815b4c0269a8dace51f35c: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/Remotes.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/Remotes.server.luau"
# echo "Review duplicate group 2ebf1500c20316db5dcc47bc71e69e2e66fb4372: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/WorldBoot.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/WorldBoot.luau"
# echo "Review duplicate group 2f7495dac31d46afa7e682a02198ede5d115bbe3: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.json, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.json"
# echo "Review duplicate group 312184971b42b55c0dec7e4f835ec2eb69172252: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init-legacy.server.luau.disabled, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/init-legacy.server.luau.disabled"
# echo "Review duplicate group 359f80f89fbdb74c1a4b9dce8ad506302465ab05: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/Taskbar.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/Taskbar.luau"
# echo "Review duplicate group 36c440994da9caa4f55ab751725d9475458ff718: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestRunner.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestRunner.luau"
# echo "Review duplicate group 37620f3d43e8891e41fe549ee7ab3b0e07cffd6f: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CLAUDE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/CLAUDE.md"
# echo "Review duplicate group 3b46e21c8ffe9fa3fa71d1e740c10f0388d76aae: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/RECOVERY_REPORT.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/RECOVERY_REPORT.md"
# echo "Review duplicate group 3e654aba36dee65361c35e203c8d0dece6dbdc14: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/PlayerService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/PlayerService.luau"
# echo "Review duplicate group 40cbf458f4ca926d0b0f04b373e494532a49a3b5: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/RobotTypes.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/RobotTypes.luau"
# echo "Review duplicate group 40d03750a2e8dd013c0d45a0161bf09d4e91772b: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/util/LODService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/util/LODService.luau"
# echo "Review duplicate group 40ed99e6d473180092eac0a1c157462a7d326330: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RobotUIManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RobotUIManager.luau"
# echo "Review duplicate group 4580326006ac738a0d308360c5fc47dbc7b58284: old_backups/checkpoint_20251016-175936/tools/cleanup_actions.py, tools/cleanup_actions.py"
# echo "Review duplicate group 45a996686e7e8bce97e9a5cab7f7c3aef51c3e9a: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/EconomyHandlers.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/EconomyHandlers.server.luau"
# echo "Review duplicate group 468e4bc570d4e5e1563bffa58d0792e3ff8f106f: old_backups/checkpoint_20251016-175936/src/client/DumpScrap.client.luau, src/client/DumpScrap.client.luau"
# echo "Review duplicate group 49e0b7bb5ae016ee79853459bf1fd38b221d42cc: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/default.project.json, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/default.project.json"
# echo "Review duplicate group 4e2c0560cec75369ff77e555d82e5e6a308da2e6: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/default.project.json, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/default.project.json"
# echo "Review duplicate group 4fcbeb63bc36513ce57e10eb8242a42ab62e4499: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GarageUI.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/GarageUI.luau"
# echo "Review duplicate group 50bed82ef23f687e904f427352cf8f1e651854f2: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/223549__captainvince__industrial-garage-door-storage-gate-open.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/223549__captainvince__industrial-garage-door-storage-gate-open.wav"
# echo "Review duplicate group 515d1ae64a2ca203149888de0a6d26456daf03f8: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_ion_shard.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_ion_shard.wav"
# echo "Review duplicate group 51d7f15ec3cea9e30437d8cc4e2b2f499cc01db8: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_rare_metal.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_rare_metal.wav"
# echo "Review duplicate group 5bab4d0f3329831929c8bd69ee19b9606a6422ec: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/AssignUI.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/AssignUI.luau"
# echo "Review duplicate group 5c08ecce73fb2cfd33d7ad05042e0e4340426923: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/README.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/README.md"
# echo "Review duplicate group 5cbdbe06bb05b2c2cf6de7f1484347716d2d46ef: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RobotManager.spec.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RobotManager.spec.luau"
# echo "Review duplicate group 5e44797539c35039a6439f251186f1caf2b77004: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/PartFactory.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/modules/PartFactory.luau"
# echo "Review duplicate group 61400e5c16685d3d079e4e6aacd9e9dfffea009d: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Garage/Component.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/world/Garage/Component.luau"
# echo "Review duplicate group 6448a4a2acd96d5f4f10de0f774cb10a354dcb88: README.md, old_backups/checkpoint_20251016-175936/README.md"
# echo "Review duplicate group 6607451aa2059d618572968a23e4dfeeefb6fcb5: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Boosters.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/Boosters.luau"
# echo "Review duplicate group 6644801720d85fb8ec5d0fe72c36d1f6a5f3d2da: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/GarageService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/GarageService.luau"
# echo "Review duplicate group 67641767cd7c2cf9d3dda0bbfec05c56a310b845: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/default.project.json, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/default.project.json"
# echo "Review duplicate group 6b5a9f18b20082a0173932443f016be7cf3c5cb4: old_backups/checkpoint_20251016-175936/src/client/HideResourceOverlays.client.luau, src/client/HideResourceOverlays.client.luau"
# echo "Review duplicate group 6d78dbc65fb3e28619857cc1c34dc3e76955b470: old_backups/checkpoint_20251016-175936/src/server/init.server.luau, src/server/init.server.luau"
# echo "Review duplicate group 724392b890c5593f407ed90d23eeb9c94af77b46: old_backups/checkpoint_20251016-175936/scripts/_util_rojo.py, scripts/_util_rojo.py"
# echo "Review duplicate group 72f1778a1618f73b728f77e2598a50420bb6bd3e: old_backups/checkpoint_20251016-175936/src/server/RogueGroundKiller.server.luau, src/server/RogueGroundKiller.server.luau"
# echo "Review duplicate group 74250256314dc714e5ef46e8df7196d086315b9d: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/00_spawns_and_remotes.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/server/00_spawns_and_remotes.server.luau"
# echo "Review duplicate group 763dbd503f861658ad4e96c1eedffa7a6d589baa: old_backups/checkpoint_20251016-175936/src/server/WatchNewParts.server.luau, src/server/WatchNewParts.server.luau"
# echo "Review duplicate group 77e070c866bea53fa03cfb3a15e8fe207cb2e598: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RemoteManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/RemoteManager.luau"
# echo "Review duplicate group 7c4ee2a36ff80d8e489268909f87478d58479c78: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/workspace-setup.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/workspace-setup.server.luau"
# echo "Review duplicate group 816f5db05c4258eacbc95543535846f1434d61e3: old_backups/checkpoint_20251016-175936/src/server/ScrapTerminator.server.luau, src/server/ScrapTerminator.server.luau"
# echo "Review duplicate group 862631155e1fde8a4aacf134581595224be36420: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/_bootstrap.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/_bootstrap.luau"
# echo "Review duplicate group 86ae9c8519ae1e45a2509c47167585cdba942cec: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageDoctor.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageDoctor.luau"
# echo "Review duplicate group 8a430b24fd1197c047a3bb2e884a3a18ffc95802: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/types/README.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/types/README.md"
# echo "Review duplicate group 8aa2e40e4fd672b6f0c809a2dc29342c64348c45: old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau, old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau"
# echo "Review duplicate group 8dd5514f103d903c0dd6723f4a547b566e818848: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ResourceManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ResourceManager.luau"
# echo "Review duplicate group 8fd6f0df2cb410650bfadb2d0bd1c01d268bcd35: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/.gitignore, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/.gitignore"
# echo "Review duplicate group 90b0ab5dfa0c00c98b1baf6f1afffb95aa14ab7a: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ModalManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ModalManager.luau"
# echo "Review duplicate group 930077c779753e7dcf3cb25ac371b8b9064a27b3: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageReset.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/GarageReset.server.luau"
# echo "Review duplicate group 94704eee9e556b691459fa49cc640da1fdf04db3: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RemoteSetup.spec.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/specs/RemoteSetup.spec.luau"
# echo "Review duplicate group 971113d6913babc66eac8fc9471245d1b2eef004: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/utils/README.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/utils/README.md"
# echo "Review duplicate group 9a2c14cf344f7aa0c1ac4bc12a44cb9dca3253eb: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/.gitignore, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/.gitignore"
# echo "Review duplicate group 9a78e3a042337f4a832fb982436871478029fc8a: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/ambient_hum.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/ambient_hum.wav"
# echo "Review duplicate group 9d077c3c2e99d092869232fab36feb1f10fd58ba: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/RobotService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/RobotService.luau"
# echo "Review duplicate group 9d80129fe7deba5421b7e5346dbcf8aefd829f68: old_backups/checkpoint_20251016-175936/scripts/full_manifest.py, scripts/full_manifest.py"
# echo "Review duplicate group a02576dd7384fce6cddfb057c1d675144adeb470: AGENTS.local.md, old_backups/checkpoint_20251016-175936/AGENTS.local.md"
# echo "Review duplicate group a2ed99661dc07916538ae26ed7af8030735d3513: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/SETUP_GUIDE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/SETUP_GUIDE.md"
# echo "Review duplicate group a330182ad5ac02fbc9e7f40e1c8a2338ef2195e6: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/AGENTS.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/AGENTS.md"
# echo "Review duplicate group a8eee0fd73c32ff24ab8e46e363e5b0d0f14780e: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_docs/PROJECT_INVENTORY.md"
# echo "Review duplicate group a99de0789406f761bda4937c0ae28689e39756cd: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/CommandUI.client.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_restore_snapshot_20251009-141725/src/client/CommandUI.client.luau"
# echo "Review duplicate group ad0b179f2245feb4dc25b28a35c2024ae6456e73: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/UIFactory.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/UIFactory.luau"
# echo "Review duplicate group ae03e6214aec8c0caa019d48316c63b330dacac1: old_backups/checkpoint_20251016-175936/src/server/ScrapHotfix.server.luau, src/server/ScrapHotfix.server.luau"
# echo "Review duplicate group af699ad512e2ca287a7b4256dccd85b7f2e748b4: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/PlayerManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/PlayerManager.luau"
# echo "Review duplicate group b1f14e63600201ad69ada59bac660b35f88b3b11: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/README.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/README.md"
# echo "Review duplicate group b27eb65b7009e067585479e7a37839ef4813f76e: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/29538__mikehirst__garage-door-opening.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/29538__mikehirst__garage-door-opening.wav"
# echo "Review duplicate group b30e8bb39ff109c33cf327ca829009f0e08ee3e3: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/SaveService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/SaveService.luau"
# echo "Review duplicate group b5344e38facce7ea4e44b10b418a7284a4a8e17e: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/_readme_and_license.txt, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/_readme_and_license.txt"
# echo "Review duplicate group b73cdccbf84de0ee607aa3eff2533c13f7fa27c7: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CHANGELOG.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/CHANGELOG.md"
# echo "Review duplicate group b7b5fcf8c067ad3e42870bab85cd49f2a8e35692: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/GameConstants.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/GameConstants.luau"
# echo "Review duplicate group bcedd0fa0d4c541c5c462a329dbdb0503be510e2: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server_modules/RemoteSetup.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v2/src/server_modules/RemoteSetup.luau"
# echo "Review duplicate group bd5ae41d016b82477857d0be3c364f0e1d58814c: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/RobotSkins.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared 2/config/data/RobotSkins.luau"
# echo "Review duplicate group c12ac59444ee6625881cccc99782d98bc0080cb4: old_backups/checkpoint_20251016-175936/src/client/ClickProbe.client.luau, src/client/ClickProbe.client.luau"
# echo "Review duplicate group c3f6839c9fe318a2909f2014b5567ce72c5db7f3: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/DEVELOPMENT_LOG.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/DEVELOPMENT_LOG.md"
# echo "Review duplicate group c9fc443f3b4872b5c44de8d79e06faca866430e4: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init.client.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init.client.luau"
# echo "Review duplicate group cca89c7e5ddb8ea8cab5664ae42892410acaf824: old_backups/checkpoint_20251016-175936/src/client/NukeNearDoor.client.luau, src/client/NukeNearDoor.client.luau"
# echo "Review duplicate group cefb6f362ef71b260dc3a7b317fc99b96c22be11: old_backups/checkpoint_20251016-175936/tools/cleanup_project.py, tools/cleanup_project.py"
# echo "Review duplicate group d03c5e241066e183786c705f0622dbbf20ba8c05: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_src/server/modules/BuildGuard.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_src/server/modules/BuildGuard.luau"
# echo "Review duplicate group d15470c27e748b5e02cafd5bae9cdf4201a3901c: PROJECT_TREE.txt, old_backups/checkpoint_20251016-175936/PROJECT_TREE.txt"
# echo "Review duplicate group d244b4ef857cf782b200b5aa917d5508c35e0232: old_backups/checkpoint_20251016-175936/tools/scan_project.py, tools/scan_project.py"
# echo "Review duplicate group d58570d7b0513d06d625b8c2367f7b0af46ccf48: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/README.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/README.md"
# echo "Review duplicate group d6ccec6c831e469079e11c2d994f131db6b2b4fe: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ServerStorage/Server/Systems/Resources/ResourceSystem.lua, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/ServerStorage/Server/Systems/Resources/ResourceSystem.lua"
# echo "Review duplicate group d8dcb65a93a4d7320cc143f33977093a5f435eb1: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server_modules/RC_RemoteSetup.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server_modules/RC_RemoteSetup.luau"
# echo "Review duplicate group d9288800fe68ad71e78b5ed4c3bdb322d2f4382f: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestEZ.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/tests/TestEZ.luau"
# echo "Review duplicate group d9723f386de8ec2eb03d206980e88547c85d57bd: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/GarageDoorBootstrap.server.luau.disabled, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/handlers/GarageDoorBootstrap.server.luau.disabled"
# echo "Review duplicate group db0d7f4539dc1a81570a4507dbd796b3ed38c891: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_gearbit.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_gearbit.wav"
# echo "Review duplicate group dec1293e331cf7211fb03ec11da20416e5987679: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init-refactored.client.luau.disabled, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/init-refactored.client.luau.disabled"
# echo "Review duplicate group e270ed0c1d8f933fe506e7bac46029f106b9f648: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ShopClient.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/ShopClient.luau"
# echo "Review duplicate group e2b5bd16027088b9613395fd926547d680e0244d: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EconomyService.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/services/EconomyService.luau"
# echo "Review duplicate group e4a2b3eda35f8ee39cd466dc47c126c7dfe2c32a: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/Theme.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/ui/Theme.luau"
# echo "Review duplicate group e8225a71ab45c7350470c06743a7c82b027a7d43: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/UIStyle.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/UIStyle.luau"
# echo "Review duplicate group e8409b85da742706a64c774d65ac6578d19a48e2: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/init.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/init.server.luau"
# echo "Review duplicate group ea184d346cbcc594d931f3301726abbee8fa65b7: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_crystal.wav, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/sounds/pickaxe_crystal.wav"
# echo "Review duplicate group eb44587f5802e5fb09dac05a86517bd9cd6ea7c4: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/world/RC_GarageReset.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/v3/src/server/world/RC_GarageReset.server.luau"
# echo "Review duplicate group f55b130672334e74b1763af4d077b8e0b9246b74: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/Remotes.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/shared/remotes/Remotes.luau"
# echo "Review duplicate group f649824d0e90821d23e77b950bfe031e8861666b: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/Robot-Collectors.rbxlx, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/Robot-Collectors.rbxlx"
# echo "Review duplicate group f65bb9deefca9c97ae488bbe2b91738e4d303098: old_backups/checkpoint_20251016-175936/src/client/init.client.luau, src/client/init.client.luau"
# echo "Review duplicate group f720ecf63ba06d31a9b83924d60dd89ff42e5129: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/LightingProfile.server.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server/world/LightingProfile.server.luau"
# echo "Review duplicate group f835881f15de6f120e487529e6238fbc44551b37: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/InputManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/client/modules/InputManager.luau"
# echo "Review duplicate group f97fbb29c7d8e2303945368f8031e3be8b131cd6: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RobotManager.luau, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/src/server_modules/RobotManager.luau"
# echo "Review duplicate group f9a9fe729d8618fd7dffadfef9c4bf6fa1e8a8ee: old_backups/checkpoint_20251016-175936/src/client/DebugPaverWatch.client.luau, src/client/DebugPaverWatch.client.luau"
# echo "Review duplicate group fdc469f4a49057196275141c16be1bd5c4c167e4: old_backups/checkpoint_20251016-175936/src/shared/Hello.luau, src/shared/Hello.luau"
# echo "Review duplicate group fdc5adbb9f669374530611f95552e48258c36a79: old_backups/checkpoint_20251016-175936/old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/API_REFERENCE.md, old_backups/cleanup_20251012_215540Z/20251012_215540Z_archive_20251004_124217/archive_20251004_123907/docs/API_REFERENCE.md"
# echo "Review legacy path: old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx"
# echo "Review legacy path: old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/old_backups/V1_snapshot_20251016-171507/robot-collectors-new-V1.rbxlx.lock"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/robot-collectors-new-V1.rbxlx.lock"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/.gitignore"
# echo "Review legacy path: old_backups/checkpoint_20251016-175936/robot-collectors-new-V1/default.project.json"
# echo "Review legacy path: old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/.selene/roblox 2.toml"
# echo "Review legacy path: old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server/00_spawns_and_remotes.server.luau"
# echo "Review legacy path: old_backups/cleanup_actions_20251012_220517Z/robot-collectors-new-V1/src/server_modules/RemoteSetup 2.luau"
