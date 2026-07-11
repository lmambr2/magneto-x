# FAQ — Magneto X modern stack

## Moonraker

### Warnings: `Extension klipper already added` / Unparsed `[update_manager klipper]` options

On **Moonraker v0.8.x** (Peopoly MainsailOS image), the update manager **always** registers a built-in `klipper` app. A second config section:

```ini
[update_manager klipper]
type: git_repo
path: ~/klipper
origin: https://github.com/lmambr2/magneto-x-klipper.git
…
```

is rejected and shows as unparsed options. **Remove that section** from `moonraker.conf`.

Track the host fork with **git**, not a conflicting Moonraker section:

```bash
cd ~/klipper
git remote -v   # should be lmambr2/magneto-x-klipper
git branch      # magneto-x or magneto-x-kalico
```

See `config/moonraker-update-manager.conf.snippet`. Restart Moonraker after editing.

### `[update_manager magneto-x]` invalid / missing `.release_info`

Only enable that section if `~/magneto-x` is a real `git clone` (has `.git`). An rsync tree without git will log checksum / release_info noise — comment the section out.

## Timelapse

### Unknown command `HYPERLAPSE` / `_SET_TIMELAPSE_SETUP`

Moonraker has `[timelapse]` but Klipper never loaded the **real** macros.

1. Ensure `[include timelapse.cfg]` in `printer.cfg` (package does).
2. **Replace the package stub** with the real component macros:

```bash
ln -sfn ~/moonraker-timelapse/klipper_macro/timelapse.cfg \
       ~/printer_data/config/timelapse.cfg
```

Then `RESTART`. The package ships a **soft stub** (no-op `TIMELAPSE_TAKE_FRAME`) so a slicer frame command will not hard-abort prints — but it will **not** record until the real file is linked.

To disable timelapse entirely: comment out `[timelapse]` in `moonraker.conf` and remove the include; restart moonraker + klipper.

## KAMP (adaptive mesh / purge)

### Is KAMP part of Klipper?

