---
source: https://wiki.peopoly.net/en/magneto/magneto-x/linearmotorhost-user-guide
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/linearmotorhost-user-guide
> Content may be outdated or wrong; prefer community docs when they disagree.

LinearMotorHost User Guide | Peopoly Wiki - - - - - - - -

 LinearMotorHost User Guide

 This document serves as a guide for controlling and debugging motors using LinearMotorHost.

 After applying parameter modifications, you must reference Chapter 5 in the following wiki to ensure the driver operates in Pulse Mode . Failure to confirm this setting will result in driver malfunction.

[https://wiki.peopoly.net/en/magneto/magneto-x/linearmotor-Identification](/en/magneto/magneto-x/linearmotor-Identification)

# [¶](#h-1-software-overview) 1. Software Overview

 LinearMotorHost is a debugging tool designed for closed-loop motors, specifically for in-depth parameter setting and visual debugging of MagnetoX motors. With this tool, you can optimize the motor's motion state.

 This document will cover the following topics:

- Connecting linear motors to LinearMotorHost

- Steps for motor parameter auto-tuning

- Motor test run tutorial

- Common motor parameter adjustments

# [¶](#h-2-connecting-the-linear-motor-to-linearmotorhost) 2. Connecting the Linear Motor to LinearMotorHost

## [¶](#h-21-preparations) 2.1 Preparations

-
 Download the LinearMotorHost PC software:

[Download Link](https://drive.google.com/file/d/16lOrFJKOqzSmSH-tNzmM7O9o5jv_3oQf/view?usp=sharing)

-
 USB Driver (CH340 Driver):

[Download Link](https://drive.google.com/file/d/1Jv_MqjmU_zj7GehB_cSgdGBUzO-xeHrL/view?usp=sharing)

-
 Prepare a mini USB data cable.

[Purchase Link](https://www.amazon.com/Amazon-Basics-Charging-Transfer-Gold-Plated/dp/B00NH13S44)

## [¶](#h-22-wiring-and-software-connection) 2.2 Wiring and Software Connection

### [¶](#h-1-install-ch340-driver) 1. Install CH340 Driver

 After downloading the CH340 driver, double-click to install.

### [¶](#h-2-open-the-magnetox-control-box) 2. Open the MagnetoX control box

### [¶](#h-3-connect-the-linear-motor-driver-to-the-pc) 3. Connect the linear motor driver to the PC

 First, disconnect the printer's power supply, then connect the mini USB to the linear motor driver's mini USB port, and the other end to your PC.

 Once the USB cable is connected, manually move the toolhead to the center of the PEI plate as shown in the image below:

### [¶](#h-4-connect-linearmotorhost-to-the-linear-motor-driver) 4. Connect LinearMotorHost to the Linear Motor Driver

 At this point, power on the printer.

 Open LinearMotorHost and go to System Settings > Connect Settings . On the right side, select the appropriate driver model and communication method as shown below.

 Double-click the port number to complete the connection.

Once connected, click the real-time icon. At this point, if you lightly move the corresponding motor by hand, you can see the curve change on the display.

# [¶](#h-3-steps-for-motor-parameter-auto-tuning) 3. Steps for Motor Parameter Auto-Tuning

 Motor parameter auto-tuning allows you to reset parameters to adapt to changes such as wiring, inductance, or load variations. After tuning, the motor's motion state will better match the current device status.

## [¶](#h-31-start-auto-tuning) 3.1 Start Auto-Tuning

 Click Device Control , and you will see the following interface:

Scroll down to find the Identification button, and click it.

Once initiated, the motor will automatically identify parameters such as load and electrical properties.

 You can reference the sound of the process in this video:

[Watch Video](https://youtu.be/IUIKN4x36HQ)

 After one-click identification is complete, click Save Parameters . Then, also click the save button on the left side.

## [¶](#h-32-adjust-filter-parameters) 3.2 Adjust Filter Parameters

 After automatic identification, a low-order filter is usually enabled. You need to disable this filter as shown in the figure below.

Go to Device Control > Filter Settings , click Disable , which will disable the motor to allow changes to the left-side options.

 Then set all Command Current Filter to No filter .

 Next, set Low Frequency Vibration Filter to No filter as well.

## [¶](#h-33-save-auto-tuning-results) 3.3 Save Auto-Tuning Results

# [¶](#h-4-motor-test-run) 4. Motor Test Run

 Motor test runs are crucial to observe waveform patterns while adjusting specific parameters. Each adjustment should be followed by a test run to evaluate the motor's performance.

## [¶](#h-41-set-reciprocating-motion-mode) 4.1 Set Reciprocating Motion Mode

 While the software is connected to the motor driver, go to Device Control > Trajectory > Current Mode > Position Mode .

 After setting to Position Mode, scroll down, disable the motor, then enable Reciprocating Motion Switch (note that the motor must be disabled to switch modes).

 Once the Reciprocating Motion Switch is enabled, the interface will look like this:

## [¶](#h-42-manually-define-reciprocating-motion-positions) 4.2 Manually Define Reciprocating Motion Positions

 In the previous step, we disabled the motor. Now, manually move the motor's mover to one end.

 Once moved, you will see the position value change in the software. This value indicates the motor's position:

 Enter this Position Actual Value into the Target Position input box.

 If the status box turns yellow when entering data, it means the data hasn't taken effect. Press the "Enter" key to confirm, and the input box border will turn blue.

 Next, move the mover to the other end.

 Enter the Position Actual Value into the Target Position 2 input box.

 After setting the positions, adjust the movement speed and acceleration as shown below. Enter the desired test values. When unloaded, keep the acceleration below 30,000.

In position #2, set the pause time after reaching the target. A 100ms pause is recommended.

## [¶](#h-43-start-reciprocating-motion) 4.3 Start Reciprocating Motion

 After completing the previous steps, scroll down to see the buttons below. First, click Enable , then click Send to start the reciprocating motion.

## [¶](#h-44-modify-parameters-and-observe-effects) 4.4 Modify Parameters and Observe Effects

 After starting the reciprocating motion, observe the waveform display to monitor motor behavior. You can adjust the speed and acceleration in real-time as shown below.

# [¶](#h-5-common-motor-parameter-adjustments) 5. Common Motor Parameter Adjustments

## [¶](#h-51-motor-current-and-speed-limits) 5.1 Motor Current and Speed Limits

 Go to the position shown below to adjust the motor's maximum current limit:

 In the position below, modify the motor's maximum speed limit.

 After modification, click Deliver Configuration , then click Save Parameters on the left side.

 Sometimes, the auto-detected inertia value may not be optimal. You can adjust the inertia value here for better performance:

## [¶](#h-52-motor-control-parameter-adjustments) 5.2 Motor Control Parameter Adjustments

 The motor includes three main controllers: Current Controller , Position Controller , and Speed Controller . You can find them in the following location:

 For a detailed description of each parameter's meaning and impact, please refer to this wiki: [https://wiki.peopoly.net/en/magneto/magneto-x/parameters-introduce](/en/magneto/magneto-x/parameters-introduce)

# [¶](#h-6-pulsedirection-control-settings) 6. Pulse/Direction Control Settings

 Firmware like Klipper and Marlin use pulse/direction signals for motion control. We need to configure the linear motor to support this signal type.

 First, go to Device Control > Trajectory Planner > Current Mode > Plus Control Position as shown below:

 After completing this step, configure the following parameters:

- Select Direction Pulse Control and set Pulse Input Resolution .

 Pulse Input Resolution affects the distance moved per pulse. Setting it to 20,000 means one pulse equals 1 µm of movement.

If you want one pulse to move the motor 4 µm, set Pulse Input Resolution to 5,000.

 The Smoothing Factor affects motion smoothness. Higher values result in smoother motion around sharp corners, but may produce curved edges. Lower values may cause noise, but this won't affect motion precision.

 Once configured, click Save Setting , then click Save Parameters on the left side.

# [¶](#h-7-set-automatic-identification-on-power-on) 7. Set automatic identification on power on

 After completing all settings, refer to steps 1 to 6 below to set the motor to auto-initialize after power-on.
