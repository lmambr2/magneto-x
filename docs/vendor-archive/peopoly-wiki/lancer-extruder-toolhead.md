---
source: https://wiki.peopoly.net/en/magneto/magneto-x/lancer-extruder-toolhead
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/lancer-extruder-toolhead
> Content may be outdated or wrong; prefer community docs when they disagree.

Lancer Toolhead | Peopoly Wiki - - - - - - - -

# [¶](#lancer-toolhead-overview) Lancer Toolhead Overview

 The Lancer Toolhead system is an all-metal, high flow, high torque rate extrusion system for the Magneto X, equipped with load cell and runout sensors. It consolidates many sought-after features into a streamlined design that is easy to maintain and repair. This guide aims to help users understand the details of the toolhead and assist in maintenance and adapting the Peopoly Lancer to other printers.

 Please refer this wiki for designed files: [https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-design-files](/en/magneto/magneto-x/magneto-x-design-files)

# [¶](#comprehensive-features) Comprehensive Features

- total size: 80x60x140mm （mid long meltzone）

- total weight: 354g

## [¶](#toolhead-design) Toolhead Design

- Material : All-metal constructio n (including gears) ensures durability and performance, especially with abrasive carbon-fiber and glass-fiber filaments

- High Flow Rate : Accommodates fast extrusion speeds without compromising quality.

- High Torque Rate : Provides powerful extrusion capabilities.

- Integrated Load Cell disk design to ensure nozzle alignment for sensor accuracy

## [¶](#integrated-sensors) Integrated Sensors

- Load Cell Sensor : Measures direct pressure data from the nozzle, facilitating precise z-offset adjustments and bed leveling.

- Filament Runout Sensor : Automatically detects filament absence, enhancing print reliability.

## [¶](#advantages) Advantages:

- Only need 4 Canbus connection for 24V power and communication, making wiring easier

- Modular design allow easy maintenance

 Front without cooling fan view:

 Side view:

## [¶](#key-components) Key Components

### [¶](#extruder) Extruder

- Stepper Motor: NEMA 17, optimized for high torque.

- Gear Ratio: 7.2:1, designed to increase pushing force.

- Maximum Extrusion Force: 90 Newtons, supports high flow applications.

### [¶](#hotend) Hotend

- Type: Volcano for enhanced heat transfer.

- Heater: Ceramic ring, offering variable power settings (60/100/160 W).

- Maximum Temperature: 300°C, suitable for a wide range of materials.

- Thermistor: NTC 100K, ensures accurate temperature readings.

### [¶](#load-cell-sensor) Load Cell Sensor

### [¶](#runout-sensor-with-filament-load-and-unload-button) Runout Sensor with Filament load and unload button

### [¶](#filament-gear-switch) Filament Gear Switch

### [¶](#toolhead-integrated-pcb) Toolhead Integrated PCB

- Controller: RP2040, robust performance for real-time data handling.

- Connections:

- USB and CAN Bus for communication.

- Dedicated interfaces for hotend and part cooling fans, heaters, and thermistor.

- Type C and CAN Bus ports for connectivity.

- Outputs for stepper motor and Loadcell data.

-

 Learn more about the Toolhead PCB [here](/en/magneto/magneto-x/lancer-toolhead-pcb)

## [¶](#cooling-system) Cooling System

 Hotend Fan (3010 Model):

- Maximum Speed: 8500 RPM.

- Voltage: 24V.

- PWM Control: Not supported.

 Part Cooling Fan (4015 Model):

- Maximum Speed: 13000 RPM.

- Voltage: 24V.

- PWM Control: Supported.

## [¶](#key-mechanical-data) Key Mechanical Data

 The design file is here:

[https://drive.google.com/file/d/108OJ63E4M_ov3F66hXTaR3Fc_-k3CUgw/view?usp=sharing](https://drive.google.com/file/d/108OJ63E4M_ov3F66hXTaR3Fc_-k3CUgw/view?usp=sharing)
