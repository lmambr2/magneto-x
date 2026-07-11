# S3 / PR-V1 hardware validation report

Copy this file to a **local** filled report name (gitignored if under `live-*` / `*.json`):

```bash
cp docs/validation/S3_HARDWARE_REPORT.template.md \
   docs/validation/S3_HARDWARE_REPORT-$(date +%Y%m%d)-HOSTNAME.md
```

Do **not** commit secrets (Wi‑Fi, real UUIDs, passwords). Redact serial paths.

---

## Metadata

| Field | Value |
|-------|--------|
| Date (UTC) | |
| Operator | |
| Printer identity (hostname / nick) | |
| Host OS image | e.g. MainsailOS Armbian OPi Zero 2 |
| Host track | `magneto-x` / `magneto-x-kalico` |
| `git -C ~/klipper rev-parse --short HEAD` | |
| Umbrella config rev | |
| MCU bins | stock / rebuilt (same HEAD?) |
| OriginMove or stock XY | |

## Pre-flight

| Check | Pass? | Notes |
|-------|-------|-------|
| SSH password changed | | |
| `lsusb` shows `1d50:606f` (stock hub) | | |
| `can0` up @ 250000 | | |
| `curl -s http://127.0.0.1:8880/health` serial connected | | |
| `send_command?command=RTU` → 400 | | |
| Hardened manager (not stock 0.0.0.0) | | |
| `check_includes` / Klippy config OK | | |
| Octopus + MAG_TOOL online in Mainsail | | |

## MagXY / motion

| Check | Pass? | Notes |
|-------|-------|-------|
| `LM_ENABLE` succeeds | | |
| X home direction correct for profile | | |
| Y home direction correct | | |
| Z home / probe (latch clear) | | |
| Sticky probe: clear+retry or clean first try | | |
| QGL completes | | |
| Bed mesh sample | | |
| Short print / travel without abort | | |

## Stepper-past A/B (only after modern Octopus flash)

| Build | Result |
|-------|--------|
| relax **n** | trips? Y/N — speeds tried |
| relax **y** (Octopus only) | needed? Y/N |

**Recommendation for published defconfig:** leave n / enable y (circle one)

## Failures / logs

Paste redacted snippets only:

```
# journalctl -u magneto-manager -n 50 --no-pager
# tail of klippy.log errors
```

## Sign-off

| | |
|--|--|
| S3 gate green for v1 tag? | YES / NO |
| Blockers remaining | |
| Operator signature | |

---

## Related

- [MIGRATION.md](../MIGRATION.md) · [MCU_BUILD.md](../MCU_BUILD.md) · [SECURITY.md](../SECURITY.md) · [FAQ.md](../FAQ.md)
