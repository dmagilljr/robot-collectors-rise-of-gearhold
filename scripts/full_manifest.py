#!/usr/bin/env python3
"""Full project inventory + Rojo sync map audit for ROBOT_COLLECTORS.

Enhancements:
- Detect duplicate files by SHA-1 (with safe primary selection).
- Detect files/folders "unused" by Rojo mapping (heuristic).
- Optional `--apply` mode to move unused/duplicate *redundant* files to a trash folder (not permanent delete).
- Richer Markdown/CSV/JSON reports describing actions.

Usage:
  python3 scripts/full_manifest.py                # dry-run, writes reports only
  python3 scripts/full_manifest.py --apply        # move unused/redundant files to out/.trash_YYYYmmddHHMMSS
  python3 scripts/full_manifest.py --root /path   # override detected repo root
"""

from __future__ import annotations
import argparse
import csv
import hashlib
import json
import os
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Iterable

# ----------------------------
# CLI / Globals
# ----------------------------

def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description="Full repo manifest + cleanup planner")
    ap.add_argument("--apply", action="store_true",
                    help="Move redundant/unused files to a trash folder (safe, reversible).")
    ap.add_argument("--root", type=str, default=None,
                    help="Override repo root (by default, auto-detect via nearest .git).")
    ap.add_argument("--trash", type=str, default=None,
                    help="Optional explicit trash directory (defaults to out/.trash_TIMESTAMP).")
    ap.add_argument("--include", action="append", default=[],
                    help="Additional roots considered 'used' (prefix match), repeatable. e.g. --include scripts --include docs")
    ap.add_argument("--verbose", "-v", action="count", default=0,
                    help="Increase logging verbosity.")
    ap.add_argument("--keep", type=int, default=3,
                    help="Keep N most-recent timestamped manifest_* report sets (json/csv/md); delete older ones in out/.")
    ap.add_argument("--prune-trash-days", type=int, default=14,
                    help="Delete out/.trash_* folders older than this many days.")
    return ap.parse_args()

# ----------------------------
# Utilities
# ----------------------------

def detect_root(override: str | None = None) -> Path:
    if override:
        root = Path(override).resolve()
        if not root.exists():
            raise SystemExit(f"❌ --root path does not exist: {root}")
        return root
    p = Path(__file__).resolve()
    for parent in [p] + list(p.parents):
        if (parent / ".git").exists():
            return parent
    raise SystemExit("❌ Could not find repo root (.git)")

def sha1(path: Path) -> str:
    h = hashlib.sha1()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

@dataclass
class FileRec:
    path: str
    size: int
    sha1: str
    ext: str

# ----------------------------
# Inventory
# ----------------------------

SKIP_DIR_NAMES = {".git", "old_backups", "out", ".trash", ".rojo"}
SKIP_FILE_EXTS = {".lock", ".DS_Store"}

def gather_files(root: Path) -> List[FileRec]:
    files: List[FileRec] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in SKIP_DIR_NAMES for part in path.parts):
            continue
        if path.suffix in SKIP_FILE_EXTS:
            continue
        try:
            size = path.stat().st_size
            hashv = sha1(path) if size > 0 else "0"  # zero-byte group separately
        except OSError:
            size = -1
            hashv = "ERR"
        files.append(FileRec(
            path=path.relative_to(root).as_posix(),
            size=size,
            sha1=hashv,
            ext=path.suffix.lower(),
        ))
    files.sort(key=lambda r: r.path)
    return files

# ----------------------------
# Rojo mapping (what's considered "used")
# ----------------------------

def load_rojo_map(root: Path) -> Dict[str, str]:
    """Return { localPathPrefix : targetDescriptor } from default.project.json"""
    p = root / "default.project.json"
    if not p.exists():
        return {}
    try:
        data = json.loads(p.read_text())
    except Exception as e:
        print(f"[WARN] failed to read default.project.json: {e}")
        return {}
    out: Dict[str, str] = {}

    def walk(node: dict):
        if not isinstance(node, dict):
            return
        for _, v in node.items():
            if isinstance(v, dict):
                path = v.get("path")
                tgt = v.get("target")
                name = v.get("name")
                if path:
                    dm = f"{tgt}/{name}" if tgt and name else tgt or name or ""
                    out[path] = dm
                if "tree" in v:
                    walk(v["tree"])

    walk(data.get("tree", {}))
    return out

def is_used(path: str, used_prefixes: Iterable[str]) -> bool:
    # Prefix match against any mapped path or user-includes
    return any(path.startswith(prefix.rstrip("/") + "/") or path == prefix.rstrip("/")
               for prefix in used_prefixes)

# ----------------------------
# Duplicate + Unused analysis
# ----------------------------

def group_by_sha(files: List[FileRec]) -> Dict[str, List[FileRec]]:
    d: Dict[str, List[FileRec]] = {}
    for f in files:
        d.setdefault(f.sha1, []).append(f)
    return d

