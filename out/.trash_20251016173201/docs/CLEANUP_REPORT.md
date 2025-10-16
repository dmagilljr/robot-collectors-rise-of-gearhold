# Cleanup Report

- Generated: 2025-10-12T21:58:08.423361+00:00
- Live Project: `/Users/tmagill/Documents/Development/robot_collectors/robot-collectors-new-V1`
- Archived entries: 0
- Junk actions: 0
- Tracked files: 56
- Untracked files: 8
- HEAD present: True

## Before Tree
```
robot_collectors/
├── old_backups
│   └── cleanup_20251012_215540Z
│       ├── 20251012_215540Z_archive_20251004_124217
│       │   ├── archive_20251004_123907
│       │   ├── docs
│       │   ├── src
│       │   ├── .gitignore
│       │   └── README.md
│       ├── 20251012_215540Z_docs
│       │   ├── _legacy
│       │   ├── _recovered
│       │   ├── ASSET_PIPELINE.md
│       │   ├── CODEX_BASELINE.txt
│       │   ├── CODEX_TASKS.md
│       │   ├── docs_audit.txt
│       │   ├── PROJECT_INVENTORY.json
│       │   ├── PROJECT_INVENTORY.md
│       │   ├── PROJECT_SCOPE.md
│       │   ├── RECOVERY_REPORT.md
│       │   └── STYLE.md
│       ├── 20251012_215540Z_restore_snapshot_20251009-141725
│       │   └── src
│       └── 20251012_215540Z_src
│           ├── server
│           └── .DS_Store
├── robot-collectors-new-V1
│   ├── .git
│   │   ├── hooks
│   │   │   ├── applypatch-msg.sample
│   │   │   ├── commit-msg.sample
│   │   │   ├── fsmonitor-watchman.sample
│   │   │   ├── post-update.sample
│   │   │   ├── pre-applypatch.sample
│   │   │   ├── pre-commit.sample
│   │   │   ├── pre-merge-commit.sample
│   │   │   ├── pre-push.sample
│   │   │   ├── pre-rebase.sample
│   │   │   ├── pre-receive.sample
│   │   │   ├── prepare-commit-msg.sample
│   │   │   ├── push-to-checkout.sample
│   │   │   ├── sendemail-validate.sample
│   │   │   └── update.sample
│   │   ├── info
│   │   │   └── exclude
│   │   ├── logs
│   │   │   ├── refs
│   │   │   └── HEAD
│   │   ├── objects
│   │   │   ├── 00
│   │   │   ├── 01
│   │   │   ├── 04
│   │   │   ├── 05
│   │   │   ├── 06
│   │   │   ├── 07
│   │   │   ├── 08
│   │   │   ├── 0d
│   │   │   ├── 0e
│   │   │   ├── 0f
│   │   │   ├── 10
│   │   │   ├── 12
│   │   │   ├── 13
│   │   │   ├── 14
│   │   │   ├── 16
│   │   │   ├── 17
│   │   │   ├── 18
│   │   │   ├── 19
│   │   │   ├── 1a
│   │   │   ├── 1b
│   │   │   ├── 1c
│   │   │   ├── 1d
│   │   │   ├── 1e
│   │   │   ├── 1f
│   │   │   ├── 20
│   │   │   ├── 21
│   │   │   ├── 23
│   │   │   ├── 24
│   │   │   ├── 25
│   │   │   ├── 26
│   │   │   ├── 27
│   │   │   ├── 28
│   │   │   ├── 29
│   │   │   ├── 2b
│   │   │   ├── 2c
│   │   │   ├── 2d
│   │   │   ├── 2e
│   │   │   ├── 2f
│   │   │   ├── 31
│   │   │   ├── 33
│   │   │   ├── 34
│   │   │   ├── 35
│   │   │   ├── 36
│   │   │   ├── 37
│   │   │   ├── 38
│   │   │   ├── 39
│   │   │   ├── 3a
│   │   │   ├── 3b
│   │   │   ├── 3e
│   │   │   ├── 3f
│   │   │   ├── 40
│   │   │   ├── 41
│   │   │   ├── 42
│   │   │   ├── 43
│   │   │   ├── 44
│   │   │   ├── 45
│   │   │   ├── 48
│   │   │   ├── 49
│   │   │   ├── 4a
│   │   │   ├── 4b
│   │   │   ├── 4c
│   │   │   ├── 4d
│   │   │   ├── 4e
│   │   │   ├── 4f
│   │   │   ├── 51
│   │   │   ├── 53
│   │   │   ├── 54
│   │   │   ├── 55
│   │   │   ├── 56
│   │   │   ├── 57
│   │   │   ├── 58
│   │   │   ├── 5b
│   │   │   ├── 5c
│   │   │   ├── 5d
│   │   │   ├── 5e
│   │   │   ├── 5f
│   │   │   ├── 60
│   │   │   ├── 61
│   │   │   ├── 62
│   │   │   ├── 64
│   │   │   ├── 67
│   │   │   ├── 68
│   │   │   ├── 69
│   │   │   ├── 6b
│   │   │   ├── 6f
│   │   │   ├── 70
│   │   │   ├── 73
│   │   │   ├── 74
│   │   │   ├── 76
│   │   │   ├── 79
│   │   │   ├── 7a
│   │   │   ├── 7b
│   │   │   ├── 7c
│   │   │   ├── 7d
│   │   │   ├── 7e
│   │   │   ├── 7f
│   │   │   ├── 81
│   │   │   ├── 83
│   │   │   ├── 85
│   │   │   ├── 87
│   │   │   ├── 88
│   │   │   ├── 8a
│   │   │   ├── 8d
│   │   │   ├── 8e
│   │   │   ├── 8f
│   │   │   ├── 92
│   │   │   ├── 93
│   │   │   ├── 95
│   │   │   ├── 97
│   │   │   ├── 98
│   │   │   ├── 9a
│   │   │   ├── 9b
│   │   │   ├── 9c
│   │   │   ├── 9e
│   │   │   ├── 9f
│   │   │   ├── a0
│   │   │   ├── a1
│   │   │   ├── a2
│   │   │   ├── a3
│   │   │   ├── a4
│   │   │   ├── a5
│   │   │   ├── a9
│   │   │   ├── aa
│   │   │   ├── ab
│   │   │   ├── ad
│   │   │   ├── ae
│   │   │   ├── b0
│   │   │   ├── b1
│   │   │   ├── b3
│   │   │   ├── b4
│   │   │   ├── b6
│   │   │   ├── b7
│   │   │   ├── b8
│   │   │   ├── b9
│   │   │   ├── ba
│   │   │   ├── bc
│   │   │   ├── bd
│   │   │   ├── be
│   │   │   ├── c0
│   │   │   ├── c1
│   │   │   ├── c2
│   │   │   ├── c3
│   │   │   ├── c4
│   │   │   ├── c5
│   │   │   ├── c7
│   │   │   ├── c8
│   │   │   ├── c9
│   │   │   ├── cb
│   │   │   ├── cc
│   │   │   ├── cf
│   │   │   ├── d2
│   │   │   ├── d5
│   │   │   ├── d6
│   │   │   ├── d7
│   │   │   ├── d8
│   │   │   ├── d9
│   │   │   ├── db
│   │   │   ├── dc
│   │   │   ├── dd
│   │   │   ├── df
│   │   │   ├── e0
│   │   │   ├── e4
│   │   │   ├── e6
│   │   │   ├── e7
│   │   │   ├── e8
│   │   │   ├── ea
│   │   │   ├── ec
│   │   │   ├── ee
│   │   │   ├── f0
│   │   │   ├── f1
│   │   │   ├── f2
│   │   │   ├── f4
│   │   │   ├── f5
│   │   │   ├── f7
│   │   │   ├── fa
│   │   │   ├── fb
│   │   │   ├── ff
│   │   │   ├── info
│   │   │   └── pack
│   │   ├── refs
│   │   │   ├── heads
│   │   │   ├── remotes
│   │   │   └── tags
│   │   ├── COMMIT_EDITMSG
│   │   ├── config
│   │   ├── description
│   │   ├── FETCH_HEAD
│   │   ├── HEAD
│   │   ├── index
│   │   ├── ORIG_HEAD
│   │   └── REBASE_HEAD
│   ├── .github
│   │   ├── workflows
│   │   │   └── ci.yml
│   │   └── workflows 2
│   ├── .selene
│   │   ├── roblox 2.toml
│   │   └── roblox.toml
│   ├── docs
│   │   ├── _legacy
│   │   ├── AI_Workflow.md
│   │   ├── ARCHITECTURE.md
│   │   ├── ASSET_PIPELINE.md
│   │   ├── CHANGELOG.md
│   │   ├── CLEANUP_REPORT.md
│   │   ├── CODEX_BASELINE.txt
│   │   ├── ECONOMY.md
│   │   ├── PROJECT_SCOPE.md
│   │   ├── README.md
│   │   ├── RECOVERY.md
│   │   ├── REFACTORING_GUIDE.md
│   │   ├── SETUP_GUIDE.md
│   │   └── STYLE.md
│   ├── src
│   │   ├── client
│   │   │   ├── .keep
│   │   │   ├── CommandUI.client.luau
│   │   │   ├── HatchFX.client.luau
│   │   │   └── Main.client.luau
│   │   ├── server
│   │   │   ├── modules
│   │   │   ├── tests
│   │   │   ├── world
│   │   │   ├── .DS_Store
│   │   │   ├── .keep
│   │   │   ├── 00_spawns_and_remotes.server.luau
│   │   │   ├── bootstrap.server.luau
│   │   │   ├── MissionService.server.luau
│   │   │   ├── Remotes.server.luau
│   │   │   ├── spawn_guard.server.luau
│   │   │   ├── Untitled spreadsheet.gsheet
│   │   │   └── zzz_server_banner.server.luau
│   │   ├── server_modules
│   │   │   ├── .keep
│   │   │   ├── RemoteSetup 2.luau
│   │   │   └── RemoteSetup.luau
│   │   ├── shared
│   │   │   ├── config
│   │   │   └── .keep
│   │   └── .DS_Store
│   ├── .DS_Store
│   ├── .gitignore
│   ├── default.project.json
│   ├── robot-collectors-new-V1.rbxlx
│   ├── robot-collectors-new-V1.rbxlx.lock
│   ├── selene.toml
│   ├── sourcemap.json
│   ├── stylua.toml
│   └── world.rbxm
├── tools
│   ├── cleanup_project.py
│   └── scan_project.py
├── .DS_Store
├── AGENTS.local.md
├── LICENSE
└── README.md
```

