---
source: https://wiki.peopoly.net/en/magneto/magneto-x/replace-linux-hub-pcb
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/replace-linux-hub-pcb
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide for Replacing the Linux Hub PCB | Peopoly Wiki - - - - - - - -

# [¶](#guide-to-replacing-the-linux-hub-pcb) Guide to Replacing the Linux Hub PCB

 This document provides a step-by-step guide on how to replace the Linux hub PCB.

## [¶](#h-1-remove-the-control-box-cover-plates) 1. Remove the Control Box Cover Plates

 Remove the middle cover plate of the control box:

 After removing the cover plates, take a photo of the control box to remember the positions of all the wires:

## [¶](#h-2disconnect-the-relevant-wires) 2.Disconnect the Relevant Wires

 First, disconnect the USB cables (#2 and #3), HDMI cable (#1), and CAN bus (#4):

 Disconnect the internal wires of the control box, mainly the USB data cables and 24V power cables:

 Gently lift the Orange Pi out:

## [¶](#h-3remove-the-linux-hub-board) 3.Remove the Linux Hub Board

 Loosen the screws at the four positions shown below:

 After loosening the four screws, remove the hub board from the control box.

## [¶](#h-4detach-the-cooling-fan-from-the-hub-board) 4.Detach the Cooling Fan from the Hub Board

 Remove the cooling fan from the old Linux hub board and install it onto the new Linux hub board:

 Use a Phillips socket wrench to hold the fan screws, as shown below:

 Use an Allen wrench to loosen the fan screws on the back of the Linux hub:

 After removing the fan, install it onto the new Linux hub board:

 Once the fan is installed, reassemble the Linux hub board into the control box following the original wiring configuration.

 After replacing the Linux hub, please remove the two previously connected cables!

[https://wiki.peopoly.net/en/magneto/magneto-x/linux-boot-error](/en/magneto/magneto-x/linux-boot-error)
