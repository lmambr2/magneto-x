---
source: https://wiki.peopoly.net/en/magneto/magneto-x/jeststream-orcaslicer-setting
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/jeststream-orcaslicer-setting
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Enable Jetstream in Slicing Software | Peopoly Wiki - - - - - - - -

 This document provides instructions on how to set up your slicing software to enable Jetstream.

Please ensure that your Jetstream is successfully installed and you can control it using the fan control function on the touchscreen.

 This document provides instructions on how to set up your slicing software to enable Jetstream.

Please ensure that your Jetstream is successfully installed and you can control it using the fan control function on the touchscreen.

## [¶](#h-1-enable-auxiliary-part-cooling-fan-in-orca-slicer) 1. Enable Auxiliary Part Cooling Fan in Orca Slicer

 Go to Printer settings -> Basic information -> Accessory, and enable the Auxiliary part cooling fan.

## [¶](#h-2-set-fan-speed-in-filament-settings) 2. Set Fan Speed in Filament Settings

 Configure the fan speed settings in the Filament settings section. Set the speed according to your actual needs

## [¶](#h-3-manual-control-of-jetstream-fan-via-gcode-commands) 3. Manual Control of Jetstream Fan via Gcode Commands

 To turn on the Jetstream fan: M106 P2 S255

To turn off the Jetstream fan: M107 P2
