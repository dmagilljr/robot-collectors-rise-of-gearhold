#!/usr/bin/env python3
"""Repository auditor – produce manifest describing every file and folder."""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

DEFAULT_EXCLUDES = {
    ".git",
    "out",
    "old_backups",
    "node_modules",
}
DEFAULT_GLOB_EXCLUDES = {
    "*.pyc",
    "__pycache__",
    "out/.trash*",
}
TEXT_EXTS = {
    ".luau",
    ".lua",
    ".ts",
    ".tsx",
    ".js",
    ".jsx",
    ".json",
    ".toml",
    ".yaml",
    ".yml",
    ".md",
    ".txt",
    ".rbxmx",
    ".rbxm",
    ".py",
    ".csv",
    ".sh",
    ".bat",
}


@dataclass
class Entry:
    path: str
    type: str  # file or dir
    size: int
    items: int
    subdirs: int
    extension: str
    lines: str
    category: str
    description: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=None, help="Root directory to scan (default: repo root)")
    parser.add_argument("--out", type=Path, default=None, help="Output directory (default: <root>/out)")
    parser.add_argument("--include-hidden", action="store_true", help="Include dotfolders (except .git unless --include-git)")
    parser.add_argument("--include-git", action="store_true", help="Include .git directory")
    parser.add_argument("--exclude", action="append", default=[], help="Glob pattern to exclude (repeatable)")
    parser.add_argument("--max-text-bytes", type=int, default=2_000_000, help="Max bytes for text line counting")
    parser.add_argument("--json-only", action="store_true", help="Only emit JSON output")
    parser.add_argument("--md-only", action="store_true", help="Only emit Markdown output")
    parser.add_argument("--csv-only", action="store_true", help="Only emit CSV output")
    parser.add_argument("--verbose", action="store_true", help="Print each scanned path")
    return parser.parse_args()


def repo_root_from_scripts() -> Path:
    scripts_dir = Path(__file__).resolve().parent
    return scripts_dir.parent


def should_skip(path: Path, *, args: argparse.Namespace, rel: Path) -> bool:
    parts = rel.parts
    if not args.include_hidden:
        if any(part.startswith(".") for part in parts if part not in (".", "..")):
            return True
    if parts and parts[0] in DEFAULT_EXCLUDES:
        if parts[0] == ".git" and args.include_git:
            pass
        elif parts[0] == ".git":
            return True
        else:
            return True
    for pattern in DEFAULT_GLOB_EXCLUDES:
        if path.match(pattern):
            return True
    for pattern in args.exclude:
        if path.match(pattern):
            return True
    return False


