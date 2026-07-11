---
source: https://wiki.peopoly.net/en/magneto/magneto-x/magnetox2024q2-upgrade
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/magnetox2024q2-upgrade
> Content may be outdated or wrong; prefer community docs when they disagree.

Installation Guide for MagnetoX2024Q2 Upgrade Kit | Peopoly Wiki - - - - - - - -

# [¶](#guide-to-updating-magnetox2024q2-package-to-the-magneto-x) Guide to Updating MagnetoX2024Q2 Package to the Magneto X

 This article guides you through updating the runout sensor, loadcell, and adding magnetic attachment functionality to the side fans of the Magneto X. If you wish to watch each step in detail, please view this video:

[https://youtu.be/EWkqhx4U6Ow](https://youtu.be/EWkqhx4U6Ow)

# [¶](#h-1-preparation) 1. Preparation

- Confirm you have the following replacement kit:

- Prepare the glue.

- Download the magnetic fan mounting component STL file and print it using a functional 3D printer:

[Magnetic Fan Mount STL](https://drive.google.com/file/d/1FwK7crb4LATDjlG-aUSSXo57lWddxsR-/view?usp=sharing)

# [¶](#h-2-replacement-process) 2. Replacement Process

## [¶](#h-1-disassemble-the-parts-to-be-updated) 1. Disassemble the Parts to Be Updated

### [¶](#h-11-remove-the-toolhead-cover) 1.1 Remove the Toolhead Cover

 There are two screws on either side of the toolhead cover. Remove these screws to take off the cover.

### [¶](#h-12-disconnect-the-cables) 1.2 Disconnect the Cables

 Disconnect all the connectors on the toolhead PCB except those in the red boxed area.

 Take a photo of the connections with your phone to avoid confusion later.

### [¶](#h-13-remove-the-extruder) 1.3 Remove the Extruder

 Loosen the two screws shown in the image below and remove the extruder from the machine.

After extruder uninstalled:

### [¶](#h-14-remove-the-hotend-fan) 1.4 Remove the Hotend Fan

 Remove the two screws shown in the image below and take off the hotend fan.

### [¶](#h-15-remove-the-part-fan) 1.5 Remove the Part Fan

 Loosen the two screws shown in the image below to remove the part fan.

### [¶](#h-16-remove-the-part-fan-ducts) 1.6 Remove the Part Fan Ducts

 Remove the two fan ducts as shown in the image below.

### [¶](#h-17-remove-the-hotend) 1.7 Remove the Hotend

 Loosen the three screws indicated by the arrows in the image below to remove the hotend.

### [¶](#h-18-remove-the-loadcell-mounting-frame) 1.8 Remove the Loadcell Mounting Frame

 Remove the four screws from the bottom of the loadcell to take off the mounting frame.

The removed frame should look like the image below.

## [¶](#h-2-pre-assemble-components) 2. Pre-assemble Components

 Prepare the previously printed parts.

### [¶](#h-21-install-the-nuts) 2.1 Install the Nuts

 Use pliers to install the nuts onto the fan duct as shown below.

### [¶](#h-22-attach-the-magnetic-plates) 2.2 Attach the Magnetic Plates

 Glue the magnetic plates to the fan duct as shown in the image below.

 Wipe off any excess glue with a cloth.

### [¶](#h-23-install-the-fan-magnetic-shields) 2.3 Install the Fan Magnetic Shields

 This step involves installing a shield to isolate the rotor magnets of the fan from the circular magnets. Place the shield inside the duct as shown below.

### [¶](#h-24-install-the-fan-mounting-screws) 2.4 Install the Fan Mounting Screws

 Tighten the two screws to secure the fan to the fan duct as shown below.

### [¶](#h-25-remove-the-old-runout-sensor) 2.5 Remove the Old Runout Sensor

 Use a cross socket wrench to hold the nut and an Allen wrench to remove the screws on the old runout sensor as shown below.

### [¶](#h-26-install-the-new-metal-runout-sensor) 2.6 Install the New Metal Runout Sensor

 Install the new runout sensor in the same position as the old one using the same screw holes as shown below.

## [¶](#h-3-install-the-components-onto-magneto-x) 3. Install the Components onto Magneto X

### [¶](#h-31-install-the-loadcell-mounting-frame) 3.1 Install the Loadcell Mounting Frame

 First, secure the loadcell frame with four screws as shown in the image below.

### [¶](#h-32-install-the-hotend) 3.2 Install the Hotend

 Secure the hotend with three screws. Ensure the wires are positioned as shown in the image below for easier cable management later .

### [¶](#h-33-install-the-magnetic-fans) 3.3 Install the Magnetic Fans

 Ensure the glue on the fans is dry before installation. Attach the two part fans and fan ducts magnetically to the sides of the hotend as shown below.

### [¶](#h-34-install-the-hotend-fan) 3.4 Install the Hotend Fan

 Install the two screws at the bottom of the hotend fan as shown below.

### [¶](#h-35-install-the-extruder) 3.5 Install the Extruder

 Reinstall the extruder with the new runout sensor back into its original position.

### [¶](#h-36-reconnect-the-cables) 3.6 Reconnect the Cables

 Reconnect the cables according to the photos you took earlier and organize them neatly with zip ties.

Finally, reinstall the original cover, completing the toolhead upgrade.
