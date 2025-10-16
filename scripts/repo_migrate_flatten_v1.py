#!/usr/bin/env python3
"""Flatten the `robot-collectors-new-V1` folder into the repo root (dry-run first)."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import shutil
import subprocess
import sys
import textwrap
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Tuple

try:
    from _util_rojo import load_rojo, save_rojo, rewrite_paths
except ImportError:  # pragma: no cover - allow running before module exists in PYTHONPATH
    sys.path.append(str(Path(__file__).resolve().parent))
    from _util_rojo import load_rojo, save_rojo, rewrite_paths


DRY_RUN_BANNER = """\
⚙️  Repo Migration – Flatten V1 (DRY-RUN)
----------------------------------------
This script analyses the migration of `robot-collectors-new-V1` into the repo root.
No files will be modified unless you pass --apply.
"""

APPLY_BANNER = """\
⚙️  Repo Migration – Flatten V1 (APPLY)
--------------------------------------
This will MOVE / MERGE files from `robot-collectors-new-V1` into the repo root.
Backups are stored in old_backups/. Continue only if you have reviewed the dry-run.
"""

TEXT_EXTENSIONS = {
    ".luau",
    ".lua",
    ".json",
    ".md",
    ".ts",
    ".js",
    ".toml",
    ".yml",
    ".yaml",
    ".sh",
    ".bat",
    ".txt",
    ".csv",
}


@dataclass
class FilePlan:
    rel_path: str
    source: Path
    target: Path
    action: str  # move | skip-duplicate | conflict
    reason: str = ""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Execute the migration (default: dry-run)")
    parser.add_argument("--v1-name", default="robot-collectors-new-V1", help="Name of the V1 folder at repo root")
    parser.add_argument(
        "--max-patch-bytes",
        type=int,
        default=5_000_000,
        help="Skip reference patching for files larger than this (bytes)",
    )
    parser.add_argument(
        "--no-ref-patch",
        action="store_true",
        help="Do not patch string references (still reported)",
    )
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


def detect_git_root(start: Path) -> Path:
    current = start
    for parent in [current, *current.parents]:
        if (parent / ".git").is_dir():
            return parent
    raise RuntimeError("Could not locate .git directory above script location.")


def run_git(args: Sequence[str], cwd: Path) -> Tuple[int, str, str]:
    proc = subprocess.run(
        ["git", *args],
        cwd=str(cwd),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return proc.returncode, proc.stdout, proc.stderr


def file_inventory(root: Path) -> List[Dict[str, str]]:
    code, out, _ = run_git(["ls-files", "-co", "--exclude-standard"], root)
    paths: List[Path]
    if code == 0:
        paths = [root / line.strip() for line in out.splitlines() if line.strip()]
    else:
        paths = [p for p in root.rglob("*") if p.is_file() and ".git" not in p.parts]
    manifest = []
    for path in paths:
        rel = path.relative_to(root).as_posix()
        try:
            size = path.stat().st_size
        except OSError:
            size = -1
        manifest.append({"path": rel, "size": size})
    manifest.sort(key=lambda x: x["path"])
    return manifest


def write_manifest_files(manifest: List[Dict[str, str]], out_dir: Path, prefix: str) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    json_path = out_dir / f"manifest_{prefix}.json"
    md_path = out_dir / f"manifest_{prefix}.md"
    csv_path = out_dir / f"files_{prefix}.csv"

    with json_path.open("w", encoding="utf-8") as fp:
        json.dump(manifest, fp, indent=2)
        fp.write("\n")

    with md_path.open("w", encoding="utf-8") as fp:
        fp.write(f"# File Manifest ({prefix})\n\n")
        fp.write("| Path | Size |\n| --- | --- |\n")
        for item in manifest:
            fp.write(f"| `{item['path']}` | {item['size']} |\n")

    with csv_path.open("w", encoding="utf-8", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=["path", "size"])
        writer.writeheader()
        writer.writerows(manifest)


def sha1(path: Path) -> str:
    h = hashlib.sha1()
    with path.open("rb") as fp:
        for chunk in iter(lambda: fp.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def collect_v1_files(v1_root: Path) -> List[Path]:
    files = []
    for path in v1_root.rglob("*"):
        if ".git" in path.parts or "old_backups" in path.parts or "out" in path.parts:
            continue
        if path.is_file():
            files.append(path)
    files.sort()
    return files


def make_plan(root: Path, v1_root: Path) -> List[FilePlan]:
    plan: List[FilePlan] = []
    for src in collect_v1_files(v1_root):
        rel = src.relative_to(v1_root).as_posix()
        dest = root / rel
        if dest.exists():
            try:
                if sha1(src) == sha1(dest):
                    plan.append(FilePlan(rel, src, dest, "skip-duplicate", "Identical content"))
                else:
                    backup = root / "old_backups" / "V1_conflicts" / rel
                    plan.append(FilePlan(rel, src, backup, "conflict", f"Conflict with {dest.relative_to(root)}"))
            except OSError as exc:
                plan.append(FilePlan(rel, src, dest, "error", f"hash error: {exc}"))
        else:
            plan.append(FilePlan(rel, src, dest, "move"))
    return plan


def list_rojo_files(root: Path) -> List[Path]:
    candidates = [root / "default.project.json"]
    candidates.extend(root.glob("*.project.json"))
    unique = []
    seen = set()
    for path in candidates:
        if path.exists() and path not in seen:
            unique.append(path)
            seen.add(path)
    return unique


def patch_rojo_files(rojo_files: List[Path], *, dry_run: bool, out_dir: Path, prefix: str) -> Tuple[int, List[Path]]:
    changed_total = 0
    updated_files: List[Path] = []
    preview_dir = out_dir / "rojo_preview"
    for file in rojo_files:
        try:
            data = load_rojo(file)
        except Exception as exc:  # noqa: BLE001
            print(f"[WARN] Failed to load {file}: {exc}")
            continue
        changed, new_obj = rewrite_paths(data, prefix=prefix)
        if changed:
            changed_total += changed
            updated_files.append(file)
            save_rojo(file, new_obj, dry_run=dry_run, preview_dir=preview_dir)
    return changed_total, updated_files


def is_binary(path: Path, max_check: int = 2048) -> bool:
    try:
        with path.open("rb") as fp:
            chunk = fp.read(max_check)
            if b"\0" in chunk:
                return True
    except OSError:
        return True
    return False


def gather_reference_files(root: Path) -> List[Path]:
    files = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in path.parts for part in (".git", "old_backups", "out")):
            continue
        if path.suffix.lower() in TEXT_EXTENSIONS:
            files.append(path)
    files.sort()
    return files


def patch_references(
    files: List[Path],
    *,
    dry_run: bool,
    out_dir: Path,
    max_bytes: int,
    prefix: str,
    apply_changes: bool,
) -> Tuple[int, List[str]]:
    patch_dir = out_dir / "patch_preview"
    patched_files: List[str] = []
    prefix_str = prefix
    for path in files:
        try:
            if path.stat().st_size > max_bytes:
                continue
        except OSError:
            continue
        if is_binary(path):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if prefix_str not in text:
            continue
        new_text = text.replace(prefix_str, "")
        if new_text == text:
            continue
        patched_files.append(path.relative_to(path.anchor if path.is_absolute() else Path(".")).as_posix())
        if dry_run or not apply_changes:
            patch_dir.mkdir(parents=True, exist_ok=True)
            diff_path = patch_dir / (path.relative_to(path.anchor if path.is_absolute() else Path(".")).as_posix().replace("/", "_") + ".diff")
            diff_path.parent.mkdir(parents=True, exist_ok=True)
            diff = "".join(
                textwrap.dedent("\n").join(
                    __import__("difflib").unified_diff(
                        text.splitlines(),
                        new_text.splitlines(),
                        fromfile=str(path),
                        tofile=str(path),
                        lineterm="",
                    )
                )
            )
            if not diff:
                diff = "(no diff computed)"
            diff_path.write_text(diff, encoding="utf-8")
        else:
            path.write_text(new_text, encoding="utf-8")
    return len(patched_files), patched_files


def execute_plan(plan: List[FilePlan], *, root: Path, v1_root: Path, apply: bool) -> Dict[str, int]:
    stats = {"moved": 0, "duplicates": 0, "conflicts": 0}
    if not apply:
        return stats

    timestamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    snapshot_dir = root / "old_backups" / f"V1_snapshot_{timestamp}"
    snapshot_dir.parent.mkdir(parents=True, exist_ok=True)
    if snapshot_dir.exists():
        raise RuntimeError(f"Snapshot directory already exists: {snapshot_dir}")
    shutil.copytree(v1_root, snapshot_dir)
    conflicts_dir = root / "old_backups" / "V1_conflicts"

    for item in plan:
        if item.action == "error":
            continue
        if item.action == "skip-duplicate":
            stats["duplicates"] += 1
            continue
        if item.action == "conflict":
            stats["conflicts"] += 1
            target = item.target
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item.source, target)
            continue
        # Regular move
        target = item.target
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(item.source), str(target))
        stats["moved"] += 1

    # Remove empty directories left behind
    try:
        for dirpath, dirnames, filenames in os.walk(v1_root, topdown=False):
            if not dirnames and not filenames:
                Path(dirpath).rmdir()
        if not any(v1_root.iterdir()):
            v1_root.rmdir()
    except OSError:
        pass
    return stats


def write_report(
    out_dir: Path,
    plan: List[FilePlan],
    *,
    rojo_updates: List[Path],
    rojo_changed_count: int,
    ref_patched_count: int,
    ref_files: List[str],
    apply_stats: Dict[str, int],
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    report_path = out_dir / "MIGRATION_REPORT.md"
    conflicts = [p for p in plan if p.action == "conflict"]
    duplicates = [p for p in plan if p.action == "skip-duplicate"]
    moves = [p for p in plan if p.action == "move"]

    report = [
        "# Migration Report – Flatten V1\n",
        "## Summary\n",
        f"- Files to move: {len(moves)}\n",
        f"- Duplicate files skipped: {len(duplicates)}\n",
        f"- Conflicts to backup: {len(conflicts)}\n",
        f"- Rojo files updated: {len(rojo_updates)} (paths rewritten: {rojo_changed_count})\n",
        f"- Reference patches: {ref_patched_count}\n",
        "",
        "## Conflicts (V1 kept in `old_backups/V1_conflicts/`)\n",
    ]
    if conflicts:
        report.append("| Original V1 Path | Existing Root Path | Backup Location |\n| --- | --- | --- |\n")
        for item in conflicts:
            report.append(
                f"| `{item.rel_path}` | `{item.target.relative_to(item.target.parent.parent.parent) if item.target.exists() else 'existing root file'}` | `{item.target}` |\n"
            )
    else:
        report.append("_None_\n")

    report.append("\n## Duplicate Files (identical content)\n")
    if duplicates:
        report.append("| Path |\n| --- |\n")
        for item in duplicates:
            report.append(f"| `{item.rel_path}` |\n")
    else:
        report.append("_None_\n")

    report.append("\n## Rojo Files Updated\n")
    if rojo_updates:
        for path in rojo_updates:
            report.append(f"- `{path}`\n")
    else:
        report.append("_None_\n")

    report.append("\n## Reference Patches\n")
    if ref_files:
        for path in ref_files:
            report.append(f"- `{path}`\n")
    else:
        report.append("_None_\n")

    report.append(
        textwrap.dedent(
            """
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
            """
        )
    )

    report_path.write_text("".join(report), encoding="utf-8")


def main() -> None:
    args = parse_args()
    banner = APPLY_BANNER if args.apply else DRY_RUN_BANNER
    print(banner)

    script_path = Path(__file__).resolve()
    root = detect_git_root(script_path.parent)
    v1_root = root / args.v1_name
    if not v1_root.exists():
        print(f"[ERROR] V1 folder not found: {v1_root}")
        sys.exit(1)

    out_dir = root / "out"
    out_dir.mkdir(parents=True, exist_ok=True)

    manifest_before = file_inventory(root)
    write_manifest_files(manifest_before, out_dir, "before")

    plan = make_plan(root, v1_root)
    rojo_files = list_rojo_files(root)
    rojo_changed_count, rojo_updates = patch_rojo_files(
        rojo_files,
        dry_run=not args.apply,
        out_dir=out_dir,
        prefix=f"{args.v1_name}/",
    )

    ref_files = gather_reference_files(root)
    ref_patched_count, ref_patched_list = patch_references(
        ref_files,
        dry_run=not args.apply,
        out_dir=out_dir,
        max_bytes=args.max_patch_bytes,
        prefix=f"{args.v1_name}/",
        apply_changes=not args.no_ref_patch and args.apply,
    )

    stats = execute_plan(plan, root=root, v1_root=v1_root, apply=args.apply)

    manifest_after = file_inventory(root)
    write_manifest_files(manifest_after, out_dir, "after")

    write_report(
        out_dir,
        plan,
        rojo_updates=rojo_updates,
        rojo_changed_count=rojo_changed_count,
        ref_patched_count=ref_patched_count,
        ref_files=ref_patched_list,
        apply_stats=stats,
    )

    print("\nMigration summary:")
    print(f"  Files planned: {len(plan)} (move={sum(1 for p in plan if p.action == 'move')}, duplicates={sum(1 for p in plan if p.action == 'skip-duplicate')}, conflicts={sum(1 for p in plan if p.action == 'conflict')})")
    print(f"  Rojo files touched: {len(rojo_updates)} (rewritten paths={rojo_changed_count})")
    print(f"  Reference patches: {ref_patched_count}")
    if args.apply:
        print(f"  Moved: {stats['moved']} | Duplicates skipped: {stats['duplicates']} | Conflicts archived: {stats['conflicts']}")
        print("\n[APPLY COMPLETE] Review `out/MIGRATION_REPORT.md` and run Rojo/Studio.")
    else:
        print("\n[DRY-RUN] Review previews in `out/` and run with --apply when ready.")

    print(
        textwrap.dedent(
            """
            Next commands:
              DRY-RUN:  python3 scripts/repo_migrate_flatten_v1.py
              APPLY:    python3 scripts/repo_migrate_flatten_v1.py --apply
              VSCode:   Terminal → Run Task → “Migrate (APPLY)”
              After applying, run Rojo and open Studio to validate.
            """
        ).strip()
    )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[ABORTED] Migration interrupted by user.")
        sys.exit(1)
    except Exception as exc:  # noqa: BLE001
        print(f"[FATAL] {exc}")
        sys.exit(1)

