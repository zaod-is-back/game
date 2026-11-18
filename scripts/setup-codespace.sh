#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_HOME="${ANDROID_HOME:-/workspaces/.android-sdk}"
GODOT_VERSION="4.7.2"
GODOT_ROOT="${GODOT_ROOT:-/workspaces/.godot}"

sudo apt-get update
sudo apt-get install -y wget unzip openjdk-17-jdk ca-certificates fontconfig

mkdir -p "$ANDROID_HOME" "$GODOT_ROOT"

if [[ ! -x "$GODOT_ROOT/godot" ]]; then
  curl -fL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -o /tmp/godot.zip
  unzip -q /tmp/godot.zip -d /tmp/godot
  find /tmp/godot -type f -name 'Godot_*_linux.x86_64' -exec install -m 0755 {} "$GODOT_ROOT/godot" \;
  rm -rf /tmp/godot /tmp/godot.zip
fi

if [[ ! -f "$GODOT_ROOT/templates.txt" ]]; then
  curl -fL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -o /tmp/godot-templates.tpz
  unzip -q /tmp/godot-templates.tpz -d /tmp/godot-templates
  mkdir -p "$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
  cp -a /tmp/godot-templates/templates/. "$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable/"
  printf '%s\n' "$GODOT_VERSION" > "$GODOT_ROOT/templates.txt"
  rm -rf /tmp/godot-templates /tmp/godot-templates.tpz
fi

if [[ ! -f "$ROOT/android/build/build.gradle" ]]; then
  mkdir -p "$ROOT/android/build"
  unzip -q "$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable/android_source.zip" -d "$ROOT/android/build"
fi

touch "$ROOT/android/.gdignore"
find "$ROOT/android/build" -type f -name '*.import' -delete
printf '%s.stable\n' "$GODOT_VERSION" > "$ROOT/android/.build_version"
grep -q '^org.gradle.java.home=' "$ROOT/android/build/gradle.properties" 2>/dev/null \
  && sed -i 's|^org.gradle.java.home=.*|org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64|' "$ROOT/android/build/gradle.properties" \
  || printf 'org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64\n' >> "$ROOT/android/build/gradle.properties"

if [[ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
  curl -fL "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -o /tmp/android-tools.zip
  rm -rf /tmp/android-tools
  unzip -q /tmp/android-tools.zip -d /tmp/android-tools
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  mv /tmp/android-tools/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
  rm -rf /tmp/android-tools /tmp/android-tools.zip
fi

yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-35" "build-tools;35.0.0"

cat <<EOF
Setup complete
Godot: $GODOT_ROOT/godot
Android SDK: $ANDROID_HOME
EOF