## After Tree
```
robot_collectors/
├── old_backups
│   ├── cleanup_20251012_215540Z
│   │   ├── 20251012_215540Z_archive_20251004_124217
│   │   │   ├── archive_20251004_123907
│   │   │   ├── docs
│   │   │   ├── src
│   │   │   ├── .gitignore
│   │   │   └── README.md
│   │   ├── 20251012_215540Z_docs
│   │   │   ├── _legacy
│   │   │   ├── _recovered
│   │   │   ├── ASSET_PIPELINE.md
│   │   │   ├── CODEX_BASELINE.txt
│   │   │   ├── CODEX_TASKS.md
│   │   │   ├── docs_audit.txt
│   │   │   ├── PROJECT_INVENTORY.json
│   │   │   ├── PROJECT_INVENTORY.md
│   │   │   ├── PROJECT_SCOPE.md
│   │   │   ├── RECOVERY_REPORT.md
│   │   │   └── STYLE.md
│   │   ├── 20251012_215540Z_restore_snapshot_20251009-141725
│   │   │   └── src
│   │   └── 20251012_215540Z_src
│   │       ├── server
│   │       └── .DS_Store
│   └── cleanup_20251012_215808Z
├── robot-collectors-new-V1
│   ├── .git
│   │   ├── hooks
│   │   │   ├── applypatch-msg.sample
│   │   │   ├── commit-msg.sample
│   │   │   ├── fsmonitor-watchman.sample
│   │   │   ├── post-update.sample
│   │   │   ├── pre-applypatch.sample
│   │   │   ├── pre-commit.sample
│   │   │   ├── pre-merge-commit.sample
│   │   │   ├── pre-push.sample
│   │   │   ├── pre-rebase.sample
│   │   │   ├── pre-receive.sample
│   │   │   ├── prepare-commit-msg.sample
│   │   │   ├── push-to-checkout.sample
│   │   │   ├── sendemail-validate.sample
│   │   │   └── update.sample
│   │   ├── info
│   │   │   └── exclude
│   │   ├── logs
│   │   │   ├── refs
│   │   │   └── HEAD
│   │   ├── objects
│   │   │   ├── 00
│   │   │   ├── 01
│   │   │   ├── 04
│   │   │   ├── 05
│   │   │   ├── 06
│   │   │   ├── 07
│   │   │   ├── 08
│   │   │   ├── 0d
│   │   │   ├── 0e
│   │   │   ├── 0f
│   │   │   ├── 10
│   │   │   ├── 12
│   │   │   ├── 13
│   │   │   ├── 14
│   │   │   ├── 16
│   │   │   ├── 17
│   │   │   ├── 18
│   │   │   ├── 19
│   │   │   ├── 1a
│   │   │   ├── 1b
│   │   │   ├── 1c
│   │   │   ├── 1d
│   │   │   ├── 1e
│   │   │   ├── 1f
│   │   │   ├── 20
│   │   │   ├── 21
│   │   │   ├── 23
│   │   │   ├── 24
│   │   │   ├── 25
│   │   │   ├── 26
│   │   │   ├── 27
│   │   │   ├── 28
│   │   │   ├── 29
│   │   │   ├── 2b
│   │   │   ├── 2c
│   │   │   ├── 2d
│   │   │   ├── 2e
│   │   │   ├── 2f
│   │   │   ├── 31
│   │   │   ├── 33
│   │   │   ├── 34
│   │   │   ├── 35
│   │   │   ├── 36
│   │   │   ├── 37
│   │   │   ├── 38
│   │   │   ├── 39
│   │   │   ├── 3a
│   │   │   ├── 3b
│   │   │   ├── 3e
│   │   │   ├── 3f
│   │   │   ├── 40
│   │   │   ├── 41
│   │   │   ├── 42
│   │   │   ├── 43
│   │   │   ├── 44
│   │   │   ├── 45
│   │   │   ├── 48
│   │   │   ├── 49
│   │   │   ├── 4a
│   │   │   ├── 4b
│   │   │   ├── 4c
│   │   │   ├── 4d
│   │   │   ├── 4e
│   │   │   ├── 4f
│   │   │   ├── 51
│   │   │   ├── 53
│   │   │   ├── 54
│   │   │   ├── 55
│   │   │   ├── 56
│   │   │   ├── 57
│   │   │   ├── 58
│   │   │   ├── 5b
│   │   │   ├── 5c
│   │   │   ├── 5d
│   │   │   ├── 5e
│   │   │   ├── 5f
│   │   │   ├── 60
│   │   │   ├── 61
│   │   │   ├── 62
│   │   │   ├── 64
│   │   │   ├── 67
│   │   │   ├── 68
│   │   │   ├── 69
│   │   │   ├── 6b
│   │   │   ├── 6f
│   │   │   ├── 70
│   │   │   ├── 73
│   │   │   ├── 74
│   │   │   ├── 76
│   │   │   ├── 79
│   │   │   ├── 7a
│   │   │   ├── 7b
│   │   │   ├── 7c
│   │   │   ├── 7d
│   │   │   ├── 7e
│   │   │   ├── 7f
│   │   │   ├── 81
│   │   │   ├── 83
│   │   │   ├── 85
│   │   │   ├── 87
│   │   │   ├── 88
│   │   │   ├── 8a
│   │   │   ├── 8d
│   │   │   ├── 8e
│   │   │   ├── 8f
│   │   │   ├── 92
│   │   │   ├── 93
│   │   │   ├── 95
│   │   │   ├── 97
│   │   │   ├── 98
│   │   │   ├── 9a
│   │   │   ├── 9b
│   │   │   ├── 9c
│   │   │   ├── 9e
│   │   │   ├── 9f
│   │   │   ├── a0
│   │   │   ├── a1
│   │   │   ├── a2
│   │   │   ├── a3
│   │   │   ├── a4
│   │   │   ├── a5
│   │   │   ├── a9
│   │   │   ├── aa
│   │   │   ├── ab
│   │   │   ├── ad
│   │   │   ├── ae
│   │   │   ├── b0
│   │   │   ├── b1
│   │   │   ├── b3
│   │   │   ├── b4
│   │   │   ├── b6
│   │   │   ├── b7
│   │   │   ├── b8
│   │   │   ├── b9
│   │   │   ├── ba
│   │   │   ├── bc
│   │   │   ├── bd
│   │   │   ├── be
│   │   │   ├── c0
│   │   │   ├── c1
│   │   │   ├── c2
│   │   │   ├── c3
│   │   │   ├── c4
│   │   │   ├── c5
│   │   │   ├── c7
│   │   │   ├── c8
│   │   │   ├── c9
│   │   │   ├── cb
│   │   │   ├── cc
│   │   │   ├── cf
│   │   │   ├── d2
│   │   │   ├── d5
│   │   │   ├── d6
│   │   │   ├── d7
│   │   │   ├── d8
│   │   │   ├── d9
│   │   │   ├── db
│   │   │   ├── dc
│   │   │   ├── dd
│   │   │   ├── df
│   │   │   ├── e0
│   │   │   ├── e4
│   │   │   ├── e6
│   │   │   ├── e7
│   │   │   ├── e8
│   │   │   ├── ea
│   │   │   ├── ec
│   │   │   ├── ee
│   │   │   ├── f0
│   │   │   ├── f1
│   │   │   ├── f2
│   │   │   ├── f4
│   │   │   ├── f5
│   │   │   ├── f7
│   │   │   ├── fa
│   │   │   ├── fb
│   │   │   ├── ff
│   │   │   ├── info
│   │   │   └── pack
│   │   ├── refs
│   │   │   ├── heads
│   │   │   ├── remotes
│   │   │   └── tags
│   │   ├── COMMIT_EDITMSG
│   │   ├── config
│   │   ├── description
│   │   ├── FETCH_HEAD
│   │   ├── HEAD
│   │   ├── index
│   │   ├── ORIG_HEAD
│   │   └── REBASE_HEAD
│   ├── .github
│   │   ├── workflows
│   │   │   └── ci.yml
│   │   └── workflows 2
│   ├── .selene
│   │   ├── roblox 2.toml
│   │   └── roblox.toml
│   ├── docs
│   │   ├── _legacy
│   │   ├── AI_Workflow.md
│   │   ├── ARCHITECTURE.md
│   │   ├── ASSET_PIPELINE.md
│   │   ├── CHANGELOG.md
│   │   ├── CLEANUP_REPORT.md
│   │   ├── CODEX_BASELINE.txt
│   │   ├── ECONOMY.md
│   │   ├── PROJECT_SCOPE.md
│   │   ├── README.md
│   │   ├── RECOVERY.md
│   │   ├── REFACTORING_GUIDE.md
│   │   ├── SETUP_GUIDE.md
│   │   └── STYLE.md
│   ├── src
│   │   ├── client
│   │   │   ├── .keep
│   │   │   ├── CommandUI.client.luau
│   │   │   ├── HatchFX.client.luau
│   │   │   └── Main.client.luau
│   │   ├── server
│   │   │   ├── modules
│   │   │   ├── tests
│   │   │   ├── world
│   │   │   ├── .DS_Store
│   │   │   ├── .keep
│   │   │   ├── 00_spawns_and_remotes.server.luau
│   │   │   ├── bootstrap.server.luau
│   │   │   ├── MissionService.server.luau
│   │   │   ├── Remotes.server.luau
│   │   │   ├── spawn_guard.server.luau
│   │   │   ├── Untitled spreadsheet.gsheet
│   │   │   └── zzz_server_banner.server.luau
│   │   ├── server_modules
│   │   │   ├── .keep
│   │   │   ├── RemoteSetup 2.luau
│   │   │   └── RemoteSetup.luau
│   │   ├── shared
│   │   │   ├── config
│   │   │   └── .keep
│   │   └── .DS_Store
│   ├── .DS_Store
│   ├── .gitignore
│   ├── default.project.json
│   ├── robot-collectors-new-V1.rbxlx
│   ├── robot-collectors-new-V1.rbxlx.lock
│   ├── selene.toml
│   ├── sourcemap.json
│   ├── stylua.toml
│   └── world.rbxm
├── tools
│   ├── cleanup_project.py
│   └── scan_project.py
├── .DS_Store
├── AGENTS.local.md
├── LICENSE
└── README.md
```
