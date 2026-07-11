# Changelog

All notable changes to the **magneto-x** umbrella and companion **magneto-x-klipper** tracks.

## Unreleased / main (2026-07-11)

### Host / MagXY

- **PR-K7:** `[magneto_linear_motor]` native ENABLE/DISABLE (http→hardened manager or serial); replaces shell curls for MagXY.
- **PR-M4:** Hardened magneto-manager (localhost, allowlist, no shell=True).
- Dual tracks: `magneto-x` (Klipper3d) and `magneto-x-kalico` (Kalico).

### Config package

- Parse-ready `config/` with OriginMove default, cleaned PAUSE, LINEAR-only MagXY naming.
- Optional: runout double-check, MCU temps, firmware retraction, client variables, danger_options (Kalico), Beacon notes, nginx timeouts.
- Sample `moonraker.conf.sample` + update_manager snippet.

### Klipper fork extras

- `magneto_load_cell` dwell (K2), sticky probe D7 (K3), shell PARAMS reject (K5).
- Optional `MAGNETO_RELAX_STEPPER_PAST` (default n).
- Guard + unit tests + GitHub Actions.

### Host tooling

- `os/postinstall-magneto.sh`, `os/install-magneto-services.sh`, `can0` @ 250k + txqueuelen 512.
- `scripts/preflight-magneto.sh`, `scripts/ci-magneto.sh`.
- Optional Moonraker component `os/moonraker/magneto_magxy.py` (A8 lite).

### Docs

- DESIGN, MIGRATION, SECURITY, FAQ, MCU_BUILD, FIELD_FACTS, TRACKS, STATUS, COMMUNITY_ESP32, CONTRIBUTING.

## How to update a running printer

```bash
cd ~/magneto-x && git pull
cd ~/klipper && git fetch origin && git checkout magneto-x && git pull   # or magneto-x-kalico
# reinstall manager if needed:
~/magneto-x/os/install-magneto-services.sh
# rsync config carefully; keep your magneto_device.cfg UUIDs
sudo systemctl restart klipper moonraker magneto-manager
```

MCU flash still manual from same HEAD — see `docs/MCU_BUILD.md`.
