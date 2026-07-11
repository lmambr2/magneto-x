# MCU build & flash — Magneto X

Build Octopus + Lancer from the **same** `~/klipper` git HEAD you run on the host (`magneto-x` or `magneto-x-kalico`). Decision **2A**: keep stock bins until host path works; then flash.

Defconfig fragments in this repo: `os/defconfig-octopus-magneto`, `os/defconfig-lancer-magneto`.

## Octopus Pro (main MCU, USB)

Matches BTT Octopus Pro v1.1 + Peopoly H723 field units.

```bash
cd ~/klipper
make clean
cp /path/to/magneto-x/os/defconfig-octopus-magneto .config
# or: make menuconfig and set the options below
make olddefconfig   # if using fragment
make
# out/klipper.bin → firmware.bin on TF card in Octopus, or DFU
```

### menuconfig checklist

| Option | Value |
|--------|--------|
| Architecture | STM32 |
| Processor | **STM32H723** |
| Bootloader offset | **128KiB bootloader** |
| Clock | **25 MHz crystal** |
| Communication | USB (PA11/PA12) |
| Extra low-level options | Yes if enabling MagXY relax |
| Magneto X: relax stepper past | **n** until S3 A/B (D15) |

Silkscreen may say H732; USB id on lab unit is `stm32h723xx`. If flash fails, use DFU recovery and re-check processor selection.

### Flash notes

- SD card: copy `out/klipper.bin` as `firmware.bin`, insert, reset.  
- After flash, re-check `/dev/serial/by-id/usb-Klipper_stm32h723xx_*` and update `magneto_device.cfg` if needed.

## Lancer toolhead (RP2040, CAN)

```bash
cd ~/klipper
make clean
cp /path/to/magneto-x/os/defconfig-lancer-magneto .config
make olddefconfig
make
# out/klipper.uf2 — hold BOOT, USB-C to PC, copy to RPI_RP2
```

| Option | Value |
|--------|--------|
| Architecture | RP2040 |
| Communication | CAN bus |
| CAN bus speed | **250000** (stock Linux Hub) |
| `MAGNETO_RELAX_STEPPER_PAST` | **must be n / absent** |

After flash: `canbus_query.py can0` and set `canbus_uuid` in `magneto_device.cfg`.

## Same-HEAD discipline

```bash
cd ~/klipper && git rev-parse --short HEAD
# Record this for both MCU builds and host
```

Do not mix mainline host with Kalico-built firmware (or reverse).

## Stepper-past A/B (after modern flash)

1. Build Octopus with relax **n**, print / rapid XY.  
2. If “Stepper too far in past” appears on MagXY only, rebuild with relax **y**, reflash Octopus only.  
3. Document outcome in a validation note before making relax the published default.
