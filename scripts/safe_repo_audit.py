#!/usr/bin/env python3
"""
Safe repository auditor producing a read-only markdown report.
"""
from __future__ import annotations

import hashlib
import json
import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

MAX_HASH_SIZE = 25 * 1024 * 1024  # 25MB
REPORT_PREFIX = "SAFE_AUDIT_REPORT_"
EXCLUDED_DIRS = {".git", "out", "node_modules", ".vscode", ".idea"}
SKIP_FILENAMES = {".DS_Store"}


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


@dataclass
class RojoMapping:
    service: str
    context: str
    relative: str
    absolute: Path
    exists: bool
    inside_repo: bool


def load_rojo_mappings(repo_root: Path) -> Tuple[List[RojoMapping], List[str]]:
    config_path = repo_root / "default.project.json"
    diagnostics: List[str] = []
    if not config_path.exists():
        diagnostics.append("default.project.json not found; Rojo mapping unavailable.")
        return [], diagnostics

    try:
        raw_data = json.loads(config_path.read_text(encoding="utf-8"))
    except Exception as exc:
        diagnostics.append(f"Failed to parse default.project.json: {exc}")
        return [], diagnostics

    mappings: List[Tuple[str, str, str]] = []

    def collect_from_node(service: str, node, key_path: List[str]) -> List[Tuple[str, str, str]]:
        results: List[Tuple[str, str, str]] = []
        if isinstance(node, dict):
            path_value = node.get("$path")
            if isinstance(path_value, str):
                context = "/".join(key_path) if key_path else service
                results.append((service, context, path_value))
            for child_key in sorted(k for k in node.keys() if not k.startswith("$")):
                results.extend(collect_from_node(service, node[child_key], key_path + [child_key]))
        elif isinstance(node, list):
            for index, child in enumerate(node):
                indexed_key = f"{key_path[-1]}[{index}]" if key_path else f"{service}[{index}]"
                results.extend(collect_from_node(service, child, key_path[:-1] + [indexed_key] if key_path else [indexed_key]))
        elif isinstance(node, str):
            context = "/".join(key_path) if key_path else service
            results.append((service, context, node))
        return results

    def harvest_from_mapping(source, source_name: str):
        if isinstance(source, dict):
            for key in sorted(k for k in source.keys() if not k.startswith("$")):
                mappings.extend(collect_from_node(key, source[key], [key]))
        elif isinstance(source, list):
            for index, entry in enumerate(source):
                entry_name = entry.get("name") if isinstance(entry, dict) else f"{source_name}[{index}]"
                name = entry_name or f"{source_name}[{index}]"
                if isinstance(entry, dict):
                    root_value = entry.get("root") or entry.get("path")
                    if isinstance(root_value, str):
                        mappings.append((name, name, root_value))
                    elif root_value is not None:
                        mappings.extend(collect_from_node(name, root_value, [name]))
                elif isinstance(entry, str):
                    mappings.append((f"{source_name}[{index}]", f"{source_name}[{index}]", entry))
        elif isinstance(source, str):
            mappings.append((source_name, source_name, source))

    tree_section = raw_data.get("tree")
    serve_section = raw_data.get("serve")
    if tree_section is not None:
        harvest_from_mapping(tree_section, "tree")
    if serve_section is not None:
        harvest_from_mapping(serve_section, "serve")

    if not mappings:
        diagnostics.append("No Rojo root mappings could be inferred from default.project.json.")

    seen = set()
    rojo_entries: List[RojoMapping] = []
    for service, context, rel_path in mappings:
        rel_path = rel_path.strip()
        if not rel_path:
            continue
        normalized_rel = Path(rel_path)
        rel_string = normalized_rel.as_posix()
        if (service, context, rel_string) in seen:
            continue
        seen.add((service, context, rel_string))
        absolute = (repo_root / normalized_rel).resolve()
        inside_repo = is_relative_to(absolute, repo_root)
        exists = absolute.exists()
        if not inside_repo:
            diagnostics.append(f"Rojo mapping '{context}' points outside the repository: {rel_string}")
        rojo_entries.append(
            RojoMapping(
                service=service,
                context=context,
                relative=rel_string,
                absolute=absolute,
                exists=exists,
                inside_repo=inside_repo,
            )
        )
    return rojo_entries, diagnostics


WHITELIST_PREFIXES = [
    ".github/",
    "docs/",
    ".selene/",
    "scripts/",
]

WHITELIST_SUFFIXES = {".md", ".txt", ".png", ".jpg", ".jpeg"}

WHITELIST_EXACT = {
    "LICENSE",
    "package.json",
    "package-lock.json",
    "yarn.lock",
    ".gitignore",
    ".editorconfig",
    "stylua.toml",
    "selene.toml",
}

WHITELIST_NAME_PREFIXES = ["README", "CHANGELOG", ".PRETTIER"]


