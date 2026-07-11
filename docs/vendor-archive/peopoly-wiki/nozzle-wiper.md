---
source: https://wiki.peopoly.net/en/magneto/magneto-x/nozzle-wiper
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/nozzle-wiper
> Content may be outdated or wrong; prefer community docs when they disagree.

Peopoly Nozzle Wipe Felt User Guide | Peopoly Wiki - - - - - - - -

 This document explains how to use the Wippe suite, using Magneto X as an example.

## [¶](#h-1-concept-for-nozzle-wiping) 1. Concept for Nozzle Wiping

 First, to clean the nozzle before printing, a small portion of the print area needs to be sacrificed. As shown in the diagram below:

We need to attach the nozzle wiper felt within the designated nozzle wiper region.

 On the Magneto X, you will need to manually adjust the X-axis travel. Modify the maximum travel of the X-axis to 312 in the printer.cfg file:

## [¶](#h-2-attaching-the-nozzle-wiper-felt) 2. Attaching the Nozzle Wiper Felt

 Use the provided 3M adhesive to fix the felt on your PEI sheet, as shown in the diagram below:

## [¶](#h-3-determining-the-felt-position) 3. Determining the Felt Position

 Using Klipper’s Move tool, move the X/Y axis until the nozzle aligns with the side of the felt. Note down the X and Y axis values at this position.

## [¶](#h-4-setting-up-the-nozzle-wipe-macro) 4. Setting Up the Nozzle Wipe Macro

 The macro for nozzle wiping on the Magneto X is as follows.

Copy the two position coordinates of the felt you obtained in the previous step to x_1 , y_1 , x_2 , and y_2 :

 [gcode_macro MAG_WIPE_NOZZLE]
gcode:
 {% set iterations = params.ITERATIONS|default(10)|int %}
 {% set accel = 12000 %}
 {% set x_1 = 308 %}
 {% set y_1 = 15 %}

 {% set x_2 = 308 %}
 {% set y_2 = 305 %}
 {% set EXTRUDER_TEMP = params.EXTRUDER|default(200)|float %}
 SET_VELOCITY_LIMIT ACCEL={accel} ACCEL_TO_DECEL={accel / 2}

 M109 S{ EXTRUDER_TEMP }
 G28 Z
 G1 Z20
 G1 X310 Y5
 G1 Z15
 G92 E0
 G1 E30 F200
 G92 E0
 G1 E20 F200
 G92 E0
 G1 E-10 F200
 M106 S100
 M118 Wait for the material to flow out automatically
 G4 P3000
 M107
 G4 P120000
 M118 Wait for the material to flow out automatically
 G1 Z3.1
 {% for i in range(iterations) %}
 G0 X{ x_1 } Y{ y_1 } F8000
 G0 X{ x_1 } Y{ y_1+20 } F8000
 {% endfor %}
 G1 Z20
 G1 X{x_1} Y5
 G1 Z3.1
 {% for i in range(iterations) %}
 G0 X{ x_1 } Y{ y_1 } F8000
 G0 X{ x_1 } Y{ y_1+20 } F8000
 {% endfor %}
 G1 Z20
 G1 X{x_2} Y300
 G1 Z4.5
 {% for i in range(iterations) %}
 G0 X{ x_2 } Y{ y_2 } F8000
 G0 X{ x_2 } Y{ y_2+20 } F8000
 {% endfor %}
 G1 Z20
 G1 X{x_2} Y330
 G1 Z0.2
 {% for i in range(iterations) %}
 G0 X{ x_2 } Y{ y_2+30 } F8000
 G0 X{ x_2 } Y{ y_2+50 } F8000
 {% endfor %}
 G1 Z20
 G1 X5 Y5 F8000

 After completing the setup, you can place the MAG_WIPE_NOZZLE macro in any location where you need nozzle wiping, such as under the PRINT_START or PRINT_END macro definitions.

 Here we suggest you to put it in the PRINT_START macro (macros.cfg):
