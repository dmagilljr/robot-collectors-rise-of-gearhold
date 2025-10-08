# agents.md — Robot Collectors (robot-collectors-new-V1)

This file tells Codex exactly how to edit this repo. Keep it short and surgical.

## Model & Defaults
- Use **gpt-5-codex**.
- Reasoning: **medium** (raise to high for audits/refactors).
- Approvals: ask before writing or running commands.

## Editing Rules (must follow)
1. **One file per patch.** Do not “also” change other files.
2. **Force write + echo.** After every change, print the first 60 lines of the file.
3. **Idempotent.** Safe to apply the same patch multiple times.
4. **No interactive modes.** If an edit fails, return the error plainly.

## Rojo Map (robot-collectors-new-V1)
- `robot-collectors-new-V1/default.project.json`
- `ServerScriptService/Server`   ← `robot-collectors-new-V1/src/server`
- `ServerScriptService/Modules`  ← `robot-collectors-new-V1/src/server_modules`
- `ServerScriptService/World`    ← `robot-collectors-new-V1/src/server/world`
- `StarterPlayerScripts`         ← `robot-collectors-new-V1/src/client`

## Runtime Proofs
- Every server script edited must print a **banner** on boot:
  ```lua
  print("🏗️ <file> ACTIVE", os.time())
  ```
