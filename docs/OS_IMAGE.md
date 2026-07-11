# Modern host image for Magneto X (Orange Pi Zero 2)

## Stock situation

Peopoly ships an **Armbian-based MainsailOS** image:

- User: `pi` / password: `armbian`
- Tags (mirror repo): `magneto-x-mainsailOS-2024-2-12-v1.0.9` … `2024-4-8-v1.1.1`
- Online update package version strings up to ~`v1.1.3` / `v1.1.4`
- Bundles ancient Klipper tree, Moonraker, Mainsail, KlipperScreen, Qt5 Magmotor, magneto-manager

The mirror repo (`mypeopoly/magneto-x-os-mirror`) often only holds **git tags / LFS pointers**, not a convenient local blob. Prefer downloading official Peopoly TF images from their wiki when you need a recovery baseline.

## Recommended modern path

### Option A — Official MainsailOS for Orange Pi Zero 2 (preferred)

Mainsail documents Orange Pi Zero 2 as a supported Armbian-based target:

- Docs: https://docs.mainsail.xyz/mainsailos/supported-sbcs/orange-pi-zero-2/
- Flash guide: https://docs.mainsail.xyz/mainsailos/getting-started/armbian/

Steps:

1. Flash **current MainsailOS** for **Orange Pi Zero 2** (Armbian) to a quality SD card (32 GB+ A2 recommended).
2. First boot, SSH as the image’s default user (check MainsailOS docs for current defaults — Peopoly used `pi`/`armbian`; stock MainsailOS may differ).
3. `sudo apt update && sudo apt full-upgrade` (reboot if kernel updates).
4. Install **CAN** for the Linux Hub USB-CAN adapter (often `slcan` or `gs_usb` depending on hub chip):

   ```bash
   # Example for gs_usb style adapters — verify with lsusb
   sudo ip link set can0 up type can bitrate 1000000
   # Persist via systemd-networkd or a udev + oneshot service (see os/can0.network)
   ```

5. Point Klipper at **your fork** (`magneto-x-modern`) — not `Klipper3d/klipper` alone, and not `mypeopoly/Klipper`.
6. Install magneto-manager + Magmotor deps from `os/install-magneto-services.sh`.
7. Deploy `config/` from this workspace.
8. Flash MCUs with firmware built from the same host tree.

### Option B — Fresh Armbian + KIAUH

1. Armbian CLI for Orange Pi Zero 2 from https://www.armbian.com/orange-pi-zero-2/
2. Install KIAUH → Klipper / Moonraker / Mainsail / Crowsnest / optional KlipperScreen.
3. Same fork remote + services as Option A.

### Option C — Keep Peopoly image, only upgrade Klipper

Fastest to “get motion,” worst long-term:

1. Boot stock image.
2. Replace `~/klipper` with `magneto-x-modern`.
3. Rebuild both MCU firmwares.
4. Keep magneto-manager / Magmotor as-is.

Use this only as a **bridge** while validating MagXY + load-cell behavior.

## Hardware hooks the OS must provide

| Need | Detail |
|------|--------|
| USB to Octopus | Type-C data — `/dev/serial/by-id/usb-Klipper_stm32h723xx_*` |
| USB-CAN to toolhead | Linux Hub PCB — `can0` @ 1 Mbit |
| USB-serial to ESP32 | CH340 — magneto-manager opens “USB Serial” @ 115200 |
| Display | Micro-HDMI + USB touch (stock panel) |
| WiFi | Onboard H616 or USB antenna as shipped |
| Qt5 libs | Required only if you run the `Magmotor` GUI binary |

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
   - clones `lmambr2/klipper` @ `magneto-x-modern`
   - installs magneto-manager systemd unit
   - drops default `printer_data/config` from this repo
   - enables `can0`

That is more work than Option A and can wait until the fork boots cleanly on real hardware.

## Safety notes

- **48 V** linear motors: enable only when clear of jams; use `LM_DISABLE` after prints.
- Kill / fault pin `PG11` on Octopus pauses and cools in stock config — keep it.
- Never flash random ESP32 firmware without a recovery plan (UART boot).
