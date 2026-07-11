---
source: https://wiki.peopoly.net/en/magneto/magneto-x/loadcell-data-monitoring
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/loadcell-data-monitoring
> Content may be outdated or wrong; prefer community docs when they disagree.

Loadcell Data Monitoring | Peopoly Wiki - - - - - - - -

# [¶](#how-to-analyze-loadcell-data) How to analyze loadcell data

 This document is used to guide how to use the MagnetoSuperTool under Windows systems to monitor loadcell data changes.

## [¶](#h-1-prepare) 1. Prepare

 Download the necessary tools, and drivers from specified Google Drive links：

 •	Loadcell data analyzer (Windows):

[https://drive.google.com/file/d/1eRz45MiWh0N8hKp48JBwt5rhxk_XaPnP/view?usp=sharing](https://drive.google.com/file/d/1eRz45MiWh0N8hKp48JBwt5rhxk_XaPnP/view?usp=sharing)

 •	Windows CH340 driver for loadcell sensor

[https://drive.google.com/file/d/1ugbnCXYBs2T3aSLttxoFAsL4RUzEKYEY/view?usp=sharing](https://drive.google.com/file/d/1ugbnCXYBs2T3aSLttxoFAsL4RUzEKYEY/view?usp=sharing)

 •	CH340 data cable

 You can purchase it here:

[https://www.amazon.com/Yuly-Transfer-Adapter-Download-Converter/dp/B0CS9JJRQ5](https://www.amazon.com/Yuly-Transfer-Adapter-Download-Converter/dp/B0CS9JJRQ5)

### [¶](#install-ch340-driver) Install CH340 Driver

 After downloading the CH340 driver, double-click

 And you will reach to this step:

 Please finish the install.

## [¶](#h-2-remove-the-casing-of-the-printer-toolhead) 2. Remove the casing of the printer toolhead

 Power off and then unplug the printer from the power outlet.

Use the included pink allen wrench to unscrew the two screws on both sides of the printer toolhead housing.

## [¶](#h-3-ch340-data-cable-wiring) 3. CH340 data cable wiring

 First make sure the printer is off. And your pc has a USB port that is close enough (use the data cable to measure) to the printer’s toolhead. A laptop is recommended and make sure you place it in a secure spot that is not on top of the Magneto X magnetic rail.

 The below is a picture showing the serial port for loadcell with pin definition:

 The CH340 cable has 2 ends, one side is USB and the other side is serial:

 Do not plug the USB port of the CH340 data cable into your PC at the moment.

 Notice the color patterns on the CH340 cable’s serial side.

 Connect CH340 data cable’s serial side in the following color order to the serial port. The red is connecting to 5V.

## [¶](#h-4-get-ch340-port) 4. Get CH340 Port

 DO NOT POWER UP Printer

Plug the CH340 data cable USB side into your PC’s available USB port.

Right-click My Computer (or Computer) and choose Manage .

 Choose Device Manager in the window that appears. Click Port . Check the serial port of USB-SERIAL CH340.

The information COM3 included in the parentheses is the serial port.

## [¶](#h-5-install-loadcell-data-monitoring-software) 5. Install Loadcell data monitoring software

 Find the Loadcell data tool zip file: MagnetoSuperTool-v1.0.2-loadcell-exe.zip

This is a portable Windows program so no install is needed. You would need to place it in an easy to access folder.

 Open the Loadcell data monitoring software by clicking on

MagnetoSuperTool-loadcell.exe

## [¶](#h-6-monitoring-loadcell-data) 6. Monitoring Loadcell data

 Setting up the com port number. Please make sure the data cable is plugged in the PC’s USB port.

Find out the com number of the CH340 driver in earlier step.

 The click the refresh (#1 in the below graph) and then check port number (#2) to see if it is correct. If not, click on the port number and you use the drop downbox to select the CH340 port number for loadcell sensor

 You can then click the play button (#3) to receive data stream

 Now tap on the tip of the nozzle (without printer powering on the printer) like this

 And see if there are data coming into the graph

 The data stream will look like this.
