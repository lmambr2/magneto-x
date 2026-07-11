---
source: https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-adjust-z-offset-value
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-adjust-z-offset-value
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Adjusting the Z_offset Value for Magneto X | Peopoly Wiki - - - - - - - -

# [¶](#guide-to-adjusting-the-z_offset-value-for-magneto-x) Guide to Adjusting the Z_offset Value for Magneto X

 This document provides guidance on adjusting the z_offset value of Magneto X.

 Each Magneto X unit undergoes manual calibration and full-coverage printing tests before leaving the factory. Initially, you may not need to adjust the z_offset to achieve a decent first layer.

 However, slight deformations in the PEI surface due to shipping or usage over time may necessitate adjustments to the z_offset value.

## [¶](#when-to-adjust-the-z_offset-value) When to Adjust the Z_offset Value

 The following diagram illustrates different outcomes based on the nozzle's distance from the PEI plate:

## [¶](#how-to-adjust-the-z_offset-value) How to Adjust the Z_offset Value

 It is advised not to adjust the z_offset value in the following manner:

Instead, adjustments should be made by modifying the z_offset under the [probe] section in the printer.cfg file.

## [¶](#z_offset-value-considerations) Z_offset Value Considerations

 Before adjusting the z_offset value, it is essential to understand:

 Assuming a z_offset value of 0 means the nozzle just touches the hotbed, a value of -0.2 means the nozzle is 0.2mm above the hotbed, and a value of 0.2 indicates the nozzle is below the hotbed by 0.2mm, potentially causing the first layer to be too compressed.

 Based on the outcomes depicted in the diagram, adjust the z_offset value accordingly.

 Note that it is recommended to limit adjustments to no more than 0.1 at a time, especially when making the offset closer to the hotbed, to avoid damaging the surface of the PEI plate.