No. **KAMP** ([kyleisah/KAMP](https://github.com/kyleisah/KAMP)) is community macros. This package vendors it under `config/KAMP/` and enables it by default via `KAMP_Settings.cfg`.

### What does PRINT_START do now?

Parametric (Orca-compatible):

1. Cancel pending MagXY auto-disable  
2. `LM_ENABLE` → home if needed  
3. `M190` if `BED=` passed (no-op if already hot)  
4. `QUAD_GANTRY_LEVEL`  
5. **`BED_MESH_CALIBRATE`** (KAMP adaptive; full bed without labels)  
6. `M109` if `EXTRUDER=` passed  
7. **`LINE_PURGE`**

Optional flags: `MESH=0`, `PURGE=0`, `CHAMBER=` (logged only).  
Stock Orca start G-code already heats then calls  
`PRINT_START EXTRUDER=… BED=…` — see [`slicer/orca/`](../slicer/orca/).

### Self-check without printing

```text
FULL_CALIBRATE              # LM_ENABLE, G28, QGL, mesh
FULL_CALIBRATE SAVE=1       # also SAVE mesh profile default + SAVE_CONFIG
FULL_CALIBRATE SHAPER=1     # optional input shaper (usually skip on MagXY)
```

QGL is **session-only** (not stored by `SAVE_CONFIG`). Mesh can be persisted with `SAVE=1`.

### Adaptive mesh always probes the whole bed

Slicer must emit object labels (`EXCLUDE_OBJECT_DEFINE`) before mesh. Enable **Label objects** / **Exclude Object** in Orca/PrusaSlicer/SuperSlicer. Without labels KAMP falls back to full-bed mesh (still valid).

Also require `[exclude_object]` in `printer.cfg` (already present in this package).

### Which Orca profile?

Use system **Peopoly → Magneto X** (300×400 bed). Overlay machine start G-code from [`slicer/orca/machine_start_gcode.txt`](../slicer/orca/machine_start_gcode.txt) if you want the documented Magneto-modern comments; stock Orca start already works with parametric `PRINT_START`.

### Can I turn KAMP features off?

In `KAMP_Settings.cfg`, comment individual includes. If you disable `Adaptive_Meshing.cfg`, restore a plain `BED_MESH_CALIBRATE` wrapper in `macros.cfg` (or call the built-in only). Do not leave two `BED_MESH_CALIBRATE` macros defined.

## Networking / uploads

### Large Orca / PrusaSlicer uploads fail

Raise nginx timeouts under `http {` in `/etc/nginx/nginx.conf`.
Snippet in-repo: `config/optional/nginx-timeouts.conf.snippet`.

```nginx
proxy_send_timeout 500s;
proxy_read_timeout 500s;
fastcgi_send_timeout 500s;
fastcgi_read_timeout 500s;
```

`sudo systemctl restart nginx`.

## Motion / MagXY

### XY homes the wrong way / axes feel swapped

Published default is **OriginMove** (X=300 / Y=400). For factory stock orientation, in `printer.cfg`:

```ini
# [include optional/origin_move.cfg]
[include motion_xy_stock.cfg]
```

Only one of the two includes.

### `No trigger on stepper_y after full movement`

Y is almost always homing the **wrong direction**. On stock Peopoly and this lab unit the Y endstop is at **min (0)**, not max:

```ini
# optional/origin_move.cfg — [stepper_y]
position_endstop: 0
position_max: 400
```

A draft that used `position_endstop: 400` homes toward max and never hits the switch. After changing, `RESTART` / `FIRMWARE_RESTART`, then `G28 Y` alone to verify.

### Clean OS vs bridge (did we reimage?)

| Path | What it is |
|------|------------|
| **A / 1B clean OS** | New MainsailOS Armbian image + `postinstall-magneto.sh` |
| **C1 bridge** | Keep Peopoly `magneto-x-mainsailOS-*` image; hardened manager + modern Klipper |

Lab unit work so far is **C1 bridge** (Peopoly OS still present: Magmotor/`auto-uuid`, `magnetox-os-update`). Clean OS is still the long-term v1 path; it is **not** required for S3 motion once modern host+MCUs work.

### `LM_ENABLE` does nothing

1. Config has `[magneto_linear_motor]` and host is magneto-x-klipper with PR-K7  
2. `curl -s http://127.0.0.1:8880/health` — serial connected?  
3. ESP32 on CH340 “USB Serial”?  
4. Hardened manager running (http backend default)  
5. `MAGNETO_LINEAR_STATUS` for backend/errors  

### Probe: “triggered prior to movement”

Load-cell latch sticky. Modern stack: auto-clear + D7 one retry then hard fail. Manually: `CLEAR_LOAD_CELL` / `LC28` before Z home. Probe speed **0.5** mm/s (not 2.0).

### “Stepper too far in past”

Stock Peopoly disabled this in MCU code. Our fork defaults **relax = off**. Stock bins may already relax. Do not enable `MAGNETO_RELAX_STEPPER_PAST` until S3 A/B on modern firmware. Field configs already use `step_pulse_duration: 0.0000002` (200 ns).

## CAN / toolhead

### MAG_TOOL offline

```bash
lsusb   # expect 1d50:606f for stock hub
ip -d link show can0   # bitrate 250000
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

Bitrate **250 kbit** on stock Linux Hub — not 1 Mbit.

## Host tracks

### Mainline vs Kalico?

Both supported. Start with `magneto-x` if unsure. Switch: [TRACKS.md](TRACKS.md). Same config package; Kalico-only: `optional/danger_options.cfg`.

## Pause / resume broken in Mainsail

Duplicate PAUSE macros. Our package: PAUSE only in `macros.cfg`; `mainsail.cfg` has none.

## `force_move` / STEPPER_BUZZ / recovery moves

`[force_move] enable_force_move: True` is on for Magneto recovery culture.
It can move axes **without** normal soft limits and with MagXY still armed.
**Prefer `LM_DISABLE` first.** Expert-only; easy to crash the toolhead.

## Beacon / Eddy / HX717 load cell

Not stock. Require hardware redesign. Keep `magneto_load_cell` on Lancer.
See `config/optional/alt_hardware_notes.cfg` and community alt-stack guides.

## Where are Magmotor binaries?

Not in this repo (proprietary). Copy from Peopoly `magnetox-os-update` / stock image; optional `./os/install-magneto-services.sh --with-magmotor` if the tree is present locally.

## Preflight on the host

```bash
~/magneto-x/scripts/preflight-magneto.sh
```

Checks USB CAN `1d50:606f`, can0 @ 250k / txqueuelen, manager health/allowlist, K7 files, config placeholders.

## Troubleshooting tree (LM_ENABLE fail)

```
LM_ENABLE fails?
├─ manager down → systemctl status magneto-manager; install hardened
├─ health disconnected → ESP32 USB, CH340, permissions (dialout)
├─ 400 command not allowed → good (allowlist); use ENABLE only
├─ curl to wrong host → must be 127.0.0.1 from printer
└─ shell module missing → wrong Klipper tree / branch
```

## Filament runout on gpio29

Optional: `[include optional/runout_double_check.cfg]` (EmperorArthur-style delayed double-check). Do not also enable stock `filament_switch_sensor` on the same pin.
