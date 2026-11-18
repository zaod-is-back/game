#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-/workspaces/.godot/godot}"

cd "$ROOT"
"$GODOT" --headless --path "$ROOT" --editor --quit
"$GODOT" --headless --path "$ROOT" --import
test -f project.godot
test -f export_presets.cfg
test -f dist/zaodworld-stop23-v1.apk
test -s dist/zaodworld-stop23-v1.apk
grep -q 'BUILD_NUMBER := "zaodworld-stop23-v1"' scripts/main.gd
grep -q 'CharacterBody3D' scripts/main.gd
grep -q '_setup_world' scripts/main.gd
grep -q 'InputEventScreenTouch' scripts/main.gd
echo "Stop 2 and 3 combined automated checks passed"
