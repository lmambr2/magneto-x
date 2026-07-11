---
source: https://wiki.peopoly.net/en/magneto/magneto-x/set-mcu-uuid
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/set-mcu-uuid
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to set MCU uuid | Peopoly Wiki - - - - - - - -

# [¶](#guide-to-set-mcu-uuid) Guide to set MCU uuid

 When replacing the BTT Octopus Pro 1.1 motherboard or updating the firmware of the BTT motherboard, klipper needs to manually set the UUID of the BTT motherboard. This document describes how to set the MCU UUID.

 If it is not set correctly, klipper will display the error message "mcu 'mcu': Unable to connect"

 In this step, you must first configure the network for the printer and obtain the printer's IP address.

 The following interfaces can be used to assist in completing uuid configuration.Please enter the following http request in a browser on the same LAN as your printer

## [¶](#set-mcu-uuid) Set MCU UUID

 This link will return the UUID of the printer's motion motherboard.

Use the following command to check whether the MCU is mounted on the Linux system

 http://xxx.xxx.xxx.xx:8880/get-mcu-uuid

 If successful it returns something like "{"mcu-uuid":" /dev/serial/by-id/usb-Klipper_stm32h723xx_1C003E001951313236343430-if00"}"

 The description is normal.

If "{'error': "No MCU uuid found"}" is returned,it may be that the connection between MCU and linux is not established. You need to check whether the USB connection between the mcu and the pi is normal.

 Next, we need to write the mcu-uuid to the specified file. This operation can be completed through the following http request.

 If the execution is successful, a string starting with "mcu-uuid-success" will be returned. If the execution fails, a string description starting with "error" will be returned.

 http://xxx.xxx.xxx.xx:8880/set-mcu-uuid

 After the setting is successful, please motor FIRMWARE RESTART to restart the klipper firmware.

 If you encounter failure to set the mcu uuid, please contact our after-sales support email in time: [support@peopoly.net](mailto:support@peopoly.net)
