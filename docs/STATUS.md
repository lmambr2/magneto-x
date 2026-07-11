# Implementation status (2026-07-11)

Living checklist vs DESIGN PR plan. Update when PRs land.

## Complete (software)

| ID | Title | Where |
|----|--------|--------|
| PR-M1 | Design + research docs | `docs/DESIGN.md`, RESEARCH, … |
| PR-M2 | Parse-ready config | `config/` + `check_includes` |
| PR-M3 | Moonraker snippet | `config/moonraker-update-manager.conf.snippet` |
| PR-M4 | Hardened magneto-manager | `os/magneto-manager/`, install script, tests |
| PR-M5 | Migration guide | `docs/MIGRATION.md` |
| PR-M6 | MCU defconfigs + build doc | `os/defconfig-*`, `docs/MCU_BUILD.md` |
| PR-M7 | Security guide | `docs/SECURITY.md` |
| PR-M8 | FAQ | `docs/FAQ.md` |
| PR-M9 lite | Postinstall skeleton | `os/postinstall-magneto.sh` |
| PR-K1 | Crystal / MCU docs | magneto-x-klipper `docs/Magneto_X.md` |
| PR-K2 | CLEAR_LOAD_CELL dwell | both tracks |
| PR-K3 | Sticky probe D7 retry | both tracks |
| PR-K4 | Relax default n + defconfig assert | Kconfig + `os/check-defconfigs.sh` + `klipper/test/configs/magneto-*` |
| PR-K5 | Shell PARAMS reject | both tracks |
| PR-K6 lite | CI gate script | `scripts/ci-magneto.sh` (+ example workflow under `docs/ci/`) |
| **PR-K7** | Native MagXY module | **Finished** — localhost http default, serial optional, LM_* aliases, tests, config/docs |
| Polish | force_move warning, nginx snippet, alt-hardware notes, DESIGN sync | config/ + FAQ + DESIGN rev3+ |
| Tracks | Mainline + Kalico A/B | `docs/TRACKS.md`, branches |
| Decisions | Operator locks §1–7, §6 | `docs/DECISIONS_LOCKED.md` |
| Field | CAN/H723/SSH | `docs/FIELD_FACTS.md` |
| Preflight | Host checklist script | `scripts/preflight-magneto.sh` |
| CHANGELOG / CONTRIBUTING | Release + contrib guide | root |
| A8 lite | Moonraker MagXY proxy | `os/moonraker/` |
| Optional configs | runout, temps, client vars, beacon notes, fw retract | `config/optional/` |

## Blocked on hardware (not “software done”)

| ID | Title | Notes |
|----|--------|--------|
| **PR-V1** | S3 hardware validation | Template: `docs/validation/S3_HARDWARE_REPORT.template.md` — fill on machine |
| MCU flash | Modern Octopus + Lancer | After host path works (2A); recipe in MCU_BUILD |
| v1 git tag | D20 release | Requires PR-V1 green |

## Deferred (not done offline)

| ID | Title | Notes |
|----|--------|--------|
| PR-M9 full | Custom MainsailOS image | postinstall is enough |
| PR-M10 deep ESP32 flash | Community FW cookbook | overview only in COMMUNITY_ESP32.md |
| Beacon/HX717 **hardware** | Toolhead redesign | notes only under `optional/` |

## Local verify

```bash
bash scripts/ci-magneto.sh
./os/postinstall-magneto.sh --dry-run
# on printer:
./scripts/preflight-magneto.sh
```

## Rollout stages

| Stage | Status |
|-------|--------|
| S0 docs | **done** |
| S1 fork gap-close | **done** (K2/K3/K5) |
| S2 config | **done** |
| S2b manager | **done** |
| S3 hardware | **open** (template ready) |
| S4 clean OS docs | **done** (M5 + postinstall) |
| S5 moonraker snippet | **done** |
| S6 defconfigs | **done** |
| S7 optional | deferred |
| Doc/config polish (force_move, nginx, Beacon notes, DESIGN sync) | **done** |
