# Magneto X config package

Parse-ready Klipper configs for [magneto-x](https://github.com/lmambr2/magneto-x) / [magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper).

**Not affiliated with Peopoly.** Fill in your own MCU serial / CAN UUID before use.

## Deploy

1. On the printer host, back up `~/printer_data/config`.
2. Copy this directory’s contents into `~/printer_data/config/` (or merge carefully).
3. Edit **`magneto_device.cfg`**:
   - `[mcu] serial:` → your Octopus path under `/dev/serial/by-id/`
   - `[mcu MAG_TOOL] canbus_uuid:` → toolhead CAN UUID  
     (`~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0`)
4. Choose **exactly one** motion profile in `printer.cfg`:
   - **OriginMove** (**default**): `[include optional/origin_move.cfg]`  
     Driver1 = X 300 mm, Driver0 = Y 400 mm (many field machines + lab unit)  
   - **Stock Peopoly XY**: comment OriginMove, enable  
     `[include motion_xy_stock.cfg]`  
     Driver0 = X 400 mm, Driver1 = Y 300 mm
5. Ensure host Klipper includes Magneto extras from **magneto-x-klipper**:
   - default branch **`magneto-x`** (mainline), or  
   - **`magneto-x-kalico`** for Kalico A/B (see [docs/TRACKS.md](../docs/TRACKS.md)).
6. magneto-manager must answer on `http://127.0.0.1:8880` for `LM_ENABLE` / `LM_DISABLE`.
7. `FIRMWARE_RESTART` and home carefully (`LM_ENABLE` is required before XY motion).

## Layout

| File | Role |
|------|------|
| `printer.cfg` | Top-level includes + bed/Z/fans/homing |
| `mainsail.cfg` | Virtual SD, pause_resume, CANCEL — **no PAUSE/RESUME** |
| `macros.cfg` | PAUSE/RESUME, LM_*, print start/end |
| `shell_command.cfg` | Optional shell fallback (MagXY uses `[magneto_linear_motor]` PR-K7) |
| `magneto_device.cfg` | MCU serial + CAN UUID placeholders |
| `magneto_toolhead.cfg` | Lancer extruder, load cell, ADXL, fans |
| `motion_xy_stock.cfg` | Default XY + probe/QGL/mesh |
| `optional/origin_move.cfg` | Alternate XY orientation |
| `KAMP_Settings.cfg` + `KAMP/` | Adaptive purge / smart park |
| `macros.cfg.stock-v1.1.3` | **Reference only** — not included |

## Defaults worth knowing

- Probe **speed: 0.5** mm/s (stock load-cell accuracy; avoid 2.0)
- Shell surface: **LINEAR_MOTOR_*** only (no `hello_world`, no `LINER_*` shell cmds)
- `LINER_MOTOR` gcode macro is a thin alias to `LINEAR_MOTOR` for old panels
- Stock CAN hub is typically **250 kbit** (not 1M)

## Validate package

From the repo root:

```bash
python3 scripts/check_includes.py config
```

Exit code 0 means every `[include …]` from `printer.cfg` resolves inside the package.

## Optional profiles

| Profile | How to enable |
|---------|----------------|
| OriginMove XY | **Default** `optional/origin_move.cfg` |
| Stock Peopoly XY | Swap include → `motion_xy_stock.cfg` |
| Kalico `danger_options` | **Only** on host branch `magneto-x-kalico`: uncomment `[include optional/danger_options.cfg]` |
| nginx large uploads | Host: merge `optional/nginx-timeouts.conf.snippet` into nginx (not Klipper) |
| Beacon/Eddy/HX notes | Comments only: `optional/alt_hardware_notes.cfg` (no active sections) |