def is_whitelisted(rel_path: Path) -> bool:
    posix_path = rel_path.as_posix()
    lower_posix = posix_path.lower()
    for prefix in WHITELIST_PREFIXES:
        if posix_path.startswith(prefix):
            return True
    name = rel_path.name
    if name in WHITELIST_EXACT:
        return True
    upper_name = name.upper()
    for prefix in WHITELIST_NAME_PREFIXES:
        if upper_name.startswith(prefix):
            return True
    suffix = rel_path.suffix.lower()
    if suffix in WHITELIST_SUFFIXES:
        return True
    if name.lower().startswith(".prettier"):
        return True
    return False


def compute_sha1(path: Path) -> Tuple[Optional[str], Optional[str]]:
    try:
        size = path.stat().st_size
    except OSError as exc:
        return None, f"Failed to stat {path}: {exc}"
    if size > MAX_HASH_SIZE:
        return None, None
    sha1_obj = hashlib.sha1()
    try:
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                sha1_obj.update(chunk)
    except OSError as exc:
        return None, f"Failed to read {path}: {exc}"
    return sha1_obj.hexdigest(), None


def gather_rojo_classifiers(roots: Sequence[RojoMapping]) -> Tuple[List[Path], List[str]]:
    directories: List[Path] = []
    exact_files: List[str] = []
    for mapping in roots:
        if not mapping.exists or not mapping.inside_repo:
            continue
        if mapping.absolute.is_dir():
            directories.append(mapping.absolute)
        elif mapping.absolute.is_file():
            exact_files.append(mapping.relative)
    return directories, exact_files


def classify_files(
    repo_root: Path,
    roots: Sequence[RojoMapping],
) -> Dict[str, object]:
    rojo_dirs, rojo_files = gather_rojo_classifiers(roots)
    rojo_dirs = sorted(set(rojo_dirs))
    rojo_files_set = set(rojo_files)

    file_records = []
    whitelisted = set()
    rojo_mapped = set()
    unclassified = set()
    duplicates: Dict[str, List[Dict[str, object]]] = {}
    hashing_errors: List[str] = []
    oversized_files: List[Tuple[str, int]] = []
    legacy_hits: List[str] = []

    for dirpath, dirnames, filenames in os.walk(repo_root):
        current = Path(dirpath)
        relative_dir = current.relative_to(repo_root)
        if any(part in EXCLUDED_DIRS for part in relative_dir.parts):
            dirnames[:] = []
            continue
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS]
        for filename in sorted(filenames):
            if filename in SKIP_FILENAMES:
                continue
            abs_path = current / filename
            try:
                if not abs_path.is_file():
                    continue
            except OSError:
                continue
            rel_path = abs_path.relative_to(repo_root)
            rel_posix = rel_path.as_posix()
            file_size = abs_path.stat().st_size
            total_record = {
                "path": rel_posix,
                "size": file_size,
                "sha1": None,
            }
            is_white = is_whitelisted(rel_path)
            if is_white:
                whitelisted.add(rel_posix)
            is_rojo = False
            if rel_posix in rojo_files_set:
                is_rojo = True
            else:
                abs_path_resolved = abs_path.resolve()
                for directory in rojo_dirs:
                    if is_relative_to(abs_path_resolved, directory):
                        is_rojo = True
                        break
            if is_rojo:
                rojo_mapped.add(rel_posix)
            if not is_white and not is_rojo:
                unclassified.add(rel_posix)
            sha1_hash, error = compute_sha1(abs_path)
            if error:
                hashing_errors.append(error)
            elif sha1_hash is None:
                oversized_files.append((rel_posix, file_size))
            else:
                total_record["sha1"] = sha1_hash
                duplicates.setdefault(sha1_hash, []).append(total_record)
            file_records.append(total_record)
            if "robot-collectors-new-v1" in rel_posix.lower():
                legacy_hits.append(rel_posix)

    legacy_hits = sorted(set(legacy_hits))
    oversized_files.sort(key=lambda item: item[0])
    return {
        "files": sorted(file_records, key=lambda item: item["path"]),
        "whitelisted": sorted(whitelisted),
        "rojo_mapped": sorted(rojo_mapped),
        "unclassified": sorted(unclassified),
        "duplicates": duplicates,
        "hashing_errors": hashing_errors,
        "oversized_files": oversized_files,
        "legacy_hits": legacy_hits,
    }


def format_duplicate_section(duplicates: Dict[str, List[Dict[str, object]]]) -> List[str]:
    lines: List[str] = []
    duplicate_groups = [
        (hash_value, sorted(entries, key=lambda item: item["path"]))
        for hash_value, entries in duplicates.items()
        if len(entries) > 1
    ]
    duplicate_groups.sort(key=lambda item: (-len(item[1]), item[0]))
    if not duplicate_groups:
        lines.append("- None detected.")
        return lines
    for hash_value, entries in duplicate_groups:
        size_display = entries[0]["size"] if entries[0]["size"] is not None else "unknown size"
        lines.append(f"- sha1 {hash_value} ({len(entries)} files, {size_display} bytes)")
        for entry in entries:
            lines.append(f"  - {entry['path']}")
    return lines


