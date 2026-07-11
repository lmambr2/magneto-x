# Magneto X modernization workspace

Personal project to run a Peopoly **Magneto X** on **modern Klipper** without contributing Magneto-specific patches to upstream Klipper.

## Quick findings

| Question | Answer |
|----------|--------|
| What did Peopoly fork? | Upstream `5f0d252b` (**2023-05-25**, v0.11 era) |
| How bad is the history? | `master` is a squash; branch **`magneto-x`** keeps real parents |
| How invasive is their Klipper? | **~172 lines**: load-cell reset, shell command, two small safety tweaks |
| MagXY in Klipper? | **No** — ESP32 + MotionG closed-loop; Klipper only emits step/dir |
| Working Klipper tree | `klipper/` → branch **`magneto-x-modern`** (based on [lmambr2/klipper](https://github.com/lmambr2/klipper)) |

## Docs

- [docs/RESEARCH.md](docs/RESEARCH.md) — fork analysis, hardware map, community inventory  
- [docs/MODERNIZATION.md](docs/MODERNIZATION.md) — build/flash/install steps  
- [docs/OS_IMAGE.md](docs/OS_IMAGE.md) — Orange Pi Zero 2 / MainsailOS plan  
- [klipper/docs/Magneto_X.md](klipper/docs/Magneto_X.md) — in-tree Magneto notes  

## Layout

| Path | Purpose |
|------|---------|
| `klipper/` | Your fork + Magneto port (`magneto-x-modern`) |
| `config/` | Clean printer configs (fill in UUIDs) |
| `os/` | Host service install helpers |
| `peopoly-klipper/` | Reference `mypeopoly/Klipper` |
| `magnetox-os-update/` | Magmotor / manager binaries |
| `community/` | Third-party reference clones |

## Policy

- **Do not** open PRs or push Magneto work to `Klipper3d/klipper`.
- Push only to **your** GitHub fork (`lmambr2/klipper`) when you are ready.

## Next steps on hardware

1. Push `magneto-x-modern` to GitHub (when you want).  
2. Flash a current **MainsailOS Orange Pi Zero 2** image (or bridge on stock).  
3. Install fork + `os/install-magneto-services.sh`.  
4. Deploy `config/`, set serial/CAN IDs.  
5. Build/flash Octopus + Lancer from the same tree.  
6. `LM_ENABLE` → `G28` → QGL → test print.  
