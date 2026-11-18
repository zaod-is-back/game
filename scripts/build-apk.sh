#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-/workspaces/.godot/godot}"
ANDROID_HOME="${ANDROID_HOME:-/workspaces/.android-sdk}"
export ANDROID_HOME
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

cd "$ROOT"
mkdir -p dist build
touch "$ROOT/android/.gdignore"
find "$ROOT/android/build" -type f -name '*.import' -delete

printf '\norg.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64\n' >> "$ROOT/android/build/gradle.properties"
sed -i 's/^org.gradle.java.home=.*$//' "$ROOT/android/build/gradle.properties"
printf 'org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64\n' >> "$ROOT/android/build/gradle.properties"

rm -rf "$ROOT/android/build/src/main/assets" \
  "$ROOT/android/build/src/debug/assets" \
  "$ROOT/android/build/src/release/assets"

cd "$ROOT/android/build"
JAVA_HOME="$JAVA_HOME" ./gradlew --stop >/dev/null 2>&1 || true
cd "$ROOT"

"$GODOT" --headless --path "$ROOT" --import
"$GODOT" --headless --path "$ROOT" --export-release "Android" "$ROOT/dist/zaodworld-stop01-v1.apk"

test -s "$ROOT/dist/zaodworld-stop01-v1.apk"
sha256sum "$ROOT/dist/zaodworld-stop01-v1.apk" | tee "$ROOT/dist/zaodworld-stop01-v1.apk.sha256"
mkdir -p "$ROOT/z"
cp "$ROOT/dist/zaodworld-stop01-v1.apk" "$ROOT/z/zw.apk"
sha256sum "$ROOT/z/zw.apk" | tee "$ROOT/z/zw.apk.sha256"
ls -lh "$ROOT/dist/zaodworld-stop01-v1.apk"
ls -lh "$ROOT/z/zw.apk"
