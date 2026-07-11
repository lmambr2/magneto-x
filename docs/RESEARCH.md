# Peopoly Magneto X — Firmware Research Notes

Working basis: [lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper)  
**Policy: do not open PRs or push commits to upstream [Klipper3d/klipper](https://github.com/Klipper3d/klipper).**  
All Magneto work stays on the personal fork / this workspace.

---

## 1. What Peopoly actually forked

| Item | Finding |
|------|---------|
| Peopoly claim | “Customized Klipper **V0.11**” (wiki) |
| Real base commit | `5f0d252b408ef0cd182367ba4cc224b8d105f0ec` |
| Base message | `docs: Minor update to Config_Changes.md dates` — **Kevin O'Connor, 2023-05-25** |
| Era | Post-**v0.11.0** (Dec 2022), pre-**v0.12.0** (late 2023) |
| Distance from modern master | ~1300 commits (as of mid-2026) |

### Broken history on `master`

Peopoly’s public `master` is a **squashed “magneto x init commit”** (`8dc303bd`, 2024-02-10) with no upstream parents. That is what people mean by “they broke the commit history.”

### Usable branch: `magneto-x`

Branch `mypeopoly/Klipper` → `magneto-x` **does** keep real git history and two Peopoly commits on top of the base above:

1. `c8d2e754` — *add magneto-x klipper modified files* (2024-02-16)
2. `78c3e29a` — *remove stepper event full shutdown* (2024-04-03)

**Always analyze `magneto-x`, not squashed `master`.**

---

## 2. Peopoly’s actual Klipper code delta

Only **six paths** changed relative to `5f0d252b` (~172 lines):

| File | Change | Why |
|------|--------|-----|
| `klippy/extras/magneto_load_cell.py` | **New** | Pulse GPIO to reset STC8051+CS1237 digital probe latch (`LC28` / `LL28` / `LH28`) |
| `klippy/extras/gcode_shell_command.py` | **New** (Arksine) | Run shell from gcode — used for MagXY ENABLE/DISABLE via HTTP |
| `klippy/extras/homing.py` | Soften “Probe triggered prior to movement” | Sticky load-cell high until reset |
| `klippy/extras/probe.py` | Minor / mostly dead code | Looked up load cell; clear path largely commented out |
| `src/stepper.c` | Disable `shutdown("Stepper too far in past")` | MagXY short pulses + ESP32 bridge timing |
| `README.md` | Marketing text | — |

**There is no custom kinematics, no MagXY closed-loop math in Klipper, and no linear-motor driver in Klipper.**  
X/Y look like normal step/dir steppers to Klipper (`rotation_distance: 3.2`, `step_pulse_duration: 0.0000002`).

---

## 3. Hardware architecture (firmware-relevant)

```
┌─────────────────────┐     USB      ┌──────────────────────────┐
│ Orange Pi Zero 2    │─────────────▶│ BTT Octopus Pro 1.1      │
│ (Armbian/Mainsail)  │              │ STM32H723/H732           │
│ Klipper host        │              │ Z×4, bed, X/Y step+dir,  │
│ Moonraker/Mainsail  │              │ endstops, Jetstream, …   │
│ magneto-manager:8880│              └───────────┬──────────────┘
└─────────┬───────────┘                          │ step/dir
          │ USB-serial (CH340)                   ▼
          │                            ┌──────────────────────┐
          └───────────────────────────▶│ ESP32 MagXY bridge   │
                                       │ (MotionG RS485×2)    │
          USB-CAN (Linux Hub PCB)      └──────────────────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ Lancer toolhead │  RP2040 + TMC2209 extruder
         │ CAN UUID        │  load-cell digital probe, ADXL, fans
         └─────────────────┘
```

| Power | Use |
|-------|-----|
| 24 V / 350 W | Logic, heaters, Z, toolhead |
| 48 V / 600 W | Linear motors |

| Module | MCU / SoC | Firmware surface |
|--------|-----------|------------------|
| Host | Orange Pi Zero 2 (H616) | Linux image + Klippy |
| Main board | STM32H723 | Klipper MCU USB |
| Toolhead | RP2040 | Klipper MCU CAN |
| MagXY bridge | ESP32-WROOM-32D | Vendor / [EmperorArthur reverse eng.](https://github.com/EmperorArthur/magneto_x_linear_motor_controller_firmware) |
| Load cell front-end | STC8051 + CS1237 | Separate binary; threshold DIP switches |
| Linear drivers | MotionG DN1-G60xxN | Closed-loop; params via Magmotor / LinearMotorHost |

Default SSH (stock image): `pi` / `armbian`.

---

## 4. What is *not* in Klipper (but required to run)

| Component | Role |
|-----------|------|
| `magneto-manager.py` (Flask :8880) | UUID helpers, `send_command=ENABLE/DISABLE` to ESP32 |
| `Magmotor` (Qt5 aarch64 binary) | GUI for MagXY params / errors |
| `MagnetoWifiHelper` | WiFi helper binary |
| KlipperScreen panels | Linear motor UI |
| Stock OS image tags | `magneto-x-mainsailOS-2024-*-v1.0.9` … `v1.1.1` (Git LFS mirror mostly empty of blobs in clone) |

LM enable path (stock macros had a **typo** `LINER_MOTOR_*` vs `LINEAR_MOTOR_*` that could break `_LM_ENABLE`):

```
LM_ENABLE → RUN_SHELL_COMMAND → curl :8880/send_command?command=ENABLE → ESP32
```

---

## 5. Community repos (useful takeaways)

| Repo | Value |
|------|--------|
| [mypeopoly/Klipper](https://github.com/mypeopoly/Klipper) | Source of truth for patches (`magneto-x` branch) |
| [mypeopoly/magneto-x-klipper-config](https://github.com/mypeopoly/magneto-x-klipper-config) | Official printer configs |
| [mypeopoly/magnetox-os-update](https://github.com/mypeopoly/magnetox-os-update) | Manager scripts, binaries, late macros |
| [EmperorArthur/magneto_x_linear_motor_controller_firmware](https://github.com/EmperorArthur/magneto_x_linear_motor_controller_firmware) | ESP32 / Modbus reverse engineering |
| [kaihanga FAQ](https://kaihanga.github.io/peopoly-magnetox-faq/) | Pause/resume, SSH, Beacon, nginx timeouts |
| [hazyavocado/Peopoly-MagnetoX-CFG](https://github.com/hazyavocado/Peopoly-MagnetoX-CFG) | Pause/resume + client.cfg fixes |
| [PlazmaZero/MagnetoX-OriginMove](https://github.com/PlazmaZero/MagnetoX-OriginMove) | XY origin / port swap without rewiring |
| [mitant](https://github.com/mitant/peopoly-magneto-x-config), [WilliamJamieson](https://github.com/WilliamJamieson/Magneto_x_config) | User config backups / Klipper-Backup |
| [Schmudus/My-Magneto-X](https://github.com/Schmudus/My-Magneto-X) | Heavy hardware path (Pi + Kalico + Eddy, etc.) |
| [JMack89427/magneto_klipper](https://github.com/JMack89427/magneto_klipper) | Dump of home tree (less useful as a clean fork) |

---

## 6. Upstream Klipper today vs Magneto needs

| Feature | Status |
|---------|--------|
| Native `load_cell` / `load_cell_probe` | **Yes**, but for **ADC chips** (HX71x, ADS1220, …). **Cannot** replace Peopoly’s digital latch without hardware change |
| `gcode_shell_command` | Still **not** upstream (security). Still required for MagXY macros unless you rewrite enable as a native module |
| “Stepper too far in past” | Still present; Peopoly still needs the relaxation on MagXY builds |
| “Probe triggered prior to movement” | Modern API has `check_movement=`; sticky digital probe still needs clear + soft handling |

---

## 7. Modernization strategy (this workspace)

1. **Host Klipper**: `lmambr2/magneto-x-klipper` branch `magneto-x` = current upstream + Magneto extras only.
2. **Configs**: cleaned package under `config/` (UUID placeholders, fixed LM naming, single PAUSE/RESUME).
3. **Host OS**: prefer **current MainsailOS Armbian image for Orange Pi Zero 2** + KIAUH/git install of our fork + magneto-manager services — not Peopoly’s frozen 2024 image as long-term base.
4. **MCUs**: rebuild Octopus (H723 USB) and Lancer (RP2040 CAN) from the modern tree; enable `MAGNETO_RELAX_STEPPER_PAST` on Octopus only.
5. **ESP32 / load-cell MCU**: keep vendor firmware initially; optional later work from EmperorArthur’s reverse engineering.
6. **Never PR Magneto patches to Klipper3d.**

See [MODERNIZATION.md](MODERNIZATION.md) and [OS_IMAGE.md](OS_IMAGE.md) for procedures.
