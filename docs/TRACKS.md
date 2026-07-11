# A/B tracks: mainline Klipper vs Kalico

Firmware host options for Magneto X live in **[lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper)**.

| Branch | Upstream base | Role |
|--------|---------------|------|
| **`magneto-x`** | [Klipper3d/klipper](https://github.com/Klipper3d/klipper) | **Default** — start here |
| **`magneto-x-kalico`** | [KalicoCrew/kalico](https://github.com/KalicoCrew/kalico) | Optional A/B |

Canonical switch / Moonraker / dual-tree procedure:  
**https://github.com/lmambr2/magneto-x-klipper/blob/magneto-x/docs/TRACKS.md**  
(same file on `magneto-x-kalico`).

## Same on both tracks

- `[magneto_load_cell]` + sticky-probe soft-fail  
- Optional `MAGNETO_RELAX_STEPPER_PAST` on Octopus  
- MagXY via magneto-manager + `[gcode_shell_command]`  
- Umbrella `config/` package (this repo)

## Kalico-only (optional)

After switching to `magneto-x-kalico`, you may enable Kalico extras (read Kalico docs first):

- Sample include: [`config/optional/danger_options.cfg`](../config/optional/danger_options.cfg)  
- MPC / velocity PID / PID profiles — see [Kalico additions](https://docs.kalico.gg/Kalico_Additions.html)  
- Schmudus-style advanced stacks remain documented as **alt hardware**, not default

## Config rule

Keep printer configs **track-agnostic** unless a section is clearly Kalico-only.  
Gate Kalico-only files with a commented include:

```ini
# Only on magneto-x-kalico host — leave commented on mainline
# [include optional/danger_options.cfg]
```

## Policy

- Default install docs use **`magneto-x`**.  
- Do not PR Magneto patches to Klipper3d or KalicoCrew.  
- Reflash MCUs when changing tracks (host/MCU protocol must match).
