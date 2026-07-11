# Field facts (researched 2026-07-11)

Measured on live Magneto X (`mainsailos` / lab unit) + Peopoly public materials + stock backups. These are **not product forks** — they lock install docs.

## CAN / Linux Hub (OQ#3 — **closed for stock hub**)

| Fact | Value | Source |
|------|--------|--------|
| Interface | `can0` | live `ip link` |
| Driver | **`gs_usb`** | `uevent` `DRIVER=gs_usb` |
| USB VID:PID | **`1d50:606f`** | live `lsusb` + sysfs `PRODUCT=1d50/606f/0` |
| USB description | OpenMoko / **Geschwister Schneider CAN adapter** (candleLight-class) | `lsusb` |
| Bitrate | **250000** (not 1 Mbit) | live + interfaces.d + backup |
| Sample point | 0.875 | live |
| txqueuelen | 128 (stock); community often raises to 512 | stock `can.txt`; Schmudus guide |
| Hub topology | Terminus 7-port hub `1a40:0201` on bus | live `lsusb` |

**Install recipe (stock hub):** bind `gs_usb`, bring up `can0` at **250000**, then `canbus_query.py can0`. Do not document 1 Mbit for stock Peopoly Linux Hub.

If someone replaces the hub with a different USB-CAN, re-check `lsusb` / bitrate.

## Octopus MCU (OQ#2 — **closed for this unit + Peopoly BOM**)

| Fact | Value | Source |
|------|--------|--------|
| Klipper identity | `usb-Klipper_stm32h723xx_*` | live serial-by-id + backup |
| MCU constant | `MCU: stm32h723xx` | Moonraker printer objects / validation JSON |
| CLOCK_FREQ | 400000000 | validation JSON |
| Crystal pins reserved | PH0/PH1 | mcu_constants |
| Peopoly marketing BOM | BTT Octopus Pro 1.1 **(STM32H723)** | peopoly.net product page |
| Stock MCU firmware string | `v0.11.0-205-g5f0d252b-dirty-…` | validation (ancient — host later; bins stay until flash decision) |

**H732 silkscreen confusion:** some boards/docs mention H732 package family; USB id and mcu_constants on the live unit are **H723**. Defconfig **STM32H723** + **25 MHz** crystal remains correct. If a future unit enumerates differently, photograph silkscreen and use DFU recovery — do not ship a second defconfig until that evidence exists.

## ESP32 / MagXY serial

| Fact | Value |
|------|--------|
| USB | CH340 `1a86:7523` → `/dev/ttyUSB0` (`usb-1a86_USB_Serial`) |
| Manager | talks 115200 to “USB Serial” |

## SSH / OS users (OQ#6)

| Environment | User | Default password (change immediately) |
|-------------|------|----------------------------------------|
| **MainsailOS on Armbian SBC** (clean install docs) | **`pi`** | **`armbian`** — [MainsailOS Armbian docs](https://docs.mainsail.xyz/mainsailos/getting-started/armbian/) |
| Live Peopoly stock image | **`pi`** (uid 1001) | was `armbian` on lab unit (operator may have changed) |
| Plain Armbian first boot | often `root` / `1234` | not the MainsailOS path |

Document **per image**: clean MainsailOS OPi → `pi`/`armbian`; never assume `mainsail` user unless a future image says so.

## XY orientation (supports decision 3B)

Live `printer.cfg`:

- `[stepper_x]` comment Driver1, `position_max: 300`
- `[stepper_y]` comment Driver0, `position_max: 400`

That is **OriginMove-style** (X=300 / Y=400), not stock Peopoly Driver0=X400 / Driver1=Y300. Publishing OriginMove as default matches this unit and PlazmaZero / field reports.

## Stepper-past shutdown (D15 — still experimental)

| Fact | Value |
|------|--------|
| Stock Peopoly tree | Unconditionally removed / disabled “Stepper too far in past” on MagXY path |
| Our fork | `MAGNETO_RELAX_STEPPER_PAST` **default n** |
| Decision 2A | Stock MCU bins kept initially → **cannot change** stepper-past until flash |
| Modern need | **Unknown** until S3 A/B on modern host + MagXY motion |

Do **not** enable by default. If first modern-host print with stock bins never trips the shutdown, leave **n** forever. If it trips on Octopus MagXY only, enable on Octopus defconfig and re-flash.

## Host software (lab snapshot)

| Item | Value |
|------|--------|
| OS label | `magneto-x-mainsailOS-2024-5-1-v1.1.3-mag-x` |
| Kernel | 5.16.17-sun50iw9 |
| Host Klipper | `v0.11.0-275-g8ef0f7d7e-dirty` |
| Moonraker | ~v0.8.0-era |
| Klippy state | ready (at validation capture) |

## Remaining optional captures

- Full `dd` of eMMC was incomplete earlier — not required for decisions above.
- Second machine H732 silkscreen photo — only if community reports non-H723 USB ids.
