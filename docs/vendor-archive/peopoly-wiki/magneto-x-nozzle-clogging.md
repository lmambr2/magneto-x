---
source: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-nozzle-clogging
archived: 2026-07-11
vendor: Peopoly wiki
license_note: Vendor documentation archived for preservation; not authored by magneto-x project
---

> **Archive copy** of Peopoly wiki page. Original: https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-nozzle-clogging
> Content may be outdated or wrong; prefer community docs when they disagree.

Nozzle Clogging | Peopoly Wiki - - - - - - - -

# [¶](#h-1-summary-of-problem-analysis-and-solution-tips) 1. Summary of problem analysis and solution tips

## [¶](#h-1-reasons-why-the-nozzle-is-blocked) 1. Reasons why the nozzle is blocked

 The nozzle cannot discharge material normally, which is generally caused by the following two situations:

- Material is stuck on the extruder gear

- Material is stuck in the heating pipe

 Before performing plugging treatment, please prepare the following tools:

## [¶](#h-2-processing-flow) 2. Processing flow

 graph TB
 A(move down bed 100mm) --> B[nozzle 230]
 B[nozzle heating to 230] --> C{click Unload}
 C{click Unload} -- can unloaded --> d[Remove Teflon pipe]
 C{click Unload} -- can not unload --> e[disassemble the extruder]
 d[remove teflon pipe] --> f[clean with needle]
 e[disassemble the extruder] --> g{extruder gear jammed?}
 g{extruder gear jammed?} -- yes -->h[clear jam]
 h[clear jam] --> i[reinstall the extruder]
 g{extruder gear jammed?} -- no -->f[clean with needle]
 f[clean with needle] --> k[reinstall the extruder]
 k[reinstall the extruder] --> l[finish]
 i[reinstall the extruder] --> l[finish]

# [¶](#h-2-specific-steps) 2. Specific steps

 Here are the specific operation methods of the above processing process. Please note that do not follow the order below, but follow the order of the operation process in the previous chapter.

## [¶](#move-bed-down-100mm) move bed down 100mm

 Lowers the heated bed platform so there is more room for maneuvering

## [¶](#click-unload) click "Unload"

 Each time you click "Load" or "Unload", the extruder will extrude/retract 20mm

 Heat the nozzle to 230 degrees. If you are using ABS or other high temperature materials, please heat the nozzle to 270 degrees directly.

 Tips :

 In order to unload materials more smoothly, you can click "Load" after the nozzle is heated to let some filaments on the head heat and melt, and then click "Unload" continuously to pull out the filaments.

## [¶](#remove-telfon-pipe) remove telfon pipe

## [¶](#clean-with-needle) clean with needle

 Please note that the operations here are performed with the nozzle heated. Please be careful of burns.

 If you are able to successfully eject material, follow the steps below to clear the nozzle with a needle.

 If you are unable to return the material and have dismantled the extruder, use a needle to clean it as shown in the figure below

## [¶](#disassemble-the-extruder) disassemble the extruder

- When performing the following operations, please disconnect the printer power in advance

- If the nozzle was heated in the previous steps, be sure to wait for the nozzle to cool before performing the action.

## [¶](#extruder-gear-jammed) extruder gear jammed?
