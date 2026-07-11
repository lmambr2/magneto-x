# Package audit — magneto-x deployable config & Peopoly legacy

**Date:** 2026-07-11  
**Scope:** Active `config/` include graph, host manager surface, legacy Peopoly macros/snapshots  
**CI gate:** `bash scripts/ci-magneto.sh` → **exit 0** (evidence: scratch `ci-magneto-audit.log`)  
**Include graph:** 12 files from `printer.cfg` (evidence: scratch `include-graph.txt`)

Severity: **critical** / **high** / **medium** / **low** / **info**

---

## 1. Active deploy set (include graph)

Resolved by `python3 scripts/check_includes.py config` (must match any “does it load?” claim):

| File | Role |
|------|------|
| `printer.cfg` | Top-level; MagXY module; homing_override; bed/Z/fans |
| `shell_command.cfg` | **Empty active content** — legacy MagXY curl stubs **commented** |
| `mainsail.cfg` | virtual_sd, pause_resume, CANCEL, layer-pause helpers |
| `macros.cfg` | PRINT_*/PAUSE/RESUME, QGL wrapper, LINEAR/LINER, filament, lights |
| `magneto_device.cfg` | MCU serial + CAN UUID placeholders |
| `magneto_toolhead.cfg` | Extruder, fans, ADXL, `[magneto_load_cell]` |
| `KAMP_Settings.cfg` | Adaptive mesh + Line_Purge + Smart_Park ON |
| `KAMP/Adaptive_Meshing.cfg` | Sole `BED_MESH_CALIBRATE` owner |
| `KAMP/Line_Purge.cfg` | `LINE_PURGE` |
| `KAMP/Smart_Park.cfg` | `SMART_PARK` (included, not auto-called) |
| `optional/origin_move.cfg` | XY + probe + bed_mesh + QGL geometry (default motion) |
| `timelapse.cfg` | **Stub** (no TIMELAPSE_* macros) |

**Not in active graph (out-of-deploy / reference):**

| Artifact | Why out-of-deploy |
|----------|-------------------|
| `macros.cfg.stock-v1.1.3` | Header: reference only; not included |
| `KAMP/Voron_Purge.cfg` | Commented out in `KAMP_Settings.cfg` |
| `motion_xy_stock.cfg` | Alternate motion; commented in `printer.cfg` |
| `optional/*` except origin_move | Opt-in includes |
| `backups/stock-live-*` | Historical lab snapshot |
| `peopoly-klipper/`, `community/*`, `magneto-x-klipper-config/` | Mirrors / community, not package load path |
| `macros.cfg` stock shells (`LINER_MOTOR_*`, `UPDATE_OS`, `RESIZE_*`, `TEST_*`) | Removed from modern package |

---

## 2. Bugs / risks

| ID | Sev | Finding | Path / symbol | Notes |
|----|-----|---------|--------------|-------|
| B1 | **medium** | ~~`LEVEL_BED` / bare `QUAD_GANTRY_LEVEL` do **not** `LM_ENABLE`~~ **Fixed** | `macros.cfg` | Both wrappers now `LM_ENABLE` first; policy tests assert it. |
| B2 | **medium** | ~~`CREATE_BED_MESH` never heats bed~~ **Fixed** | `macros.cfg` | Default `BED=60` + `M190`; `BED=0` skips. `FULL_CALIBRATE` same. |
| B3 | **medium** | ~~CI shell MagXY comment false green~~ **Fixed** | `scripts/check_includes.py` | Active module or active shells only. |
| B4 | **low** | ~~Timelapse stub hard-fails slicer frames~~ **Fixed** | `timelapse.cfg` | Soft no-op `TIMELAPSE_TAKE_FRAME` / `HYPERLAPSE`; still replace for real capture. |
| B5 | **low** | ~~`MAGNETO_OS_VERSION` misnamed~~ **Fixed** | `macros.cfg` | Clear description + `MAGNETO_MANAGER_VERSION` alias. |
| B6 | **low** | ~~`heater_bed` `min_temp: -200`~~ **Fixed** | `printer.cfg` | Now `min_temp: 0`; policy rejects &lt; 0. |
| B7 | **low** | ~~Shaper freqs look factory-true~~ **Fixed** | `printer.cfg` | Comments: seed only; recalibrate with SHAPER_CALIBRATE. |
| B8 | **low** | ~~`force_move` / SET_XYZ casual~~ **Mitigated** | `printer.cfg` / macros | Stronger expert-only wording on force_move + SET_XYZ_POSITION. |
| B9 | **info** | ~~`SMART_PARK` never in PRINT_START~~ **Fixed** | `macros.cfg` | Park after mesh before nozzle heat; `PARK=0` to skip. |
| B10 | **info** | ~~QGL always full G28~~ **Fixed** | `macros.cfg` | Skip full re-home when XYZ already homed. |
| B11 | **info** | ~~Mesh not auto-loaded on restart~~ **Fixed** | `macros.cfg` | `delayed_gcode _MAGNETO_LOAD_DEFAULT_MESH` loads `default` if present. |
| B12 | **high** (host, fixed earlier) | Moonraker v0.8 rejects second `[update_manager klipper]` | `moonraker-update-manager.conf.snippet` | Documented + postinstall strips; **CI covers** “no active section in snippet.” |
| B13 | **high** (macro, fixed earlier) | Dual `BED_MESH_CALIBRATE` breaks KAMP params | historical | **CI covers** single owner Adaptive_Meshing. |
| B14 | **medium** (ops) | Stock Peopoly `PRINT_START` used `MESH_LOAD` only (no QGL) | stock macros | Package correctly improved; do not reintroduce stock start. |

