# Process / filament tuning notes (Orca + Magneto X)

## System baselines (upstream Peopoly in Orca)

| Preset family | Typical outer wall | Infill | Travel | Notes |
|---------------|-------------------|--------|--------|--------|
| 0.20 Standard (@MagnetoX) | ~200 mm/s | ~300 | 500 | Aggressive; fine after solid mesh + PA |
| peopoly_common (slower base) | ~120 | ~200 | 350 | Safer first-print path |

## Calmer first-print overlay (suggested after mesh, before racing)

If first layers or ringing look rough with stock Standard:

| Setting | Try |
|---------|-----|
| Outer wall speed | 120–150 mm/s |
| Inner wall / infill | 180–220 mm/s |
| Initial layer speed | 40–60 mm/s |
| Outer wall acceleration | 2000–3000 |
| Travel | 300–400 mm/s |

Save as a user process, e.g. `0.20mm Standard calm @MagnetoX`, so system presets stay intact.

## Filament (re-calibrate; do not trust seeds forever)

| Profile (system) | Seed PA | Notes |
|------------------|---------|--------|
| Peopoly Generic PLA | 0.02 | Orca PA tower |
| Peopoly Generic PETG | base | Lower fan; watch stringing |
| Peopoly Lancer ABS-GF | 0.016 | Enclosure / venting per filament |

Always: **flow ratio** + **max volumetric speed** from Orca calibration for your nozzle.

## MagXY-specific

- MagXY closed-loop already smooths motion; **input shaping** is optional (`FULL_CALIBRATE SHAPER=1` or `RUN_INPUT_SHAPER`).
- Do not treat Orca “machine max accel 20000” as a goal — leave printer.cfg / slicer process accels conservative until S3 sign-off.
