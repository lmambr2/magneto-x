---
source: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-linux-mcu-firmware
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-linux-mcu-firmware
> Content may be outdated or wrong; prefer community docs when they disagree.

Firmware Update Guide for Magneto X Modules | Peopoly Wiki - - - - - - - -

# [¶](#firmware-update-guide-for-magneto-x-modules) Firmware Update Guide for Magneto X Modules

 This document provides instructions for flashing firmware to various modules of the Magneto X.

## [¶](#h-1-klipper-host-orange-pi-zero2) 1. Klipper Host (Orange Pi Zero2)

 To update the firmware on the Orange Pi Zero 2, you need to upgrade the image. Refer to this wiki for details:

[Updating TF Image](/en/magneto/magneto-x/update-tf-image)

 Alternatively, you can update the system online:

[Online System Update](/en/magneto/magneto-x/update-magneto-x-online)

## [¶](#h-2-btt-octopus-pro-11) 2. BTT Octopus Pro 1.1

 The motion control board for Magneto X uses the BTT Octopus Pro 1.1 with an STM32H732 version.

 [¶](#flashing-firmware) Flashing Firmware
 Download the precompiled .bin firmware from:

[Download Firmware](https://drive.google.com/file/d/1sOB3uz85s-ZXus_DNUjokj1pInnj6SGU/view?usp=sharing)

 After downloading, rename the file to firmware.bin , copy it to a TF card, insert the TF card into the MCU’s TF card slot, and reset the Octopus Pro board. Wait about 10 seconds to complete the firmware update.

 [¶](#compiling-firmware) Compiling Firmware
 To open the Klipper firmware config tool, connect to your printer via SSH and execute the following commands:

 cd ~/klipper
make menuconfig

After setting all configurations, close the menu (press q ). To clear the cache and build the new firmware, execute:

 make clean
make

 The firmware will be compiled and located at ~/klipper/out/klipper.bin .

## [¶](#h-3-lancer-toolhead-pcb-firmware-compilation-and-flashing) 3. Lancer Toolhead PCB Firmware Compilation and Flashing

 For hardware details about the Lancer Toolhead PCB, refer to this wiki:

[Lancer Toolhead PCB](/en/magneto/magneto-x/lancer-toolhead-pcb)

 [¶](#updating-firmware) Updating Firmware
 Download the compiled toolhead PCB firmware from:

[Download Toolhead Firmware](https://drive.google.com/file/d/1cuyXaVL2yDgjBWItpVP9TXJBgwdEVkK1/view?usp=sharing)

 Steps to update:

- Press and hold the boot button on the toolhead board.

- Connect the toolhead board to your computer via a Type-C data cable.

- Your computer will recognize an RPI_RP2 drive.

- Copy the downloaded .uf2 firmware file to the RPI_RP2 disk. The drive will automatically eject after copying.

 [¶](#compiling-firmware-1) Compiling Firmware
 To open the Klipper firmware config tool, connect to your printer via SSH and execute:

 cd ~/klipper
make menuconfig

After setting all configurations, close the menu (press q ). To clear the cache and build the new firmware, execute:

 make clean
make

 The firmware will be compiled and located at ~/klipper/out/klipper.uf2 .

## [¶](#h-4-loadcell-mcu-firmware-update) 4. Loadcell MCU Firmware Update

 The loadcell data acquisition uses an STC8051 microcontroller, with the ADC chip CS1237 responsible for collecting loadcell sensor deformation data, which is then processed by the STC8051 to output a high/low signal.

 The RPI2040 chip on the toolhead PCB collects this high/low signal as a probe signal.

 To update the loadcell firmware, refer to this link:

[Loadcell Firmware Update](/en/magneto/magneto-x/loadcell-update-firmware)

 The loadcell trigger threshold is adjustable, with the default threshold set to 200. You can monitor loadcell value changes in real-time via this wiki:

[Loadcell Data Monitoring](/en/magneto/magneto-x/loadcell-data-monitoring)

 You can set the loadcell trigger threshold using the DIP switches on the toolhead PCB.

 The threshold value table is blow:

## [¶](#h-5-linear-motor-driver-control-board-firmware-upgrade) 5. Linear Motor Driver Control Board Firmware Upgrade

 The linear motor driver control board is based on ESP32 and is a crucial part of the linear motor system. Refer to the following wiki to flash firmware to this board:

[Updating Linear Motor Controller Firmware](/magneto/magneto-x/how-to-update-linear-motor-controller-firmware)
