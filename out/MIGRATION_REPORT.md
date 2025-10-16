# Migration Report – Flatten V1
## Summary
- Files to move: 84
- Duplicate files skipped: 0
- Conflicts to backup: 2
- Rojo files updated: 0 (paths rewritten: 0)
- Reference patches: 4
## Conflicts (V1 kept in `old_backups/V1_conflicts/`)
| Original V1 Path | Existing Root Path | Backup Location |
| --- | --- | --- |
| `.gitignore` | `old_backups/V1_conflicts/.gitignore` | `/Users/tmagill/Documents/Development/robot_collectors/old_backups/V1_conflicts/.gitignore` |
| `default.project.json` | `old_backups/V1_conflicts/default.project.json` | `/Users/tmagill/Documents/Development/robot_collectors/old_backups/V1_conflicts/default.project.json` |

## Duplicate Files (identical content)
_None_

## Rojo Files Updated
_None_

## Reference Patches
- `Users/tmagill/Documents/Development/robot_collectors/AGENTS.local.md`
- `Users/tmagill/Documents/Development/robot_collectors/robot-collectors-new-V1/docs/AI_Workflow.md`
- `Users/tmagill/Documents/Development/robot_collectors/robot-collectors-new-V1/docs/CLEANUP_ACTIONS.md`
- `Users/tmagill/Documents/Development/robot_collectors/robot-collectors-new-V1/docs/README.md`

## Next Steps
1. Review `out/` previews (manifests, patch previews, rojo previews).
2. Run the script with `--apply` once satisfied.
3. After applying:
   - Inspect `old_backups/V1_snapshot_<timestamp>/`.
   - Run `rojo sourcemap` or equivalent and open Studio.
   - Delete stale conflict backups once resolved.

## Rollback Instructions
```
git reset --hard
git clean -fd
```
or manually restore from `old_backups/V1_snapshot_<timestamp>/`.