No **critical** “will brick parse” issues found in the active graph under current CI.

---

## 3. Legacy Peopoly assessment (keep / fix / remove)

### 3.1 Active macros & MagXY paths

| Symbol | Source | Classification | Rationale |
|--------|--------|----------------|-----------|
| `PRINT_START` | macros.cfg | **keep** | Modern parametric start: LM → QGL → KAMP mesh → purge. Replaces stock MESH_LOAD-only start. |
| `PRINT_END` | macros.cfg | **keep** | Cool + delayed `LM_DISABLE`. Jetstream-safe. |
| `delay_disable_motor` | macros.cfg | **keep** | MagXY disarm after print. |
| `FULL_CALIBRATE` | macros.cfg | **keep** | Product self-check; stock had weaker `CALIBRATE_BED`. |
| `FULL_CALIBRATE_BED` | macros.cfg | **keep** | Thin alias → `FULL_CALIBRATE {rawparams}`. |
| `LEVEL_BED` | macros.cfg | **keep** | `LM_ENABLE` then QGL (P1/B1 fixed). |
| `CREATE_BED_MESH` | macros.cfg | **keep** | Hot mesh default BED=60 (B2 fixed). |
| `MESH_LOAD` | macros.cfg | **keep** | Safe load if profile exists; prints should not rely on it. |
| `BED_MESH_CALIBRATE` | KAMP Adaptive | **keep** | Sole owner; Magneto Z re-home patch. |
| `LINE_PURGE` | KAMP | **keep** | Default purge path. |
| `SMART_PARK` | KAMP | **keep** | Called from PRINT_START after mesh (PARK=0 to skip). |
| `_KAMP_Settings` | KAMP_Settings | **keep** | Variable store. |
| `VORON_PURGE` | KAMP file | **remove from deploy** (already) | File present, include commented — leave off unless user wants logo purge. |
| `QUAD_GANTRY_LEVEL` wrapper | macros.cfg | **keep** | `LM_ENABLE` + home + QGL base + G28 Z (P1 fixed). |
| `PAUSE` / `RESUME` | macros.cfg only | **keep** | Sole owners; mainsail correctly omits. Safer Jetstream checks than stock. |
| `cool_hot_end` | macros.cfg | **keep** | Pause timeout cool. |
| `CANCEL_PRINT` | mainsail.cfg | **keep** | `LM_DISABLE` + Jetstream off. |
| `SET_PAUSE_*` / `SET_PRINT_STATS_INFO` | mainsail.cfg | **keep** | Mainsail layer-pause plumbing. |
| `_CLIENT_*` / `_TOOLHEAD_PARK_*` | mainsail.cfg | **keep** | Client helpers for cancel/pause. |
| `LOAD_FILAMENT` / `UNLOAD_FILAMENT` | macros.cfg | **keep** | Stock-derived; work. |
| `_C_UNLOAD_FILAMENT` | stock only | **remove** (already) | Panel helper; not in package. |
| `LINEAR_MOTOR` | macros.cfg | **keep** | Thin wrapper → `MAGNETO_LINEAR_*`. |
| `LINER_MOTOR` | macros.cfg | **keep** | Typo alias for old screens; one-liner cost. |
| `LM_ENABLE` / `LM_DISABLE` | module aliases | **keep** | PR-K7 `register_lm_aliases: True` — **not** shell. |
| Shell `LINEAR_MOTOR_ENABLE/DISABLE` | shell_command.cfg | **remove/replace** (inactive) | Fully commented; correct for PR-K7. Do not re-enable unless module off. |
| Stock `LINER_MOTOR_*` shells + curls | stock | **remove** (already) | Superseded by hardened manager + native module. |
| `MAGNETO_OS_VERSION` / `MAGNETO_MANAGER_VERSION` | macros.cfg | **keep** | OS name is alias; prefer MAGNETO_MANAGER_VERSION (B5 fixed). |
| `M106` / `M107` | macros.cfg | **keep** | Jetstream `P2` routing — Peopoly hardware. |
| `TOGGLE_LIGHTS` | macros.cfg | **keep** | Chamber LED. |
| `SET_XYZ_POSITION` | macros.cfg | **keep** (expert) | Dangerous; force_move culture. |
| `RUN_INPUT_SHAPER` | macros.cfg | **keep** (optional) | MagXY already smooths. |
| `Z_TO_BOTTOM` | macros.cfg | **keep** | Utility. |
| Stock `TEST_*_MOVE`, `RESIZE_*`, `UPDATE_OS*`, `TUNE_*_PID` | stock | **remove** (already) | Security/noise (shell OS update, resize FS). PID via console is enough. |
| Stock `CALIBRATE_BED` | stock | **remove/replace** | Replaced by `FULL_CALIBRATE`. |
| Stock `LINEAR_MOTOR_CONTROL` / `MOTOR_CONTROL` shells | stock | **remove** (already) | Magmotor helper surface. |
| `[magneto_linear_motor]` | printer.cfg | **keep** | Primary MagXY path. |
| `[magneto_load_cell]` | toolhead | **keep** | Lancer latch clear. |
| `[exclude_object]` | printer.cfg | **keep** | Required for KAMP. |
| `[homing_override]` Z | printer.cfg | **keep** | LM_ENABLE + center + CLEAR_LOAD_CELL + G28 Z. |
| `timelapse.cfg` stub | package | **keep** (stub) | Host replaces with real macros when component present. |

