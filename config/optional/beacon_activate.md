# Enabling Beacon on Magneto X (operator checklist)

This is a **hardware conversion**, not a stock enable.

## Stock vs Beacon

| Path | Probe | Z home |
|------|--------|--------|
| **Stock** | `[probe]` PE12 + `[magneto_load_cell]` | sticky load-cell |
| **Beacon** | USB `[beacon]` | Beacon virtual endstop |

You must not leave both active.

## Steps

1. **Power off** printer. Mount Beacon. Route USB to host. Power on.  
2. On host:
   ```bash
   cd ~/magneto-x
   ./os/install-beacon.sh
   ls /dev/serial/by-id/usb-Beacon*
   ```
3. Edit `~/printer_data/config/optional/beacon.cfg`:
   - `serial:` real by-id path  
   - `x_offset` / `y_offset` for mount  
   - `home_xy_position` / `safe_z_home` for bed center  
4. In `printer.cfg` add:
   ```ini
   [include optional/beacon.cfg]
   ```
5. Disable stock probe:
   - In `optional/origin_move.cfg` (or `motion_xy_stock.cfg`): **comment out entire `[probe]` section**  
   - In `magneto_toolhead.cfg`: **comment out `[magneto_load_cell]`** (and spare load-cell pin if desired)  
6. `FIRMWARE_RESTART`  
7. Calibrate (MagXY armed):
   ```gcode
   LM_ENABLE
   G28 X Y
   G0 X150 Y200 F6000
   BEACON_CALIBRATE
   # paper test with TESTZ, then:
   ACCEPT
   SAVE_CONFIG
   ```
8. Mesh: `BED_MESH_CALIBRATE` (scan mode).  
9. First print: babystep Z; then `Z_OFFSET_APPLY_PROBE` if offered.

## Macros / MagXY

Keep `LM_ENABLE` before motion (`homing_override`, `PRINT_START` already do this).

## Reverse

Remove `[include optional/beacon.cfg]`, restore `[probe]` + `[magneto_load_cell]`, restart.

## Docs

- https://docs.beacon3d.com/quickstart/  
- https://docs.beacon3d.com/config/  
