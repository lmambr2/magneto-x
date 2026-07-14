# Modern host image for Magneto X

## Preferred: Raspberry Pi 5 + MainsailOS arm64

Full checklist: **[RPI5_BRINGUP.md](RPI5_BRINGUP.md)**

| Item | Value |
|------|--------|
| Image | `2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz` |
| Download | `./os/download-mainsailos.sh rpi5` |
| Flash | `BOARD=rpi5 sudo ./os/flash-mainsailos-sd.sh /dev/sdX` |
| Stack | `./os/postinstall-magneto.sh` |

Pi Imager can preconfigure Wi‑Fi/SSH. Same USB cabling as OPi (Octopus, CAN hub, MagXY, cam, touch).

## Stock Peopoly situation

Peopoly ships an **Armbian-based MainsailOS** image:

- User: `pi` / password: `armbian`
- Tags (mirror repo): `magneto-x-mainsailOS-2024-2-12-v1.0.9` … `2024-4-8-v1.1.1`
- Online update package version strings up to ~`v1.1.3` / `v1.1.4`
- Bundles ancient Klipper tree, Moonraker, Mainsail, KlipperScreen, Qt5 Magmotor, magneto-manager

Prefer official Peopoly TF images only as recovery baseline — not for long-term.

## Alternate hosts

### Option A — Orange Pi Zero 2 (lab bridge / legacy)

- Docs: https://docs.mainsail.xyz/mainsailos/supported-sbcs/orange-pi-zero-2/
- `./os/download-mainsailos.sh opi-zero2`
- `BOARD=opi-zero2 sudo ./os/flash-mainsailos-sd.sh /dev/sdX`
- Then same postinstall as Pi 5
- Keep cam at **720p15** for 1 GB RAM

### Option B — Fresh Armbian / Raspberry Pi OS + KIAUH

1. Install OS for your board  
2. KIAUH → Klipper / Moonraker / Mainsail / Crowsnest  
3. `./os/postinstall-magneto.sh`

### Option C — Keep Peopoly image, only upgrade Klipper

Fastest to “get motion,” worst long-term — bridge only.

## Hardware hooks the OS must provide

| Need | Detail |
|------|--------|
| USB to Octopus | Type-C data — `/dev/serial/by-id/usb-Klipper_stm32h723xx_*` |
| USB-CAN to toolhead | Linux Hub PCB — `can0` @ **250 kbit** (`gs_usb` `1d50:606f`) |
| USB-serial to ESP32 | CH340 — magneto-manager opens “USB Serial” @ 115200 |
| Display | Micro-HDMI + USB touch (stock panel) |
| WiFi | Host onboard / USB antenna as shipped |
| Qt5 libs | Required only if you run the `Magmotor` GUI binary |
| Beacon (optional) | USB to host — [optional/beacon.cfg](../config/optional/beacon.cfg) |

Preferred host: **Raspberry Pi 5** ([RPI5_BRINGUP.md](RPI5_BRINGUP.md)).

## nginx timeouts (large OrcaSlicer uploads)

From the community FAQ — add under `http {` in `/etc/nginx/nginx.conf`:

```nginx
proxy_send_timeout 500s;
proxy_read_timeout 500s;
fastcgi_send_timeout 500s;
fastcgi_read_timeout 500s;
```

Then `sudo systemctl restart nginx`.

## Linux MCU (optional)

Klipper can also run an MCU process on the Orange Pi itself (`make menuconfig` → Linux process). Magneto X **does not require** this for stock motion (Octopus + toolhead CAN cover I/O). Only add a Linux MCU if you want host GPIO (extra fans, LEDs) without wiring to the Octopus.

## Image build automation (later)

If you want a reproducible custom image:

1. Fork/build via [MainsailOS](https://github.com/mainsail-crew/MainsailOS) Armbian board config for `orangepizero2`.
2. Add a post-install script that:
   - clones `lmambr2/magneto-x-klipper` @ `magneto-x`
   - installs magneto-manager systemd unit
   - drops default `printer_data/config` from this repo
   - enables `can0`

That is more work than Option A and can wait until the fork boots cleanly on real hardware.

## Safety notes

- **48 V** linear motors: enable only when clear of jams; use `LM_DISABLE` after prints.
- Kill / fault pin `PG11` on Octopus pauses and cools in stock config — keep it.
- Never flash random ESP32 firmware without a recovery plan (UART boot).