### 3.2 Stock snapshot behavior (not deployed)

| Stock pattern | Worked on Peopoly image? | Package status |
|---------------|--------------------------|----------------|
| `LM_ENABLE` → `RUN_SHELL_COMMAND CMD=LINER_MOTOR_ENABLE` → curl manager | Yes (typo LINER) | Replaced by native module |
| `PRINT_START` → mesh load static + LINE_PURGE, **no QGL** | Yes if mesh saved | Improved: QGL + adaptive mesh |
| `BED_MESH_CALIBRATE` in macros **and** KAMP Adaptive | Fragile / order-dependent | Fixed: macros do not redefine |
| Dual PAUSE in mainsail + macros | Known break | Fixed: mainsail has no PAUSE |
| Shell OS git clone / resize / update from gcode | Yes, dangerous | Removed from package |
| Heat-to-70 on every QGL/mesh | Yes, slow | Dropped; operator/slicer heats |

---

## 4. Refactor opportunities

| Pri | Opportunity | Why |
|-----|-------------|-----|
| P1–P3 audit fixes | **done** (2026-07-11) | B1–B11 addressed in package; residual P4 UX only |
| P2 | Split `macros.cfg` into print / MagXY / UI includes | Optional readability; not required for correctness |
| P3 | Drop empty `shell_command.cfg` include if forever PR-K7-only | Optional; file remains as documented fallback stubs |
| P4 | Promote “hot FULL_CALIBRATE” into KlipperScreen button | UX only |

---

## 5. CI re-verification (covered vs uncovered)

### Covered by current gate (`ci-magneto.sh` exit 0)

