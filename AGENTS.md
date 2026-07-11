# magneto-x — Agent Steering

This file guides AI coding assistants working in the **Magneto X modernization** workspace. Follow it unless the user overrides it for a specific task.

**Product:** Community stack for the Peopoly Magneto X (MagXY linear motors + Lancer toolhead). **Not affiliated with Peopoly.**

**Two published repos (do not collapse):**

| Repo | Default branch | Owns |
|------|----------------|------|
| [lmambr2/magneto-x](https://github.com/lmambr2/magneto-x) | `master` (docs may say `main`) | Umbrella: configs, host tooling, design docs, vendor archive |
| [lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper) | **`magneto-x`** | Klipper/Kalico host + MCU tree + Magneto extras |

**Local workspace:** `/home/lane/Projects/magneto-x/` — umbrella git root. Nested `klipper/` is a **separate git clone** of `magneto-x-klipper` (gitignored by the umbrella). Edit/commit/push each repo independently.

**Language / docs:** English for code, comments, user-facing gcode help, and project docs.

---

## 0. System map — what this actually is

This is **not** “just a Klipper config.” It is a **multi-layer machine stack**. Fix bugs at the **owner** layer, not with a config hack that papers over the wrong subsystem.

### A. Host firmware (Klippy + MCU code — `klipper/` → magneto-x-klipper)

| Track | Branch | Upstream base | Role |
|-------|--------|---------------|------|
| **Default** | `magneto-x` | Klipper3d/klipper | Supported path for most owners |
| **Optional A/B** | `magneto-x-kalico` | KalicoCrew/kalico | Extra features; same Magneto delta |

**Owns:** step scheduling, kinematics, heaters, probe/homing, TMC, CAN MCU protocol, Magneto extras.

**Magneto-owned extras (must survive upstream sync):**

| Path | Role |
|------|------|
| `klippy/extras/magneto_load_cell.py` | STC8051/CS1237 **digital latch** reset (`CLEAR_LOAD_CELL` / `LC28`) — **not** upstream `load_cell` / `load_cell_probe` |
| `klippy/extras/gcode_shell_command.py` | `RUN_SHELL_COMMAND` for MagXY (vendored on mainline; **native on Kalico**) |
| `klippy/extras/homing.py` patches | Sticky-probe soft-fail / D7 clear+retry (markers) |
| `src/stepper.c` + `src/Kconfig` | Optional `MAGNETO_RELAX_STEPPER_PAST` (Octopus MagXY only) |
| `magneto/MANIFEST.json` + `scripts/magneto_guard.py` | Guard against silent merge loss |

Markers: `MAGNETO-X-BEGIN` … `MAGNETO-X-END`. After every upstream merge/rebase:

```bash
cd klipper && python3 scripts/magneto_guard.py && python3 -m unittest discover -s tests/magneto -v
```

### B. Printer config package (umbrella — `config/`)

**Owns:** pin maps, macros, shell command allowlist, motion profiles, Mainsail-safe includes.

| Path | Owns |
|------|------|
| `config/printer.cfg` | Top-level includes + machine sections |
| `config/magneto_device.cfg` | MCU serial + CAN UUID placeholders |
| `config/magneto_toolhead.cfg` | Lancer extruder, load cell, ADXL, fans |
| `config/motion_xy_stock.cfg` | Default XY (Driver0=X 400, Driver1=Y 300) |
| `config/optional/origin_move.cfg` | Alternate XY orientation (many field machines) |
| `config/optional/danger_options.cfg` | **Kalico host only** |
| `config/shell_command.cfg` | MagXY curl allowlist only (`LINEAR_MOTOR_*`) |
| `config/macros.cfg` | `LM_ENABLE` / pause / print start — single PAUSE/RESUME |
| `config/mainsail.cfg` | Virtual SD etc. — **no** PAUSE/RESUME |

Parse check (umbrella):

```bash
python3 scripts/check_includes.py config
```

### C. MagXY / linear motors (outside Klipper)

| Piece | Role |
|-------|------|
| MotionG DN1-G60xxN ×2 | Closed-loop drivers; RS485 / 48 V |
| ESP32 bridge | Peopoly firmware; serial “USB Serial” to host |
| `magneto-manager` HTTP `:8880` | ENABLE/DISABLE (and more); stock binds `0.0.0.0` + `shell=True` — **harden before clean-OS install** |
| Magmotor / MagnetoWifiHelper | **Proprietary** — never commit binaries; user copies from Peopoly packages |

Klipper only emits **step/dir**. Do **not** implement MagXY closed-loop inside Klipper for v1.

Enable sequence (critical):

1. Manager up on `127.0.0.1:8880`
2. `LM_ENABLE` → shell → curl → manager → ESP32 → ENABLE
3. Then home / move XY

### D. MCUs & field bus

| Board | Typical link | Notes |
|-------|--------------|-------|
| BTT Octopus Pro (H723) | USB serial | MagXY step/dir; optional stepper-past relax |
| Lancer toolhead RP2040 | CAN | Extruder, probe latch pin, ADXL |
| Linux Hub USB-CAN | Host `can0` | Stock field: **`gs_usb` @ 250000** (not 1 Mbit) |

Host and MCU firmware **must be built from the same track** (`magneto-x` or `magneto-x-kalico`). Switching tracks ⇒ rebuild/reflash both MCUs.

### E. Host OS (Orange Pi Zero 2)

| Path | Owns |
|------|------|
| `os/` | CAN network unit, service install helpers |
| `docs/OS_IMAGE.md` | MainsailOS / Armbian preferred long-term |
| Stock Peopoly image | Bridge only — frozen packages |

Preferred long-term: modern MainsailOS Armbian. Stock 2024 image is a migration bridge.

### F. Docs & archaeology (umbrella — `docs/`)

| Path | Owns |
|------|------|
| `docs/DESIGN.md` | Architecture, key decisions D1–D20, PR plan |
| `docs/TRACKS.md` | Mainline vs Kalico A/B |
| `docs/MODERNIZATION.md` | Build / flash / install |
| `docs/SOURCE_ANALYSIS.md` | Include/skip for every vendor/community source |
| `docs/vendor-archive/` | Frozen Peopoly wiki + github bundles |
| `backups/` | Local stock dumps (may contain secrets — scrub before publish) |

### G. Local-only reference trees (not published)

Usually gitignored under the umbrella:

`klipper/`, `peopoly-klipper/`, `community/`, `magnetox-os-update/`, `magneto-manager-tool/`, large `backups/**/*.img*`

Do not commit proprietary binaries, printer models (`*.stl`, `*.gcode`), secrets, or full OS images into public git.

### Topological seams (where clean cuts go)

- **Host vs MagXY:** MagXY arm/disarm stays in manager/ESP32 — not Klippy kinematics
- **Latch vs ADC probe:** `magneto_load_cell` only; never force-fit `load_cell_probe` on stock Lancer
- **Config vs firmware:** pin/UUID/macro bugs → `config/`; timing/protocol → `klipper/`
- **Track boundary:** mainline (`magneto-x`) vs Kalico (`magneto-x-kalico`) — do not casually merge branches
- **Security boundary:** shell commands are an allowlist; manager must not stay world-open on clean installs
- **Upstream boundary:** **never** open PRs or push Magneto patches to `Klipper3d/klipper` or `KalicoCrew/kalico`

---

## Locked product decisions (operator 2026-07-11)

See [`docs/DECISIONS_LOCKED.md`](docs/DECISIONS_LOCKED.md) and [`docs/FIELD_FACTS.md`](docs/FIELD_FACTS.md).

| ID | Lock |
|----|------|
| 1B | Clean OS first (after hardened manager) |
| 2A | Configs/host first; **keep stock MCU bins** until later |
| 3B | **OriginMove** is published default XY |
| 4C | **PR-M4 hardened manager** before more config polish / clean OS |
| 5 | **Equal** mainline and Kalico A/B support |
| 7B | Operator: `gh auth refresh -s workflow` for full Kalico history pushes |

## 1. Non-negotiable policies

1. **No Magneto PRs upstream** (Klipper3d or KalicoCrew).
2. **No proprietary Magmotor / MagnetoWifiHelper** in public repos.
3. **No secrets, SSH keys, Wi‑Fi passwords, or live UUID dumps** in commits (redact backups).
4. **No print models / gcode** in public repos (`.gitignore` enforces).
5. **CAN default story is 250 kbit** for stock Linux Hub unless field data says otherwise.
6. **Default track is mainline** (`magneto-x`). Kalico is optional A/B — document, don’t make it the only path.
7. **Markers + `magneto_guard.py`** required whenever touching patched Klipper files or Mag extras.
8. **Hardened manager before** shipping a clean-OS install path that runs our install script (see DESIGN D17).

---

## 2. No test-passing architecture

- Prefer **one** clear owner for each behavior (config *or* host extra *or* manager).
- Do not leave dual broken macros (`LINEAR_*` + typo `LINER_*` shell cmds), duplicate PAUSE/RESUME, or “temporary” soft-fail that accepts bad probes forever.
- Forbidden: papering over sticky probe by disabling Z safety; enabling `MAGNETO_RELAX_STEPPER_PAST` globally “just in case”; committing secrets to make CI green.

---

## 3. Work may cascade

If a change breaks the include graph, guard, or unit tests, fix **all** layers you touched:

Example: sticky-probe policy change → `homing.py` + `magneto_load_cell` dwell + macros that call `CLEAR_LOAD_CELL` + `docs/Magneto_X.md` + MANIFEST markers + tests.

Do not leave `magneto_guard.py` red.

---

## 4. Fix at the highest responsible owner

| Symptom | Fix owner | Not |
|---------|-----------|-----|
| MagXY won’t enable | manager / ESP32 serial / shell curl allowlist | Klipper kinematics |
| “Probe triggered prior to movement” | latch clear + dwell + D7 homing policy | disable probe |
| CAN UUID missing / toolhead offline | `can0` 250k, Lancer flash, UUID in `magneto_device.cfg` | random bitrate experiments without data |
| Include missing at startup | add/fix file under `config/` | comment out half the stack |
| Upstream merge dropped MagXY | restore markers via MANIFEST / re-apply patch | silent force-theirs on `homing.py` |
| Shell RCE concern | PR-M4 manager + PR-K5 PARAMS policy | more shell macros |

---

## 5. Known bad patterns (append when discovered)

When you hit a failure mode — especially one an LLM “fixed” wrong — add a **one-line entry** here.

<!-- Format: `- [YYYY-MM-DD] <pattern> → <correct owner/fix>` -->

- [2026-07-11] Peopoly public `master` looks like a usable base → it is a **squash**. Archaeology = Peopoly branch **`magneto-x`**; ship from **our** `magneto-x` / `magneto-x-kalico`.
- [2026-07-11] Assuming stock CAN is **1 Mbit** → live Linux Hub is **`gs_usb` @ 250000**. Host + Lancer must match.
- [2026-07-11] Using upstream **`load_cell_probe`** for stock Lancer → wrong electrical interface (digital latch, not HX/ADS ADC). Use **`magneto_load_cell`**.
- [2026-07-11] Keeping stock **`LINER_*`** shell commands / dual PAUSE trees → MagXY enable and Mainsail pause break. **`LINEAR_*` only**; one PAUSE/RESUME pair.
- [2026-07-11] Soft-fail “probe prior” forever when module present → can accept a stuck latch. Design **D7**: clear + dwell + **one** retry then **hard** fail (PR-K3 if not landed yet).
- [2026-07-11] Enabling **`MAGNETO_RELAX_STEPPER_PAST`** by default without A/B → disables a real safety. Default **n**; Octopus only after S3 reproduces “too far in past” (D15).
- [2026-07-11] Pushing full Kalico history with `.github/workflows/*` via limited OAuth → rejected. Published `magneto-x-kalico` may be a **tree snapshot**; content still valid for A/B. See `docs/TRACKS.md`.
- [2026-07-11] Shipping **stock magneto-manager** on a clean public image → binds `0.0.0.0`, arbitrary serial, `shell=True`. Harden (PR-M4) before Option A install path.
- [2026-07-11] Committing **Magmotor** / live **UUIDs** / **models** → scrub; use Release assets or local-only backups.
- [2026-07-11] Merging `magneto-x` ↔ `magneto-x-kalico` as routine → diverged bases. Port Magneto delta intentionally; use MANIFEST as checklist.
- [2026-07-11] Mixing mainline host with Kalico-built MCU firmware (or reverse) → protocol mismatch. Same track for host + both MCUs.

---

## 6. Printer / host deploy safeguards

**Prefer documented procedures** in `docs/MODERNIZATION.md` and `docs/OS_IMAGE.md`. Do not invent one-off rsync of half a tree without backup.

| Rule | Why |
|------|-----|
| Backup `printer_data/config` + note UUIDs before deploy | Recovery |
| Fill `magneto_device.cfg` with **this machine’s** serial/CAN UUID | Never commit real IDs as project defaults |
| `LM_ENABLE` before XY motion | MagXY disarmed = no motion / faults |
| `CLEAR_LOAD_CELL` / auto_clear before Z probe | Sticky latch |
| Stock CAN **250k** unless measured otherwise | Matches live hub |
| Confirm `lsusb` / `ip -d link show can0` on first bring-up | OQ#3 field verification |
| Flash MCUs only from the **active** host tree | Track pairing |
| Do not `rm -rf` stock Peopoly trees without a backup path | Irreversible |

Live lab printer (when relevant): see `docs/validation/` (local; often gitignored) — treat IPs/credentials as secrets.

---

## 7. Before completing any task

Run these checks **yourself** (do not only tell the user to run them):

1. **Secrets** — scan the diff for passwords, tokens, private keys, live CAN UUIDs, Wi‑Fi PSKs, SSH keys
2. **Binaries / models** — no Magmotor, no `.stl`/`.gcode`, no full `.img` blobs in git
3. **Upstream PR risk** — changes stay in our forks; no instructions to PR Klipper3d/KalicoCrew for Magneto patches
4. **Config graph** (if `config/` touched) — `python3 scripts/check_includes.py config`
5. **Magneto guard** (if `klipper/` Magneto assets or patches touched) — `python3 scripts/magneto_guard.py` + magneto unit tests
6. **Shell surface** — deployable `shell_command.cfg` remains allowlisted MagXY/version only; no demo/`hello_world`/freeform PARAMS
7. **Track honesty** — if docs mention Kalico-only features, gate them (`optional/danger_options.cfg`) and keep mainline default clear

Task is **not done** until these pass (or you explicitly report a blocked external dependency / needs hardware).

---

## Security audit prompts (use proactively on risky changes)

When touching `gcode_shell_command`, magneto-manager, install scripts, or anything that binds a port / runs a shell:

- *"List every path from gcode to root-equivalent command execution on the host."*
- *"How does a malicious .gcode abuse RUN_SHELL_COMMAND PARAMS?"*
- *"Does magneto-manager accept commands from non-localhost? What can send_command do?"*
- *"Audit this diff for leaked serial numbers, UUIDs, and credentials."*

---

## Test / verify commands

```bash
# Umbrella (magneto-x)
python3 scripts/check_includes.py config
python3 -m unittest discover -s tests -v   # if present

# Host tree (magneto-x-klipper clone)
cd klipper
python3 scripts/magneto_guard.py
python3 -m unittest discover -s tests/magneto -v

# On printer (examples — adapt user/host)
# ip -d link show can0
# curl -sG http://127.0.0.1:8880/ ...   # only after understanding manager API
# ~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

Hardware gates (LM_ENABLE → home → QGL → print) require the real machine; do not claim S3 validation from CI alone.

---

## Project conventions

### Commits / PRs

- Complete sentences; focused diffs; every changed line traces to the request
- Magneto behavior changes: update `docs/Magneto_X.md` / `DESIGN.md` when contracts change
- Prefer small PRs aligned with DESIGN plan IDs (`PR-K2`, `PR-M4`, …) when doing planned work

### Config

- **`LINEAR_*` only** for shell MagXY names; typo `LINER_*` is historical debt
- One PAUSE/RESUME implementation (macros), not also in mainsail/client
- OriginMove is **optional** include; stock XY is the published default unless the project flips that decision
- Placeholders for serial/UUID, not one owner’s production IDs

### Klipper fork

- Minimal Magneto delta; prefer new `extras/` modules over deep core rewrites
- Always keep `MAGNETO-X-BEGIN/END` on patched upstream hunks
- Stepper-past: default **off**; document Octopus-only enable after reproduction

### Docs

- Do not add markdown files the user did not ask for; update existing docs when behavior changes
- Vendor wiki dumps stay under `docs/vendor-archive/` as frozen reference

### Naming / discoverability

- Search terms: Magneto, Magneto X, MagXY
- Repo names per `docs/NAMING.md` — not `peopoly-*`, not bare `klipper` as the public brand

---

## Behavioral guidelines

*Bias toward caution over speed — this stack can crash a toolhead into a bed or brick an MCU. Use judgment on trivial doc typos.*

### Think before coding

- State assumptions explicitly (track, CAN bitrate, which machine, stock vs clean OS).
- If multiple interpretations exist, present them — do not pick silently.
- If a simpler approach exists (config-only vs fork patch), say so.
- Hardware-destructive steps (flash, `dd`, force-push, manager bind changes): confirm with the user first unless already authorized.

### Simplicity first

- Minimum Magneto delta that solves the problem.
- No speculative MagXY-in-Klipper rewrites, Beacon-first redesigns, or second kinematics for v1.
- No error handling theater for impossible printer states; do handle sticky latch and disarmed MagXY.

### Surgical changes

- Do not “improve” unrelated Klipper core or reformat Peopoly archives.
- Do not refactor stock vendor trees in `community/` unless the task is archival cleanup.
- Match existing style in each repo.
- Remove orphans **your** changes created; mention pre-existing debt.

### Goal-driven execution

- Prefer: guard/test → fix → green guard/tests → (hardware) LM_ENABLE checklist when in scope.
- Multi-step work: brief plan with `step → verify:` per step.
- Rollout stages (design): S0 docs → S1 fork gaps → S2 config → S2b hardened manager → **S3 hardware** → clean OS. Do not skip S3 claims without a printer.

**Working if:** smaller diffs, markers intact, no secrets, questions before flashing not after.

---

## Phase priority (hardware-gated)

1. **S0–S1** — Docs + Magneto extras gap-close (dwell, D7 sticky policy, shell PARAMS) + guard green  
2. **S2** — Parse-ready `config/` on a real host (`check_includes` + Klippy start far enough to demand MCU serial)  
3. **S2b** — Hardened magneto-manager before any public clean-OS install script  
4. **S3 / PR-V1** — Live machine: manager, CAN 250k, `LM_ENABLE`, home, QGL, short print; stepper-past A/B only if needed  
5. **S4+** — Clean MainsailOS path, Moonraker update_manager, defconfigs CI  
6. **Optional** — Kalico A/B, OriginMove default flip, EmperorArthur ESP32, native MagXY module (S7)

Do not treat scaffolds or doc-only work as “printer fixed” until S3 is explicitly run on hardware.

---

## Quick pointer map

| Need | Open |
|------|------|
| Architecture + PR plan | `docs/DESIGN.md` |
| Mainline vs Kalico | `docs/TRACKS.md` |
| Build/flash | `docs/MODERNIZATION.md` |
| OS install | `docs/OS_IMAGE.md` |
| What to port / ignore | `docs/SOURCE_ANALYSIS.md` |
| In-tree Magneto notes | `klipper/docs/Magneto_X.md` |
| Upstream merge procedure | `klipper/docs/UPSTREAM_SYNC.md` |
| Naming / Moonraker origin | `docs/NAMING.md` |
