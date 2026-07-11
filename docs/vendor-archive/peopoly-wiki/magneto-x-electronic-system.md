---
source: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-electronic-system
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-electronic-system
> Content may be outdated or wrong; prefer community docs when they disagree.

Overview of the Magneto X Electronic Hardware System | Peopoly Wiki - - - - - - - -

 The electronic control system of Magneto X consists of more than 20 different PCBs.

 Through this document, you can better understand the composition of the circuit system of Magneto X, which will facilitate your customization.

## [¶](#h-1-hardware-system-overview) 1. Hardware System Overview

 The Magneto X system consists of five main components from a hardware perspective:

- Power Supply System

- Linear Motor Control System

- Linear Motor Driver Control PCB

- X/Y Linear Motor Driver

- Linear Motor

- Rotor

- Stator

- Magnetic Scale

- Magnetic Scale Encoder

- Linux PCB

- Orange Pi Zero2

- Linux Hub PCB

- BTT MCU PCB

- Toolhead PCB

 A hardware system diagram is shown below:

## [¶](#h-2-hardware-submodule-introduction) 2. Hardware Submodule Introduction

### [¶](#h-21-power-supply-system) 2.1 Power Supply System

 The power supply system is primarily composed of two switching power supplies: one is 24V, 350W, and the other is 48V, 600W. The 48V power supply is mainly for the linear motor.

### [¶](#h-22-magxy-system) 2.2 MagXY System

 The MagXY system includes three parts: the linear motor driver control board, the linear motor driver, and the linear motor itself.

- Linear Motor Driver Control PCB

 The linear motor driver control board is developed based on the ESP32. It plays a crucial role in error handling, initialization, calibration, and adjustment functions essential for optimal motor performance. Plans are in place to enhance its capabilities for advanced data-sharing features.

- Linear Motor Driver Module

This module converts pulse signals into three-phase AC signals to control the linear motor, ensuring precise motor movement by varying the current in the motor coils.

- Linear Motor

The linear motor comprises four main parts: the rotor, stator, magnetic scale, and magnetic scale encoder.

 The rotor integrates coils that, when energized, generate thrust in different directions.

 The magnetic scale provides positional feedback to the driver and control board, enabling closed-loop position control.

### [¶](#h-23-linux-pcb-introduction) 2.3 Linux PCB Introduction

 For detailed hardware information about the Orange Pi Zero2, please refer to [this link](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-Zero-2.html).

The Linux PCB system consists of an Orange Pi Zero2 and a Linux Hub expansion board, which includes a USB-to-CAN bus module and a USB hub chip. The Linux Hub PCB also features a CPU cooling fan controlled via the GPIO of the BTT motherboard.

### [¶](#h-24-btt-octopus-pro-11stm32h732-version) 2.4 BTT Octopus Pro 1.1(STM32H732 Version)

 For detailed information about the MCU mainboard, please refer to [this GitHub link](https://github.com/bigtreetech/BIGTREETECH-OCTOPUS-Pro).

 This mainboard connects:

- Four Z-axis stepper motors

- Z-axis limit/probe pins

- X/Y motor pulse lines

- X/Y limit switches

- Heated bed PWM signal

- Heated bed temperature sensor

- CPU cooling fan

- Jetstream fan

 The BTT MCU is connected to the Linux PCB via a Type-C data cable.

### [¶](#h-25-toolhead-pcb) 2.5 Toolhead PCB

The Toolhead is connected to the Linux PCB via a CAN bus cable, which includes a 24V power supply for the nozzle heater and the extruder.

 The Toolhead PCB controls the following hardware:

- Extruder motor

- Nozzle heating element

- Nozzle thermistor

- Two side fans

- One hotend fan

- Load cell signal

- Filament runout detection

- Load/unload buttons

 The CAN bus communication simplifies the wiring between the toolhead and the Linux PCB. For more detailed information about the Toolhead PCB, please refer to [this wiki](/en/magneto/magneto-x/lancer-toolhead-pcb).
