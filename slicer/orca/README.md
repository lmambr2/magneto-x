# OrcaSlicer — Magneto X (magneto-x package)

Peopoly ships **system** profiles in upstream Orca under **Peopoly → Magneto X**.  
Use those as the base; apply the Magneto-modern notes below so start G-code matches this repo’s macros (KAMP, parametric `PRINT_START`).

**Not affiliated with Peopoly.** Profiles in Orca are upstream SoftFever/OrcaSlicer + Peopoly vendor data.

## Quick setup

1. Install current [OrcaSlicer](https://github.com/OrcaSlicer/OrcaSlicer/releases).
2. **Add printer** → vendor **Peopoly** → **Peopoly Magneto X** (0.4 / 0.6 / 0.8 nozzle).
3. Bed size in system profile is **300 × 400 × 300** (OriginMove / Driver1=X). Matches this package’s default `optional/origin_move.cfg`.
4. Connect host: Moonraker / Mainsail at the printer IP (e.g. `http://LAB_HOST`).
5. Apply **Machine G-code** and **process** recommendations below (or paste from the files in this folder).

## Required for adaptive mesh (KAMP)

| Setting | Where | Value |
|---------|--------|--------|
| **Label objects** / Exclude objects | Printer settings → Basic / Advanced | **ON** |
| Host `[exclude_object]` | Already in package `printer.cfg` | — |

Without labels, `BED_MESH_CALIBRATE` still runs a **full-bed** mesh (normal).

## Machine start / end G-code

Paste into **Printer settings → Machine G-code**.

### Recommended (Magneto-modern) — `machine_start_gcode.txt`

Heats in the slicer, then hands off to parametric `PRINT_START` (QGL → KAMP mesh → `LINE_PURGE`).  
Compatible with stock Peopoly Orca start style.

### Stock upstream (already in Orca `fdm_klipper_common`)

```gcode
M190 S[bed_temperature_initial_layer_single]
M109 S[nozzle_temperature_initial_layer]
PRINT_START EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer_single]
```

Either form works with this package’s `PRINT_START`. The recommended file adds comments, optional chamber arg, and documents `MESH`/`PURGE` flags.

### End G-code

```gcode
PRINT_END
```

## Filament / process notes

- **Pressure advance** and flow in Peopoly Generic / Lancer filaments are **factory seeds** — re-run Orca Calibration (PA, flow, max volumetric) per spool.
- Stock **0.20mm Standard** outer wall ~200 mm/s, infill ~300, travel 500 — aggressive. After first good mesh, if quality suffers, try the calmer process hints in `process_notes.md`.
- **Jetstream** (if installed): Printer → Accessory → enable **Auxiliary part cooling fan**; control with `M106 P2` / `M107 P2` (see Peopoly wiki / package FAQ).
- **Timelapse**: layer change → `TIMELAPSE_TAKE_FRAME` only if `timelapse.cfg` is included on the host.

## After host macro updates

When you pull a new `macros.cfg` with parametric `PRINT_START` / `FULL_CALIBRATE`, no Orca reinstall is required.  
Console self-check (not a print):

```text
FULL_CALIBRATE
FULL_CALIBRATE SAVE=1
```

## Upstream profile tree

- https://github.com/OrcaSlicer/OrcaSlicer/tree/main/resources/profiles/Peopoly  
- Vendor wiki (archived): `docs/vendor-archive/peopoly-wiki/orcaslicer-wiki.md`
