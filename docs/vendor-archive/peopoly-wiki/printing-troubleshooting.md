---
source: https://wiki.peopoly.net/en/magneto/magneto-x/printing-troubleshooting
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/printing-troubleshooting
> Content may be outdated or wrong; prefer community docs when they disagree.

Troubleshooting Common 3D Printing Issues and Solutions | Peopoly Wiki - - - - - - - -

 This document guides you through potential issues you might encounter during the printing process and their corresponding solutions.

## [¶](#h-1-common-printing-issues) 1. Common Printing Issues

- Poor first layer printing

- Under-extrusion

- Over-extrusion

- Printing VFA

## [¶](#h-2-common-problem-solutions) 2. Common Problem Solutions

### [¶](#h-21-poor-first-layer-printing) 2.1 Poor First Layer Printing

-
 Please check if the extruder lever is placed in the correct position.

-
 Check the bedmesh results to see the extent of the deformation.

-
 Try adjusting the z_offset value, refer to this link:

[https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-adjust-z-offset-value](/en/magneto/magneto-x/guide-to-adjust-z-offset-value)

-
 Check if solid glue is applied.

### [¶](#h-22-under-extrusion) 2.2 Under-extrusion

 Please refer to this link to understand the basic structure affecting the extruder:

[https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-extruder-operation-guide](/en/magneto/magneto-x/magneto-x-extruder-operation-guide)

-
 Please check if the extruder lever is placed in the correct position.

-
 Check if the extruder screws are loose.

 Please refer this link to uninstall the extruder first:

[https://drive.google.com/file/d/1RDAWSSaZ11vgu9SzUROEA_5Bm7R6LnwD/view?usp=sharing](https://drive.google.com/file/d/1RDAWSSaZ11vgu9SzUROEA_5Bm7R6LnwD/view?usp=sharing)

 Check whether the screws pointed by the arrows below are loose

- Check if the extruder tension spring is adjusted properly.

 As shown in the image below, tighten the screws until they are flush with the outer surface.

### [¶](#h-23-over-extrusion) 2.3 Over-extrusion

- Check if the printing temperature is appropriate; excessively high printing temperatures can cause severe over-extrusion.

- Reduce the Flow Ratio parameter in the slicing settings and perform flow calibration.

### [¶](#h-24-severe-vfa) 2.4 Severe VFA

-
 Increase the speed appropriately; VFA will decrease at speeds above 150mm/s.

ps: The actual printing speed you set cannot be lower than 150mm/s

-
 Calibrate the motor, refer to this document:

[https://wiki.peopoly.net/en/magneto/magneto-x/linear-motor-calibration-guide](/en/magneto/magneto-x/linear-motor-calibration-guide)

-
 Adjust the encoder position (Y axis), refer to this document:

[https://wiki.peopoly.net/en/magneto/magneto-x/manual-adjust-y-motor-encoder](/en/magneto/magneto-x/manual-adjust-y-motor-encoder)