def choose_primary(candidates: List[FileRec]) -> FileRec:
    """Choose a primary to keep among duplicates; prefer NOT under 'robot-collectors-new-V1',
    then shortest path, then smallest size (though equal by sha1)."""
    def score(rec: FileRec) -> Tuple[int, int, int]:
        s1 = 0 if "robot-collectors-new-V1" not in rec.path else 1
        s2 = len(rec.path)  # shorter is better
        s3 = rec.size
        return (s1, s2, s3)
    return sorted(candidates, key=score)[0]

def plan_cleanup(files: List[FileRec], rojo_map: Dict[str, str], user_includes: List[str]) -> Tuple[List[FileRec], List[FileRec], Dict[str, List[FileRec]]]:
    """
    Returns:
      - unused_files: not mapped by Rojo nor user-includes
      - redundant_dupes: duplicates we can safely remove (keep one primary)
      - dup_groups: map sha1 -> list (for reporting)
    """
    used_prefixes = set(rojo_map.keys()) | set(user_includes)

    # Unused = not under any used prefix
    unused_files = [f for f in files if not is_used(f.path, used_prefixes)]

    # Duplicates
    dup_groups = {h: recs for h, recs in group_by_sha(files).items() if len(recs) > 1 and h not in {"ERR", "0"}}
    redundant: List[FileRec] = []
    for _, group in dup_groups.items():
        primary = choose_primary(group)
        for rec in group:
            if rec is primary:
                continue
            # Mark as redundant if (a) not used OR (b) duplicate copy lives under undesired folder
            if (rec.path != primary.path) and ("robot-collectors-new-V1" in rec.path or not is_used(rec.path, used_prefixes)):
                redundant.append(rec)

    # Remove duplicates that are ALSO in unused_files (dedupe list for output)
    redundant_set = {r.path for r in redundant}
    redundant_dupes = [f for f in files if f.path in redundant_set]

    return unused_files, redundant_dupes, dup_groups

# ----------------------------
# Apply (move to trash)
# ----------------------------

def ensure_trash(root: Path, explicit: str | None) -> Path:
    if explicit:
        t = Path(explicit).resolve()
    else:
        ts = datetime.utcnow().strftime("%Y%m%d%H%M%S")
        t = root / "out" / f".trash_{ts}"
    t.mkdir(parents=True, exist_ok=True)
    return t

def move_to_trash(root: Path, trash: Path, relpath: str, verbose: int = 0):
    src = root / relpath
    if not src.exists():
        return
    dst = trash / relpath
    dst.parent.mkdir(parents=True, exist_ok=True)
    if verbose:
        print(f"[MOVE] {src} -> {dst}")
    shutil.move(str(src), str(dst))

def remove_empty_dirs(root: Path, start: Path, verbose: int = 0):
    # Walk from start upward, removing empty dirs within repo
    for path in sorted(start.rglob("*"), key=lambda p: len(str(p)), reverse=True):
        if path.is_dir():
            try:
                path.rmdir()
                if verbose:
                    print(f"[RMDIR] {path}")
            except OSError:
                pass


# ----------------------------
# Output Cleaning
# ----------------------------

