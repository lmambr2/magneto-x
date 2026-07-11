---
source: https://wiki.peopoly.net/en/magneto/magneto-x/get-error-code-in-touchscreen
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/get-error-code-in-touchscreen
> Content may be outdated or wrong; prefer community docs when they disagree.

Guide to Capturing Linear Motor Error Codes | Peopoly Wiki - - - - - - - -

 This document guides you on how to capture motor error codes when errors occur in the motor.

 Note: This document requires your firmware to be updated to v1.1.2. Please refer to this link to check and update your Magneto X firmware version:

[https://wiki.peopoly.net/en/magneto/magneto-x/update-magneto-x-online](/en/magneto/magneto-x/update-magneto-x-online)

## [¶](#h-1-entering-motor-monitoring-mode) 1. Entering Motor Monitoring Mode

 First, go to the homepage, then click on the macro button on the right side and find the LINEAR_MOTOR_CONTROL macro. Click to open it.

 After clicking LINEAR_MOTOR_CONTROL, a new interface will pop up, indicating that you have entered the motor monitoring state.

## [¶](#h-2-reconnect-the-motor-control-board) 2. Reconnect the Motor Control Board

 The previous step started a new motor control program; now, you need to reconnect to the motor's serial port. Follow the steps below to complete the connection and verify if the connection was successful:

- #1 Click 'Update' to get the serial number of the motor control motherboard.

- #2 Click 'Connect' to connect to the motor control motherboard.

- #3 Click 'Get Version' to see if a version number is displayed on the right side.

## [¶](#h-3-monitor-the-motor-and-obtain-error-codes) 3. Monitor the Motor and Obtain Error Codes

 After the motor monitoring software is activated via the touchscreen, you need to use a browser to access and control your printer.

 Switch your macros.cfg to the macro linked below：

[https://github.com/mypeopoly/magnetox-os-update/blob/dev/config/macros.cfg](https://github.com/mypeopoly/magnetox-os-update/blob/dev/config/macros.cfg)

 The TEST_X_MOVE and TEST_Y_MOVE macros are added here.

 Usage gcode command:

 TEST_X_MOVE SPEED=800 ITERATIONS=500

The X-axis can be run 500 times at a speed of 800mm/s.

 If an error code occurs, it will be displayed on the right side of the interface, as shown in the figure:

The codes 0x32 and 0x30 are the motor's error codes.

## [¶](#h-4-common-error-codes) 4. Common error codes

 The following are some frequently occurring error codes and their corresponding handling methods.

After obtaining the error code, please contact [support@peopoly.net](mailto:support@peopoly.net) first.

In order to solve your problem more efficiently, please feedback all the problems in this template to us:

 error code
 reason
 how to solve

 0x33,0x31
 There is poor contact or disconnection in the power lines U, V, and W of the motor.
 Check whether the motor power cable is properly connected

 0x32,0x30
 The power supply voltage of the driver is insufficient and below the minimum value of the hardware voltage input.
 enable motor again

 0xFF,0x07
 Hardware overcurrent caused an error in the DRV nFault pin.
 Check whether the power output line of the motor is short-circuited between phases, or short-circuited to the ground

 0x84,0x00
 The protection is activated when the maximum velocity limit switch is turned on.
 reduce speed

 0x86,0x11
 position control error exceeds the tracking error window
 Check whether cable connections are correct 2.Ensure that the motor power is appropriate
