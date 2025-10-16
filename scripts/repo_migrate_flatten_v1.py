#!/usr/bin/env python3
"""Flatten `robot-collectors-new-V1` into `ROBOT_COLLECTORS` safely (dry-run by default)."""
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Tuple

DEFAULT_FROM = "robot-collectors-new-V1"
DEFAULT_TO = "ROBOT_COLLECTORS"
DEFAULT_OUT_DIR = "OUT"
DEFAULT_KEEP = 5
DEFAULT_EXTS = ".luau,.lua,.ts,.tsx,.js,.jsx,.json,.toml,.yaml,.yml,.md,.txt,.rbxmx,.rbxm,.py"
DEFAULT_EXCLUDES = [
    ".git/",
    ".github/",
    "node_modules/",
    "*.lock",
    ".DS_Store",
    ".idea/",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.psd",
    "*.blend",
    "*.fbx",
    "*.unity",
    "build/",
    "dist/",
    "screenshots/",
    "logs/",
    "OUT/**",
]

PATH_PATTERNS = [
    r'(["\'])([^"\']*?)([^"\']+?)(["\'])',
    r'(require|import)\s*\(?["\']([^"\']*?)([^"\']+?)["\']\)?',
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument("--apply", action="store_true", help="Perform the migration (default: dry-run)")
    parser.add_argument("--from", dest="src", default=DEFAULT_FROM, help=f"Source folder name (default: {DEFAULT_FROM})")
    parser.add_argument("--to", dest="dst", default=DEFAULT_TO, help=f"Destination folder name (default: {DEFAULT_TO})")
    parser.add_argument("--update-refs", dest="update_refs", action="store_true", default=True, help="Rewrite path references (default: on)")
    parser.add_argument("--no-update-refs", dest="update_refs", action="store_false", help="Disable reference rewriting")
    parser.add_argument("--delete-source", dest="delete_source", action="store_true", default=True, help="Delete source folder when empty (default: on)")
    parser.add_argument("--no-delete-source", dest="delete_source", action="store_false", help="Keep source folder after migration")
    parser.add_argument("--out-clean", action="store_true", help="Clean the OUT/ folder after migration")
    parser.add_argument("--out-dir", default=DEFAULT_OUT_DIR, help=f"OUT folder path (default: {DEFAULT_OUT_DIR})")
    parser.add_argument("--out-keep", type=int, default=DEFAULT_KEEP, help=f"Keep N newest items in OUT (default: {DEFAULT_KEEP})")
    parser.add_argument("--include-ext", default=DEFAULT_EXTS, help=f"Comma list of file extensions to rewrite (default: {DEFAULT_EXTS})")
    parser.add_argument("--exclude", default="", help="Comma list of glob patterns to ignore")
    parser.add_argument("--backup", default=None, help="Backup root directory (default: scripts/_backup/<timestamp>/)")
    parser.add_argument("--git", dest="use_git", action="store_true", default=None, help="Force use of git mv/rm")
    parser.add_argument("--no-git", dest="use_git", action="store_false", help="Disable git operations even if repo is clean")
    parser.add_argument("--yes", action="store_true", help="Assume yes to prompts / warnings")
    parser.add_argument("--verbose", action="store_true", help="Verbose logging")
    parser.epilog = (
        "Examples:\n"
        "  Dry-run (default):\n"
        "    python3 scripts/repo_migrate_flatten_v1.py\n\n"
        "  Apply with OUT clean (keep 7 newest):\n"
        "    python3 scripts/repo_migrate_flatten_v1.py --apply --out-clean --out-keep 7 --yes\n\n"
        "  Apply without rewriting references:\n"
        "    python3 scripts/repo_migrate_flatten_v1.py --apply --no-update-refs --yes\n\n"
        "  Custom folders:\n"
        "    python3 scripts/repo_migrate_flatten_v1.py --from robot-collectors-new-V1 --to ROBOT_COLLECTORS --apply --yes\n"
    )
    return parser.parse_args()


def print_header(apply: bool) -> None:
    mode = "APPLY" if apply else "DRY-RUN"
    print(f"⚙️  Repo Migration – Flatten V1 ({mode})")
    print("-" * 52)


def is_git_repo(root: Path) -> bool:
    return (root / ".git").is_dir()


def git_status_clean(root: Path) -> bool:
    try:
        result = subprocess.run(["git", "status", "--porcelain"], cwd=root, check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    except FileNotFoundError:
        return False
    return result.returncode == 0 and result.stdout.strip() == ""


def ensure_directory(path: Path, *, apply: bool) -> None:
    if apply:
        path.mkdir(parents=True, exist_ok=True)


def matches_exclude(path: Path, patterns: List[str]) -> bool:
    rel = path.as_posix()
    for pattern in patterns:
        if pattern.endswith("/**"):
            if rel.startswith(pattern[:-3]):
                return True
        elif fnmatch.fnmatch(rel, pattern):
            return True
    return False


def sha1(path: Path) -> str:
    h = hashlib.sha1()
    with path.open("rb") as fp:
        for chunk in iter(lambda: fp.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def iter_files(root: Path, *, exclude: List[str]) -> Iterator[Path]:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if matches_exclude(path.relative_to(root), exclude):
            continue
        yield path


def safe_read_text(path: Path) -> Optional[str]:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return None


def safe_write_text(path: Path, content: str, *, apply: bool) -> None:
    if apply:
        path.write_text(content, encoding="utf-8")


def backup_file(src: Path, backup_root: Path, *, apply: bool, verbose: bool) -> Optional[Path]:
    if not apply:
        return None
    backup_path = backup_root / src.relative_to(src.anchor if src.is_absolute() else Path("."))
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, backup_path)
    if verbose:
        print(f"  BACKUP → {backup_path}")
    return backup_path


def move_with_git(src: Path, dst: Path, *, apply: bool, use_git: bool, verbose: bool) -> bool:
    if not apply:
        return True
    if use_git:
        try:
            subprocess.run(["git", "mv", str(src), str(dst)], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            return True
        except subprocess.CalledProcessError as exc:
            if verbose:
                print(f"  WARN git mv failed: {exc.stderr.strip()}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(src), str(dst))
    return True


def delete_with_git(path: Path, *, apply: bool, use_git: bool, verbose: bool) -> bool:
    if not apply:
        return True
    if use_git:
        try:
            subprocess.run(["git", "rm", "-r", str(path)], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            return True
        except subprocess.CalledProcessError as exc:
            if verbose:
                print(f"  WARN git rm failed: {exc.stderr.strip()}")
    if path.is_dir():
        shutil.rmtree(path)
    elif path.exists():
        path.unlink()
    return True


def clean_out_folder(out_dir: Path, keep: int, *, apply: bool) -> Tuple[int, List[Path]]:
    if not out_dir.exists():
        return 0, []
    entries = [(child, child.stat().st_mtime) for child in out_dir.iterdir()]
    entries.sort(key=lambda x: x[1], reverse=True)
    keep_entries = entries[:keep]
    remove_entries = entries[keep:]
    removed: List[Path] = []
    for path, _ in remove_entries:
        removed.append(path)
        if apply:
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()
    return len(removed), removed


def rewrite_refs(
    files: Iterable[Path],
    *,
    apply: bool,
    patterns: List[re.Pattern],
    stats: Dict[str, int],
    verbose: bool,
) -> None:
    for path in files:
        text = safe_read_text(path)
        if text is None:
            continue
        replaced = 0
        new_text = text
        for pattern in patterns:
            def _repl(match: re.Match) -> str:
                nonlocal replaced
                replaced += 1
                groups = list(match.groups())
                for i, value in enumerate(groups):
                    if isinstance(value, str) and "robot-collectors-new-V1/" in value:
                        groups[i] = value.replace("robot-collectors-new-V1/", "")
                return "".join(groups[:1]) + "".join(groups[1:])

            new_text = pattern.sub(_repl, new_text)
        if replaced and new_text != text:
            stats["rewrites"] += 1
            stats["replacements"] += replaced
            print(f"  REWRITE {path} ({replaced} replacements)")
            safe_write_text(path, new_text, apply=apply)
        elif verbose and replaced:
            print(f"  NOTE {path}: replacements counted but content unchanged")


def main() -> int:
    args = parse_args()
    print_header(args.apply)

    root = Path.cwd()
    src_dir = root / args.src
    dst_dir = root / args.dst
    out_dir = root / args.out_dir
    exclude_patterns = [pattern.strip() for pattern in DEFAULT_EXCLUDES]
    if args.exclude:
        exclude_patterns.extend([pattern.strip() for pattern in args.exclude.split(",") if pattern.strip()])

    if not src_dir.exists() or not src_dir.is_dir():
        print(f"[ERROR] Source directory not found: {src_dir}")
        return 1
    if src_dir.resolve() == dst_dir.resolve():
        print("[ERROR] Source and destination directories must differ.")
        return 1

    ensure_directory(dst_dir, apply=args.apply)

    is_repo = is_git_repo(root)
    use_git = args.use_git
    if use_git is None:
        use_git = is_repo
    if use_git and not git_status_clean(root):
        warning = "[WARN] Git working tree not clean. Proceeding may merge into a dirty tree."
        print(warning)
        if not args.yes:
            response = input("Continue? [y/N] ").strip().lower()
            if response not in ("y", "yes"):
                print("Aborted.")
                return 1

    include_exts = {ext.strip().lower() if ext.startswith(".") else f".{ext.strip().lower()}" for ext in args.include_ext.split(",") if ext.strip()}
    patterns = [re.compile(pattern) for pattern in PATH_PATTERNS]

    timestamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    backup_root = Path(args.backup) if args.backup else root / "scripts" / "_backup" / timestamp
    if args.apply:
        backup_root.mkdir(parents=True, exist_ok=True)
        print(f"Backup root: {backup_root}")
    else:
        print(f"Backup root (dry-run): {backup_root}")

    move_stats = defaultdict(int)
    conflict_list: List[Tuple[Path, Path]] = []

    for path in iter_files(src_dir, exclude=exclude_patterns):
        relative = path.relative_to(src_dir)
        dest = dst_dir / relative

        # Ensure destination parent exists only when applying.
        if args.apply:
            dest.parent.mkdir(parents=True, exist_ok=True)
        else:
            # Dry-run: simulate directory creation if missing
            if not dest.parent.exists():
                try:
                    rel_parent = dest.parent.relative_to(root)
                except Exception:
                    rel_parent = dest.parent
                print(f"  MKDIR (dry-run) {rel_parent}")
        if dest.exists():
            try:
                if sha1(path) == sha1(dest):
                    print(f"  SKIP (identical) {relative}")
                    move_stats["skip_identical"] += 1
                    continue
            except OSError as exc:
                print(f"  ERROR hashing {path}: {exc}")
                continue
            backup_file(dest, backup_root, apply=args.apply, verbose=args.verbose)
            new_dest = dest.with_name(dest.name + ".migrated")
            print(f"  CONFLICT {relative} -> {new_dest.name}")
            conflict_list.append((dest, new_dest))
            if args.apply:
                shutil.copy2(dest, new_dest)
                shutil.copy2(path, dest)
            move_stats["conflicts"] += 1
        else:
            print(f"  MOVE {relative} -> {dest.relative_to(root)}")
            move_with_git(path, dest, apply=args.apply, use_git=use_git, verbose=args.verbose)
            move_stats["moved"] += 1

    if args.delete_source:
        if args.apply:
            try:
                delete_with_git(src_dir, apply=True, use_git=use_git, verbose=args.verbose)
                print(f"  DELETE source dir {src_dir}")
            except Exception as exc:
                print(f"[WARN] Failed to delete source dir: {exc}")
        else:
            print(f"  DELETE (dry-run) source dir {src_dir}")

    rewrite_stats = {"rewrites": 0, "replacements": 0}
    if args.update_refs:
        ref_files = [
            path
            for path in iter_files(root, exclude=exclude_patterns)
            if path.suffix.lower() in include_exts and not path.is_relative_to(src_dir)
        ]
        print(f"Scanning {len(ref_files)} files for reference rewrites…")
        rewrite_refs(ref_files, apply=args.apply, patterns=patterns, stats=rewrite_stats, verbose=args.verbose)
    else:
        print("Reference rewriting disabled.")

    out_deleted = 0
    deleted_paths: List[Path] = []
    if args.out_clean:
        out_deleted, deleted_paths = clean_out_folder(out_dir, args.out_keep, apply=args.apply)
        for path in deleted_paths:
            print(f"  DELETE OUT {path}")
    else:
        print("OUT cleanup disabled.")

    print("\nSummary:")
    print(f"  Moves executed: {move_stats['moved']}")
    print(f"  Identical skipped: {move_stats['skip_identical']}")
    print(f"  Conflicts handled: {move_stats['conflicts']}")
    print(f"  Files rewritten: {rewrite_stats['rewrites']} (total replacements: {rewrite_stats['replacements']})")
    print(f"  OUT deletions: {out_deleted}")
    print(f"  Backup directory: {backup_root}")
    if conflict_list:
        print("  Conflicts detail:")
        for dest, new_dest in conflict_list:
            print(f"    {dest} -> {new_dest}")
    if not args.apply:
        print("\nDry-run complete. Run with --apply to execute.")
    else:
        print("\nMigration applied successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
