# Hardened magneto-manager (PR-M4)

Flask HTTP bridge for MagXY ENABLE/DISABLE and UUID helpers.

**Marker:** source contains `MAGNETO_MANAGER_HARDENED = 1` — install script refuses stock copies without it.

## Defaults

| Setting | Default | Env override |
|---------|---------|--------------|
| Bind | `127.0.0.1:8880` | `MAGNETO_MANAGER_HOST`, `MAGNETO_MANAGER_PORT` |
| Config | `$HOME/printer_data/config/magneto_device.cfg` | `MAGNETO_CONFIG_PATH` |
| Klippy python | `$HOME/klippy-env/bin/python` | `MAGNETO_KLIPPY_PYTHON` |
| Klipper tree | `$HOME/klipper` | `MAGNETO_KLIPPER_DIR` |
| CAN iface | `can0` | `MAGNETO_CAN_IFACE` |
| Resize endpoint | **403** | `MAGNETO_ALLOW_RESIZE=1` to enable |

## Allowlisted serial commands

`ENABLE`, `DISABLE` only (via `/send_command?command=…`).

## Install

From umbrella repo on the printer host:

```bash
./os/install-magneto-services.sh
# optional Magmotor Qt binary copy (not shipped in git):
# ./os/install-magneto-services.sh --with-magmotor
```

## Test locally

```bash
python3 -m unittest discover -s tests -v -p 'test_magneto_manager*.py'
```
