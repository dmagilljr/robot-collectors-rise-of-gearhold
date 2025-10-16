#!/usr/bin/env python3
"""
Safety-first cleanup for the live Robot Collectors project.

Run from repository root:
    python3 tools/cleanup_actions.py
"""

from __future__ import annotations

import os
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional

LIVE = "robot-collectors-new-V1"
BACKUPS = "old_backups"

DOC_EXTENSIONS = {".gsheet", ".docx", ".xlsx", ".pdf"}
KEEP_VARIANTS = {".keep 2", ".keep copy", ".keep copy 2"}


@dataclass
class ActionRecord:
    action: str
    source: str
    destination: str
    reason: str


def utc_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S") + "Z"


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def relative_to_root(path: Path, root: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve()))
    except Exception:
        return str(path.resolve())


class CleanupContext:
    def __init__(self, root: Path, live_dir: Path, session_dir: Path) -> None:
        self.root = root
        self.live_dir = live_dir
        self.session_dir = session_dir
        self.actions: List[ActionRecord] = []

    def archive(self, path: Path, reason: str) -> Optional[Path]:
        if not path.exists():
            return None
        try:
            rel = path.relative_to(self.root)
        except ValueError:
            rel = path.relative_to(self.live_dir)
        destination = self.session_dir / rel
        ensure_dir(destination.parent)
        try:
            shutil.move(str(path), str(destination))
            self.log(
                "archive",
                relative_to_root(path, self.root),
                relative_to_root(destination, self.root),
                reason,
            )
            return destination
        except Exception as exc:
            print(f"[WARN] Failed to archive {path}: {exc}")
            return None

    def delete(self, path: Path, reason: str) -> bool:
        if not path.exists():
            return False
        try:
            path.unlink()
            self.log("delete", relative_to_root(path, self.root), "-", reason)
            return True
        except Exception as exc:
            print(f"[WARN] Failed to delete {path}: {exc}")
            return False

    def move(self, source: Path, destination: Path, reason: str) -> bool:
        if not source.exists():
            return False
        ensure_dir(destination.parent)
        try:
            shutil.move(str(source), str(destination))
            self.log(
                "move",
                relative_to_root(source, self.root),
                relative_to_root(destination, self.root),
                reason,
            )
            return True
        except Exception as exc:
            print(f"[WARN] Failed to move {source} -> {destination}: {exc}")
            return False

    def rename(self, source: Path, destination: Path, reason: str) -> bool:
        if not source.exists():
            return False
        ensure_dir(destination.parent)
        try:
            source.rename(destination)
            self.log(
                "rename",
                relative_to_root(source, self.root),
                relative_to_root(destination, self.root),
                reason,
            )
            return True
        except Exception as exc:
            print(f"[WARN] Failed to rename {source} -> {destination}: {exc}")
            return False

    def log(self, action: str, source: str, destination: str, reason: str) -> None:
        self.actions.append(ActionRecord(action, source, destination, reason))


def remove_ds_store(ctx: CleanupContext) -> None:
    for path in ctx.live_dir.rglob(".DS_Store"):
        ctx.delete(path, "remove .DS_Store")


def handle_selene_duplicate(ctx: CleanupContext) -> None:
    duplicate = ctx.live_dir / ".selene" / "roblox 2.toml"
    canonical = duplicate.parent / "roblox.toml"
    if not duplicate.exists():
        return
    if canonical.exists():
        ctx.archive(duplicate, "duplicate selene config")
    else:
        ctx.rename(duplicate, canonical, "normalize selene config name")


def merge_github_workflows(ctx: CleanupContext) -> None:
    duplicate_dir = ctx.live_dir / ".github" / "workflows 2"
    if not duplicate_dir.exists():
        return
    canonical_dir = ctx.live_dir / ".github" / "workflows"
    ensure_dir(canonical_dir)
    for item in duplicate_dir.iterdir():
        destination = canonical_dir / item.name
        if destination.exists():
            ctx.archive(item, "duplicate workflow entry")
        else:
            ctx.move(item, destination, "merge workflow entry")
    ctx.archive(duplicate_dir, "archive merged workflow directory")


def handle_remote_setup_duplicate(ctx: CleanupContext) -> None:
    duplicate = ctx.live_dir / "src" / "server_modules" / "RemoteSetup 2.luau"
    canonical = duplicate.parent / "RemoteSetup.luau"
    if not duplicate.exists():
        return
    if canonical.exists():
        ctx.archive(duplicate, "duplicate RemoteSetup module")
    else:
        ctx.rename(duplicate, canonical, "normalize RemoteSetup module name")


