# Host profile: Raspberry Pi 5

Preferred Magneto X host. Use with MainsailOS **raspberry_pi-arm64** image.

## Quick path

1. `./os/download-mainsailos.sh rpi5`  
2. `BOARD=rpi5 sudo ./os/flash-mainsailos-sd.sh /dev/sdX`  
3. Imager: Wi‑Fi + SSH keys  
4. Boot → `./os/postinstall-magneto.sh`  
5. Restore device IDs / mesh  

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