def build_proposed_actions(duplicates: Dict[str, List[Dict[str, object]]], legacy_hits: Sequence[str]) -> List[str]:
    actions: List[str] = []
    duplicate_groups = [
        (hash_value, sorted(entries, key=lambda item: item["path"]))
        for hash_value, entries in duplicates.items()
        if len(entries) > 1
    ]
    duplicate_groups.sort(key=lambda item: (-len(item[1]), item[0]))
    for hash_value, entries in duplicate_groups:
        paths = ", ".join(entry["path"] for entry in entries)
        actions.append(f"# echo \"Review duplicate group {hash_value}: {paths}\"")
    for legacy_path in legacy_hits:
        actions.append(f"# echo \"Review legacy path: {legacy_path}\"")
    if not actions:
        actions.append("# echo \"No actions proposed.\"")
    return actions


def write_report(repo_root: Path, data: Dict[str, object], roots: Sequence[RojoMapping], diagnostics: Sequence[str]) -> Path:
    out_dir = repo_root / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    report_path = out_dir / f"{REPORT_PREFIX}{timestamp}.md"

    files = data["files"]
    whitelisted = data["whitelisted"]
    rojo_mapped = data["rojo_mapped"]
    unclassified = data["unclassified"]
    duplicates = data["duplicates"]
    hashing_errors = data["hashing_errors"]
    oversized_files = data["oversized_files"]
    legacy_hits = data["legacy_hits"]

    lines: List[str] = []
    lines.append("# Safe Repo Audit Report")
    lines.append(f"Generated: {datetime.now().isoformat(timespec='seconds')}")
    lines.append("")
    if diagnostics:
        lines.append("## Diagnostics")
        for message in diagnostics:
            lines.append(f"- {message}")
        lines.append("")
    lines.append("## Summary")
    lines.append(f"- Files scanned: {len(files)}")
    lines.append(f"- Whitelisted: {len(whitelisted)}")
    lines.append(f"- Rojo-mapped: {len(rojo_mapped)}")
    lines.append(f"- Unclassified: {len(unclassified)}")
    if oversized_files:
        lines.append(f"- Files skipped (>25MB): {len(oversized_files)}")
    if hashing_errors:
        lines.append(f"- Hashing errors: {len(hashing_errors)}")
    lines.append("")

    lines.append("## Rojo Roots (valid/missing)")
    if roots:
        for mapping in sorted(roots, key=lambda item: (item.service, item.context, item.relative)):
            status_parts = []
            if mapping.exists:
                status_parts.append("exists")
            else:
                status_parts.append("missing")
            if not mapping.inside_repo:
                status_parts.append("outside repo")
            status = ", ".join(status_parts)
            context_display = mapping.context or mapping.service
            lines.append(f"- {context_display} -> {mapping.relative} ({status})")
    else:
        lines.append("- No Rojo roots discovered.")
    lines.append("")

    lines.append("## File Classification")
    lines.append(f"- Whitelisted samples: {', '.join(whitelisted[:5]) + (' ...' if len(whitelisted) > 5 else '')}" if whitelisted else "- Whitelisted samples: none")
    lines.append(f"- Rojo-mapped samples: {', '.join(rojo_mapped[:5]) + (' ...' if len(rojo_mapped) > 5 else '')}" if rojo_mapped else "- Rojo-mapped samples: none")
    lines.append(f"- Unclassified samples: {', '.join(unclassified[:5]) + (' ...' if len(unclassified) > 5 else '')}" if unclassified else "- Unclassified samples: none")
    if oversized_files:
        lines.append("- Oversized files (skipped hashing):")
        for rel_path, size in oversized_files:
            lines.append(f"  - {rel_path} ({size} bytes)")
    if hashing_errors:
        lines.append("- Hashing errors encountered:")
        for error in hashing_errors:
            lines.append(f"  - {error}")
    lines.append("")

    lines.append("## Duplicate Files")
    lines.extend(format_duplicate_section(duplicates))
    lines.append("")

    lines.append("## Legacy Buckets (matches)")
    if legacy_hits:
        for path in legacy_hits:
            lines.append(f"- {path}")
    else:
        lines.append("- None detected.")
    lines.append("")

    lines.append("## Proposed Actions (commented commands)")
    for action in build_proposed_actions(duplicates, legacy_hits):
        lines.append(action)
    lines.append("")

    report_path.write_text("\n".join(lines), encoding="utf-8")
    return report_path


def main() -> int:
    script_path = Path(__file__).resolve()
    repo_root = script_path.parents[1]
    rojo_roots, diagnostics = load_rojo_mappings(repo_root)
    scan_data = classify_files(repo_root, rojo_roots)
    report_path = write_report(repo_root, scan_data, rojo_roots, diagnostics)
    print(report_path.relative_to(repo_root))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
