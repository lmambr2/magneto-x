# Clean OS refresh (Path A / decision **1B**)

Lab status before reimage: Path **C1** bridge on Peopoly MainsailOS (Debian 11 / kernel 5.16).  
Target: **MainsailOS 3.0.0** Armbian **Trixie** for **Orange Pi Zero 2**, then `postinstall-magneto.sh`.

## What you need physically

| Item | Notes |
|------|--------|
| Orange Pi Zero 2 | Lab unit currently on the LAN (see local notes; do not commit host IPs) |
| Flash media | Lab boots **`mmcblk1` ~29 GB** (SD or eMMC). Prefer a **spare SD** so the old Peopoly image stays a recovery disk. |
| Host PC | Linux/macOS with USB reader, or `dd`/`balenaEtcher`/`Raspberry Pi Imager` |
| Network | Ethernet or Wi‑Fi for first SSH |

**This cannot be completed over SSH alone** — the running OS cannot safely reimage its own boot media.

## Pre-flight backup (already captured for lab)

| Artifact | Path |
|----------|------|
| Full `printer_data/config` tarball | `backups/pre-clean-os-20260711/printer_data_config.tgz` |
| Device IDs | `backups/pre-clean-os-20260711/magneto_device.cfg` |
| Printer + mesh SAVE_CONFIG | `backups/pre-clean-os-20260711/printer.cfg` |
| Host/USB/CAN snapshot | `backups/pre-clean-os-20260711/*.txt` |

**Do not commit live serials, CAN UUIDs, or lab LAN IPs to a public remote.**  
Device IDs live only in **gitignored** files under `backups/pre-clean-os-*/` (e.g. `magneto_device.cfg`). Keep that directory local or private.

### Device IDs (restore after reimage)

After backup, `magneto_device.cfg` in the pre-clean directory has your Octopus serial and toolhead CAN UUID. Restore with:

```bash
./os/restore-after-clean-os.sh ~/pre-clean-os-YYYYMMDD
# or set PRE_CLEAN_BACKUP=... when running postinstall-magneto.sh
```

If you only have a running machine, re-discover:

```bash
ls -la /dev/serial/by-id/
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

USB inventory (must reappear after boot — VID:PID only, no device serials):

| Device | ID |
|--------|-----|
| Octopus H723 | `1d50:614e` |
| CAN hub gs_usb | `1d50:606f` @ **250 kbit** |
| MagXY ESP32 CH340 | `1a86:7523` → “USB Serial” |
| Touch USB bridge | `1a86:e5e3` |
| Webcam | `0c45:6366` (optional) |

MCU firmware: **keep current modern bins** (lock **2A** already satisfied on lab). Do **not** reflash MCUs during OS refresh unless host cannot talk to them.

## Image

| Field | Value |
|-------|--------|
| Release | [MainsailOS 3.0.0](https://github.com/mainsail-crew/MainsailOS/releases/tag/3.0.0) |
| Board file | `2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz` |
| Download | https://github.com/mainsail-crew/MainsailOS/releases/download/3.0.0/2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz |
| Local cache | `backups/mainsailos-images/` (if downloaded) |

```bash
# On the PC used for flashing:
cd /path/to/magneto-x/backups/mainsailos-images
# verify:
sha256sum -c 2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz.sha256
```

## Flash procedure

1. **Power down** the printer / Orange Pi completely. Unplug USB-C power.
2. Remove the **boot SD** (or use a new SD if the Peopoly system is on eMMC you will leave alone).
3. On the flash PC:

   ```bash
   # Identify the SD carefully — WRONG DEVICE DESTROYS DATA
   lsblk -o NAME,SIZE,TYPE,TRAN,MODEL
   # Example only — replace /dev/sdX with the SD:
   xzcat 2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz \
     | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
   sync
   ```

   Or use Balena Etcher / Raspberry Pi Imager with the `.img.xz`.

4. Insert SD into OPi Zero 2, reconnect printer USB devices, power on.
5. First boot may take several minutes (expand rootfs). Find the host:

   ```bash
   # mDNS
   ping -c1 mainsailos.local
   # or check your router DHCP for a new host
   ```

6. SSH (defaults — **change password immediately**):

   ```bash
   ssh pi@mainsailos.local   # password: armbian (confirm on MainsailOS docs if changed)
   passwd
   ```

7. OS updates:

   ```bash
   sudo apt update && sudo apt full-upgrade -y
   sudo reboot
   ```

## Code readiness (do we need more changes before boot?)

| Area | Status for clean OS |
|------|---------------------|
| `postinstall-magneto.sh` | Ready — CAN 250k, manager, config, dialout, gs_usb |
| Package `config/` | Ready — OriginMove default, KAMP, MagXY module |
| `restore-after-clean-os.sh` | Ready — **selective** restore (never clobbers Trixie `moonraker.conf` with Peopoly dump) |
| MCU flash | **Not required** for first boot (2A) if current bins already modern |
| Magmotor Qt GUI | Optional `--with-magmotor` only; needs local `magnetox-os-update` tree |
| Moonraker update UI | Prefer git remote on `~/klipper`; v0.8 strip logic only if old Moonraker detected |

No further **blocking** code changes are required to boot Path A. Remaining work is **on-device** (flash already done → boot → postinstall → restore).

## Postinstall (software stack)

On the **new** host, as `pi`:

```bash
# From laptop — prefer rsync if you have unpushed commits:
# rsync -a --delete --exclude .venv-test --exclude backups/mainsailos-images \
#   /path/to/magneto-x/ pi@HOST:~/magneto-x/
# scp -r backups/pre-clean-os-20260711 pi@HOST:~/pre-clean-os

