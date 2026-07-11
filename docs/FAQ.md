# FAQ — Magneto X modern stack

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
