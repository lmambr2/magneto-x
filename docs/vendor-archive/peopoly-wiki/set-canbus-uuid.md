---
source: https://wiki.peopoly.net/en/magneto/magneto-x/set-canbus-uuid
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/set-canbus-uuid
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Setting Toolhead CANBUS uuid | Peopoly Wiki - - - - - - - -

# [¶](#guide-to-setting-toolhead-canbus-uuid) Guide to Setting Toolhead CANBUS uuid

 Generally, after replacing the toolhead pcb, you need to manually set the toolhead's canbus uuid again. If you do not set it, an error message "mcu 'MAG_TOOL': Unable to connect" will appear.

 This document guides how to set the canbus uuid

## [¶](#set-canbus-uuid) Set CANBUS uuid

 In this step, you must first configure the network for the printer and obtain the printer's IP address.

 The following interfaces can be used to assist in completing uuid configuration.Please enter the following http request in a browser on the same LAN as your printer

 Please enter the following http request in the browser to complete the setting of canbus uuid.

 http://xxx.xxx.xxx.xx:8880/set-can-uuid

 If the setting is successful, you will see the "{'suc': "set canbus uuid successful"}" string returned.

 If the setting is unsuccessful, a string starting with "error" will be returned. The error will be followed by the specific error content.

 After the setting is successful, please motor FIRMWARE RESTART to restart the klipper firmware.

 If you encounter failure to set the canbus uuid, please contact our after-sales support email in time: [support@peopoly.net](mailto:support@peopoly.net)
