#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

mkdir -p "${REPO_ROOT}/out"

REPORT_PATH="$(python3 "${REPO_ROOT}/scripts/safe_repo_audit.py")"

echo "Report generated at: ${REPORT_PATH}"