def clean_out(root: Path, keep: int = 3, prune_trash_days: int = 14, verbose: int = 0):
    """Housekeeping for the out/ folder.
    - Keep only the most-recent `keep` timestamped manifest_* report sets (json/csv/md).
    - Remove older timestamped sets.
    - Prune .trash_* folders older than `prune_trash_days` days.
    - Remove any zero-byte files left behind by previous runs.
    """
    out_dir = root / "out"
    if not out_dir.exists():
        return

    # 1) Group timestamped manifest sets by their base (manifest_YYYY-mm-dd_HH-MM-SS)
    # Collect all files that match that pattern.
    manifest_files = sorted(out_dir.glob("manifest_*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    # Determine bases to keep
    keep_bases = set()
    for mf in manifest_files[:max(keep, 0)]:
        base = mf.stem  # e.g., manifest_2025-10-16_17-26-25
        keep_bases.add(base)
    # Anything beyond the keep window gets deleted across extensions
    to_delete: List[Path] = []
    for mf in manifest_files[max(keep, 0):]:
        base = mf.stem
        for ext in (".json", ".csv", ".md"):
            cand = out_dir / f"{base}{ext}"
            if cand.exists():
                to_delete.append(cand)
    # Execute deletes
    for p in to_delete:
        try:
            if verbose:
                print(f"[CLEAN] remove {p}")
            p.unlink(missing_ok=True)
        except Exception as e:
            print(f"[WARN] failed to remove {p}: {e}")

    # 2) Prune .trash_* folders older than prune_trash_days
    from datetime import timedelta
    cutoff = datetime.utcnow() - timedelta(days=max(prune_trash_days, 0))
    for d in out_dir.glob(".trash_*"):
        if not d.is_dir():
            continue
        # Try to parse timestamp from folder name
        ts_str = d.name.replace(".trash_", "")
        dt = None
        for fmt in ("%Y%m%d%H%M%S",):
            try:
                dt = datetime.strptime(ts_str, fmt)
                break
            except ValueError:
                dt = None
        # Fall back to mtime if parsing fails
        if dt is None:
            dt = datetime.utcfromtimestamp(d.stat().st_mtime)
        if dt < cutoff:
            try:
                if verbose:
                    print(f"[CLEAN] prune {d}")
                shutil.rmtree(d)
            except Exception as e:
                print(f"[WARN] failed to prune {d}: {e}")

    # 3) Remove zero-byte files left behind
    for p in out_dir.glob("**/*"):
        if p.is_file():
            try:
                if p.stat().st_size == 0:
                    if verbose:
                        print(f"[CLEAN] remove zero-byte {p}")
                    p.unlink(missing_ok=True)
            except FileNotFoundError:
                pass

# ----------------------------
# Reporting
# ----------------------------

def write_outputs(root: Path,
                  manifest: List[FileRec],
                  rojo_map: Dict[str, str],
                  unused: List[FileRec],
                  redundant_dupes: List[FileRec],
                  dup_groups: Dict[str, List[FileRec]],
                  keep: int,
                  prune_trash_days: int,
                  verbose: int):
    out_dir = root / "out"
    out_dir.mkdir(exist_ok=True)
    timestamp = datetime.utcnow().strftime("%Y-%m-%d_%H-%M-%S")
    json_path = out_dir / f"manifest_{timestamp}.json"
    md_path = out_dir / f"manifest_{timestamp}.md"
    csv_path = out_dir / f"manifest_{timestamp}.csv"

    # JSON manifest
    json.dump([rec.__dict__ for rec in manifest], open(json_path, "w"), indent=2)

    # CSV manifest
    with open(csv_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["path", "size", "sha1", "ext"])
        w.writeheader()
        for rec in manifest:
            w.writerow(rec.__dict__)

    # Markdown summary
    total = len(manifest)
    approx_used = sum(1 for f in manifest for prefix in rojo_map.keys() if f.path.startswith(prefix))
    lines = [
        f"# Project Manifest ({timestamp})",
        f"- Total files: **{total}**",
        f"- Approx synced by Rojo: **{approx_used}**",
        f"- Unused (candidate for removal): **{len(unused)}**",
        f"- Duplicate groups: **{len(dup_groups)}** (redundant files: **{len(redundant_dupes)}**)",
        "",
        "## Top 30 Unused (examples)",
        "| Path | Size |",
        "| --- | ---: |",
    ]
    for rec in unused[:30]:
        lines.append(f"| `{rec.path}` | {rec.size:,} |")

    lines += [
        "",
        "## Duplicate Groups (first 10)",
        "",
    ]
    for i, (h, group) in enumerate(list(dup_groups.items())[:10], start=1):
        lines.append(f"### Group {i} — sha1 `{h}` ({len(group)} files)")
        for rec in group:
            lines.append(f"- `{rec.path}` ({rec.size:,} bytes)")
        lines.append("")

    md_path.write_text("\n".join(lines))
    print(f"✅ Reports written to {out_dir}")
    clean_out(root, keep=keep, prune_trash_days=prune_trash_days, verbose=verbose)

# ----------------------------
# Main
# ----------------------------

def main():
    args = parse_args()
    root = detect_root(args.root)
    if args.verbose:
        print(f"📂 Auditing repo: {root}")

    # Gather files + map
    manifest = gather_files(root)
    rojo_map = load_rojo_map(root)

    # Build list of used prefixes
    used_prefixes = set(rojo_map.keys()) | set(args.include or [])

    # Plan
    unused, redundant_dupes, dup_groups = plan_cleanup(manifest, rojo_map, list(used_prefixes))

    # Apply?
    if args.apply:
        trash_dir = ensure_trash(root, args.trash)
        print(f"🗑️  APPLY mode: moving files to trash at {trash_dir}")
        moved_paths = set()

        def move_list(lst: List[FileRec], label: str):
            print(f" - Moving {len(lst)} {label}…")
            for rec in lst:
                if rec.path in moved_paths:
                    continue
                move_to_trash(root, trash_dir, rec.path, verbose=args.verbose)
                moved_paths.add(rec.path)

        # First move redundant duplicate copies, then unused
        move_list(redundant_dupes, "redundant duplicate files")
        move_list(unused, "unused files")

        # Clean up now-empty directories
        remove_empty_dirs(root, root, verbose=args.verbose)
        print("✅ Apply complete (moved to trash).")

    # Always write reports
    write_outputs(
        root,
        manifest,
        rojo_map,
        unused,
        redundant_dupes,
        dup_groups,
        keep=args.keep,
        prune_trash_days=args.prune_trash_days,
        verbose=args.verbose,
    )

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)