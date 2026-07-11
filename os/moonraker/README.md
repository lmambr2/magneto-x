# Optional Moonraker MagXY proxy (A8 lite)

**Default MagXY path:** Klipper `[magneto_linear_motor]` (PR-K7) → manager → ESP32.

This component is an **optional** Moonraker-side HTTP proxy to the same hardened manager (ENABLE/DISABLE only). Use it for dashboards/scripts that speak Moonraker but not Klipper gcode.

## Install

```bash
# Component must be importable as moonraker.components.magneto_magxy
ln -sf ~/magneto-x/os/moonraker/magneto_magxy.py \
       ~/moonraker/moonraker/components/magneto_magxy.py
```

`moonraker.conf`:

```ini
[magneto_magxy]
manager_url: http://127.0.0.1:8880
```

Restart Moonraker, then:

```bash
curl -s http://127.0.0.1:7125/server/magneto_magxy/health
curl -s http://127.0.0.1:7125/server/magneto_magxy/enable
```

## Security

- Still depends on hardened manager allowlist.
- Prefer binding Moonraker auth as usual; do not expose manager on `0.0.0.0`.
