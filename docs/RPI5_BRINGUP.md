# Raspberry Pi 5 bring-up (Magneto X)

**Preferred host** for the modern stack (Helix, Crowsnest, Shake&Tune, KlipperCortex).  
Orange Pi Zero 2 remains supported; Pi 5 has more RAM/CPU headroom.

## Image

| Field | Value |
|-------|--------|
| Release | [MainsailOS 3.0.0](https://github.com/mainsail-crew/MainsailOS/releases/tag/3.0.0) |
| Board file | `2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz` |
| Covers | Pi 3 / 4 / **5** (64-bit) |
| Download helper | `./os/download-mainsailos.sh rpi5` |
| Flash helper | `BOARD=rpi5 sudo ./os/flash-mainsailos-sd.sh /dev/sdX` |

Pi Imager: use the MainsailOS OS list entry for Raspberry Pi (arm64), or flash the `.img.xz` above.

### First boot (Pi advantages)

Use **Raspberry Pi Imager → gear** to preconfigure:

- Wi‑Fi SSID / password / country  
- Hostname (e.g. `magneto`)  
- SSH + user `pi` (or your choice) + password or public key  

Then you can skip keyboard-on-console for Wi‑Fi.

Default MainsailOS Armbian users differ from pure RPi images — after flash, check [MainsailOS docs](https://docs.mainsail.xyz/mainsailos/) if login fails. Stock Magneto lab path used `pi` / change immediately.

## Hardware cabling (unchanged from OPi)

| Device | Connection |
|--------|------------|
| Octopus | USB data → Pi |
| Linux Hub CAN | USB → Pi (`gs_usb`, **250 kbit**) |
| MagXY ESP32 | USB CH340 → Pi |
| Webcam | USB → Pi |
| Touch panel | HDMI + USB touch → Pi |
| Beacon (optional) | USB → Pi (do **not** hotplug sensor end) |

Pi 5: use a **solid 5 V high-current PSU**; underpowered Pi → USB disconnects that look like MCU faults.

## Software stack after first boot

```bash
sudo apt update && sudo apt full-upgrade -y
# reboot if kernel updated

git clone https://github.com/lmambr2/magneto-x.git ~/magneto-x
# optional: scp pre-clean backup for serials/mesh
# PRE_CLEAN_BACKUP=~/pre-clean-os-YYYYMMDD ./os/postinstall-magneto.sh

cd ~/magneto-x
./os/postinstall-magneto.sh
```

Postinstall installs (defaults): CAN 250k, hardened manager, config package, HelixScreen, Crowsnest, Shake&Tune, KlipperCortex tree (service waits for vision model).

### Pi 5–friendly webcam

More RAM → you can raise stream quality in `~/printer_data/config/crowsnest.conf`:

```ini
resolution: 1920x1080
max_fps: 15
# or 30 if free -h stays comfortable under print + Helix
```

Package default stays **1280×720@15** for Zero 2 safety; override on Pi 5.

## Device IDs

Edit `magneto_device.cfg` (or restore from pre-clean backup):

```ini
[mcu]
serial: /dev/serial/by-id/usb-Klipper_stm32h723xx_…-if00

[mcu MAG_TOOL]
canbus_uuid: …
```

```bash
ls /dev/serial/by-id/
ip -details link show can0 | grep bitrate   # must be 250000
curl -s http://127.0.0.1:8880/health
```

MCU firmware: if already modern (`61fc2f6-…` style), **no reflash** required for host swap.

## Beacon (optional hardware path)

Stock Lancer uses **load-cell probe** (`[probe]` PE12 + `[magneto_load_cell]`).  
Beacon is an **alt probe path** — USB to host, replaces stock `[probe]`.

1. Mount Beacon (~2.6 mm nozzle Z recess); custom mount may be required.  
2. Install module: `./os/install-beacon.sh`  
3. Enable config (pick one motion profile still):

   ```ini
   # printer.cfg — comment stock load-cell probe path expectations:
   # [include magneto_toolhead.cfg] still needed for extruder/fans,
   # but disable PE12 probe + magneto_load_cell when using Beacon (see optional/beacon.cfg)
   [include optional/beacon.cfg]
   ```

4. Set `serial:` + `x_offset` / `y_offset` for **your** mount.  
5. Calibrate: `G28 X Y` → center → `BEACON_CALIBRATE` → `ACCEPT` → `SAVE_CONFIG`.  

Details: [optional/beacon.cfg](../config/optional/beacon.cfg), [docs.beacon3d.com](https://docs.beacon3d.com/).

## Acceptance checklist

- [ ] MainsailOS arm64 image booted on Pi 5  
- [ ] SSH works; default password changed  
- [ ] Octopus + MagXY + CAN present; CAN **250k**  
- [ ] Klippy ready; Helix on panel  
- [ ] Webcam stream in Mainsail  
- [ ] `LM_ENABLE` + home  
- [ ] (Optional) Beacon installed + calibrated  
- [ ] Short print via `PRINT_START`  

## Related

- [OS_IMAGE.md](OS_IMAGE.md) · [HARDWARE.md](HARDWARE.md) · [CLEAN_OS_REFRESH.md](CLEAN_OS_REFRESH.md)  
- [MCU_BUILD.md](MCU_BUILD.md) (only if reflashing MCUs)  
