---
source: https://wiki.peopoly.net/en/magneto/magneto-x
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x
> Content may be outdated or wrong; prefer community docs when they disagree.

Magneto X | Peopoly Wiki - - - - - - - -

# [¶](#h-0introduction) 0.Introduction

 The Peopoly Magneto X, a state-of-the-art desktop FFF/FDM 3D printer, stands out with its MagXY magnetic levitation system, delivering unprecedented precision and speed. This printer boasts a 400 x 300 x 300 mm build volume, a PEI magnetic build surface, and a 1000W heater for fast, even heating. Featuring the Lancer extruder, it supports a wide array of materials. Key features include a 1080P camera, a 7-inch IPS touchscreen, and comprehensive connectivity options, making it ideal for both enthusiasts and professionals seeking high-performance 3D printing.

# [¶](#h-1quick-links) 1.Quick Links

## [¶](#h-11-quick-start) ⚡1.1 Quick Start

### [¶](#getting-started-with-magneto-x-unboxing-and-setup) [⚡Getting Started with Magneto X: Unboxing and Setup](/en/magneto/magneto-x/setup-guide-q)

### [¶](#how-to-install-magneto-x-enclosure) [⚡How to install Magneto X Enclosure](/en/magneto/magneto-x/enclosure-setup-guide-q)

### [¶](#magnetox2024q2-upgrade) [⚡MagnetoX2024Q2 Upgrade](/en/magneto/magneto-x/magnetox-2024q2-update-toolhead-part)

### [¶](#how-to-assemble-the-linear-motor-kit) [⚡How to Assemble the Linear Motor Kit](/en/magneto/magneto-x/linear-motor-kit-user-manual)

## [¶](#️12-download-software-and-updates) 🗝️1.2 Download Software and Updates

- [Orca Slicer](/en/magneto/magneto-x/orcaslicer-wiki)

- [Klipper TF Card Firmware Mirror and Tools](/en/magneto/magneto-x/klipper-firmware)

- [Guide to update Magneto X System Online](/en/magneto/magneto-x/update-magneto-x-online)

## [¶](#h-13-troubleshooting) 🦾1.3 Troubleshooting

- [FAQ (including where to Seek Help)](/en/magneto/magneto-x/magneto-x-faq)

### [¶](#xy-block-error) 🚩X/Y block error

- [Guide to get linear motor error code from touchscreen](/en/magneto/magneto-x/get-error-code-in-touchscreen)

- [Guide to Retrieving Error Codes for Linear Motors](/en/magneto/magneto-x/guide-to-get-linear-motor-error)

 X-axis error

