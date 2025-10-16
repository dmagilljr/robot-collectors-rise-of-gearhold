#!/usr/bin/env python3
"""Utility helpers for working with Rojo project files."""
from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, Iterable, Iterator, Tuple

__all__ = [
    "load_rojo",
    "save_rojo",
    "iter_paths_in_tree",
    "rewrite_paths",
]


def load_rojo(path: Path) -> Dict:
    """Load a Rojo project JSON file into a Python dictionary."""
    with path.open("r", encoding="utf-8") as fp:
        return json.load(fp)


def save_rojo(path: Path, obj: Dict, *, dry_run: bool = False, preview_dir: Path | None = None) -> None:
    """Save a Rojo project JSON file.

    If dry_run is True, the file is written to preview_dir / path.name instead.
    """
    target = path
    if dry_run and preview_dir is not None:
        preview_dir.mkdir(parents=True, exist_ok=True)
        target = preview_dir / path.name

    with target.open("w", encoding="utf-8") as fp:
        json.dump(obj, fp, indent=2, sort_keys=True)
        fp.write("\n")


def iter_paths_in_tree(tree: Dict, *, ancestors: Iterable[str] | None = None) -> Iterator[Tuple[Dict, Tuple[str, ...]]]:
    """Yield mapping nodes that contain a `$path` entry within the Rojo tree."""
    ancestors = tuple(ancestors or ())
    for name, value in tree.items():
        if not isinstance(value, dict):
            continue
        current = ancestors + (name,)
        if "$path" in value:
            yield value, current
        if "$children" in value and isinstance(value["$children"], dict):
            yield from iter_paths_in_tree(value["$children"], ancestors=current)
        # Support Rojo 7 tree layout (`children` embedded by name)
        for key in ("children", "tree"):
            if key in value and isinstance(value[key], dict):
                yield from iter_paths_in_tree(value[key], ancestors=current)


def rewrite_paths(obj: Dict, prefix: str = "robot-collectors-new-V1/") -> Tuple[int, Dict]:
    """Rewrite all `$path` values that start with the given prefix.

    Returns (changed_count, new_obj).
    """
    changed = 0

    def _rewrite(tree: Dict) -> None:
        nonlocal changed
        for mapping, _ in iter_paths_in_tree(tree):
            path_value = mapping.get("$path") or mapping.get("path")
            if isinstance(path_value, str) and path_value.startswith(prefix):
                new_value = path_value[len(prefix) :]
                if mapping.get("$path") is not None:
                    mapping["$path"] = new_value
                else:
                    mapping["path"] = new_value
                changed += 1

    _rewrite(obj.get("tree", obj))
    return changed, obj

