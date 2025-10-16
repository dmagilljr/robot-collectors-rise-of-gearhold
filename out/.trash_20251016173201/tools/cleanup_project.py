#!/usr/bin/env python3
"""
Project cleanup utility for Robot Collectors.

Usage:
    python3 tools/cleanup_project.py

The script is designed to run from the repository root
/Users/tmagill/Documents/Development/robot_collectors
and performs non-destructive consolidation of legacy folders,
while preparing the active project directory for Rojo + Git workflows.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from fnmatch import fnmatch
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


ROOT_EXPECTED_LIVE = "robot-collectors-new-V1"
BACKUP_DIR_NAME = "old_backups"
SESSION_PREFIX = "cleanup"

ROJO_BASELINE = {
    "name": "Robot Collectors",
    "tree": {
        "$className": "DataModel",
        "ServerScriptService": {
            "Server": {"$path": "src/server"},
        },
        "StarterPlayer": {
            "StarterPlayerScripts": {"$path": "src/client"},
        },
        "ReplicatedStorage": {
            "Shared": {"$path": "src/shared"},
        },
    },
}

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------


def now_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%SZ")


def safe_relative(path: Path, base: Path) -> Path:
    try:
        return path.resolve().relative_to(base.resolve())
    except Exception:
        return Path(path.name)


def build_tree_snapshot(root: Path, max_depth: int = 3) -> str:
    """
    Produce a simple ASCII tree (limited depth) for reporting.
    """
    lines: List[str] = []

    def recurse(current: Path, prefix: str, depth: int) -> None:
        try:
            entries = sorted(
                current.iterdir(),
                key=lambda p: (not p.is_dir(), p.name.lower()),
            )
        except Exception:
            return
        total = len(entries)
        for index, entry in enumerate(entries):
            connector = "└── " if index == total - 1 else "├── "
            lines.append(f"{prefix}{connector}{entry.name}")
            if entry.is_dir() and depth < max_depth:
                extension = "    " if index == total - 1 else "│   "
                recurse(entry, prefix + extension, depth + 1)

    lines.append(f"{root.resolve().name}/")
    recurse(root, "", 0)
    return "\n".join(lines)


class MoveSession:
    """
    Handles routing files/folders into session-specific backup buckets.
    """

    def __init__(self, root: Path, session_dir: Path) -> None:
        self.root = root
        self.session_dir = session_dir
        self.session_dir.mkdir(parents=True, exist_ok=True)

    def move(self, path: Path, label: str) -> Optional[Path]:
        dest = self._destination(path)
        try:
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(path), str(dest))
            print(f"[INFO] Moved {label}: {path} -> {dest}")
            return dest
        except Exception as exc:
            print(f"[WARN] Failed to move {label} {path}: {exc}")
            return None

    def _destination(self, original: Path) -> Path:
        rel = safe_relative(original, self.root)
        timestamp = now_stamp()
        candidate = self.session_dir / f"{timestamp}_{rel.name}"
        counter = 1
        while candidate.exists():
            candidate = self.session_dir / f"{timestamp}_{rel.name}_{counter}"
            counter += 1
        return candidate


def remove_file(path: Path) -> bool:
    try:
        path.unlink()
        print(f"[INFO] Removed file {path}")
        return True
    except Exception as exc:
        print(f"[WARN] Could not remove {path}: {exc}")
        return False


def compute_refs_size(git_dir: Path) -> int:
    refs = git_dir / "refs"
    total = 0
    if not refs.exists():
        return total
    for dirpath, _, filenames in os.walk(refs):
        for name in filenames:
            full = Path(dirpath) / name
            try:
                total += full.stat().st_size
            except OSError:
                continue
    return total


def call_git(args: List[str], cwd: Path) -> Optional[str]:
    try:
        proc = subprocess.run(
            ["git", *args],
            cwd=str(cwd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
            text=True,
        )
    except FileNotFoundError:
        print("[WARN] git is not installed or not accessible.")
        return None
    except Exception as exc:
        print(f"[WARN] git command failed: {' '.join(args)} ({exc})")
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# Main cleanup logic
# ---------------------------------------------------------------------------


def run_cleanup(root: Path) -> int:
    before_tree = build_tree_snapshot(root)

    backup_root = root / BACKUP_DIR_NAME
    backup_root.mkdir(exist_ok=True)
    session_dir = backup_root / f"{SESSION_PREFIX}_{now_stamp()}"
    mover = MoveSession(root, session_dir)

    archived_folders: List[str] = []
    junk_actions: List[str] = []

    live_dir = ensure_live_directory(root, mover, archived_folders)
    if live_dir is None:
        print("[ERROR] Could not locate or create live project directory.")
        return 1

    consolidate_top_level(root, live_dir, mover, archived_folders)
    ensure_rojo_config(live_dir)
    cleanup_live_project(live_dir, mover, junk_actions)
    git_summary = reconcile_git(root, live_dir, mover)

    after_tree = build_tree_snapshot(root)
    write_report(live_dir, before_tree, after_tree, archived_folders, junk_actions, git_summary)

    suspects_count = git_summary.get("untracked_count", 0)
    print("")
    print("===== CLEANUP SUMMARY =====")
    print(f"Live project: {live_dir}")
    print(f"Archived/moved: {len(archived_folders)} entries")
    print(f"Junk handled: {len(junk_actions)} actions")
    print(f"Tracked files: {git_summary.get('tracked_count', 'n/a')}")
    print(f"Untracked files: {suspects_count}")
    print(f"HEAD present: {git_summary.get('head_exists', False)}")
    print("===========================")

    return 0


def ensure_live_directory(root: Path, mover: MoveSession, archived: List[str]) -> Optional[Path]:
    """
    Guarantee we have a directory named ROOT_EXPECTED_LIVE.
    Rename or move other variants as necessary.
    """
    target = root / ROOT_EXPECTED_LIVE
    if target.exists() and target.is_dir():
        return target

    candidates: List[Path] = []
    for entry in root.iterdir():
        if entry.is_dir():
            name = entry.name.lower()
            if "robot" in name and "collector" in name and "new" in name:
                candidates.append(entry)

    if not candidates:
        print("[WARN] No live project directory found; creating fresh structure.")
        try:
            target.mkdir(parents=True, exist_ok=True)
            (target / "src").mkdir(exist_ok=True)
            (target / "docs").mkdir(exist_ok=True)
        except Exception as exc:
            print(f"[ERROR] Failed to create live directory: {exc}")
            return None
        return target

    # Pick newest candidate to rename
    candidates.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    primary = candidates[0]
    if primary.name != ROOT_EXPECTED_LIVE:
        try:
            primary.rename(target)
            print(f"[INFO] Renamed {primary} -> {target}")
        except Exception as exc:
            print(f"[ERROR] Could not rename {primary} to {target}: {exc}")
            return None
    for extra in candidates[1:]:
        archived.append(extra.name)
        mover.move(extra, "duplicate live project")
    return target


def consolidate_top_level(root: Path, live_dir: Path, mover: MoveSession, archived: List[str]) -> None:
    """
    Apply top-level consolidation rules.
    """
    patterns = [
        "archive_*",
        "restore_snapshot_*",
        "robot-collectors-old*",
        "robot_collectors_backup*",
    ]
    skip = {ROOT_EXPECTED_LIVE, BACKUP_DIR_NAME, "tools"}

    for entry in list(root.iterdir()):
        if entry.name in skip:
            continue
        if entry.is_dir():
            if any(fnmatch(entry.name, pat) for pat in patterns):
                archived.append(entry.name)
                mover.move(entry, "legacy folder")
                continue
        # Move canonical project assets into live folder
        target_names = ["src", "docs", ".selene", ".gitignore", "default.project.json", "Rojo.toml"]
        if entry.name in target_names:
            destination = live_dir / entry.name
            if destination.exists():
                archived.append(entry.name + " (duplicate)")
                mover.move(entry, "conflicting canonical asset")
            else:
                try:
                    ensure_parent(destination)
                    shutil.move(str(entry), str(destination))
                    print(f"[INFO] Moved project asset {entry.name} into live directory")
                except Exception as exc:
                    print(f"[WARN] Could not move {entry.name} into live project: {exc}")
            continue
        if entry.is_file():
            # Move stray project files (common config/lock/snapshot files)
            if entry.suffix.lower() in {".json", ".lock", ".yml", ".yaml", ".rbxl", ".rbxlx", ".rbxmx"}:
                destination = live_dir / entry.name
                if destination.exists():
                    archived.append(entry.name + " (duplicate file)")
                    mover.move(entry, "duplicate file")
                else:
                    try:
                        shutil.move(str(entry), str(destination))
                        print(f"[INFO] Relocated stray file {entry.name} into live project")
                    except Exception as exc:
                        print(f"[WARN] Could not relocate {entry.name}: {exc}")


def ensure_rojo_config(live_dir: Path) -> None:
    rojo_path = live_dir / "default.project.json"
    if rojo_path.exists():
        return
    try:
        ensure_parent(rojo_path)
        with rojo_path.open("w", encoding="utf-8") as handle:
            json.dump(ROJO_BASELINE, handle, indent=2)
        print(f"[INFO] Created baseline Rojo config at {rojo_path}")
    except Exception as exc:
        print(f"[WARN] Failed to create Rojo config: {exc}")


def cleanup_live_project(live_dir: Path, mover: MoveSession, actions: List[str]) -> None:
    src_dir = live_dir / "src"
    if src_dir.exists():
        remove_redundant_keep_files(src_dir, actions)

    # Move temp directories inside live project
    temp_patterns = ["archive_*", "restore_snapshot_*", ".trash"]
    for entry in list(live_dir.iterdir()):
        if entry.is_dir() and any(fnmatch(entry.name, pat) for pat in temp_patterns):
            mover.move(entry, "temp directory")
            actions.append(f"Moved temp directory {entry.name}")

    # Also scan src/ for nested temp directories
    if src_dir.exists():
        for entry in list(src_dir.glob("**/*")):
            if entry.is_dir() and any(fnmatch(entry.name, pat) for pat in temp_patterns):
                mover.move(entry, "nested temp directory")
                actions.append(f"Moved nested temp directory {entry.relative_to(live_dir)}")

    suffixes = (".disabled", ".old", ".backup")
    for entry in live_dir.rglob("*"):
        if entry.is_file() and entry.name.endswith(suffixes):
            mover.move(entry, "legacy file")
            actions.append(f"Moved legacy file {entry.relative_to(live_dir)}")


def remove_redundant_keep_files(src_dir: Path, actions: List[str]) -> None:
    for dirpath, _, filenames in os.walk(src_dir):
        keep_variants = [name for name in filenames if name.lower().startswith(".keep")]
        if len(keep_variants) <= 1:
            continue
        keep_variants.sort(key=lambda x: (0 if x == ".keep" else 1, x))
        keep_to_preserve = keep_variants[0]
        dir_path = Path(dirpath)
        for name in keep_variants[1:]:
            removal_target = dir_path / name
            if remove_file(removal_target):
                actions.append(f"Removed duplicate .keep {removal_target.relative_to(src_dir)}")


def reconcile_git(root: Path, live_dir: Path, mover: MoveSession) -> Dict[str, object]:
    git_dirs: List[Path] = []
    root_git = root / ".git"
    if root_git.is_dir():
        git_dirs.append(root_git)
    for entry in root.iterdir():
        if entry.is_dir():
            candidate = entry / ".git"
            if candidate.is_dir():
                git_dirs.append(candidate)

    best: Optional[Path] = None
    best_score: Tuple[int, int, float] = (-1, -1, -1.0)
    for git_dir in git_dirs:
        head_exists = (git_dir / "HEAD").exists()
        refs_size = compute_refs_size(git_dir)
        mtime = git_dir.stat().st_mtime
        score = (1 if head_exists else 0, refs_size, mtime)
        if score > best_score:
            best = git_dir
            best_score = score

    for git_dir in git_dirs:
        if best is None or git_dir == best:
            continue
        mover.move(git_dir, ".git duplicate")

    git_summary: Dict[str, object] = {
        "tracked_count": "n/a",
        "untracked_count": "n/a",
        "head_exists": False,
    }

    if best is None:
        print("[WARN] No .git directory found; skipping git summary.")
        return git_summary

    # Ensure selected git dir lives under the live project root
    dest_git = live_dir / ".git"
    if best.parent != live_dir:
        try:
            if dest_git.exists():
                mover.move(dest_git, "existing live .git")
            ensure_parent(dest_git)
            shutil.move(str(best), str(dest_git))
            print(f"[INFO] Moved Git metadata into live project: {dest_git}")
        except Exception as exc:
            print(f"[WARN] Could not relocate git directory: {exc}")
            return git_summary
        git_dir = dest_git
    else:
        git_dir = best

    head_exists = (git_dir / "HEAD").exists()
    git_summary["head_exists"] = head_exists

    tracked = call_git(["ls-files"], cwd=live_dir)
    if tracked is not None:
        git_summary["tracked_count"] = len([line for line in tracked.splitlines() if line.strip()])
    untracked = call_git(["ls-files", "--others", "--exclude-standard"], cwd=live_dir)
    if untracked is not None:
        git_summary["untracked_count"] = len([line for line in untracked.splitlines() if line.strip()])

    return git_summary


def write_report(
    live_dir: Path,
    before_tree: str,
    after_tree: str,
    archived: List[str],
    actions: List[str],
    git_summary: Dict[str, object],
) -> None:
    docs_dir = live_dir / "docs"
    docs_dir.mkdir(parents=True, exist_ok=True)
    report_path = docs_dir / "CLEANUP_REPORT.md"

    lines: List[str] = []
    lines.append("# Cleanup Report")
    lines.append("")
    lines.append(f"- Generated: {datetime.now(timezone.utc).isoformat()}")
    lines.append(f"- Live Project: `{live_dir}`")
    lines.append(f"- Archived entries: {len(archived)}")
    lines.append(f"- Junk actions: {len(actions)}")
    lines.append(f"- Tracked files: {git_summary.get('tracked_count', 'n/a')}")
    lines.append(f"- Untracked files: {git_summary.get('untracked_count', 'n/a')}")
    lines.append(f"- HEAD present: {git_summary.get('head_exists', False)}")
    lines.append("")
    lines.append("## Before Tree")
    lines.append("```")
    lines.append(before_tree)
    lines.append("```")
    lines.append("")
    lines.append("## After Tree")
    lines.append("```")
    lines.append(after_tree)
    lines.append("```")
    lines.append("")
    if archived:
        lines.append("## Archived / Moved Items")
        for item in archived:
            lines.append(f"- {item}")
        lines.append("")
    if actions:
        lines.append("## Cleanup Actions")
        for item in actions:
            lines.append(f"- {item}")
        lines.append("")

    try:
        with report_path.open("w", encoding="utf-8") as handle:
            handle.write("\n".join(lines))
        print(f"[INFO] Wrote cleanup report to {report_path}")
    except Exception as exc:
        print(f"[WARN] Failed to write cleanup report: {exc}")


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------


def main() -> int:
    root = Path.cwd()
    return run_cleanup(root)


if __name__ == "__main__":
    sys.exit(main())