- [0x86,0x11 Error](https://drive.google.com/file/d/1YvXEburHgwLfZbjzodwrOS5yFYbMY-HZ/view?usp=sharing)

- [Guide for X axis motor hardware check](/en/magneto/magneto-x/x-axis-hardware-check)

- [Guide to Replacing the X-Axis Cable](/en/magneto/magneto-x/guide-to-replace-x-wires)

 Contact [support@peopoly.net](mailto:support@peopoly.net) replace the X axis cable.

 Y-axis error

- [How to replace Y axis](/en/magneto/magneto-x/how-to-replace-y-axis)

### [¶](#the-system-cannot-start-normallyloop-reboot) 🚩The system cannot start normally/loop reboot

- [System Booting Troubleshooting](/en/magneto/magneto-x/linux-boot-error)

### [¶](#klipper-z-error) 🚩Klipper z error

 error1:

 Endstop z still triggered after retract

 Contact [support@peopoly.net](mailto:support@peopoly.net) replace the loadcell or toolhead pcb.

 error2:

 TMC 'stepper_z1/2/3' reports error: GSTAT zzz

- [How to change z_stepper pin](/en/magneto/magneto-x/guid-to-change-z-stepper-pin)

 Contact [support@peopoly.net](mailto:support@peopoly.net) replace the TMC2209 driver

 error3:

 Klipper has shut down Intemal error on command:"QUAD GANTRY LEVEL BASE"

 Contact [support@peopoly.net](mailto:support@peopoly.net) replace the loadcell

 error4:

 Klipper has shut down Intemal error on command:"BED_MESH_CALIBRATE_BASE"

 Contact [support@peopoly.net](mailto:support@peopoly.net) replace the loadcell

### [¶](#klipper-heating-error) 🚩Klipper heating error

 error:

 See the 'verify heater' section in docs/Config Reference.mdfor the parameters that control this check.

 Connect [support@peopoly.net](mailto:support@peopoly.net) replace the hotend

### [¶](#connect-network) 🚩Connect network

- [Magneto X's Wifi setting](/en/magneto/magneto-x/how-to-connect-wifi)

- [Guide to Editing the TF Card of Magneto X for Wifi Connection](/en/magneto/magneto-x/magneto-x-edit-tf-card-connect-wifi)

- [Guide to Connecting Your Magneto X to Ethernet](/en/magneto/magneto-x/magneto-x-connect-ethernet)

- [How to Replacing the WiFi Antenna on Magneto X for Enhanced Signal Quality](/en/magneto/magneto-x/change-wifi-antenna)

### [¶](#extruder-issue) 🚩Extruder issue

- [Load and Unload Filament](/en/magneto/magneto-x/magneto-x-load-unload-filament)

- [Extruder Operation Guide](/en/magneto/magneto-x/magneto-x-extruder-operation-guide)

- [How to fix extrusion issues](/en/magneto/magneto-x/fixing-extrusion-issues)

- [How to clear a filament jam](/en/magneto/magneto-x/magneto-x-nozzle-clogging)

### [¶](#print-troubleshooting) 🚩Print troubleshooting

-
 [Guide to Adjusting the Z_offset Value for Magneto X](/en/magneto/magneto-x/guide-to-adjust-z-offset-value)

-
 [Extruder and VFA](/en/magneto/magneto-x/printing-troubleshooting)

### [¶](#others) 🚩Others

- [Tips for Bounding Box Error in OrcaSlicer When Importing and Slicing Large Models](/en/magneto/magneto-x/orcaslicer-volume-height-exceeds)

- [M112 Troubleshooting](/en/magneto/magneto-x/fix-m112-error)

## [¶](#h-14-maintenance-upkeep) 👨‍🔧1.4 Maintenance & Upkeep

### [¶](#common-operations) 👨‍🔧Common Operations

- [How to print](/en/magneto/magneto-x/print-with-magneto-x)

- [Guide to export 3mf file](/en/magneto/magneto-x/export-3mf)

- [How to edit Magneto X's config file](/en/magneto/magneto-x/edit-config-file)

- [Load and Unload Filament](/en/magneto/magneto-x/magneto-x-load-unload-filament)

- [Extruder Operation Guide](/en/magneto/magneto-x/magneto-x-extruder-operation-guide)

- [How to Replace Hotend](/en/magneto/magneto-x/replace-meltzone)

- [Disassemble the Extruder](https://drive.google.com/file/d/1RDAWSSaZ11vgu9SzUROEA_5Bm7R6LnwD/view?usp=sharing)

- [Linear Guide Maintenance](/en/magneto/magneto-x/linear-guide-maintenance)

### [¶](#replacement-parts) 👨‍🔧Replacement Parts

- [Guide to Replacing X Axis Gantry](https://drive.google.com/file/d/1VGRommVibSIBN163rm6N5U9GwCDTwPxt/view?usp=sharing)

- [Guide to Replacing Y Axis Gantry](/en/magneto/magneto-x/how-to-replace-y-axis)

- [Guide to Replacing Y Axis Mover](/en/magneto/magneto-x/replace-y-axis-mover)

- [Guide to Replacing the X-Axis Cable](/en/magneto/magneto-x/guide-to-replace-x-wires)

- [Guide to Replacing Linux Hub PCB](/en/magneto/magneto-x/replace-linux-hub-pcb)

- [Guide to Replacing Loadcell](https://drive.google.com/file/d/1bPTocGxilvOkrGhZhm0ZWEM5SjYlZOzO/view?usp=sharing)

- [Guide to Replacing Hotend](/en/magneto/magneto-x/replace-meltzone)

- [Guide to Replacing Nozzle](/en/magneto/magneto-x/guide-to-replace-nozzle)

- [Guide to Replacing Toolhead PCB](/en/magneto/magneto-x/guide-to-replace-toolhead-pcb)

### [¶](#software-setting) 👨‍🔧Software Setting

- [How to set timezone](/en/magneto/magneto-x/mainsail-os-timezone-setting)

- [How to use timelapse](/en/magneto/magneto-x/guide-to-timelapse)

- [How to monitor real-time data of loadcell](/en/magneto/magneto-x/loadcell-data-monitoring)

- [How to Activating Adaptive Meshing on Magneto X (KAMP)](/en/magneto/magneto-x/how-to-enable-adaptive-meshing-feature)

- [How to Set CanBs UUID](/en/magneto/magneto-x/set-canbus-uuid)

- [How to set MCU UUID](/en/magneto/magneto-x/set-mcu-uuid)

### [¶](#calibrate) 👨‍🔧Calibrate

- [How to Calibrate Magneto X Linear Motor](/en/magneto/magneto-x/linear-motor-calibration-guide)

- [How to adjust Y axis endoder position](/en/magneto/magneto-x/manual-adjust-y-motor-encoder)

- [Guide to Adjusting the Z_offset Value for Magneto X](/en/magneto/magneto-x/guide-to-adjust-z-offset-value)

- [How to Corrected the abnormal z_offset value](/en/magneto/magneto-x/z-offset-troubleshooting)

- [How to Calibrate Magneto X for Printing specific filament](/en/magneto/magneto-x/calibrate-specific-filament)

- [How to print with Magneto X](/en/magneto/magneto-x/print-with-magneto-x)

- [LinearMorotHost User Guide](/en/magneto/magneto-x/linearmotorhost-user-guide)

- [Linear Motor Software Auto Calibrate](/en/magneto/magneto-x/linearmotor-Identification)

- [LinearMorotHost Parameter Descriptions](/en/magneto/magneto-x/parameters-introduce)

# [¶](#h-2comprehensive-guides) 2.Comprehensive Guides

## [¶](#h-21-features) 📚2.1 Features

- [Magneto X features and specification](/en/magneto/magneto-x/feature-and-specification)

## [¶](#h-22-hardware-overview) 📚2.2 Hardware Overview

- [Overview of the Magneto X Electronic Hardware System](/en/magneto/magneto-x/magneto-x-electronic-system)

- [Lancer Toolhead](/en/magneto/magneto-x/lancer-extruder-toolhead)

- [Lancer Toolhead PCB](/en/magneto/magneto-x/lancer-toolhead-pcb)

## [¶](#h-23-magneto-x-cadstep-resource) 📚2.3 Magneto X CAD/STEP Resource

- [Magneto X CAD/STEP Resource Center](/en/magneto/magneto-x/magneto-x-design-files)

## [¶](#h-24-software-and-firmware) 📚2.4 Software and Firmware

- [Klipper Firmware](/en/magneto/magneto-x/klipper-firmware)

- [Guide to Update Magneto X All MCU Firmware](/en/magneto/magneto-x/magneto-linux-mcu-firmware)

- [Guide to update Magneto X System Online](/en/magneto/magneto-x/update-magneto-x-online)

- [How to update loadcell's firmware](/en/magneto/magneto-x/loadcell-update-firmware)

- [Orca Slicer](/en/magneto/magneto-x/orcaslicer-wiki)

## [¶](#h-25-printing-material-guide) 📚2.5 Printing Material Guide

- [How to Calibrate Magneto X for Printing special filament](/en/magneto/magneto-x/calibrate-specific-filament)

## [¶](#h-26-accessories-and-add-ones) 📚2.6 Accessories and Add-Ones

- [Enclosure](/en/magneto/magneto-x/enclosure-setup-guide)

- [Jetstream Install](/en/magneto/magneto-x/install-jetstream)

- [Jestream Orca Slicer Setting](/en/magneto/magneto-x/jeststream-orcaslicer-setting)

- [Peopoly Nozzle Wipe Felt User Guide](/en/magneto/magneto-x/nozzle-wiper)

- [Printable Accessories](/en/magneto/magneto-x/magneto-x-design-files)
