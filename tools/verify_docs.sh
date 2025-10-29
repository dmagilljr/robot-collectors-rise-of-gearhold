#!/bin/bash
set -e
echo "🔍 Verifying canonical doc integrity..."
for f in docs/PROJECT_OVERVIEW.md docs/TECH_AUDIT.md docs/ROADMAP.md docs/STYLE_GUIDE.md docs/SETUP_GUIDE.md; do
  [[ -f "$f" ]] || { echo "❌ Missing $f"; exit 1; }
  grep -q "Robot Collectors: Rise of Gearhold" "$f" || echo "⚠️ Missing project name in $f"
  grep -q "v0.6.3-pre" "$f" || echo "⚠️ Missing version tag in $f"
  grep -q "Gameplay Loop" "$f" || echo "⚠️ Missing Gameplay Loop mention in $f"
  grep -q "ChatGPT ↔ Codex Alignment" "$f" || echo "⚠️ Missing alignment line in $f"
  grep -q "Related: \[Project Overview\]" "$f" || echo "⚠️ Missing footer in $f"
done
echo "✅ Doc check complete."
