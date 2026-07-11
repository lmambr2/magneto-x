---
source: https://wiki.peopoly.net/en/magneto/magneto-x/how-to-enable-adaptive-meshing-feature
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/how-to-enable-adaptive-meshing-feature
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Activating Adaptive Meshing on Magneto X | Peopoly Wiki - - - - - - - -

 This document is intended to guide the activation of the adaptive meshing feature on Magneto X.

 Adaptive meshing is a function within the KAMP library. Once activated, before each printing, Magneto X will perform a bed mesh within the range of the model's area size.

 To enable the adaptive meshing feature, there are two main steps:

- Edit the KAMP_Settings.cfg file

- Edit the macros.cfg file

## [¶](#h-1edit-the-kamp_settingscfg-file) 1.	Edit the KAMP_Settings.cfg file

 First, in the browser, go to the mainsail console page and find the KAMP_Settings.cfg file:

 Remove the # at the beginning of the third line in the KAMP_Settings.cfg file to activate the adaptive meshing feature.

 Before enabling:

 After enabling:

 After making changes, remember to click the "SAVE & RESTART" button in the top right corner to save and restart Klipper to apply the changes.

## [¶](#h-2-edit-the-macroscfg-file) 2. Edit the macros.cfg file

 In the mainsail console page, find the macros.cfg file:

 Open the macros.cfg file and locate line 57:

 Remove the "#" in front of BED_MESH_CALIBRATE, as shown in the following figure:

 After making changes, remember to click the "SAVE & RESTART" button in the top right corner to save and restart Klipper to apply the changes.
