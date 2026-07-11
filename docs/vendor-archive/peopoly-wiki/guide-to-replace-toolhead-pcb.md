---
source: https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-replace-toolhead-pcb
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/guide-to-replace-toolhead-pcb
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Replace Toolhead PCB | Peopoly Wiki - - - - - - - -

# [¶](#h-1-preparation) 1. Preparation

 First, disconnect the printer from the power supply. Never replace any components while the machine is powered on.

 Prepare the following tools as shown in the image below:

# [¶](#h-2-steps) 2. Steps

## [¶](#h-21-remove-the-metal-cover-plate) 2.1 Remove the Metal Cover Plate

 After removing the outer shell of the Toolhead, you will see the metal cover plate as shown in the image below.

Please remove the four screws highlighted in the image:

## [¶](#h-22-disconnect-the-connectors-from-the-toolhead-pcb) 2.2 Disconnect the Connectors from the Toolhead PCB

 After removing the cover, proceed to disconnect all the connectors from the Toolhead PCB. Please note the following:

- If any connector is glued, use a heat gun to soften the glue by blowing it for about 30 seconds before attempting to remove the connector.

- Before disconnecting any wires, take a picture of the wiring with your phone. This will serve as a reference when installing the new Toolhead PCB.

 Be careful not to pull on the wires directly. Instead, grip the connectors to avoid damaging the cables.

## [¶](#h-23-loosen-the-fixing-posts-on-the-toolhead-pcb) 2.3 Loosen the Fixing Posts on the Toolhead PCB

 Using a cross wrench, remove the four brass posts as shown in the image below:

## [¶](#h-24-loosen-the-u-v-w-power-screws-on-the-toolhead-pcb) 2.4 Loosen the U, V, W Power Screws on the Toolhead PCB

 Using a flathead screwdriver, loosen the U, V, W screws on the Toolhead PCB.

After completing the above steps, you can remove the old Toolhead PCB and install the new one.

## [¶](#h-25-reset-canbus-uuid) 2.5 Reset Canbus UUID

 After replacing the toolhead pch, you need to re-set the canbus uuid in klipper. Please refer to this wiki for settings:

[https://wiki.peopoly.net/en/magneto/magneto-x/set-canbus-uuid](/en/magneto/magneto-x/set-canbus-uuid)
