# AI / Dev Workflow (Robot Collectors)

**Source of truth:** files on disk in this repo.  
**Design & reasoning:** ChatGPT (this doc, specs, prompts).  
**Writes:** Codex CLI (one file per prompt, with VERIFY).

## Golden rules
1. Open a **new Codex session** for every set of edits. Never `resume` old ones.
2. **One file per prompt.** Overwrite exact content; include a VERIFY block to echo head.
3. After a working change: **git add/commit** (“checkpoint”).
4. Rojo: keep **all code** under `robot-collectors-new-V1/src/...`. JSON map must match.
5. Runtime proofs: every server build **prints a banner** + geometry proofs.

## Apply order for world features
- `WorldBoot.run()` → `Spawn.ensure()` → `Garage.Mount(spec)` (or other components)

## Debug loop
- Check Output: build counts, proofs.
- Use `ON_PLANE` probe (in docs) to list any part on the door plane.
- Post the exact log/path into ChatGPT; implement the **one-line fix** via Codex.
