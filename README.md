# magneto-x

Community modernization for the **Peopoly Magneto X** (MagXY linear motors + Lancer toolhead).

**Not affiliated with Peopoly.** Vendor firmware/history is frozen and hard to maintain; this project runs **modern Klipper** with only the Magneto-specific pieces carried forward.

If you own a Magneto X that never quite worked because of the stock Klipper tree, this is meant for you.

## Repos

| Repo | Purpose |
|------|---------|
| **[lmambr2/magneto-x](https://github.com/lmambr2/magneto-x)** (this tree) | Docs, printer configs, Orange Pi host tooling |
| **[lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper)** | Modern host + Magneto extras: branch **`magneto-x`** (default) or **`magneto-x-kalico`** (A/B) |

> Published as [lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper) (default branch `magneto-x`). See [docs/NAMING.md](docs/NAMING.md).

**Policy:** do not open PRs or push Magneto patches to [Klipper3d/klipper](https://github.com/Klipper3d/klipper).

## Quick findings

| Question | Answer |
|----------|--------|
| What did Peopoly fork? | Upstream `5f0d252b` (**2023-05-25**, v0.11 era) |
| Broken history? | Peopoly `master` is a squash; their branch **`magneto-x`** keeps real parents |
| How invasive is their Klipper? | **~172 lines**: load-cell reset, shell command, two small safety tweaks |
| MagXY in Klipper? | **No** — ESP32 + MotionG closed-loop; Klipper only emits step/dir |
| Working host tree | `klipper/` → **`magneto-x`** (default) or **`magneto-x-kalico`** |

## Agent / contributor steering

- **[AGENTS.md](AGENTS.md)** — system map  
- **[CONTRIBUTING.md](CONTRIBUTING.md)** · **[CHANGELOG.md](CHANGELOG.md)** — contrib + release notes, ownership seams, policies, known-bad patterns, and pre-merge checks for AI assistants and humans

## Docs

- **[docs/DECISIONS_LOCKED.md](docs/DECISIONS_LOCKED.md)** — operator locks (clean OS, OriginMove default, equal Kalico, …)  
- **[docs/STATUS.md](docs/STATUS.md)** — what is landed vs hardware-gated  
- **[docs/AUDIT_PACKAGE_2026-07-11.md](docs/AUDIT_PACKAGE_2026-07-11.md)** — package bug/legacy Peopoly audit  

- **[docs/MIGRATION.md](docs/MIGRATION.md)** — bridge + clean OS install  
- **[docs/CLEAN_OS_REFRESH.md](docs/CLEAN_OS_REFRESH.md)** — Path A/1B reimage runbook (backup → flash → restore)  

- **[docs/SECURITY.md](docs/SECURITY.md)** · **[docs/FAQ.md](docs/FAQ.md)** · **[docs/MCU_BUILD.md](docs/MCU_BUILD.md)**  
- **[docs/FIELD_FACTS.md](docs/FIELD_FACTS.md)** — measured CAN `1d50:606f` @ 250k, H723, SSH user  
- **[docs/DESIGN.md](docs/DESIGN.md)** — full design (architecture, key decisions, PR plan)  
- **[docs/validation/](docs/validation/)** — S3 / PR-V1 hardware report template
- **[docs/TRACKS.md](docs/TRACKS.md)** — mainline vs Kalico A/B options  
- **[docs/SOURCE_ANALYSIS.md](docs/SOURCE_ANALYSIS.md)** — every upstream/community link: include/skip + wiki dump rationale  
- [docs/NAMING.md](docs/NAMING.md) — repo names, GitHub descriptions, topics  
- [docs/RESEARCH.md](docs/RESEARCH.md) — fork analysis, hardware map, community inventory  
- [docs/MODERNIZATION.md](docs/MODERNIZATION.md) — build / flash / install  
- [docs/OS_IMAGE.md](docs/OS_IMAGE.md) — Orange Pi Zero 2 / MainsailOS  
- [docs/vendor-archive/peopoly-wiki/](docs/vendor-archive/peopoly-wiki/) — **frozen Peopoly wiki** (69 pages, 2026-07-11)  
- In-tree: [Magneto_X.md](https://github.com/lmambr2/magneto-x-klipper/blob/magneto-x/docs/Magneto_X.md) · [TRACKS.md](https://github.com/lmambr2/magneto-x-klipper/blob/magneto-x/docs/TRACKS.md)

## Layout

| Path | Purpose |
|------|---------|
| `klipper/` | Clone of **magneto-x-klipper** (branch `magneto-x`) |
| `config/` | Clean printer configs (fill in UUIDs) |
| `slicer/orca/` | Orca machine G-code + process notes (use with system Peopoly profiles) |
| `os/` | Host service install helpers |
| `docs/` | Project documentation |
| `peopoly-klipper/`, `community/`, … | Local reference clones (not published) |

## Install (clean OS)

```bash
# On the Orange Pi (MainsailOS), after cloning this repo:
./os/postinstall-magneto.sh              # track magneto-x
# TRACK=magneto-x-kalico ./os/postinstall-magneto.sh
# ./os/postinstall-magneto.sh --dry-run
```

Then edit `magneto_device.cfg`, run `./scripts/preflight-magneto.sh`, `LM_ENABLE`, home. MCU flash later: [docs/MCU_BUILD.md](docs/MCU_BUILD.md).  
Hardware sign-off: [docs/validation/S3_HARDWARE_REPORT.template.md](docs/validation/S3_HARDWARE_REPORT.template.md).

Details: [docs/MIGRATION.md](docs/MIGRATION.md) · [docs/STATUS.md](docs/STATUS.md).
