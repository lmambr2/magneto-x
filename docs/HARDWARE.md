# Magneto X — stock hardware support (clean OS)

**Goal:** every factory interface works on MainsailOS + magneto-x postinstall — not a stripped “Klipper only” image.

| Hardware | Interface | Package / postinstall |
|----------|-----------|------------------------|
| BTT Octopus Pro (motion MCU) | USB serial `usb-Klipper_stm32h723xx_*` | `magneto_device.cfg` + klipper fork |
| Lancer toolhead (RP2040) | CAN @ **250 kbit** via Linux Hub | `can0.network`, `canbus_uuid` |
| Linux Hub (gs_usb) | USB `1d50:606f` | `modprobe gs_usb`, CAN unit |
| MagXY ESP32 bridge | USB CH340 `USB Serial` | hardened `magneto-manager` + `[magneto_linear_motor]` |
| 7″ IPS panel | HDMI + USB touch (`1a86:e5e3`) | **HelixScreen** (default) |
| Stock USB webcam | UVC (lab: `0c45:6366`) | **Crowsnest** + Mainsail `/webcam/` |
| Bed / heaters / fans / load cell | Octopus + toolhead pins | `printer.cfg`, `magneto_toolhead.cfg`, `magneto_load_cell` |
| ADXL (if present) | Toolhead SPI | toolhead config |
| Filament runout | Toolhead GPIO gpio29 | **default ON** `optional/runout_double_check.cfg` |
| MCU temps | temperature_mcu | **default ON** `optional/mcu_temps.cfg` |
| Timelapse | crowsnest + moonraker-timelapse | **enabled** when component present |
| Shake&Tune | ADXL + [klippain-shaketune](https://github.com/Frix-x/klippain-shaketune) | **default ON** via `install-shaketune.sh` |
| KlipperCortex | Webcam + [KlipperCortex](https://github.com/Vladush/KlipperCortex) vision | **install ON**; enable after `.vmfb` compile |

## Install path

```bash
./os/postinstall-magneto.sh
# installs: CAN, manager, config, HelixScreen, Crowsnest (defaults ON)
```

Opt-outs (not recommended for stock machines):

| Flag | Skips |
|------|--------|
| `--skip-helixscreen` | Local touch UI |
| `--skip-crowsnest` | Webcam stream |
| `--skip-klipper-clone` | Host tree swap |

Standalone:

```bash
./os/install-helixscreen.sh
./os/install-crowsnest.sh
./os/install-crowsnest.sh --configure-only   # after plugging cam later
```

## Webcam URLs

After crowsnest is up:

- Stream: `http://<host>/webcam/?action=stream`
- Snapshot: `http://<host>/webcam/?action=snapshot`

Moonraker `[webcam Magneto]` is appended so Mainsail/Helix list the camera.

**Orange Pi Zero 2 RAM:** package default is **1280×720 @ 15 fps**. Stock marketing is 1080p30 — raise in `crowsnest.conf` only if `free -h` shows comfortable headroom.

## Not redistributed (obtain privately)

| Item | Why |
|------|-----|
| Magmotor / MagnetoWifiHelper binaries | Proprietary (D13) — optional `--with-magmotor` from local Peopoly tree |
| Peopoly MagXY touchscreen panels | Custom KlipperScreen — HelixScreen is the OSS panel path |

## Validation checklist

```bash
ls /dev/serial/by-id/          # Octopus + MagXY CH340
ip -br link show can0          # UP, LOWER_UP
curl -s http://127.0.0.1:8880/health
curl -s http://127.0.0.1:7125/printer/info   # ready
systemctl is-active helixscreen crowsnest magneto-manager klipper moonraker
curl -sI http://127.0.0.1:8080/?action=stream | head -5   # crowsnest direct
lsusb | grep -iE '0c45|1d50|1a86|cam'
```

See also: [CLEAN_OS_REFRESH.md](CLEAN_OS_REFRESH.md), [OS_IMAGE.md](OS_IMAGE.md), [SECURITY.md](SECURITY.md).
