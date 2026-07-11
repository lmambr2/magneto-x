# Locked product decisions (2026-07-11)

Operator choices from decision review. Supersedes provisional “start with bridge” framing where they conflict.

| # | Topic | Locked choice | Implication |
|---|--------|---------------|-------------|
| **1B** | v1 success path | **Clean OS first** | New MainsailOS/Armbian image is the primary install story. Requires **hardened magneto-manager (PR-M4)** before public install scripts. Stock Peopoly OS is recovery/bridge only, not the ship target. |
| **2A** | MCU flash timing | **Configs + host first; keep stock MCU bins** | Do not flash Octopus/Lancer until host Klippy + config + manager work with **existing** firmware. Reduces brick risk. MCU rebuild is a later milestone (still required before claiming “full modern stack”). |
| **3B** | XY orientation default | **OriginMove published default** | `printer.cfg` includes `optional/origin_move.cfg` by default; stock Peopoly XY is the alternate. Matches live field unit + many community machines. |
| **4C** | Security sequencing | **Hardened manager next** | PR-M4 before further config polish and before clean-OS install path. Stock manager is not acceptable for Option A install. |
| **5** | Kalico | **Equal A/B support** | `magneto-x` and `magneto-x-kalico` both first-class: docs, guard/tests, answers. Mainline is still the “start here if unsure” recommendation for recovery speed, but Kalico is not second-class. |
| **7B** | GitHub Actions OAuth | **Refresh `gh` with `workflow` scope** | Allows pushing full Kalico history with workflows; improves long-term Kalico track hygiene. Operator action: `gh auth refresh -h github.com -s workflow` (browser). |

## Implied execution order

```
PR-M4 hardened manager
  → PR-K2/K3/K5 (dwell, sticky D7, shell PARAMS) in parallel where possible
  → clean OS image path (1B) using hardened manager only
  → deploy OriginMove-default config (3B) + host fork (stock MCU bins, 2A)
  → S3 hardware validation on clean OS
  → MCU flash from chosen track (later; not blocking first motion on stock bins)
  → equal-track CI/docs for Kalico (5)
```

## Still open (scope freeze — see below)

Section **6** items (D7 dwell/retry, PARAMS, stepper-past default, Moonraker packaging, etc.) need individual yes/no after the expanded notes in the decision reply / DESIGN. Until answered, **design defaults stand**: ship K2/K3/K5 as v1 gates; stepper-past stays **off** until S3 A/B.

## Field research closed (was “not really decisions”)

See [FIELD_FACTS.md](FIELD_FACTS.md).

## Software complete / hardware open

See **[STATUS.md](STATUS.md)**. Remaining for v1 tag: **PR-V1** on a real printer (template under `docs/validation/`).

## Scope freeze §6 (2026-07-11) — all recommended

| Item | Lock | PR |
|------|------|-----|
| A Sticky-probe D7 clear+retry+hard fail | **Yes** | PR-K3 |
| B `CLEAR_LOAD_CELL` dwell in-command | **Yes** | PR-K2 |
| C Shell PARAMS ignore/reject for LM | **Yes** | PR-K5 |
| D Hardened magneto-manager | **Yes** (already 4C) | PR-M4 |
| E Stepper-past default on Octopus | **No** until S3 A/B | — |
| F Moonraker update_manager packaging | **Later** | — |
| G Full image / Magmotor in git | **No** | — |
| H EmperorArthur ESP32 | **No** v1 | — |
| I KlipperScreen MagXY port | **Later** | — |

Revisit E/F/G/H/I after S3 / clean-OS success.

