---
source: https://wiki.peopoly.net/en/magneto/magneto-x/disable-runout-sensor
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/disable-runout-sensor
> Content may be outdated or wrong; prefer community docs when they disagree.

Magneto X Disable Runout Sensor | Peopoly Wiki - - - - - - - -

# [¶](#disable-filament-runout-sensor) Disable Filament Runout Sensor

 We have identified a bug in Klipper that may lead to instability with the filament runout sensor. Github notice at the end.

 Some of our users have reported experiencing random pauses during printing. As a result, we recommend temporarily disabling the filament runout sensor feature to ensure your normal testing is not affected. Once we have identified a more suitable fix, we will inform you so you can re-enable this feature.

## [¶](#locate-the-magneto_toolheadcfg-file) Locate the magneto_toolhead.cfg file

## [¶](#comment-out-the-filament_switch_sensor-runout_sensor-sectionfrom-line-136-to-line-139) Comment out the [filament_switch_sensor Runout_Sensor] section.（From line 136 to line 139)

 In front of each line, please add a # sign to disable configuration information.

 Before comment out:

 After comment out:

 ）

 Github notice by Klipper

[https://github.com/Klipper3d/klipper/commit/92fe8f15b82d7c7ccb7f8ac6552259adeac471fb](https://github.com/Klipper3d/klipper/commit/92fe8f15b82d7c7ccb7f8ac6552259adeac471fb)
