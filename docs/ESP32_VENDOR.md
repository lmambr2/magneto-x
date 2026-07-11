# ESP32 / MagXY firmware (vendor first)

**v1 policy (D11):** keep Peopoly ESP32 firmware. Do not flash community images until S3 is green on vendor FW.

## What the host needs

| Item | Detail |
|------|--------|
| USB | CH340 `1a86:7523` — description often “USB Serial” |
| Baud | 115200 |
| Manager | Hardened `ENABLE` / `DISABLE` only via `:8880` |
| Closed-loop | MotionG drivers; outside Klipper |

## Recovery (if ESP32 becomes unresponsive)

1. Power-cycle 48 V linear supply and 24 V logic (safe stop first).  
2. Check `curl -s http://127.0.0.1:8880/health` and `lsusb` for CH340.  
3. Re-seat USB; confirm user is in `dialout`.  
4. Stock Peopoly tools: `magneto-manager-tool` / wiki ESP update path (vendor archive under `docs/vendor-archive/peopoly-wiki/`).  
5. UART boot / esptool: only with a known-good Peopoly firmware binary you obtained yourself — **not** shipped in this repo.

## Community firmware (deferred — PR-M10)

[EmperorArthur/magneto_x_linear_motor_controller_firmware](https://github.com/EmperorArthur/magneto_x_linear_motor_controller_firmware) is research-grade open work. Optional later:

- Document ENABLE/DISABLE string compatibility with our manager allowlist  
- UART pinout + recovery  
- Explicit “voids vendor support” warning  

Do not make this the default install path.