def classify(path: Path, *, is_dir: bool, root: Path, entry: Entry) -> Tuple[str, str]:
    rel = entry.path
    lower = rel.lower()

    # Directories
    if is_dir:
        top = rel.split("/", 1)[0] if "/" in rel else rel
        folder_descriptions = {
            "src": "Game source code (Luau, modules, assets)",
            "scripts": "Automation / repo maintenance scripts",
            "tools": "Custom tools used by the game",
            "docs": "Project documentation",
            ".github": "CI/CD workflows and templates",
            ".vscode": "Editor settings",
            "out": "Generated reports and previews (safe to clean)",
            "old_backups": "Archived snapshots from migrations",
        }
        desc = folder_descriptions.get(top, "Project folder")
        return "Directory", desc

    suffix = path.suffix.lower()
    # Roblox assets
    if suffix in {".rbxl", ".rbxlx"}:
        return "Roblox Place", "Studio place file (XML/JSON)."
    if suffix in {".rbxm", ".rbxmx"}:
        return "Roblox Model", "Studio model (XML/JSON)."

    # Luau/Lua scripts
    if suffix in {".lua", ".luau"}:
        if any(part.lower() in {"serverscriptservice", "serverscripts", "server"} for part in path.parts):
            return "Server Script", "Luau script (server)"
        if any(part.lower() in {"starterplayerscripts", "startergui", "replicatedfirst", "client"} for part in path.parts):
            return "Client Script", "Luau script (client)"
        return "Shared Script", "Luau script (shared)"

    # Rojo project config
    if path.name == "default.project.json" or suffix == ".project.json":
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            project_name = data.get("name", "Unnamed")
            tree = data.get("tree", {})
            keys = ", ".join(sorted(tree.keys())) if isinstance(tree, dict) else "n/a"
            return "Rojo Project", f"Rojo project ({project_name}); top-level keys: {keys}"
        except Exception:
            return "Rojo Project", "Rojo project (unreadable)"
    if path.name == "sourcemap.json":
        return "Rojo Sourcemap", "Rojo sourcemap output"

    # Documentation / meta
    if path.name.lower() == "readme.md":
        heading = extract_first_heading(path)
        desc = f"Documentation (README) – {heading}" if heading else "Documentation (README)"
        return "Documentation (README)", desc
    if path.name.upper() == "LICENSE":
        return "License", "Project license"
    if ".github/workflows" in lower and suffix in {".yml", ".yaml"}:
        return "CI Workflow", "GitHub Actions workflow"
    if rel.startswith("docs/"):
        return "Documentation", "Project documentation asset"

    # Config
    if path.name == "selene.toml" or rel.startswith(".selene/"):
        return "Selene (Luau lint)", "Selene configuration"
    if path.name == "stylua.toml":
        return "StyLua (formatter)", "StyLua configuration"
    if rel.startswith(".vscode/"):
        return "Editor Settings", "VS Code settings"
    if path.name == "package.json":
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            name = data.get("name", "package")
            scripts = data.get("scripts", {})
            count = len(scripts) if isinstance(scripts, dict) else 0
            return "Node project config", f"package.json (name={name}, scripts={count})"
        except Exception:
            return "Node project config", "package.json"

    # Scripts / tools
    if rel.startswith("scripts/"):
        return "Repo Scripts/Utilities", "Repository maintenance script"
    if rel.startswith("tools/"):
        return "Project Tools", "Project tooling"

    # Generic fallback
    if suffix in TEXT_EXTS:
        return "Code", "Text-based code or configuration"
    if suffix in {".png", ".jpg", ".jpeg", ".gif", ".psd"}:
        return "Data (Media)", "Image or media asset"
    if suffix in {".mp3", ".wav", ".ogg"}:
        return "Data (Media)", "Audio asset"
    if suffix in {".zip", ".7z", ".rar"}:
        return "Data (Archive)", "Archived data"

    return "Other", "Uncategorised item"


def extract_first_heading(path: Path) -> Optional[str]:
    try:
        with path.open("r", encoding="utf-8") as fp:
            for line in fp:
                stripped = line.strip()
                if stripped.startswith("#"):
                    return stripped.lstrip("#").strip()
    except Exception:
        pass
    return None


def count_lines(path: Path, limit: int) -> str:
    try:
        size = path.stat().st_size
        if size > limit:
            return "-"
        with path.open("r", encoding="utf-8", errors="ignore") as fp:
            return str(sum(1 for _ in fp))
    except Exception:
        return "-"


def gather_entries(root: Path, args: argparse.Namespace) -> List[Entry]:
    entries: List[Entry] = []
    for path in sorted(root.rglob("*")):
        rel = path.relative_to(root)
        if rel == Path("."):
            continue
        if should_skip(path, args=args, rel=rel):
            continue
        if args.verbose:
            print(f"Scanning {rel}")
        if path.is_dir():
            items = list(path.iterdir())
            entry = Entry(
                path=rel.as_posix(),
                type="dir",
                size=0,
                items=len([p for p in items if p.is_file()]),
                subdirs=len([p for p in items if p.is_dir()]),
                extension="",
                lines="-",
                category="",
                description="",
            )
        else:
            size = path.stat().st_size
            entry = Entry(
                path=rel.as_posix(),
                type="file",
                size=size,
                items=0,
                subdirs=0,
                extension=path.suffix.lower(),
                lines=count_lines(path, args.max_text_bytes) if path.suffix.lower() in TEXT_EXTS else "-",
                category="",
                description="",
            )
        cat, desc = classify(path, is_dir=path.is_dir(), root=root, entry=entry)
        entry.category = cat
        entry.description = desc
        entries.append(entry)
    return entries


def ensure_out_dir(out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)


def write_json(entries: List[Entry], out_file: Path) -> None:
    data = [asdict(entry) for entry in entries]
    out_file.write_text(json.dumps({"generated_at": datetime.utcnow().isoformat(), "entries": data}, indent=2), encoding="utf-8")


