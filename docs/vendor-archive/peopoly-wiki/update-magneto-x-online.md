---
source: https://wiki.peopoly.net/en/magneto/magneto-x/update-magneto-x-online
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/update-magneto-x-online
> Content may be outdated or wrong; prefer community docs when they disagree.

How to Update the Magneto X System Online | Peopoly Wiki - - - - - - - -

# [¶](#how-to-update-the-magneto-x-system-online) How to Update the Magneto X System Online

 This document outlines the process of updating system changes on Magneto X through online macros.

 Before performing the following steps, please confirm the version of your current system. After Magneto X is connected to the network, enter in the browser(Please fill in your device IP address according to the actual situation): [http://xxx.xxx.xx.xx:8880/get_os_version](http://xxx.xxx.xx.xx:8880/get_os_version)

 If your version is equal to or greater than v1.1.0 , you can update using the methods in this document. If the version is lower than v1.1.0 or does not return the version, please refer to this wiki to update the system:

[https://wiki.peopoly.net/en/magneto/magneto-x/update-tf-image](/en/magneto/magneto-x/update-tf-image)

## [¶](#h-1-preparation) 1. Preparation

 Before starting the update, ensure that your Magneto X has normal internet access.

## [¶](#h-2-updating-macroscfg) 2. Updating macros.cfg

 Open the Magneto X mainsail control interface in a browser and locate the macros.cfg file to open it:

 Open the following link in your browser:

[raw.githubusercontent.com/mypeopoly/magnetox-os-update/main/config/macros.cfg](http://raw.githubusercontent.com/mypeopoly/magnetox-os-update/main/config/macros.cfg)

 Then select all content (Ctrl+A) and copy (Ctrl+C).

 Next, open the macros.cfg file, select all (Ctrl+A), and replace the contents of the macros.cfg file with the previously copied content (Ctrl+V).

 After replacing, click SAVE & RESTART to make the changes take effect.

## [¶](#h-3-execute-the-update-system-macro) 3. Execute the Update System Macro

 Go to the mainsail homepage and enter the following in the console command input field: _UPDATE_OS

Then press Enter to start the update.

 An update log will be output during the update process.

 After the update is complete, the system will automatically perform a reboot. Once the reboot is finished, the update is completed.

## [¶](#h-4-check-if-the-update-is-complete) 4. Check if the Update is Complete:

 On the touchscreen page, click Configuration -> Network.

On this page, you can see a new light bulb button in the upper right corner.

 Click this button to enter the Magneto X back-end networking interface:

 You can get the current system version by entering .

 The latest version is v1.1.3
