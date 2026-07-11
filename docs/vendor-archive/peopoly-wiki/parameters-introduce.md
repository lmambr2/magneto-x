---
source: https://wiki.peopoly.net/en/magneto/magneto-x/parameters-introduce
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/parameters-introduce
> Content may be outdated or wrong; prefer community docs when they disagree.

Linear Motor Parameters | Peopoly Wiki - - - - - - - -

 This document introduces commonly used parameters when tuning motor parameters and explains how these parameters impact performance.

# [¶](#h-1-overview-of-common-parameters) 1. Overview of Common Parameters

 The main parameters discussed are:

- Electrical Gain

- Inertia Value

- Moving Average Filter

- Speed Observer Bandwidth

- Mechanical Gain

# [¶](#h-2-parameter-descriptions) 2. Parameter Descriptions

## [¶](#h-21-electrical-gain) 2.1 Electrical Gain

 Meaning : The higher the gain, the faster the current response, with greater overshoot and more current noise.

The default electrical gain value is 100%, and the typical adjustment range is 10% to 200%. A higher gain increases the bandwidth of the current loop, improving current tracking performance. However, if set too high, it may lead to electromagnetic noise.

## [¶](#h-22-inertia-value-setting) 2.2 Inertia Value Setting

Inertia values are generally obtained through one-click identification.

 If the inertia is set much smaller than the actual value, the system may experience low-frequency oscillation, loss of position control, and errors such as excessive follow-up deviation or speed runaway.

 If the inertia is set too large, typically 7-8 times greater than the actual value, it can cause high-frequency vibration and noise in the motor, leading to overheating in the motor and driver, and significant current fluctuation.

## [¶](#h-23-moving-average-filter) 2.3 Moving Average Filter

 Smoothing Factor Range : 0.2–51.2 ms

 Parameter Explanation :

- The smoothing factor represents the time delay (in milliseconds) for the commanded position to reach the target after the acceleration is smoothed from point to point.

- A larger smoothing factor results in smoother acceleration and reduced settling time, but it increases the overall planning time.

## [¶](#h-24-speed-observer-bandwidth) 2.4 Speed Observer Bandwidth

The higher the bandwidth, the faster the speed control response and the better the real-time speed measurement. However, excessive bandwidth can lead to high-frequency noise, increased speed fluctuation, and position oscillation. The typical adjustment range is 100–1200 rad/s.

 Below is a comparison of the impact of different speed observer bandwidths on system rigidity under the same external load torque disturbance.

- Higher bandwidth improves the system's ability to resist disturbances and increases rigidity, but setting it too high may cause high-frequency vibration.

- Lower bandwidth corresponds to a lower cutoff frequency for speed measurement filtering, which increases the filter coefficient, resulting in slower speed control response and lower rigidity.

## [¶](#h-25-mechanical-gain) 2.5 Mechanical Gain

The default mechanical gain is 100%, and we generally adjust it within the range of 1% to 900%. Higher mechanical gain improves control rigidity and dynamic position tracking performance, reducing settling time. However, excessively high gain may lead to high-frequency vibration and noise.
