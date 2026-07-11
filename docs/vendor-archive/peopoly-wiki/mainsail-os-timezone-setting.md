---
source: https://wiki.peopoly.net/en/magneto/magneto-x/mainsail-os-timezone-setting
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/mainsail-os-timezone-setting
> Content may be outdated or wrong; prefer community docs when they disagree.

Guides to modify the timezone | Peopoly Wiki - - - - - - - -

 This document guides you on how to modify the timezone in Mainsail.

## [¶](#h-1-connect-to-mainsail-using-ssh) 1. Connect to Mainsail using SSH

 If you can already use SSH to log in to Linux, please skip the following steps and log in directly with the account and password.

- Account: pi

- Password: armbian

 First, locate your Raspberry Pi on your local network.

I highly recommend installing Advanced IP Scanner:

[https://www.advanced-ip-scanner.com/](https://www.advanced-ip-scanner.com/)

 Locate the IP address and copy it.

 Open PuTTY and paste the copied IP address from the previous step.

Click on Open.

 You will see this window the first time you connect to the Raspberry Pi from your computer.

Click on Yes.

 Use your login, default is pi .

 Hit Enter.

 Enter the password for the pi account.

Default value is armbian .

 You should see this information after a successful login.

## [¶](#h-2-set-the-timezone) 2. Set the timezone

 In the command line, enter: sudo orangepi-config

Then enter the password: armbian

 You will then enter the following interface:

 Select a time zone based on your area.

 Click OK, then restart the system to complete the setup.
