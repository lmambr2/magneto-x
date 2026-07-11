---
source: https://wiki.peopoly.net/en/magneto/magneto-x/loadcell-update-firmware
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/loadcell-update-firmware
> Content may be outdated or wrong; prefer community docs when they disagree.

How to update loadcell's firmware and analyze loadcell data | Peopoly Wiki - - - - - - - -

# [¶](#how-to-update-loadcells-firmware-and-analyze-loadcell-data) How to update loadcell's firmware and analyze loadcell data

 This instruction helps user to update loadcell firmware and shows how to analyze loadcell data under Windows system.

## [¶](#h-1-prepare) 1. Prepare

 Download the necessary firmware, tools, and drivers from specified Google Drive links：

 •	Download Loadcell firmware:

[https://drive.google.com/file/d/19BcvezolxWfI0vbG0V6bgINePu3O5TLY/view?usp=sharing](https://drive.google.com/file/d/19BcvezolxWfI0vbG0V6bgINePu3O5TLY/view?usp=sharing)

 •	Loadcell loadcell firmware tool (Windows):

STC-ISP-V6.92A.exe:

[https://drive.google.com/file/d/1O6i7CEs35yXGqg3kEyNwhrBTIQ8bq5jp/view?usp=sharing](https://drive.google.com/file/d/1O6i7CEs35yXGqg3kEyNwhrBTIQ8bq5jp/view?usp=sharing)

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

## [¶](#h-4-prepare-loadcell-sensor-firmware-too) 4. Prepare Loadcell sensor firmware too

 Please copy the firmware too:

stc-isp-v6.92A.exe

 To your hardware in an easily accessible folder.

It runs on Windows and does not require installation.

## [¶](#h-5-configure-firmware-burning-tool) 5. Configure Firmware burning tool

### [¶](#h-51-get-ch340-port) 5.1 Get CH340 Port

 DO NOT POWER UP Printer

Plug the CH340 data cable USB side into your PC’s available USB port.

Right-click My Computer (or Computer) and choose Manage .

 Choose Device Manager in the window that appears. Click Port . Check the serial port of USB-SERIAL CH340.

The information COM3 included in the parentheses is the serial port.

### [¶](#h-52-open-the-loadcell-firmware-toolstc-isp-v692aexe) 5.2 Open the Loadcell firmware tool：stc-isp-v6.92A.exe

 And you see this Windows

It is all in Chinese so we will first switch to the English interface:

Find the English button on the upper left:

The software interface is now English.

 Please make sure that (by referring to the below diagram)

•	1 the MCU type is set to STC8H8K64U (it should be by default)

•	2 set the scan port to your CH340 port number by using the dropbox. And in this case (com3)

•	3 Click on H/W OPtion tab (#3 in below graph)

•	4 Go to Input IRC frequency to 30 Mhz (see below graph for reference)

 Next graph has more steps:

- Find the Self-Define Download tab in Figure (see #1)

- Click the Self-Define Download tab (see #2)

- Make the options in this to match red box marked in the graph below as #3

 Enabling USB-CDC/Com

Baudrate set to 115200

Partity is number

Enable RTS and DTR

Enable Using default STC

Send Self-deine commands

## [¶](#h-6-update-firmware) 6. Update firmware

 Click Open Code File (#1)

 Select the downloaded firmware above, which is magx-loadcell-20240201.hex.

And click open

 After selecting the file, click "Download/Program" (see #2) to start upload the firmware to the loadcell.

 When you see the progress bar as shown below, it means that the loadcell's firmware is being updated:

 If you see the following output, the update is successful.

## [¶](#if-you-do-not-see-the-following-output-please-carefully-check-whether-the-previous-configuration-is-consistent) If you do not see the following output, please carefully check whether the previous configuration is consistent.

 Once the firmware is updated successfully, please close the Loadcell firmware software.

 **After updating the firmware, unplug the data cable from the USB port from the computer. Wait for 5 seconds and plug it right back. **

## [¶](#h-7-install-loadcell-data-monitoring-software) 7. Install Loadcell data monitoring software

 Find the Loadcell data tool zip file: MagnetoSuperTool-v1.0.2-loadcell-exe.zip

This is a portable Windows program so no install is needed. You would need to place it in an easy to access folder.

 Open the Loadcell data monitoring software by clicking on

MagnetoSuperTool-loadcell.exe

 Setting up the com port number. Please make sure the data cable is plugged in the PC’s USB port.

Find out the com number of the CH340 driver in earlier step.

 The click the refresh (#1 in the below graph) and then check port number (#2) to see if it is correct. If not, click on the port number and you use the drop downbox to select the CH340 port number for loadcell sensor

 You can then click the play button (#3) to receive data stream

 Now tap on the tip of the nozzle (without printer powering on the printer) like this

 And see if there are data coming into the graph

 The data stream will look like this.
