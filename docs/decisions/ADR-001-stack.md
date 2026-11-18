# ADR-001: Engine and build stack

Status: Accepted for Stop 1
Date: 2026-11-18

## Decision

Use Godot 4.7.2 with the GL compatibility renderer, GDScript, Android Gradle export templates, OpenJDK 17, and Android SDK/platform-tools 35. The project is built and exported entirely by command-line scripts inside GitHub Codespaces.

## Rejected options

- Unity: paid/additional commercial tooling and heavier editor/build setup for this pipeline.
- Unreal Engine: large downloads, build requirements, and a poor fit for a small 3D mobile prototype.
- Native Android/OpenGL: much larger amount of custom engine work for world streaming and 3D rendering.
- Flutter plus a 3D plugin: weaker native 3D/world-game support and a less complete ecosystem.

## Requirement proof

1. **Runs in Codespaces:** a devcontainer and setup script install the engine and Android SDK; no desktop GUI is required.
2. **One-command release APK:** `make build` invokes a headless Godot Android export.
3. **Large 3D world:** Godot is a full 3D engine, supports chunked scenes/resources, streaming, mobile GL compatibility, and Android export.
4. **Commercial use:** Godot Engine is MIT-licensed and may be used in commercial products; exact third-party licences are tracked in `docs/licenses.md`.
5. **Locked for this stop:** the ADR will remain unchanged through Stop 2. It may change after Stop 2 only with written owner approval.

## Risk

The owner must manually install and test the APK because this Codespace has no Android phone or connected GPU. The report will record that limitation and cannot claim mobile FPS or stability evidence.
