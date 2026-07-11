---
source: https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-timelapse
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-timelapse
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Using the Timelapse Feature of Magneto X | Peopoly Wiki - - - - - - - -

## [¶](#h-1-preparation) 1. Preparation

 Ensure that the system version of Magneto X is equal to or higher than v1.1.3. If not, please refer to this link to upgrade the system:

[https://wiki.peopoly.net/en/magneto/magneto-x/update-magneto-x-online](/en/magneto/magneto-x/update-magneto-x-online)

 After upgrade the system, please edit printer.cfg, add "[include timelapse.cfg]":

 Restart klipper, and you can see the TIMELAPSE menu on the left sidebar of mainsail:

 Refer to the settings shown in the figure below and set up timelapse:

## [¶](#h-2-configure-your-slicing-software) 2. Configure Your Slicing Software:

 The main step is to add TIMELAPSE_TAKE_FRAME in the G-code for layer changes.

- Orca Slicer

Printer Settings --> Machine G-code --> Before Layer change G-code --> TIMELAPSE_TAKE_FRAME

- Prusa Slicer

Printer Settings -> Custom G-code -> Before layer change G-code -> TIMELAPSE_TAKE_FRAME

- Ultimaker Cura

Extensions -> Post Processing -> Modify G-Code ->

Add a script -> Insert at layer change -> G-code to insert = TIMELAPSE_TAKE_FRAME

## [¶](#h-3-after-completing-the-setup-you-will-see-the-saved-video-file-in-the-timelapse-section-on-the-right-side-after-printing-is-finished) 3. After completing the setup, you will see the saved video file in the timelapse section on the right side after printing is finished.
