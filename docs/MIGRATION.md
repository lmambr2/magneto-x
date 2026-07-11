# Migration: stock Peopoly → magneto-x stack

**Prerequisite decisions:** clean OS is the v1 path (1B); flash MCUs only after host works (2A); OriginMove default XY (3B); **hardened manager required** for any new install (4C / PR-M4).

## Paths at a glance

| Path | When | Security |
|------|------|----------|
| **A — Clean MainsailOS** (preferred long-term / 1B) | New SD/eMMC | Hardened manager only |
| **C1 — Bridge + hardened manager** | Keep Peopoly image short-term | Replace stock manager |
| **C2 — Bridge + firewall only** | Air-gapped LAN, temporary | Stock manager + port 8880 → localhost; residual risk |

**Lab unit (2026-07):** Path **C1** — Peopoly `magneto-x-mainsailOS-…-v1.1.3` still on disk; modern host+MCUs + hardened manager. **Clean OS reimage was not performed.**

Do **not** cherry-pick macros while leaving OS-update `LINER_*` trees active — deploy the full `config/` package.

`./os/postinstall-magneto.sh` is the one-shot for **Path A** (also usable on a cleaned host). It installs CAN 250k + txqueuelen service, manager, config, moonraker update_manager, and wires timelapse macros when the component is present.

---

## Path A — Clean MainsailOS (Option A)

1. **Backup** stock config, note serial + CAN UUID, MagXY still works on stock if possible.
2. Flash **current MainsailOS Armbian for Orange Pi Zero 2**  
   https://docs.mainsail.xyz/mainsailos/getting-started/armbian/  
   SSH: **`pi` / `armbian`** (change password immediately).
3. `sudo apt update && sudo apt full-upgrade` (reboot if kernel updates).
4. **CAN** for stock Linux Hub (`gs_usb` **`1d50:606f`** @ **250000**):

   ```bash
   lsusb | grep -i 1d50
   sudo ip link set can0 up type can bitrate 250000
   # Persist: copy os/can0.network → /etc/systemd/network/80-can0.network
   sudo networkctl reload || true
   ```

5. Clone umbrella + run **postinstall** (preferred one-shot):

   ```bash
   git clone https://github.com/lmambr2/magneto-x.git ~/magneto-x
   cd ~/magneto-x
   ./os/postinstall-magneto.sh
   # Kalico: TRACK=magneto-x-kalico ./os/postinstall-magneto.sh
   # Magmotor GUI: ./os/postinstall-magneto.sh --with-magmotor
   curl -s http://127.0.0.1:8880/health
   ```

   Manual equivalent: stop klipper → clone `magneto-x-klipper` @ track →
   `os/install-magneto-services.sh` → rsync `config/` → moonraker snippet.

6. Edit `~/printer_data/config/magneto_device.cfg` (serial + canbus_uuid).
7. `~/magneto-x/scripts/preflight-magneto.sh`
8. nginx large uploads: see [FAQ.md](FAQ.md).
9. **MCU flash** — deferred until host talks to stock bins (2A). When ready: [MCU_BUILD.md](MCU_BUILD.md).
10. `FIRMWARE_RESTART` → `LM_ENABLE` → home carefully.
11. Fill [validation/S3_HARDWARE_REPORT.template.md](validation/S3_HARDWARE_REPORT.template.md) for PR-V1.

### Rollback (clean OS)

```bash
sudo systemctl stop klipper
mv ~/klipper ~/klipper-broken
mv ~/klipper-mainsail-backup ~/klipper   # or reclone
sudo systemctl start klipper
```

---

## Path C — Bridge on Peopoly stock image

### C1 (preferred if networked)

1. Backup `~/printer_data/config` and `~/klipper`.
2. Stop services; replace `~/klipper` with `magneto-x` (or kalico) clone as above.
3. **Disable stock manager**, install hardened:

   ```bash
   sudo systemctl disable --now magneto-manager.service 2>/dev/null || true
   # install from umbrella os/install-magneto-services.sh
   ```

4. Deploy full `config/` package (not partial macro merges).
5. Point Moonraker update_manager at magneto-x-klipper.
6. Keep stock MCU bins until host path works; then flash per MCU_BUILD.md.

### C2 (air-gap only)

Keep stock manager **only** if:

```bash
# Example nftables: drop non-local 8880
sudo nft add rule inet filter input tcp dport 8880 ip saddr != 127.0.0.1 drop
```

Or patch bind to 127.0.0.1. Residual risk: local gcode can still hit allowlist-less stock `/send_command`. Prefer C1.

### Rollback (bridge)

```bash
sudo systemctl stop klipper
mv ~/klipper ~/klipper-magneto-broken
mv ~/klipper-peopoly-backup ~/klipper
# restore config.bak if needed
sudo systemctl start klipper
```

---

## Checklist before calling migration “done”

- [ ] `curl -s http://127.0.0.1:8880/health` → serial connected (ESP32 present)
- [ ] `curl -s 'http://127.0.0.1:8880/send_command?command=RTU'` → **400** (hardened)
- [ ] `python3 ~/magneto-x/scripts/check_includes.py ~/printer_data/config` (or package copy)
- [ ] Klippy ready; Octopus + MAG_TOOL online
- [ ] `LM_ENABLE` then careful home
- [ ] Same git HEAD recorded for host (and later both MCUs)

## Related

- [SECURITY.md](SECURITY.md) · [MCU_BUILD.md](MCU_BUILD.md) · [FAQ.md](FAQ.md) · [FIELD_FACTS.md](FIELD_FACTS.md) · [TRACKS.md](TRACKS.md)
