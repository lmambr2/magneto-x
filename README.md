# magneto-x

Community modernization for the **Peopoly Magneto X** (MagXY linear motors + Lancer toolhead).

**Not affiliated with Peopoly.** Vendor firmware/history is frozen and hard to maintain; this project runs **modern Klipper** with only the Magneto-specific pieces carried forward.

If you own a Magneto X that never quite worked because of the stock Klipper tree, this is meant for you.

## Repos

| Repo | Purpose |
|------|---------|
| **[lmambr2/magneto-x](https://github.com/lmambr2/magneto-x)** (this tree) | Docs, printer configs, Orange Pi host tooling |
| **[lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper)** | Modern Klipper + Magneto extras (branch `magneto-x`) |

> Published as [lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper) (default branch `magneto-x`). See [docs/NAMING.md](docs/NAMING.md).

**Policy:** do not open PRs or push Magneto patches to [Klipper3d/klipper](https://github.com/Klipper3d/klipper).

## Quick findings

| Question | Answer |
|----------|--------|
| What did Peopoly fork? | Upstream `5f0d252b` (**2023-05-25**, v0.11 era) |
| Broken history? | Peopoly `master` is a squash; their branch **`magneto-x`** keeps real parents |
| How invasive is their Klipper? | **~172 lines**: load-cell reset, shell command, two small safety tweaks |
| MagXY in Klipper? | **No** — ESP32 + MotionG closed-loop; Klipper only emits step/dir |
| Working Klipper tree | `klipper/` → branch **`magneto-x`** |

## Docs

- **[docs/DESIGN.md](docs/DESIGN.md)** — full design (architecture, key decisions, PR plan)  
- **[docs/SOURCE_ANALYSIS.md](docs/SOURCE_ANALYSIS.md)** — every upstream/community link: include/skip + wiki dump rationale  
- [docs/NAMING.md](docs/NAMING.md) — repo names, GitHub descriptions, topics  
- [docs/RESEARCH.md](docs/RESEARCH.md) — fork analysis, hardware map, community inventory  
- [docs/MODERNIZATION.md](docs/MODERNIZATION.md) — build / flash / install  
- [docs/OS_IMAGE.md](docs/OS_IMAGE.md) — Orange Pi Zero 2 / MainsailOS  
- [docs/vendor-archive/peopoly-wiki/](docs/vendor-archive/peopoly-wiki/) — **frozen Peopoly wiki** (69 pages, 2026-07-11)  
- In-tree: [magneto-x-klipper docs/Magneto_X.md](https://github.com/lmambr2/magneto-x-klipper/blob/magneto-x/docs/Magneto_X.md)

## Layout

| Path | Purpose |
|------|---------|
| `klipper/` | Clone of **magneto-x-klipper** (branch `magneto-x`) |
| `config/` | Clean printer configs (fill in UUIDs) |
| `os/` | Host service install helpers |
| `docs/` | Project documentation |
| `peopoly-klipper/`, `community/`, … | Local reference clones (not published) |

## Next steps

1. Rename GitHub fork `klipper` → **`magneto-x-klipper`** and push branch `magneto-x`.  
2. Publish this workspace as **`magneto-x`**.  
3. Flash a modern Orange Pi image; install fork + magneto-manager; deploy `config/`.  
4. Build/flash Octopus + Lancer; `LM_ENABLE` → home → QGL → print.  

Details: [docs/MODERNIZATION.md](docs/MODERNIZATION.md).
