---
source: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-must-read-before-first-print
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-must-read-before-first-print
> Content may be outdated or wrong; prefer community docs when they disagree.

Must Read before First Print | Peopoly Wiki - - - - - - - -

# [¶](#must-read-before-first-print) Must read before first print

 This wiki provides essential recommendations for optimizing the use of the Magneto X, aiming to significantly improve your printing stability.

## [¶](#testing-material-settings) Testing Material Settings

 Due to the unique design of the Magneto X Lancer extruder, predicting the behavior of your preferred materials in terms of temperature and flow rate can be challenging. Unless you're using Peopoly's PLA-CF or PETG-CF, we advise conducting material tests in the following sequence:

- Run a Temperature Test : Start with temperature test in Orcaslicer's calibration

- Max Volumentric Speed: Once you've established the right temperature, proceed with flow rate testing to determine the best settings.

 Set Max volumetic speed here:

- Adjust Printing Speed: Based on the results from your flow rate tests, adjust your printing speed. Consider your layer height and nozzle size for optimal results.

 This wiki provides specific details on how to complete [the above three steps](/en/magneto/magneto-x/calibrate-specific-filament)

## [¶](#apply-a-thin-coat-of-glue-stick-for-pei) Apply a thin coat of glue stick for PEI

 Before printing with the Magneto X, please applying a thin coat of glue stick to ensure that the first layer sticks to the PEI platform.

## [¶](#meltzone-and-nozzle-recommendations) Meltzone and Nozzle Recommendations

 We suggest beginning with a medium-length meltzone and a 0.4mm nozzle. This approach helps you familiarize yourself with the Magneto X and its Lancer extruders.

## [¶](#layer-height-guidelines) Layer Height Guidelines

- With a 0.4mm nozzle , start with a 0.2mm layer height.

- When using a 0.6mm nozzle, it's advisable to switch to a 0.3mm layer height for better results.

## [¶](#firmware-update-caution) Firmware Update Caution

 Please refrain from using the auto-update feature in Klipper for Magneto X at this time. Magneto X is running a custom version of 0.11 Klipper that is not yet merged with the main branch and trying to auto-update to 0.12 can lead to printing problems. We will notify you when auto-updates are safe. Until then, please manually flash the mirror or update configurations provided by us.

## [¶](#hardware-modification-caution) Hardware Modification Caution

 Before you consider disassembling or maintaining the X and Y-axis linear motors, contact us to prevent any potential issues with printing accuracy and motor functionality. Your cooperation is crucial in maintaining the integrity and performance of your Magneto X printer.
