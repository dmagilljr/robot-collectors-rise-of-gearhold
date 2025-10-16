

# RECOVERY PLAYBOOK — v0.6.0-alpha World Expansion

> **Purpose:** Provide a quick way to restore, verify, and test the last known working build (`v0.6.0-alpha-world-ready`).

---

## 1) Golden Tag (Known-Good State)
- **Tag Name:** `v0.6.0-alpha-world-ready`
- **Commit Message:** `World expansion + resource system ready`

**Command to tag the current state:**
```bash
git add -A
git commit -m "World expansion + resource system ready"
git tag -a v0.6.0-alpha-world-ready -m "Golden working state"
git push && git push --tags
```

**Rollback to tag:**
```bash
git checkout v0.6.0-alpha-world-ready
```

---

## 2) Manual Smoke Test (45 seconds)
**Goal:** Confirm core functionality works after any merge or restore.

1. Launch Studio.
2. Verify `Output` shows:
   - `[bootstrap] running WorldBoot.run()`
   - `[WorldBoot ACTIVE]`
   - `[TerrainLoader] Plaza anchors ready`
   - `[ZoneTrigger] Registered`
   - `[WorldInteract] Resource prompts initialized`
   - `[ResourceService] Initialized`
   - `[Remotes] ensured RC_Remotes with OpenCommandUI, HatchRobot, HatchFX`
3. Walk to garage door → auto open.
4. Confirm no floor overhang behind the back wall.
5. Collect from a nearby `ScrapPile_*` or `EnergyCrystal_*`; HUD should increment immediately.
6. Interact with console:
   - Hatch menu opens → click “Hatch Robot.”
   - Menu closes immediately.
   - Hatch ceremony runs:
     - Pre-flash → Beam on → Rings brighten → Billboard scan ring → Capsule dissolve → Robot appears → Robot slides down ramp → Beam off → Banner.
7. Use the deposit terminal (or `DepositAll` trigger) → HUD resets to zero and `Output` prints deposit summary.
8. Verify no red errors in `Output`.

✅ **If all pass:** safe to proceed to next version tag.

❌ **If any fail:** rollback using tag command above.

---

## 3) Feature Flags & Attributes
| Location | Attribute | Default | Description |
|-----------|------------|----------|--------------|
| `ServerScriptService/World/Garage` | `FORCE_FIXUP` | false | Visual alignment pass (dev only) |
| `ServerScriptService/World/Garage` | `DEV_TRACE` | false | Verbose console logging (dev only) |
| `workspace/.../GD_SpawnPad` | `LaserEnabled` | false | Toggles beam during hatch ceremony |

---

## 4) Quick File Integrity Check
| Expected Path | Description |
|----------------|-------------|
| `ServerScriptService/World/Garage/Component.luau` | Builds garage shell, façade, and floor |
| `ServerScriptService/World/Garage/Interior.luau` | Spawns console, lockers, and spawn pad |
| `ServerScriptService/World/Garage/Shows/Hatch.luau` | Handles ceremony (beam, ring, capsule, bot) |
| `ServerScriptService/World/TerrainLoader.server.luau` | Mounts plaza, anchors, and paths |
| `ServerScriptService/World/ZoneTrigger.server.luau` | Emits ZoneChanged events when players move |
| `ServerScriptService/World/WorldInteract.server.luau` | Attaches prompts to Scrap/Energy props |
| `ServerScriptService/Server/services/ResourceService.server.luau` | Tracks Scrap/Energy and handles DepositAll |
| `ReplicatedStorage/Shared/ResourceDefs.luau` | Resource type metadata |
| `ServerScriptService/Remotes.server.luau` | Wires RC_Remotes and triggers HatchShow |
| `StarterPlayer/StarterPlayerScripts/CommandUI.client.luau` | Handles console open/close and hatch trigger |
| `StarterPlayer/StarterPlayerScripts/ui/ResourceHUD.client.luau` | Displays resource totals |
| `StarterPlayer/StarterPlayerScripts/ui/ZoneToast.client.luau` | Shows zone entry toast |
| `StarterPlayer/StarterPlayerScripts/ui/ZoneSFX.client.luau` | Manages ambient zone audio |

---

## 5) Common Failure Modes
| Symptom | Likely Cause | Fix |
|----------|---------------|-----|
| UI doesn’t close when hatching | Missing client listener for `CloseCommandUI` | Re‑check client script listener |
| Ceremony doesn’t play | `HatchShow` require path incorrect or not saved | Confirm file exists at `/Shows/Hatch.luau` and ends with `return HatchShow` |
| Beam not visible | `LaserEnabled` not toggled | Ensure HatchShow toggles attribute at start/end |
| Rings square / flicker | Old Cylinder hoop still active | Ensure BillboardGui scanner replaced correctly |
| Missing interior | Interior error stops mount | Check `Output` for `[Garage.Component] Interior.Mount failed` |
| Missing WorldZones | `TerrainLoader.server.luau` not running or mis-mapped | Ensure script under `ServerScriptService/World`, restart server, verify `workspace/WorldZones` |
| Duplicate World Scripts | `default.project.json` double-maps `src/server/world` | Add `"world": { "$ignore": true }` inside the Server mapping and re-sync |
| ZoneTrigger error (`OnClientEvent`) | Legacy `OnClientEvent` wiring used on server | Update to `:FireClient`, re-publish, restart Rojo |

---

## 6) Smoke Test Script (Optional)
```lua
-- ServerScriptService/World/tests/Smoke.server.luau
--!strict
local ok = true
local SSS = game:GetService("ServerScriptService")
local garageFolder = SSS:FindFirstChild("World") and SSS.World:FindFirstChild("Garage")

local function has(path)
	return garageFolder and garageFolder:FindFirstChild(path, true)
end

ok = ok and has("Shows/Hatch")
ok = ok and has("Interior")
ok = ok and has("Component")

if ok then
	print("[SMOKE] Garage structure OK")
else
	warn("[SMOKE] Garage structure MISSING pieces")
end
```

---

## 7) Versioning Discipline
| Step | Action |
|------|--------|
| 1 | After every verified build → commit & tag (e.g., `v0.6.0-alpha-world-ready`) |
| 2 | Log changes in `CHANGELOG.md` |
| 3 | Update `ARCHITECTURE.md` if folder structure or system behavior changes |
| 4 | Run smoke test before merging new features |

---

## 8) Golden State Checklist
- [x] Garage shell & façade intact
- [x] Floor flush with back wall
- [x] Console prompt → closes instantly
- [x] Hatch ceremony runs full sequence
- [x] Resource HUD updates when collecting + depositing
- [x] Zone toast/SFX trigger when crossing anchors
- [x] No red errors in Output
- [x] Tag pushed to remote (`v0.6.0-alpha-world-ready`)

---

**End of Recovery Playbook**
