# Pre–clean-OS backup (lab unit)

Captured **2026-07-11** from Path **C1** bridge lab host before Path **A / 1B** reimage.

| File | Contents |
|------|----------|
| `printer_data_config.tgz` | Full `~/printer_data/config` |
| `magneto_device.cfg` | Octopus serial + toolhead CAN UUID |
| `printer.cfg` | Live top-level config + SAVE_CONFIG bed mesh |
| `macros.cfg` | Snapshot of macros at backup time |
| `*.txt` / `health.json` | Host/USB/CAN/service inventory |

## Restore

After flashing MainsailOS + `./os/postinstall-magneto.sh` on the Pi:

```bash
# copy this directory to the Pi, then:
~/magneto-x/os/restore-after-clean-os.sh ~/pre-clean-os-20260711
```

See [docs/CLEAN_OS_REFRESH.md](../../docs/CLEAN_OS_REFRESH.md).

**Privacy:** contains machine-specific serial paths — do not publish.
