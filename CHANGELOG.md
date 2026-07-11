# Changelog

All notable changes to the **magneto-x** umbrella and companion **magneto-x-klipper** tracks.

## Unreleased / main (2026-07-11)

### Config — KAMP as default

- **KAMP** (community adaptive mesh/purge) is **default ON** in the config package:
  - `Adaptive_Meshing.cfg` enabled in `KAMP_Settings.cfg` (was commented)
  - `PRINT_START` uses `BED_MESH_CALIBRATE` + `LINE_PURGE` (no static default mesh / hard-coded purge)
  - Removed conflicting `BED_MESH_CALIBRATE` wrapper from `macros.cfg` (KAMP owns the name)
  - Magneto Z re-home kept inside `KAMP/Adaptive_Meshing.cfg`
  - `mesh_margin: 5` default; slicer Label Objects recommended for true adaptive bounds

### Config — parametric PRINT_START + FULL_CALIBRATE + Orca pack

- **Parametric `PRINT_START`**: Orca-compatible `EXTRUDER`/`BED`/`CHAMBER`, optional `MESH=`/`PURGE=`; heat → QGL → KAMP mesh → purge.
- **`FULL_CALIBRATE`**: one-button self-check (`SAVE=1` persists mesh; `SHAPER=1` optional). `FULL_CALIBRATE_BED` is an alias.
- **`CANCEL_PRINT`**: turns off Jetstream if present and **`LM_DISABLE`** MagXY immediately.
- **`slicer/orca/`**: machine start/end G-code snippets, process notes, Label Objects checklist (does not re-vendor full Orca JSON).

### Moonraker update_manager (v0.8)

- Do **not** add `[update_manager klipper]` on Moonraker v0.8 — conflicts with built-in updater (“Extension klipper already added” / unparsed options).
- Track host via `~/klipper` git remote → `lmambr2/magneto-x-klipper`; snippet + postinstall updated; FAQ documents fix.

### Config / CI P1 (audit follow-ups)

- `QUAD_GANTRY_LEVEL` and `LEVEL_BED` call `LM_ENABLE` before motion (bare panel QGL safe).
- `check_includes` MagXY path: require active `[magneto_linear_motor]` **or** uncommented `LINEAR_MOTOR_*` shells (commented stubs no longer pass CI).

### Clean OS (1B) prep

- Lab pre-reimage backup under `backups/pre-clean-os-*` (local; device IDs not for public push).
- MainsailOS **3.0.0** Orange Pi Zero 2 image cached under `backups/mainsailos-images/` (gitignored).
- Runbook: `docs/CLEAN_OS_REFRESH.md`; restore helper: `os/restore-after-clean-os.sh`.
- Physical flash still requires boot media offline — cannot complete over SSH alone.

### Audit findings sweep (remaining B2–B11)

- Hot mesh defaults: `CREATE_BED_MESH` / `FULL_CALIBRATE` use `BED=60` (BED=0 cold).
- `PRINT_START` calls `SMART_PARK` after mesh; `PARK=0` to skip.
- QGL skips full re-home when already XYZ-homed.
- Startup `delayed_gcode` loads bed_mesh profile `default` if present.
- Timelapse stub soft no-ops for TIMELAPSE_*/HYPERLAPSE; FAQ updated.
- `MAGNETO_MANAGER_VERSION` macro; OS name kept as alias with clear description.
- `heater_bed` `min_temp: 0` (was −200); input_shaper comments as seed-only; SET_XYZ expert warn.

### CI / lint / tests

- `scripts/check_config_policy.py` — Magneto footguns (KAMP single owner, parametric PRINT_START / FULL_CALIBRATE, Moonraker snippet, Orca start G-code, SAVE_CONFIG format, manager hardening, defconfigs, core MD links).
- `config/timelapse.cfg` stub so offline includes resolve; host still replaces with real moonraker-timelapse link.
- `scripts/check_md_links.py`, `requirements-dev.txt`, `pyproject.toml` (ruff), `.pre-commit-config.yaml`.
- `scripts/ci-magneto.sh` runs includes + policy + md links + bash -n + shellcheck + ruff + unittest.
- Expanded manager HTTP/allowlist tests; `tests/test_macros_policy.py` for macros / SAVE_CONFIG / Orca.
- GitHub Actions `.github/workflows/magneto-ci.yml` installs shellcheck + dev deps.

### Lab deploy / S3 (2026-07-11 evening)

- S3 **draft** report: `docs/validation/S3_HARDWARE_REPORT-20260711-mainsailos-draft.md` (bridge path; short print still open).
- OriginMove Y endstop fixed to min (`position_endstop: 0`).
- Moonraker `update_manager` → `lmambr2/magneto-x-klipper` (+ optional umbrella `magneto-x`); postinstall merges snippet.
- Timelapse macros: `[include timelapse.cfg]` in package `printer.cfg`.
- `os/can0-txqueuelen.service`; postinstall enables; FAQ/MIGRATION clarify clean OS (1B) vs bridge C1.

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