def write_csv(entries: List[Entry], out_file: Path) -> None:
    with out_file.open("w", newline="", encoding="utf-8") as fp:
        writer = csv.writer(fp)
        writer.writerow(["path", "type", "category", "description", "size", "lines", "extension", "files", "subdirs"])
        for entry in entries:
            writer.writerow(
                [
                    entry.path,
                    entry.type,
                    entry.category,
                    entry.description,
                    entry.size,
                    entry.lines,
                    entry.extension,
                    entry.items,
                    entry.subdirs,
                ]
            )


def top_level_summary(entries: List[Entry]) -> Dict[str, str]:
    summaries = {}
    for entry in entries:
        if entry.type != "dir":
            continue
        top = entry.path.split("/", 1)[0]
        summaries[top] = entry.description
    return summaries


def write_markdown(entries: List[Entry], out_file: Path, root: Path) -> None:
    total_files = sum(1 for e in entries if e.type == "file")
    total_dirs = sum(1 for e in entries if e.type == "dir")
    total_size = sum(e.size for e in entries if e.type == "file")
    by_category = Counter(e.category for e in entries)
    largest_files = sorted((e for e in entries if e.type == "file"), key=lambda e: e.size, reverse=True)[:10]

    folder_section = top_level_summary(entries)

    lines = [
        "# Repository Manifest\n",
        f"- Generated: {datetime.utcnow():%Y-%m-%d %H:%M UTC}\n",
        f"- Root: `{root}`\n",
        f"- Files: {total_files}\n",
        f"- Directories: {total_dirs}\n",
        f"- Total size: {total_size:,} bytes\n",
        "\n## Category Totals\n",
    ]
    for category, count in sorted(by_category.items(), key=lambda x: (-x[1], x[0])):
        lines.append(f"- **{category}**: {count}\n")

    lines.append("\n## Top-level Folders\n")
    for folder, description in sorted(folder_section.items()):
        lines.append(f"- `{folder}/`: {description}\n")

    lines.append("\n## Top 10 Largest Files\n")
    lines.append("| Path | Size |\n| --- | --- |\n")
    for entry in largest_files:
        lines.append(f"| `{entry.path}` | {entry.size:,} |\n")

    lines.append("\n## Full Inventory\n")
    lines.append("| Path | Type | Category | Size | Lines | Description |\n| --- | --- | --- | --- | --- | --- |\n")
    for entry in entries:
        size_str = f"{entry.size:,}" if entry.type == "file" else "-"
        lines.append(
            f"| `{entry.path}` | {entry.type} | {entry.category} | {size_str} | {entry.lines} | {entry.description} |\n"
        )

    out_file.write_text("".join(lines), encoding="utf-8")


def print_console_summary(entries: List[Entry]) -> None:
    total_files = sum(1 for e in entries if e.type == "file")
    total_dirs = sum(1 for e in entries if e.type == "dir")
    total_size = sum(e.size for e in entries if e.type == "file")
    by_category = Counter(e.category for e in entries)
    largest_files = sorted((e for e in entries if e.type == "file"), key=lambda e: e.size, reverse=True)[:10]

    print(f"Files: {total_files}  Directories: {total_dirs}  Total size: {total_size:,} bytes")
    print("Categories:")
    for category, count in sorted(by_category.items(), key=lambda x: (-x[1], x[0])):
        print(f"  {category}: {count}")
    print("Top 10 largest files:")
    for entry in largest_files:
        print(f"  {entry.path} ({entry.size:,} bytes)")


def main() -> int:
    args = parse_args()
    root = args.root or repo_root_from_scripts()
    out_dir = args.out or (root / "out")
    ensure_out_dir(out_dir)

    entries = gather_entries(root, args)

    json_path = out_dir / "MANIFEST_LATEST.json"
    csv_path = out_dir / "MANIFEST_LATEST.csv"
    md_path = out_dir / "MANIFEST_LATEST.md"

    if not args.csv_only and not args.md_only:
        write_json(entries, json_path)
    if not args.json_only and not args.md_only:
        write_csv(entries, csv_path)
    if not args.json_only and not args.csv_only:
        write_markdown(entries, md_path, root)

    print_console_summary(entries)
    return 0


if __name__ == "__main__":
    sys.exit(main())

