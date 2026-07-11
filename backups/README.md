# Backups

## Track A — Peopoly public sources

- Git repos/bundles: [`docs/vendor-archive/peopoly-github/`](../docs/vendor-archive/peopoly-github/)
- Wiki text: [`docs/vendor-archive/peopoly-wiki/`](../docs/vendor-archive/peopoly-wiki/)
- OS images (`*.img.xz`, ~1.1 GB each): downloaded under `peopoly-os-images/` locally; **gitignored**. Prefer GitHub Release assets on this repo: https://github.com/lmambr2/magneto-x/releases/tag/peopoly-os-images-archive

## Track B — Live machine

- `stock-live-YYYYMMDD…/` — configs, Magmotor binaries as on unit, inventory, Magneto Klipper extras.

## Privacy

Live backups may include WiFi credentials in moonraker/sonar configs — review before making the repo public if needed.

## Safety policy

- **No** STL/3MF/gcode print files.
- **No** WiFi passwords, API keys, private keys, or moonraker secrets.
- **No** Magmotor / MagnetoWifiHelper in the public repo (see DESIGN D13).
- Live backup MCU UUIDs / serials / LAN addresses are **redacted**.
- Large OS/disk images are gitignored; use Releases for factory OS mirrors.
