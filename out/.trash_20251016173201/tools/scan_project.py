#!/usr/bin/env python3
"""
Inventory tooling for the robot_collectors project.

Run from the repository root:
    python3 tools/scan_project.py
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from collections import Counter, defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Inventory the project workspace")
    parser.add_argument("--root", type=str, default=None, help="Override repository root (defaults to CWD)")
    parser.add_argument("--since-days", type=int, default=120, help="Threshold in days for considering tracked files stale")
    return parser.parse_args()


class GitHelper:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.available = self._probe_git()

    def _probe_git(self) -> bool:
        try:
            subprocess.run(
                ["git", "--version"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
        except FileNotFoundError:
            return False

        try:
            result = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                cwd=str(self.root),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=False,
            )
        except (FileNotFoundError, OSError):
            return False
        if result.returncode != 0:
            return False
        # Allow projects mounted inside a larger git repo; ensure the requested root is inside.
        repo_top = Path(result.stdout.strip()).resolve()
        try:
            self.root.resolve().relative_to(repo_top)
        except ValueError:
            # Root is outside of git repo; consider git unavailable for this scan.
            return False
        return True

    def run_git(self, args: List[str]) -> Optional[str]:
        if not self.available:
            return None
        try:
            result = subprocess.run(
                ["git", *args],
                cwd=str(self.root),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=False,
            )
        except (FileNotFoundError, OSError):
            self.available = False
            return None
        if result.returncode != 0:
            # Silence expected failures; callers can treat None as absence.
            return None
        return result.stdout

    def check_ignore(self, rel_path: str) -> bool:
        if not self.available:
            return False
        try:
            result = subprocess.run(
                ["git", "check-ignore", rel_path],
                cwd=str(self.root),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=False,
            )
        except (FileNotFoundError, OSError):
            self.available = False
            return False
        if result.returncode == 0:
            return True
        return False

    def last_commit(self, rel_path: str) -> Optional[str]:
        output = self.run_git(["log", "-1", "--format=%cI", "--", rel_path])
        if output:
            value = output.strip()
            return value or None
        return None

    def tracked_files(self) -> Iterable[str]:
        output = self.run_git(["ls-files"])
        if not output:
            return []
        return (line for line in output.splitlines() if line.strip())

    def untracked_files(self) -> Iterable[str]:
        output = self.run_git(["ls-files", "--others", "--exclude-standard"])
        if not output:
            return []
        return (line for line in output.splitlines() if line.strip())


def isoformat_utc(ts: float) -> str:
    dt = datetime.fromtimestamp(ts, tz=timezone.utc)
    return dt.isoformat().replace("+00:00", "Z")


def safe_read_text_lines(path: Path) -> Optional[int]:
    try:
        with path.open("r", encoding="utf-8", errors="ignore") as handle:
            return sum(1 for _ in handle)
    except (OSError, UnicodeDecodeError):
        return None


def compute_sha1(path: Path, max_bytes: int) -> Optional[str]:
    try:
        file_size = path.stat().st_size
    except OSError:
        return None
    if file_size > max_bytes:
        return None
    h = hashlib.sha1()
    try:
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                h.update(chunk)
    except OSError:
        return None
    return h.hexdigest()


def load_rojo_mappings(root: Path) -> List[Tuple[str, str]]:
    mappings: List[Tuple[str, str]] = []
    default_project = root / "default.project.json"
    if not default_project.exists():
        return mappings
    try:
        with default_project.open("r", encoding="utf-8") as handle:
            data = json.load(handle)
    except (OSError, json.JSONDecodeError):
        return mappings

    tree = data.get("tree")
    if not isinstance(tree, dict):
        return mappings

    def traverse(node: Dict[str, object], virtual_path: List[str]) -> None:
        if not isinstance(node, dict):
            return
        path_value = node.get("$path")
        if isinstance(path_value, str):
            resolved = (default_project.parent / path_value).resolve()
            try:
                rel = resolved.relative_to(root)
            except ValueError:
                rel = None
            if rel is not None:
                local = rel.as_posix().rstrip("/")
                virtual = "/".join(virtual_path)
                mappings.append((local, virtual))
        for key, value in node.items():
            if key.startswith("$"):
                continue
            if isinstance(value, dict):
                traverse(value, virtual_path + [key])

    traverse(tree, [])
    return mappings


def path_in_rojo(rel_path: str, mappings: List[Tuple[str, str]]) -> bool:
    if not mappings:
        return False
    for local, _ in mappings:
        if not local:
            continue
        if rel_path == local or rel_path.startswith(local + "/"):
            return True
    return False


def any_legacy_segment(rel_path: str) -> bool:
    legacy_names = {"legacy", "old", "unused", "backup"}
    for segment in rel_path.split("/"):
        if segment.lower() in legacy_names:
            return True
    return False


def human_size(num_bytes: int) -> str:
    units = ["B", "KB", "MB", "GB"]
    size = float(num_bytes)
    for unit in units:
        if size < 1024 or unit == units[-1]:
            return f"{size:.2f} {unit}"
        size /= 1024
    return f"{size:.2f} GB"


def ensure_docs_folders(root: Path) -> None:
    docs_dir = root / "docs"
    docs_dir.mkdir(parents=True, exist_ok=True)


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve() if args.root else Path.cwd().resolve()
    ensure_docs_folders(root)

    git = GitHelper(root)

    excluded_dirs = {".git", "node_modules", ".venv", "__pycache__", ".idea", ".vscode"}
    excluded_files = {".DS_Store"}
    text_exts = {".luau", ".lua", ".py", ".ts", ".js", ".json", ".md", ".txt"}
    binary_exts = {".rbxm", ".rbxmx", ".fbx", ".png", ".jpg", ".jpeg"}

    tracked_set = set(git.tracked_files()) if git.available else set()
    untracked_set = set(git.untracked_files()) if git.available else set()

    rojo_mappings = load_rojo_mappings(root)

    files_data: List[Dict[str, object]] = []
    sha_buckets: Dict[str, List[Dict[str, object]]] = defaultdict(list)
    totals_bytes = 0
    by_ext_counter: Counter[str] = Counter()
    size_by_ext: Dict[str, int] = defaultdict(int)
    folder_counter: Counter[str] = Counter()
    folder_sizes: Dict[str, int] = defaultdict(int)
    visited_dirs = set()

    now = datetime.now(timezone.utc)
    stale_tracked_threshold = timedelta(days=args.since_days)
    stale_untracked_threshold = timedelta(days=14)

    for dirpath, dirnames, filenames in os.walk(root):
        rel_dir = Path(dirpath).resolve().relative_to(root)
        if rel_dir.as_posix() not in visited_dirs:
            visited_dirs.add(rel_dir.as_posix())
        dirnames[:] = [d for d in dirnames if d not in excluded_dirs]

        for filename in filenames:
            if filename in excluded_files:
                continue
            abs_path = Path(dirpath) / filename
            try:
                rel_path = abs_path.resolve().relative_to(root)
            except ValueError:
                # Skip files outside the declared root (possible via symlink traversal).
                continue
            rel_posix = rel_path.as_posix()

            try:
                stat_result = abs_path.stat()
            except OSError:
                continue

            ext = "".join(abs_path.suffixes[-1:]) if abs_path.suffixes else ""
            ext = ext.lower()
            if ext == "" and "." in filename:
                ext = f".{filename.split('.')[-1].lower()}"

            by_ext_counter[ext] += 1
            size_by_ext[ext] += stat_result.st_size
            totals_bytes += stat_result.st_size

            top_level = rel_posix.split("/", 1)[0] if "/" in rel_posix else rel_posix
            if not top_level:
                top_level = "[root]"
            folder_counter[top_level] += 1
            folder_sizes[top_level] += stat_result.st_size

            git_tracked = rel_posix in tracked_set
            git_ignored = False
            if not git_tracked and rel_posix not in untracked_set:
                # Not tracked and not listed as standard untracked; still perform ignore check.
                git_ignored = git.check_ignore(rel_posix)
            elif not git_tracked:
                git_ignored = git.check_ignore(rel_posix)

            last_commit = git.last_commit(rel_posix) if git_tracked else None
            last_commit_dt: Optional[datetime] = None
            if last_commit:
                try:
                    last_commit_dt = datetime.fromisoformat(last_commit.replace("Z", "+00:00"))
                except ValueError:
                    last_commit_dt = None

            is_text = ext in text_exts
            if not is_text and ext.lower() in binary_exts:
                line_count = None
            elif is_text:
                line_count = safe_read_text_lines(abs_path)
            else:
                line_count = None

            sha1_hash = compute_sha1(abs_path, max_bytes=2 * 1024 * 1024)

            mtime_dt = datetime.fromtimestamp(stat_result.st_mtime, tz=timezone.utc)
            orphan_rojo = False
            if rel_posix.startswith("src/"):
                orphan_rojo = not path_in_rojo(rel_posix, rojo_mappings)

            info: Dict[str, object] = {
                "path": rel_posix,
                "size": stat_result.st_size,
                "mtime": isoformat_utc(stat_result.st_mtime),
                "ext": ext,
                "git_tracked": git_tracked,
                "git_ignored": git_ignored,
                "last_commit": last_commit,
                "line_count": line_count,
                "orphan_rojo": orphan_rojo,
                "suspect_reason": None,
                "sha1": sha1_hash,
                "_mtime_dt": mtime_dt,
                "_last_commit_dt": last_commit_dt,
                "_reasons": [],
            }

            if sha1_hash:
                sha_buckets[sha1_hash].append(info)

            files_data.append(info)

    total_files = len(files_data)
    total_dirs = len(visited_dirs)

    duplicates_groups: List[List[str]] = []

    for sha_value, group in sha_buckets.items():
        if len(group) <= 1:
            continue
        sorted_group = sorted(group, key=lambda item: item["_mtime_dt"], reverse=True)
        preferred = sorted_group[0]
        duplicate_paths = [entry["path"] for entry in sorted_group]
        duplicates_groups.append(duplicate_paths)
        for duplicate in sorted_group[1:]:
            duplicate["_reasons"].append(f"duplicate_of:{preferred['path']}")

    for info in files_data:
        reasons: List[str] = info["_reasons"]
        rel_posix = info["path"]  # type: ignore[assignment]
        mtime_dt: datetime = info["_mtime_dt"]  # type: ignore[assignment]
        git_tracked = info["git_tracked"]  # type: ignore[assignment]
        git_ignored = info["git_ignored"]  # type: ignore[assignment]
        last_commit_dt: Optional[datetime] = info["_last_commit_dt"]  # type: ignore[assignment]
        orphan_rojo = info["orphan_rojo"]  # type: ignore[assignment]

        if not git_tracked and not git_ignored:
            if now - mtime_dt > stale_untracked_threshold:
                reasons.append("untracked_stale")
        if git_tracked and (not rel_posix.startswith("src/")):
            if last_commit_dt and now - last_commit_dt > stale_tracked_threshold:
                reasons.append("stale_tracked")
        if orphan_rojo:
            reasons.append("rojo_orphan")
        if any_legacy_segment(rel_posix):
            reasons.append("legacy_path")

        if reasons:
            info["suspect_reason"] = "; ".join(reasons)
        else:
            info["suspect_reason"] = None

        # Clean up internal keys before serialization.
        info.pop("_mtime_dt", None)
        info.pop("_last_commit_dt", None)
        info.pop("_reasons", None)

    suspects = [item for item in files_data if item["suspect_reason"]]
    rojo_orphans = [item for item in files_data if item["orphan_rojo"]]
    untracked_not_ignored = [
        item for item in files_data if (not item["git_tracked"]) and (not item["git_ignored"])
    ]

    by_ext_dict = dict(sorted(by_ext_counter.items(), key=lambda x: x[0]))

    inventory = {
        "scanned_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "root": str(root),
        "totals": {
            "files": total_files,
            "bytes": totals_bytes,
            "directories": total_dirs,
        },
        "by_ext": by_ext_dict,
        "files": files_data,
    }

    json_path = root / "docs" / "PROJECT_INVENTORY.json"
    with json_path.open("w", encoding="utf-8") as handle:
        json.dump(inventory, handle, indent=2)

    top_largest = sorted(files_data, key=lambda item: item["size"], reverse=True)[:10]
    by_ext_rows = sorted(
        ((ext or "(none)", count, size_by_ext[ext]) for ext, count in by_ext_counter.items()),
        key=lambda row: row[1],
        reverse=True,
    )
    folder_rows = sorted(
        ((folder or "[root]", folder_counter[folder], folder_sizes[folder]) for folder in folder_counter),
        key=lambda row: row[1],
        reverse=True,
    )

    md_lines: List[str] = []
    md_lines.append("# Project Inventory")
    md_lines.append(f"Scanned at: {inventory['scanned_at']}")
    md_lines.append("")
    md_lines.append("## Summary")
    md_lines.append(f"- Files: {total_files}")
    md_lines.append(f"- Directories: {total_dirs}")
    md_lines.append(f"- Total size: {human_size(totals_bytes)}")
    md_lines.append("")

    md_lines.append("## Top 10 Largest Files")
    if top_largest:
        md_lines.append("| Path | Size |")
        md_lines.append("| --- | --- |")
        for item in top_largest:
            md_lines.append(f"| {item['path']} | {human_size(item['size'])} |")
    else:
        md_lines.append("_No files found._")
    md_lines.append("")

    md_lines.append("## Counts by Extension")
    if by_ext_rows:
        md_lines.append("| Extension | Files | Size |")
        md_lines.append("| --- | ---: | ---: |")
        for ext, count, sz in by_ext_rows:
            md_lines.append(f"| {ext} | {count} | {human_size(sz)} |")
    else:
        md_lines.append("_No data._")
    md_lines.append("")

    md_lines.append("## Counts by Folder")
    if folder_rows:
        md_lines.append("| Folder | Files | Size |")
        md_lines.append("| --- | ---: | ---: |")
        for folder, count, sz in folder_rows:
            md_lines.append(f"| {folder} | {count} | {human_size(sz)} |")
    else:
        md_lines.append("_No data._")
    md_lines.append("")

    md_lines.append("## Suspected Unused")
    if suspects:
        md_lines.append("| Path | Reason | Last Commit | Size |")
        md_lines.append("| --- | --- | --- | ---: |")
        for item in sorted(suspects, key=lambda x: x["path"]):
            reason = item["suspect_reason"] or ""
            last_commit = item["last_commit"] or "-"
            md_lines.append(
                f"| {item['path']} | {reason} | {last_commit} | {human_size(item['size'])} |"
            )
    else:
        md_lines.append("_No suspected unused files._")
    md_lines.append("")

    md_lines.append("## Duplicates")
    if duplicates_groups:
        for group in duplicates_groups:
            md_lines.append(f"- {' , '.join(group)}")
    else:
        md_lines.append("_No duplicate content detected._")
    md_lines.append("")

    md_lines.append("## Rojo Orphans")
    if rojo_orphans:
        md_lines.append("| Path | Size | Last Commit |")
        md_lines.append("| --- | ---: | --- |")
        for item in sorted(rojo_orphans, key=lambda x: x["path"]):
            md_lines.append(
                f"| {item['path']} | {human_size(item['size'])} | {item['last_commit'] or '-'} |"
            )
    else:
        md_lines.append("_No Rojo orphans detected._")
    md_lines.append("")

    md_lines.append("## Untracked (not ignored)")
    if untracked_not_ignored:
        for item in sorted(untracked_not_ignored, key=lambda x: x["path"]):
            md_lines.append(f"- {item['path']} ({human_size(item['size'])})")
    else:
        md_lines.append("_All files are tracked or ignored._")
    md_lines.append("")

    md_lines.append("## Recommended Actions")
    recommended_actions: List[str] = []
    if duplicates_groups:
        recommended_actions.append(
            f"[ ] Review duplicate files starting with {duplicates_groups[0][0]}."
        )
    if rojo_orphans:
        recommended_actions.append(
            f"[ ] Map or relocate Rojo orphan {rojo_orphans[0]['path']}."
        )
    if untracked_not_ignored:
        recommended_actions.append(
            f"[ ] Decide on tracking or removing untracked file {untracked_not_ignored[0]['path']}."
        )
    if not recommended_actions:
        recommended_actions.append("[ ] Review inventory findings and confirm no action needed.")
    for action in recommended_actions:
        md_lines.append(f"- {action}")

    md_path = root / "docs" / "PROJECT_INVENTORY.md"
    with md_path.open("w", encoding="utf-8") as handle:
        handle.write("\n".join(md_lines) + "\n")

    print(
        f"Scanned {total_files} files ({human_size(totals_bytes)}). "
        f"Suspects: {len(suspects)}. Duplicates: {len(duplicates_groups)} groups. "
        f"Orphans: {len(rojo_orphans)}."
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