def archive_legacy_files(ctx: CleanupContext) -> None:
    legacy_path = ctx.live_dir / "src" / "server" / "00_spawns_and_remotes.server.luau"
    if legacy_path.exists():
        ctx.archive(legacy_path, "legacy server bootstrap")


def relocate_stray_docs(ctx: CleanupContext) -> None:
    src_root = ctx.live_dir / "src"
    if not src_root.exists():
        return

    docs_misc = ctx.live_dir / "docs" / "_misc"
    ensure_dir(docs_misc)

    for path in list(src_root.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix.lower() not in DOC_EXTENSIONS:
            continue

        destination = docs_misc / path.name
        if destination.exists():
            # If file already relocated, archive the source duplicate.
            ctx.archive(path, "duplicate stray doc")
            continue
        ctx.move(path, destination, "relocate stray document")

        parent = path.parent
        if parent.name.endswith(" 2") and not any(parent.iterdir()):
            ctx.archive(parent, "archive empty duplicate folder")


def remove_keep_variants(ctx: CleanupContext) -> None:
    for path in ctx.live_dir.rglob("*"):
        if not path.is_file():
            continue
        name_lower = path.name.lower()
        if name_lower == ".keep":
            continue
        if name_lower.startswith(".keep"):
            ctx.archive(path, "archive duplicate keep file")


def write_markdown_log(ctx: CleanupContext) -> None:
    docs_dir = ctx.live_dir / "docs"
    ensure_dir(docs_dir)
    log_path = docs_dir / "CLEANUP_ACTIONS.md"

    timestamp = datetime.now(timezone.utc).isoformat()

    lines: List[str] = []
    lines.append("# Cleanup Actions Log")
    lines.append("")
    lines.append(f"- Generated: {timestamp}")
    lines.append(f"- Session: {relative_to_root(ctx.session_dir, ctx.root)}")
    lines.append("")

    if ctx.actions:
        lines.append("| Action | From | To | Reason |")
        lines.append("| --- | --- | --- | --- |")
        for record in ctx.actions:
            lines.append(
                f"| {record.action} | {record.source} | {record.destination or '-'} | {record.reason} |"
            )
    else:
        lines.append("_No actions recorded._")
    lines.append("")

    summary: Dict[str, int] = {}
    for record in ctx.actions:
        summary[record.action] = summary.get(record.action, 0) + 1
    lines.append("## Summary")
    if summary:
        for action, count in sorted(summary.items()):
            lines.append(f"- {action}: {count}")
    else:
        lines.append("- No changes were necessary.")
    lines.append("")

    ensure_dir(log_path.parent)
    with log_path.open("w", encoding="utf-8") as handle:
        handle.write("\n".join(lines))


def print_summary(ctx: CleanupContext) -> None:
    summary: Dict[str, int] = {}
    for record in ctx.actions:
        summary[record.action] = summary.get(record.action, 0) + 1

    print("\n===== CLEANUP ACTION SUMMARY =====")
    if summary:
        for action, count in sorted(summary.items()):
            print(f"{action.capitalize():>10}: {count}")
    else:
        print("No actions were required.")
    print(f"Backup session: {relative_to_root(ctx.session_dir, ctx.root)}")
    print("==================================")


def prepare_context(root: Path) -> Optional[CleanupContext]:
    live_dir = root / LIVE
    if not live_dir.exists() or not live_dir.is_dir():
        print(f"[ERROR] Live project directory not found at {live_dir}")
        return None

    backup_root = root / BACKUPS
    ensure_dir(backup_root)

    session_dir = backup_root / f"cleanup_actions_{utc_stamp()}"
    ensure_dir(session_dir)

    return CleanupContext(root, live_dir, session_dir)


def main() -> int:
    root = Path.cwd()
    ctx = prepare_context(root)
    if ctx is None:
        return 1

    remove_ds_store(ctx)
    handle_selene_duplicate(ctx)
    merge_github_workflows(ctx)
    handle_remote_setup_duplicate(ctx)
    archive_legacy_files(ctx)
    relocate_stray_docs(ctx)
    remove_keep_variants(ctx)
    write_markdown_log(ctx)
    print_summary(ctx)
    return 0


if __name__ == "__main__":
    sys.exit(main())
