---
source: https://wiki.peopoly.net/en/magneto/magneto-x/z-offset-troubleshooting
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/z-offset-troubleshooting
> Content may be outdated or wrong; prefer community docs when they disagree.

How to Corrected the abnormal Z-axis z_offset value | Peopoly Wiki - - - - - - - -

# [¶](#how-to-corrected-the-abnormal-z-axis-z_offset-value) How to Corrected the abnormal Z-axis z_offset value

 Troubleshooting Guide: Resolving First Layer Adhesion Issues and Nozzle Scraping on the PEI Sheet

 If you're encountering problems with the first layer not sticking or the nozzle frequently scraping the PEI sheet, please follow the steps outlined in this document to inspect and modify your printer.cfg file.

### [¶](#h-1-identifying-the-issue) 1. Identifying the Issue

 First, access the Mainsail control interface for your Magneto X through your web browser. Locate the printer.cfg file as shown in the image below:

 Next, open the printer.cfg file and check if there is a # symbol before the z_offset parameter. If the symbol is present, it indicates that the value has been overridden, which we will explain further in the following steps.

### [¶](#h-2-resolving-the-issue) 2. Resolving the Issue

 To resolve this, start by removing the # symbol before the z_offset parameter, as shown in the image below:

 After removing the symbol, scroll to the end of the printer.cfg file, where you should see content similar to what is highlighted in the red box below:

 This is where the z_offset value is being overridden. You will need to manually delete this value. After deletion, the file should look like the image below:

 Once you've completed the above steps, click the "SAVE & RESTART" button in the top right corner.

### [¶](#h-3-restart-the-printer-and-verify-printercfg) 3. Restart the Printer and Verify printer.cfg

 After powering off and restarting your printer, check the printer.cfg file to ensure that the changes you made have taken effect.

### [¶](#h-4-understanding-the-root-cause) 4. Understanding the Root Cause

 The issue described above is caused by the use of the Z Calibration tool in KlipperScreen.

 We strongly recommend avoiding the use of this tool for leveling, as it can lead to inconsistencies with the z_offset value.
