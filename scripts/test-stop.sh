#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-/workspaces/.godot/godot}"

cd "$ROOT"
"$GODOT" --headless --path "$ROOT" --editor --quit
"$GODOT" --headless --path "$ROOT" --import
test -f project.godot
test -f export_presets.cfg
test -f dist/zaodworld-stop01-v1.apk
test -s dist/zaodworld-stop01-v1.apk
echo "Stop 1 automated checks passed"
