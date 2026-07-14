# Host profile: Raspberry Pi 5

Preferred Magneto X host. Use with MainsailOS **raspberry_pi-arm64** image.

**Hardware assumption:** Raspberry Pi 5 + **official M.2 HAT+** + NVMe SSD. Boot from NVMe when possible (see [RPI5_BRINGUP.md](../../../docs/RPI5_BRINGUP.md) Paths A/B).

## Quick path

1. `./os/download-mainsailos.sh rpi5`  
2. Image storage (pick one):  
   - **NVMe via USB enclosure:** `BOARD=rpi5 sudo ./os/flash-mainsailos-sd.sh /dev/sdX` then seat SSD in HAT, or  
   - **microSD** with Imager, then migrate to NVMe on the Pi  
3. Imager gear: Wi‑Fi + SSH keys (+ user)  
4. Boot from NVMe → confirm `findmnt /` is on `nvme0n1…`  
5. `./os/postinstall-magneto.sh`  
6. Restore device IDs / mesh  

Full detail: [docs/RPI5_BRINGUP.md](../../../docs/RPI5_BRINGUP.md)

## Suggested overrides (after postinstall)

| Setting | Zero 2 default | Pi 5 suggestion |
|---------|----------------|-----------------|
| Crowsnest resolution | 1280×720 @ 15 | 1920×1080 @ 15–30 |
| Shake&Tune `dpi` | 200 | 300 |
| KlipperCortex | optional / heavy | preferred host |

Copy helpers:

```bash
# optional cam bump
# edit ~/printer_data/config/crowsnest.conf
```

## Beacon

Not stock. Install when hardware present:

```bash
./os/install-beacon.sh
# then optional/beacon.cfg — see beacon_activate.md
```
