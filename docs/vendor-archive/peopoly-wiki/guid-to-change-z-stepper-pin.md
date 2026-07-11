---
source: https://wiki.peopoly.net/en/magneto/magneto-x/guid-to-change-z-stepper-pin
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/guid-to-change-z-stepper-pin
> Content may be outdated or wrong; prefer community docs when they disagree.

Guidelines for Replacing Z-Axis Driver Pins and Troubleshooting Errors in Klipper | Peopoly Wiki - - - - - - - -

 This document is intended to guide the replacement of Z-axis driver pins to determine whether errors in the Z-axis are due to issues with the TMC2209 or the BTT MCU.

 Corresponding Klipper error:

 Unable to read tmc uart ‘stepper_z’ register IFCNT

 Note: The above error message may also appear as stepper_z1, stepper_z2, stepper_z3. Please replace them as appropriate based on the actual situation. Below, we use stepper_z as an example to explain.

## [¶](#h-1-changing-the-position-of-the-tmc2209-driver) 1. Changing the position of the TMC2209 driver

 First, disconnect the printer from power.

As shown in the diagram below, reposition the TMC2209:

## [¶](#h-2-modifying-the-printercfg-configuration) 2. Modifying the printer.cfg configuration

 If your error involves stepper_z1, you should find [stepper_z1] and modify the corresponding pins.

 After making changes, save and restart Klipper, then move the Z-axis to see if the error persists.
