# Stop 01 report

## Goal

Build a command-line foundation from a clean Codespace to an installable Android APK.

## Build

Run:

```bash
make setup
make build
```

APK: `dist/zaodworld-stop01-v1.apk`

## Automated evidence

Commands run:

```bash
make setup
make build
make test
```

Observed output:

- `make build` completed with `DONE export`.
- APK: `dist/zaodworld-stop01-v1.apk`
- Testing copy: `z/zw.apk`
- APK size: 72 MB
- SHA-256: `a9106b9142cfda7795c1bbbc37f5108667f508549624557a5ad1a9dea2e47bc3`
- `make test` ended with `Stop 1 automated checks passed`.

## Acceptance checks

- Clean setup installs Godot and Android SDK dependencies.
- `make build` exits successfully and creates a non-empty APK.
- The start screen shows "ZAOD WORLD" and the build number.
- The app starts without crashing.

## Manual owner checklist

- Install `zaodworld-stop01-v1.apk`.
- Open the app.
- Confirm "ZAOD WORLD" is visible.
- Confirm a build number is visible.
- Confirm the app remains open and does not crash.
- Reply `PASS` or `FAIL` and include phone behaviour, a screenshot, or a log.

## Limitations

This environment cannot test the APK on the owner's phone or measure real Android FPS. Any such values must remain unreported until the owner provides manual evidence.
