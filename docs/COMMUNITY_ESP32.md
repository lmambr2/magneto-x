# Community ESP32 MagXY firmware (EmperorArthur et al.)

**Default for magneto-x:** Peopoly **vendor** ESP32 firmware (D11).  
Community firmware is **optional**, after S3 is green on vendor FW.

## What it is

Open re-implementation of the MagXY bridge board firmware:

- Repo: [EmperorArthur/magneto_x_linear_motor_controller_firmware](https://github.com/EmperorArthur/magneto_x_linear_motor_controller_firmware)  
- Local archive (workspace): `community/magneto_x_linear_motor_controller_firmware/`  
- SoC: ESP32-WROOM-32D, CH340 USB-serial **115200 8N1**  
- Talks Modbus RTU to MotionG DN1-G60xxN drivers (X + Y)

## Protocol overlap with stock / our stack

Community **ASCII mode** accepts the same primary host strings Peopoly uses:

| Host string | Effect (community) |
|-------------|--------------------|
| `ENABLE` | enableBothMotors / clear errors |
| `DISABLE` | disableBothMotors |
| `VERSION` | print firmware version |

So:

- Hardened **magneto-manager** allowlist (ENABLE/DISABLE) works.  
- **`[magneto_linear_motor]`** http or serial backends work.  
- Extra community commands (`CURRENT_X:`, `##`/`@@` Modbus raw, etc.) are **intentionally not** exposed by our manager or K7 module (footguns).

## When to consider it

| Use community | Stay vendor |
|---------------|-------------|
| Need open source / fix bugs in bridge | Printer not yet S3-validated |
| Want documented error paths | Don’t want to risk brick |
| Comfortable with PlatformIO + UART recovery | Prefer Peopoly support path |

## Risks

- **Voids easy vendor support** for MagXY.  
- Wrong flash can leave motors stuck disabled or in RTU gateway mode.  
- Must keep step/dir pulse behavior compatible with Klipper (`step_pulse_duration` 200 ns on XY).  
- Do not run **serial** backend + magneto-manager on the same CH340 at once.

## Flash / recovery (high level)

1. Install PlatformIO; open the community project.  
2. Hold boot / use USB-C as per board docs; flash.  
3. Serial monitor @ 115200; confirm boot banner / VERSION.  
4. Host: `curl` ENABLE or `MAGNETO_LINEAR_ENABLE`; LEDs green.  
5. Recovery: Peopoly vendor binary via esptool (obtain yourself — not in this repo) or re-flash community.

Exact pin maps and photos: community `README.md` + `docs/`.

## Relation to PR-K7

K7 does **not** require community firmware. It works with:

1. Vendor ESP32 + manager (default **http** backend)  
2. Community ESP32 + manager or **serial** backend  

Prefer **http + hardened manager** so UUID helpers and exclusive serial ownership stay centralized.

## Recommendation

1. Finish **S3 on vendor FW** with K7 http backend.  
2. Only then try community firmware as an A/B, with a known-good vendor binary saved for recovery.  
3. Keep manager allowlist as the security boundary regardless of which FW is on the ESP32.
