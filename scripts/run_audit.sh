#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$ROOT/scripts/repo_audit.py" --root "$ROOT" --out "$ROOT/out"
echo ""
echo "Manifest written to:"
echo "  $ROOT/out/MANIFEST_LATEST.md"
echo "  $ROOT/out/MANIFEST_LATEST.csv"
echo "  $ROOT/out/MANIFEST_LATEST.json"