- Include graph resolves (incl. timelapse stub)
- Single `BED_MESH_CALIBRATE` owner (KAMP Adaptive)
- Adaptive + Line_Purge enabled
- `PRINT_START` / `FULL_CALIBRATE` token policy
- No active `[update_manager klipper]` in snippet
- Orca start G-code `PRINT_START EXTRUDER=… BED=…`
- CANCEL path has `LM_DISABLE` (policy)
- Probe speed band on motion files
- Manager allowlist / localhost / no shell=True (unit tests)
- SAVE_CONFIG format helper (unit tests)
- Ruff + shellcheck + bash -n

### Uncovered (audit-only; not asserted by CI today)

| Gap | Related |
|-----|---------|
| `LEVEL_BED` without `LM_ENABLE` | B1 |
| Manual mesh without bed heat | B2 |
| Shell MagXY “required” matching **comments** | B3 |
| Timelapse stub ≠ working timelapse | B4 |
| Misleading `MAGNETO_OS_VERSION` | B5 |
| `SMART_PARK` never invoked from start | B9 |
| Runtime MagXY/manager health on lab host | hardware non-goal |
| QGL session-only (not SAVE_CONFIG) | documented ops |

---

## 6. Spot-check quotes (high-risk paths)

See also scratch `macro-spotcheck.txt`.

**PRINT_START (package)** — MagXY + QGL + KAMP mesh + purge; parametric heat:

```text
config/macros.cfg — PRINT_START
  LM_ENABLE → (optional G28) → M190 if BED → QUAD_GANTRY_LEVEL
  → BED_MESH_CALIBRATE → M109 if EXTRUDER → LINE_PURGE
```

**FULL_CALIBRATE** — LM_ENABLE, G28, QGL, mesh; optional SAVE_CONFIG.

**CANCEL_PRINT** — `UPDATE_DELAYED_GCODE … delay_disable_motor` + `LM_DISABLE`.

**BED_MESH_CALIBRATE** — only in `KAMP/Adaptive_Meshing.cfg` (`rename_existing: _BED_MESH_CALIBRATE`).

**Shell MagXY** — all `LINEAR_MOTOR_*` shells commented in `shell_command.cfg`; active count = 0.

**Stock PRINT_START (not deployed)** — `LM_ENABLE` + `MESH_LOAD` + `LINE_PURGE`, no QGL.

---

## 7. Inventory: reference-only Peopoly / community

| Location | Treat as |
|----------|----------|
| `config/macros.cfg.stock-v1.1.3` | Reference snapshot of stock macros+shells |
| `backups/stock-live-20260711T1649Z/` | Lab dump of Peopoly image config |
| `peopoly-klipper/` | Old vendor klipper tree |
| `community/*` | Unofficial configs/firmware notes |
| `magneto-x-klipper-config/` | Upstream-ish config mirror |
| `docs/vendor-archive/peopoly-wiki/` | Frozen wiki, not runtime |

Do **not** classify these as “live package works/fails” without loading them through `printer.cfg`.

---

## 8. Summary verdict

| Area | Verdict |
|------|---------|
| Active package parse / CI | **Healthy** (gate green) |
| MagXY path | **Modern** (module + aliases); stock shell path correctly retired |
| Mesh / start | **Modern** (KAMP + QGL); better than stock static mesh load |
| Legacy Peopoly shells/OS gcode | **Correctly removed** from deploy |
| Residual risks | LEVEL_BED without LM_ENABLE; CI shell false green; cold manual mesh; naming nits |

**Recommended next engineering (out of this analysis goal):** fix B1 + B3 first; then B2 heat helper if operators use CREATE_BED_MESH often.

---

## 9. Evidence index

| Artifact | Path |
|----------|------|
| CI full log | `{SCRATCH}/ci-magneto-audit.log` |
| Include graph | `{SCRATCH}/include-graph.txt` |
| Active inventory | `{SCRATCH}/active-inventory.txt` |
| Stock vs package | `{SCRATCH}/stock-vs-package.txt` |
| Macro spotcheck | `{SCRATCH}/macro-spotcheck.txt` |
| Shell CI false green | `{SCRATCH}/ci-false-green-shell.txt` |

`{SCRATCH}` = implementer scratch for this goal run (session harness).
