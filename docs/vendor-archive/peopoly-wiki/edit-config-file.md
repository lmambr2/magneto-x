---
source: https://wiki.peopoly.net/en/magneto/magneto-x/edit-config-file
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/edit-config-file
> Content may be outdated or wrong; prefer community docs when they disagree.

How to edit config file | Peopoly Wiki - - - - - - - -

# [¶](#how-to-edit-the-config-file-in-magneto-x) How to edit the config file in Magneto X

 This document mainly introduces how to modify the config file to adjust some printing configurations.

 Klipper's configuration files all end with the .cfg extension.

For Magneto X, you only need to pay attention to these three files: printer.cfg , magneto_toolhead.cfg , macros.cfg .

# [¶](#edit-cofig-file) Edit Cofig File

 First, ensure that your Magneto X is connected to Wifi. For instructions on how to connect to Wifi, please refer to this document: [Connecting Magneto X to Wifi ](/en/magneto/magneto-x/how-to-connect-wifi)

 After connecting to Wifi, obtain the IP address of Magneto X.

You could find the IP address on the following interface of Magneto X:

 Please open your PC browser, directly enter the obtained IP in the last step to access the mainsail control interface.

 Click on Machine, then switch to the configuration file list. Find the cfg file you want to edit, double-click to enter the editing interface.

Then, you can start modifying the parameters within.

 After editing, click SAVE&RESTART in the top right corner to save the changes and restart the Klipper firmware. After the Klipper restarts, the parameters will take effect.

# [¶](#use-the-text-search-and-replace-feature) Use the text search and replace feature

 After entering the editing page, use the shortcut key Ctrl+F on the keyboard, and the text search tool will pop up in the lower left corner of the web page.
