# Live stock backup — mainsailos @ x.x.x.x

**Captured:** 2026-07-11 UTC  
**Method:** Paramiko SFTP/SSH (password); agent host key is passphrase-locked so pubkey auth was not used from the automation host.

## Machine identity

| Item | Value |
|------|--------|
| Hostname | mainsailos |
| OS manager version | `magneto-x-mainsailOS-2024-5-1-v1.1.3-mag-x` |
| Public Peopoly OS images max | v1.1.1 (this unit is newer via online update) |
| Kernel | 5.16.17-sun50iw9 aarch64 |
| Disk | mmcblk1 ~29 GB, ~24 GB free |
| CAN | can0 gs_usb **250000** bit/s |
| Octopus serial | `usb-Klipper_stm32h723xx_REDACTED` |
| ESP32 | `/dev/ttyUSB0` (CH340) |
| Host Klipper | `8ef0f7d7e-dirty` (Klipper3d origin, dirty Peopoly tree) |

## Contents

| Path | Description |
|------|-------------|
| `config/` | Full `printer_data/config` including history backups |
| `auto-uuid/` | Manager scripts only (Magmotor/WifiHelper **not** stored) |
| `magnetox-os-update/` | On-device OS update package tree |
| `klipper/` | Magneto extras + git status snapshot (not full git history) |
| `host/` | dpkg, pip, services, CAN, Moonraker/MCU JSON |
| `SHA256SUMS` | Hashes of all files in this tree |

## Not included

- Full `dd` of mmcblk1 (use Peopoly OS image + this tree, or stream later if needed)
- Entire `~/klipper` git history (remote is Klipper3d; extras are copied)
- MCU flash dump from chip (no `out/` binaries on device; rebuild from source)

## Restore notes

1. Flash a Peopoly OS image (v1.1.1 or closest) from `backups/peopoly-os-images/` or GitHub Release.
2. Overlay `config/` into `~/printer_data/config/`.
3. Restore `auto-uuid/` and manager service.
4. Rebuild MCU firmware from matching Klipper tree if needed.


## Redaction / safety

- Proprietary `Magmotor` / `MagnetoWifiHelper` binaries **removed** from this public tree.
- MCU serial paths and CAN UUIDs **redacted**.
- LAN IPs / MACs **redacted**.
- No gcode/STL/3MF files included.
- Full disk image (if present under `disk/`) is **gitignored**.
