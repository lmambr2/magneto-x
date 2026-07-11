# Peopoly GitHub archive catalog

Captured: 2026-07-11T16:47Z

## Repositories (git)

### peopoly-klipper
- path: `peopoly-klipper` (local clone)
- remote: https://github.com/mypeopoly/Klipper.git
- HEAD: `78c3e29a90fa9189b42388c326af3890d5b81aca`
- branch: `magneto-x`

### magneto-x-klipper-config
- path: `magneto-x-klipper-config` (local clone)
- remote: https://github.com/mypeopoly/magneto-x-klipper-config.git
- HEAD: `438f57f15657674c8646e831597439686e49d795`
- branch: `main`

### magnetox-os-update
- path: `magnetox-os-update` (local clone)
- remote: https://github.com/mypeopoly/magnetox-os-update.git
- HEAD: `24aede895a207a7f77cf74dd45cfd8ed5576b4d3`
- branch: `main`

### magneto-manager-tool
- path: `magneto-manager-tool` (local clone)
- remote: https://github.com/mypeopoly/magneto-manager-tool.git
- HEAD: `bb1c4e22592f8b79678454c819e16b88dccbcf8e`
- branch: `main`

### magneto-x-os-mirror
- path: `magneto-x-os-mirror` (local clone)
- remote: https://github.com/mypeopoly/magneto-x-os-mirror.git
- HEAD: `8ce104e460a4f034ec650d4ffc1e10c2bd191a1f`
- branch: `main`


## OS images (GitHub Releases on mypeopoly/magneto-x-os-mirror)

These are ~1.1 GB each. **Do not commit into git.** Mirror as GitHub Release assets on our repo or keep SHA256 + upstream URL.

| Tag | Asset | Size (bytes) | URL |
|-----|-------|--------------|-----|
| magneto-x-mainsailOS-2024-4-8-v1.1.1 | magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz | 1155713204 | https://github.com/mypeopoly/magneto-x-os-mirror/releases/download/magneto-x-mainsailOS-2024-4-8-v1.1.1/magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz |
| magneto-x-mainsailOS-2024-3-1-v1.1.0 | Beta-Test-unit-mainsailOS-2024-3-1-v1.1.0-mag-beta.img.xz | 1123174192 | https://github.com/mypeopoly/magneto-x-os-mirror/releases/download/magneto-x-mainsailOS-2024-3-1-v1.1.0/Beta-Test-unit-mainsailOS-2024-3-1-v1.1.0-mag-beta.img.xz |
| magneto-x-mainsailOS-2024-3-1-v1.1.0 | Production-unit-mainsailOS-2024-3-1-v1.1.0.img.xz | 1123125452 | https://github.com/mypeopoly/magneto-x-os-mirror/releases/download/magneto-x-mainsailOS-2024-3-1-v1.1.0/Production-unit-mainsailOS-2024-3-1-v1.1.0.img.xz |
| magneto-x-mainsailOS-2024-2-12-v1.0.9 | magneto-x-mainsailOS-2024-2-12-v1.0.9.img.xz | 1117273104 | https://github.com/mypeopoly/magneto-x-os-mirror/releases/download/magneto-x-mainsailOS-2024-2-12-v1.0.9/magneto-x-mainsailOS-2024-2-12-v1.0.9.img.xz |

## Precompiled MCU firmware (Peopoly wiki → Google Drive)

| Module | Location |
|--------|----------|
| Octopus STM32 | [Google Drive](https://drive.google.com/file/d/1sOB3uz85s-ZXus_DNUjokj1pInnj6SGU/view) (wiki magneto-linux-mcu-firmware) |
| Lancer RP2040 UF2 | [Google Drive](https://drive.google.com/file/d/1cuyXaVL2yDgjBWItpVP9TXJBgwdEVkK1/view) |
| Loadcell STC | wiki loadcell-update-firmware |
| ESP32 MagXY | wiki linear motor controller update + magneto-manager-tool/tool-esptool/*.bin |

## What is NOT on Peopoly GitHub

- Your machine-specific UUIDs / printer.cfg calibration
- Live host reported **v1.1.3** while public OS images top out at **v1.1.1** (online update may patch beyond published imgs)
- Full Magmotor source (binary only in magnetox-os-update)

## Local archive files in this directory

```
CATALOG.md
repos/magneto-manager-tool.bundle
repos/magneto-manager-tool-tree.tar.gz
repos/magneto-x-klipper-config.bundle
repos/magneto-x-klipper-config-tree.tar.gz
repos/magnetox-os-update.bundle
repos/magnetox-os-update-tree.tar.gz
repos/peopoly-Klipper.bundle
```
