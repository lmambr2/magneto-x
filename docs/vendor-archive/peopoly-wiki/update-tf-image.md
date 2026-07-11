---
source: https://wiki.peopoly.net/en/magneto/magneto-x/update-tf-image
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/update-tf-image
> Content may be outdated or wrong; prefer community docs when they disagree.

Magneto X Update TF Card OS image | Peopoly Wiki - - - - - - - -

# [¶](#firmware-version2024-4-8-v111) Firmware Version:2024-4-8-v1.1.1

- Improve WiFi connectivity with a new Wi-Fi configuration tool that makes finding wireless access points easier in Klipper

- Improve unloading filament macro to minimize the chance of clogging due to PLA filament jaming.

- Improve bed leveling accuracy by chaning the default temperature of the heated bed to 70C during leveling.

- Ability to update OVA

# [¶](#preparation) Preparation

- TF card reader

- Download [win32diskimager](https://win32diskimager.org/)

- Download [SD Card Formatter](https://www.sdcard.org/downloads/formatter/)

- PC computer

- Download [Klipper Firmware](https://github.com/mypeopoly/magneto-x-os-mirror/releases/download/magneto-x-mainsailOS-2024-4-8-v1.1.1/magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz)

# [¶](#prepare-magneto-x) Prepare Magneto X

 Make sure the printer is power off.

 Remove the screws under the build plate as shown in the picture below to reveal the electronic:

 After removing the screws, take out the cover and you can see the TF card.

Press the TF card and take out the TF card from the printer mainboard

# [¶](#flash-firmware-to-tf-card) Flash Firmware to TF card

 Use the SD Formater software to format the TF card taken out in the previous step.

 Use the win32 disk tool to write the image to the TF card.

 The image file you downloaded ends with .xz and please decompressed into a folder first. You will get a file ending with .img. The file ending with .img is the file we need to burn to the TF card.

- Load the mirror file downloaded above

- Select the drive where the TF card is located

- Click Write

 After updating TF, re-insert the TF card into the printer’s Linux motherboard.

# [¶](#setting-the-mcu-uuid-and-canbus-uuid) Setting the MCU-UUID and CANBUS-UUID

 In this step, you must first configure the network for the printer and obtain the printer's IP address.

 The following interfaces can be used to assist in completing uuid configuration.Please enter the following http request in a browser on the same LAN as your printer

### [¶](#set-mcu-uuid) Set MCU UUID

 This link will return the UUID of the printer's motion motherboard.

Use the following command to check whether the MCU is mounted on the Linux system

 http://xxx.xxx.xxx.xx:8880/get-mcu-uuid

 If successful it returns something like "{"mcu-uuid":" /dev/serial/by-id/usb-Klipper_stm32h723xx_1C003E001951313236343430-if00"}"

 The description is normal.

If "{'error': "No MCU uuid found"}" is returned,it may be that the connection between MCU and linux is not established. You need to check whether the USB connection between the mcu and the pi is normal.

 Next, we need to write the mcu-uuid to the specified file. This operation can be completed through the following http request.

 If the execution is successful, a string starting with "mcu-uuid-success" will be returned. If the execution fails, a string description starting with "error" will be returned.

 http://xxx.xxx.xxx.xx:8880/set-mcu-uuid

 If you encounter failure to set the mcu uuid, please contact our after-sales support email in time: [support@peopoly.net](mailto:support@peopoly.net)

### [¶](#set-canbus-uuid) Set CANBUS uuid

 Please enter the following http request in the browser to complete the setting of canbus uuid.

 http://xxx.xxx.xxx.xx:8880/set-can-uuid

 If the setting is successful, you will see the "{'suc': "set canbus uuid successful"}" string returned.

 If the setting is unsuccessful, a string starting with "error" will be returned. The error will be followed by the specific error content.

 If you encounter failure to set the canbus uuid, please contact our after-sales support email in time: [support@peopoly.net](mailto:support@peopoly.net)