git clone https://github.com/lmambr2/magneto-x.git ~/magneto-x   # or use rsync above
cd ~/magneto-x

# One-shot install + restore device IDs / mesh:
PRE_CLEAN_BACKUP=~/pre-clean-os ./os/postinstall-magneto.sh
# or:
# ./os/postinstall-magneto.sh
# ./os/restore-after-clean-os.sh ~/pre-clean-os
```

**Do not** untar the old `printer_data_config.tgz` blindly over `~/printer_data` — that can replace MainsailOS 3 `moonraker.conf` with Peopoly-era settings. The restore helper allowlists safe files only.

```bash
~/magneto-x/scripts/preflight-magneto.sh
curl -s http://127.0.0.1:8880/health
# Hardened manager: RTU must be rejected
curl -s "http://127.0.0.1:8880/send_command?command=RTU"
```

Then in Mainsail: **FIRMWARE_RESTART** → `LM_ENABLE` → careful home.

### nginx (large Orca uploads)

Merge `config/optional/nginx-timeouts.conf.snippet` under `http { }` in `/etc/nginx/nginx.conf`, then `sudo systemctl restart nginx`.

### Timelapse / camera

If you use moonraker-timelapse:

```bash
# After installing the component (KIAUH or package):
ln -sfn ~/moonraker-timelapse/klipper_macro/timelapse.cfg \
       ~/printer_data/config/timelapse.cfg
```

### Password / security

- Change default SSH password  
- Prefer SSH keys  
- MagXY manager must stay on **localhost** (hardened default)

## Acceptance checklist (migration “done”)

- [ ] New MainsailOS image booted (not Peopoly bullseye 5.16 tree)
- [ ] `curl -s http://127.0.0.1:8880/health` → serial **connected**
- [ ] RTU / non-allowlist command → **400**
- [ ] Klippy **ready**; Octopus + MAG_TOOL present
- [ ] `LM_ENABLE` + home X/Y/Z
- [ ] Bed mesh / short print path works
- [ ] `docs/STATUS.md` Clean OS (1B) marked done
- [ ] S3 validation updated if this is the lab unit

## Rollback

Keep the **old Peopoly SD** labeled and unplugged. To reverse: power off, reinsert old media, boot.

## Related

- [MIGRATION.md](MIGRATION.md) · [OS_IMAGE.md](OS_IMAGE.md) · [DECISIONS_LOCKED.md](DECISIONS_LOCKED.md)  
- [SECURITY.md](SECURITY.md) · [MCU_BUILD.md](MCU_BUILD.md) (MCU flash still deferred unless needed)  
