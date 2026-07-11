# Peopoly Magneto X - Klipper Analysis Summary

## What We Know

### Hardware Architecture
The Magneto X has 20+ PCBs across five subsystems:

| Component | Details |
|---|---|
| **Host Board** | Orange Pi Zero 2 (Allwinner H616) + Linux Hub PCB with USB-to-CAN module and 7-port USB hub |
| **Motion Controller** | BTT Octopus Pro v1.1, STM32H723, connected to host via USB Type-C |
| **Toolhead MCU** | RP2040-based CAN bus toolhead PCB (`MAG_TOOL`), UUID-addressed via `canbus_uuid` |
| **Linear Motor Driver** | ESP32-based control board for MagXY magnetic levitation system |
| **Linear Motor Driver Module** | Converts pulse signals to 3-phase AC for coil current control |
| **Load Cell Sensor** | CS1237 ADC → STC8051 MCU → digital signal → RP2040 toolhead (GPIO24) |
| **Power** | 24V/350W (general) + 48V/600W (linear motors) |

### Klipper Config (from mypeopoly/magneto-x-klipper-config)
- **Kinematics**: Cartesian, max velocity 1500mm/s, max accel 15000mm/s²
- **MCU**: `[mcu]` via serial USB (`/dev/serial/by-id/usb-Klipper_stm32h723xx_...`)
- **Toolhead**: `[mcu MAG_TOOL]` via CAN bus (`canbus_uuid: 70e5d37dad1c`)
- **Extruder**: Step/dir on GPIO5/GPIO4, heater on GPIO0, TMC2209 UART driver
- **Load cell**: GPIO24 on toolhead, with GPIO25 reset pin, threshold-based digital triggering
- **Quad gantry leveling** with 4 Z steppers, 8x6 bed mesh
- **ADXL345 accelerometer** on toolhead for input shaping
- **Build volume**: 400x300x300mm

### Upstream Klipper Codebase Support (this repo)
Already present:
- **Load cell system**: `load_cell.py`, `load_cell_probe.py`, `hx71x.py`, `ads1220.py`
- **trigger_analog**: MCU-level analog trigger detection with SOS filtering (`trigger_analog.c/.py`)
- **SOS filter**: Fixed-point digital filtering for load cell noise rejection (`sos_filter.c/.h`)
- **STM32H723**: Full support including ADC, SPI, GPIO, FDCAN (`src/stm32/stm32h7*.c`)
- **CAN bus**: FDCAN driver, serial-over-CAN, UUID discovery (`fdcan.c`, `canbus.c`, `canserial.c`)
- **BTT Octopus Pro v1.1**: Board config exists (`config/generic-bigtreetech-octopus-pro-v1.1.cfg`)
- **Probe infrastructure**: Full probe system with load cell probe integration
- **Bulk sensor framework**: For high-rate sensor data streaming

---

## Peopoly's Klipper Fork - Full Diff Analysis

Cloned from `mypeopoly/Klipper`. The fork is based on an upstream Klipper snapshot
close to V0.11, squashed into a single init commit. All Peopoly-specific changes
are spread across **4 files** (plus 1 community plugin):

### 1. `klippy/extras/magneto_load_cell.py` (NEW FILE - 70 lines)

The **only truly new file**. A simple digital pin controller for load cell reset:

```
class PrinterLoadCellDigitalOut:
    - Configures a digital_out pin (GPIO25 on RP2040 toolhead)
    - Registers 3 GCode commands: LC28 (clear), LL28 (set low), LH28 (set high)
    - clear_load_cell(): pulls pin LOW for ~400ms, then HIGH again
    - Used as a "tare" / reset signal to the STC8051 loadcell MCU
```

**Key insight**: The load cell is NOT an analog sensor in Peopoly's design. The
STC8051 microcontroller handles all ADC reading and thresholding. It outputs a
simple digital high/low to the RP2040's GPIO24. The reset pin (GPIO25) is used
to tare/clear the load cell by toggling it low then high.

### 2. `klippy/extras/homing.py` (MODIFIED - 3 lines)

```diff
- raise self.printer.command_error("Probe triggered prior to movement")
+ #raise self.printer.command_error("Probe triggered prior to movement")
+ self.gcode.respond_info("Probe triggled prior to movement!!")
```

**Purpose**: Converts a fatal "probe already triggered" error into a warning
message. This is a **workaround** for the loadcell sometimes being in a triggered
state when probing begins — a known Magneto X issue.

### 3. `klippy/extras/probe.py` (MODIFIED - ~15 lines)

Changes:
- Adds `import time` (unused leftover)
- Adds `magneto_load_cell` lookup in ProbeEndstopWrapper (commented out —
  the load cell clear was attempted but abandoned)
- Adds `name` field to `get_status()` return dict
- Makes `horizontal_move_z` overridable per-command via `HORIZONTAL_MOVE_Z`
  GCode parameter (useful for QGL/bed mesh with different Z heights)

### 4. `src/stepper.c` (MODIFIED - 2 lines)

```diff
- if (diff < (int32_t)-timer_from_us(1000))
-     shutdown("Stepper too far in past");
+ // if (diff < (int32_t)-timer_from_us(1000))
+ //     shutdown("Stepper too far in past");
```

**Purpose**: Disables the safety shutdown when a stepper step event is more than
1ms behind schedule. This is a **critical workaround** — the linear motors likely
cause timing issues that trigger this shutdown. The move queue overflow errors
reported by users are related: the MCU can't keep up with the commanded step rate.

### 5. `klippy/extras/gcode_shell_command.py` (NEW FILE - community plugin)

Standard community plugin by Eric Callahan (not Peopoly-specific). Allows running
shell commands from GCode.

---

## What This Tells Us

### The Linear Motor Integration is Simpler Than Expected
Peopoly treats the linear motors as **standard steppers**. There is no custom
protocol, no UART/SPI communication with the ESP32, and no encoder feedback loop
in Klipper. The ESP32 driver board:
1. Self-initializes and auto-calibrates on power-up
2. Is switched to "Pulse Mode" (step/dir)
3. From that point, Klipper drives it exactly like a TMC stepper — step/dir pulses

The only evidence of issues is the **commented-out "Stepper too far in past"
shutdown**, which suggests the linear motor driver introduces timing jitter or
latency that a normal stepper doesn't have.

### The Load Cell is a Digital Trigger, Not Analog
The entire load cell "intelligence" lives in the STC8051 firmware:
- CS1237 ADC reads the strain gauge
- STC8051 applies threshold (set via DIP switches, default 200)
- Outputs HIGH/LOW to RP2040 GPIO24
- Klipper sees it as a simple endstop switch

This is fundamentally different from upstream Klipper's load cell approach, which
reads raw ADC values (via HX711/ADS1220) and applies sophisticated SOS filtering
on the MCU for better noise rejection and tap detection.

### Peopoly's Workarounds Reveal the Real Issues
1. **"Stepper too far in past" disabled** → Linear motor timing/latency problem
2. **"Probe triggered prior to movement" downgraded** → Load cell false triggers
3. **Load cell clear attempted in probe.py** → Tare issues between probing moves
4. **Move queue overflow** (user reports) → Step rate exceeds MCU capacity at high speeds

---

## Deep Dive: "Stepper too far in past" & Move Queue Overflow

### The Error Mechanism

The error lives in `stepper_load_next()` (`src/stepper.c:104-108`), which runs when
the MCU finishes one move segment and loads the next from its queue:

```c
// stepper_load_next() - called when current move finishes
uint32_t min_next_time = s->time.waketime;  // time of last step event
s->next_step_time += move_interval;          // scheduled time of first step in new move

if (was_active && timer_is_before(s->next_step_time, min_next_time)) {
    int32_t diff = s->next_step_time - min_next_time;
    if (diff < (int32_t)-timer_from_us(1000))   // more than 1ms behind?
        shutdown("Stepper too far in past");     // SHUTDOWN
    s->time.waketime = min_next_time;            // else: clamp to now
}
```

This fires when:
1. The stepper is actively stepping (finishing one move, loading the next)
2. The first step of the **new** move was supposed to happen >1ms **before** the
   last step of the previous move finished
3. This means the MCU fell behind — it couldn't execute steps fast enough

### Why STM32H7 is Affected

**Critical finding**: STM32H7 does NOT get the edge-optimized stepper path:

```
src/stm32/Kconfig:16:  select HAVE_STEPPER_OPTIMIZED_BOTH_EDGE if !MACH_STM32H7
```

So STM32H723 uses `stepper_event_full()`, which:
- Fires **twice per step** (once for step, once for unstep)
- Reads `timer_read_time()` on every event
- Has more overhead per step than the edge-optimized path

The edge-optimized path (`stepper_event_edge()`) toggles GPIO on each call, meaning
it fires only **once per step** and avoids the timing check entirely. This path
is available on other STM32 families but NOT H7.

### Step Rate Math for Magneto X

Config: `rotation_distance=3.2mm, microsteps=16`

```
Steps per mm = (200 full steps × 16 microsteps) / 3.2mm = 1000 steps/mm

At 1500 mm/s:  1,500,000 steps/sec = 1.5 MHz step rate
At 500 mm/s:     500,000 steps/sec = 500 kHz step rate
At 100 mm/s:     100,000 steps/sec = 100 kHz step rate
```

With `stepper_event_full()` firing twice per step:

```
At 1500 mm/s: 3,000,000 timer events/sec → 173 MCU ticks between events (520MHz)
At 500 mm/s:  1,000,000 timer events/sec → 520 MCU ticks between events
```

**173 ticks between events at max speed is extremely tight**. Each `stepper_event_full()`
call includes a `timer_read_time()`, GPIO toggle, comparison, and conditional branch.
This easily exceeds the available time budget, causing the MCU to fall behind.

### Move Queue Overflow Connection

The "Move queue overflow" (`src/basecmd.c:90`) fires when `move_alloc()` finds the
free list empty. The move pool is allocated at startup (`alloc_chunks(move_item_size, 1024, &move_count)`), requesting up to 1024 entries.

The connection to "stepper too far in past":
1. At high step rates, each move segment covers fewer steps (step compression
   creates segments of similar time duration)
2. More segments are consumed per second → moves are dequeued faster
3. If the host can't refill the queue fast enough → overflow
4. Meanwhile, the MCU is also falling behind on step execution → "too far in past"

Both errors share the root cause: **the step rate is too high for the MCU to handle**.

### Why The Linear Motor Makes It Worse

The linear motor itself isn't the direct cause — the step rate is. But:

1. **rotation_distance=3.2mm is very small** — typical belt-driven printers use
   32-40mm rotation distance, giving 10-12x fewer steps/mm
2. **1500mm/s is extremely fast** — combined with the small rotation_distance,
   this creates an enormous step rate
3. **No step-on-both-edges optimization** on STM32H7 means double the timer events
4. **The ESP32 driver may have minimum pulse width requirements** that increase
   `step_pulse_ticks`, further constraining timing

### Why H7 Is Excluded from Edge Optimization

Investigated via upstream PRs [#6852](https://github.com/Klipper3d/klipper/pull/6852)
and [#6853](https://github.com/Klipper3d/klipper/pull/6853).

**The H7's GPIO registers are absurdly slow to read** — 15+ CPU cycles for
`regs->ODR ^= g.bit`. Kevin O'Connor added a cached BSRR approach
(`stm32h7_gpio.c`) that caches the ODR register in RAM. This made the GPIO
toggle so fast that the `stepper_event_edge()` path would **violate the minimum
pulse width requirement** for Trinamic drivers (the step pin would toggle faster
than the driver can register).

So the edge optimization (`stepper_event_edge()`) was disabled for H7 to prevent
Trinamic pulse width violations. Instead, H7 uses `stepper_event_full()` which
has explicit `step_pulse_ticks` timing.

**However**, PR #6852 added "step on both edges" support to `stepper_event_full()`
itself — when `invert_step=-1` (i.e., `SF_SINGLE_SCHED`), the full path fires
**once per step** instead of twice (step + unstep). This is the modern path for
both-edge stepping on H7, and it respects `step_pulse_ticks`.

**STM32H723 benchmark results**: 7,429K steps/sec (1 stepper), 8,619K steps/sec
(3 steppers) — the **fastest MCU in Klipper's benchmarks**. Raw throughput is not
the issue.

### The Real Problem: Default Pulse Duration + No TMC Driver

The Magneto X linear motor axes (X/Y) go to an ESP32 driver board, not a TMC
driver. This means:

1. **No TMC module** → `setup_default_pulse_duration()` is never called
2. **Default `step_pulse_duration` = 2µs** (`stepper.py:81`)
3. 2µs > 500ns (`MIN_BOTH_EDGE_DURATION`) → **step-on-both-edges is DISABLED**
4. `step_pulse_ticks` = 520MHz × 2µs = **1040 ticks** (minimum time between edges)
5. The stepper uses **double-scheduled mode** (step + unstep = 2 events per step)

At 1500mm/s with 1000 steps/mm:
- 1.5M steps/sec × 2 events = **3M timer events/sec**
- At 520MHz, 3M events/sec = **173 ticks between events**
- But `step_pulse_ticks = 1040` requires minimum 1040 ticks between step and unstep
- This means the **actual minimum interval per step is 2080 ticks** (step + unstep)
- Maximum achievable step rate = 520M / 2080 = **250K steps/sec = 250mm/s**

**This is the smoking gun: with default 2µs pulse duration, the Magneto X maxes
out at ~250mm/s per axis — not the configured 1500mm/s.**

### The Fix

The solution is simple — configure the correct `step_pulse_duration` for the
ESP32 linear motor driver:

**Option A: Set `step_pulse_duration` in printer.cfg (RECOMMENDED)**
```ini
[stepper_x]
step_pulse_duration: 0.000000100  # 100ns — same as TMC drivers
```
If the ESP32 driver can handle 100ns pulses (likely, since it's just edge detection),
this enables step-on-both-edges mode automatically:
- `100ns < 500ns` → both-edges enabled → `SF_SINGLE_SCHED` → 1 event per step
- `step_pulse_ticks` = 520MHz × 100ns = 52 ticks
- Max step rate ≈ 520M / 52 = **10M steps/sec** — more than enough for 1500mm/s

**Option B: If ESP32 needs longer pulses**
If the ESP32 requires >500ns pulse width, set it explicitly:
```ini
[stepper_x]
step_pulse_duration: 0.000001  # 1µs
```
This still gives `step_pulse_ticks = 520`, and even in double-event mode:
- Max step rate = 520M / (520×2) = **500K steps/sec = 500mm/s**
- Enough for many operations but NOT for 1500mm/s

**Option C: If ESP32 driver supports dedge mode directly**
Some drivers interpret both rising AND falling edges as step events. If the ESP32
driver does this, set both `step_pulse_duration: 0.000000100` in config.

### Why Peopoly's "Fix" Was Wrong

Peopoly commented out the "Stepper too far in past" check because the MCU was
falling behind. But the root cause was using a 2µs default pulse duration with
a non-TMC driver — creating an artificially low step rate ceiling of ~250mm/s.
When the printer tried to move at 1500mm/s, the MCU couldn't generate steps fast
enough, fell behind by >1ms, and triggered the shutdown.

The proper fix is to configure the correct pulse duration, not to disable the
safety check.

---

## Updated Status

| Area | Status | Key Finding |
|---|---|---|
| Linear motor ↔ Klipper | **SOLVED** | Standard step/dir pulses, no custom protocol |
| Load cell protocol | **SOLVED** | Digital trigger via STC8051, not analog |
| Stepper timing | **ROOT CAUSE + FIX** | Default 2µs pulse duration limits step rate to ~250mm/s. Fix: set `step_pulse_duration: 0.000000100` in config |
| Move queue overflow | **ROOT CAUSE + FIX** | Same cause — fix pulse duration, step rate ceiling goes from 250K to 10M steps/sec |
| H7 edge optimization | **SOLVED** | Disabled for good reason (Trinamic pulse width), but `stepper_event_full()` supports both-edges via `SF_SINGLE_SCHED` |
| Load cell false triggers | **IDENTIFIED** | Tare/clear sequence unreliable |
| Upstream compatibility | **GAP** | Fork stuck on V0.11, needs port to current |

---

## ESP32 Linear Motor Driver — Pulse Width Analysis

### The Problem

Our initial recommendation of "just set 100ns like TMC drivers" was premature.
The ESP32-based linear motor driver is **not a TMC chip** — its minimum pulse
width depends entirely on how its firmware detects step pulses.

### ESP32 GPIO Input Timing

The ESP32 datasheet does **not formally specify** a minimum GPIO input pulse width.
The achievable minimum depends on the firmware's detection method:

| Detection Method | Min Pulse Width | Max Step Rate | Notes |
|---|---|---|---|
| **GPIO interrupt (ISR)** | ~2-5µs | ~200-500K/s | Typical ISR latency; WiFi can spike to 50µs+ |
| **Polling loop (dedicated core)** | ~120ns | ~3.6M/s | Pins task to one core, disables interrupts |
| **PCNT hardware peripheral** | ~12.5ns | ~40M/s | Hardware counter, no CPU involvement |
| **RMT hardware peripheral** | ~12.5ns | ~40M/s | Hardware, 80MHz APB clock resolution |

**Key risk**: If the ESP32 firmware uses standard GPIO interrupts (the most common
approach), then pulses shorter than ~2µs will be **missed**. Setting 100ns would
cause silent step loss and positional errors — potentially worse than the current
timing shutdown.

### ESP32 vs TMC Driver Comparison

| Driver | Min Pulse Width | Step Both Edges | Source |
|---|---|---|---|
| TMC2209 | 100ns | Yes | Datasheet spec |
| TMC5160 | 100ns | Yes | Datasheet spec |
| A4988 | 1µs | No | Datasheet spec |
| DRV8825 | 1.9µs | No | Datasheet spec |
| ESP32 (ISR) | ~2-5µs | Unknown | Architecture limit |
| ESP32 (PCNT) | ~12.5ns | N/A | Hardware peripheral |

### What We Don't Know

The Peopoly ESP32 firmware is proprietary. We cannot determine from external
analysis whether it uses:
- GPIO interrupts (would need ≥2µs pulses)
- A dedicated polling loop (could handle ~120ns)
- PCNT/RMT hardware peripheral (could handle ~12.5ns)

The LinearMotorHost configuration tool mentions "Pulse Input Resolution" (distance
per pulse) but does **not document minimum pulse width timing**.

### Additional ESP32 Concerns

- **No Schmitt triggers** on ESP32 GPIO inputs — slow rise/fall times can cause
  spurious edge detection and double-triggering
- **Flash cache misses** during ISR execution can delay interrupt handling by
  tens of microseconds
- **RTOS task scheduling** introduces non-deterministic latency

### Revised Recommendations

Given the uncertainty, a **tiered approach** is recommended:

**Tier 1 — Safe (works regardless of ESP32 firmware)**
```ini
[stepper_x]
step_pulse_duration: 0.000005  # 5µs — safe for any detection method
```
- `step_pulse_ticks` = 520MHz × 5µs = 2600 ticks
- Double-event mode: max step rate = 520M / (2600×2) = **100K steps/sec = 100mm/s**
- **Too slow** for Magneto X at full speed, but guaranteed to work
- Useful for initial testing and validation

**Tier 2 — Moderate (likely works, needs testing)**
```ini
[stepper_x]
step_pulse_duration: 0.000002  # 2µs — current Klipper default
```
- This is the existing default behavior, unchanged
- Max step rate = 250K steps/sec = **250mm/s**
- Sufficient for probing, homing, moderate print speeds

**Tier 3 — Aggressive (requires validation)**
```ini
[stepper_x]
step_pulse_duration: 0.000001  # 1µs
```
- `step_pulse_ticks` = 520 ticks, double-event mode
- Max step rate = 520M / (520×2) = **500K steps/sec = 500mm/s**
- Good for most printing, may miss steps if ESP32 uses slow ISR path

**Tier 4 — Optimal (requires ESP32 firmware confirmation)**
```ini
[stepper_x]
step_pulse_duration: 0.000000100  # 100ns — enables both-edges
```
- `100ns < 500ns` → enables `SF_SINGLE_SCHED` (1 event per step)
- Max step rate ≈ **10M steps/sec** → **10,000mm/s** theoretical
- **Only safe if ESP32 uses PCNT/RMT or dedicated polling**
- If ESP32 uses GPIO ISR, this will cause silent step loss

### Testing Protocol

To determine the ESP32's actual minimum pulse width:

1. **Start at Tier 1** (5µs) — verify basic motion works
2. **Move to Tier 2** (2µs) — should match current behavior
3. **Try Tier 3** (1µs) — test at 400mm/s, check for position errors
4. **Try Tier 4** (100ns) — test at 800mm/s+, verify with endstop accuracy
5. At each tier, run a multi-axis move pattern and check:
   - No "Stepper too far in past" shutdown
   - No "Move queue overflow" errors
   - Endstop positions are repeatable (±0.01mm)
   - No layer shifts or missed steps in prints

### Most Likely Scenario

Given that Peopoly designed this system for 1500mm/s operation, the ESP32
firmware **almost certainly uses PCNT or a dedicated polling loop** — GPIO
interrupts would be inadequate at those speeds. This means Tier 4 (100ns)
is likely safe, but should be validated empirically.

A strong clue: the LinearMotorHost allows setting "Pulse Input Resolution" to
20,000 pulses per mm. At 1500mm/s, that's 30M pulses/sec — only achievable
with hardware peripheral detection (PCNT/RMT).

---

## Load Cell Upgrade Path: CS1237/STC8051 → HX717

### Current System (Peopoly)

```
Strain Gauge → CS1237 ADC → STC8051 MCU → Digital HIGH/LOW → RP2040 GPIO24
                              ↑ DIP switches
                              (threshold=200)
```

**Problems**:
- Crude threshold-based triggering with no software control
- DIP switches for sensitivity adjustment (requires physical access)
- No tare/drift compensation in firmware
- False triggers cause "Probe triggered prior to movement" errors
- No force data available to Klipper — just a binary on/off

### Proposed System (Upstream Klipper)

```
Strain Gauge → HX717 ADC → RP2040 (DOUT + SCLK GPIOs) → Klipper load_cell_probe
                                                           ↑ SOS filter
                                                           ↑ Software tare
                                                           ↑ Force threshold (grams)
```

### Upstream Klipper Load Cell Support

Supported ADC sensors (`klippy/extras/load_cell.py`):
- **HX711** — 24-bit, 10/80 SPS, gains: A-128, B-32, A-64
- **HX717** — 24-bit, 10/20/80/320 SPS, gains: A-128, B-64, A-64, B-8
- **ADS1220** — 24-bit SPI, 20-2000 SPS, gains 1-128

**No CS1237 driver exists** in upstream Klipper. Only `sensor_hx71x.c` in `src/`.

### HX717 vs CS1237

| Feature | CS1237 (current) | HX717 (upgrade) |
|---|---|---|
| Resolution | 24-bit, ENOB ~20 bits | 24-bit, noise-free ~18.2 bits |
| Max sample rate | 1280 Hz | 320 SPS |
| Interface | SPI-like (SCLK + DRDY/DOUT) | Bit-banged GPIO (DOUT + SCLK) |
| Klipper driver | None | Full support (`hx71x.py` + `sensor_hx71x.c`) |
| Noise rejection | STC8051 threshold only | SOS filter + continuous tare |
| Configuration | DIP switches | Software (`printer.cfg`) |

The CS1237 has higher raw specs, but that's irrelevant — the STC8051 discards
all that data through crude thresholding. HX717 at 320 SPS with Klipper's SOS
filter is a massive improvement.

### Hardware Changes Required

1. **Remove/bypass STC8051** from the signal chain (it currently consumes all
   ADC data and outputs only binary HIGH/LOW)
2. **Replace CS1237 with HX717** breakout board (~$2-5)
3. **Reuse the existing strain gauge** — the gauge itself is standard
4. **Wire HX717 to two RP2040 GPIOs**:
   - DOUT (data + ready signal) → e.g. GPIO24
   - SCLK (serial clock) → e.g. GPIO25
5. Both pins must be on the **same MCU** (enforced by `hx71x.py`)
6. Power HX717 from toolhead PCB supply (2.7-5.5V)

### Firmware Changes Required

- Flash RP2040 toolhead with **upstream Klipper firmware** (includes `sensor_hx71x.c`)
- Peopoly's custom V0.11 firmware does NOT include `load_cell_probe` support

### Configuration

```ini
[load_cell_probe]
sensor_type: hx717
dout_pin: MAG_TOOL:gpio24
sclk_pin: MAG_TOOL:gpio25
sample_rate: 320
gain: A-128
counts_per_gram: <calibrated>         # Run LOAD_CELL_CALIBRATE
reference_tare_counts: <calibrated>   # Run LOAD_CELL_TARE
trigger_force: 75                     # grams — tunable in software
```

### Software Dependencies

- **NumPy** — required by `load_cell_probe.py`
- **SciPy** — required by `trigger_analog.py` for SOS filter design

### Benefits

- **Eliminates false triggers** — SOS filter rejects noise, continuous tare
  handles drift
- **Software-controlled sensitivity** — `trigger_force` in grams, adjustable
  without physical access
- **Diagnostic tools** — `LOAD_CELL_DIAGNOSTIC`, `LOAD_CELL_TEST_TAP`
- **Safety limits** — prevents bed crashes with force monitoring
- **Real-time force data** — available via webhooks for monitoring
- **Removes magneto_load_cell.py workaround** — no more LC28/LL28/LH28 commands
- **Removes homing.py workaround** — proper tare eliminates "probe triggered
  prior to movement"

### Risks

- Requires **physical modification** of toolhead PCB
- Need to identify available GPIOs on RP2040 (may require PCB tracing)
- Peopoly's custom firmware conflicts with upstream
- Warranty implications

---

## Complete Status

| Area | Status | Key Finding |
|---|---|---|
| Linear motor ↔ Klipper | **SOLVED** | Standard step/dir pulses, no custom protocol |
| Load cell protocol | **SOLVED** | Digital trigger via STC8051, not analog |
| Stepper timing | **ROOT CAUSE FOUND** | Default 2µs pulse duration limits step rate to ~250mm/s |
| Stepper timing fix | **TIERED APPROACH** | 100ns likely works but requires ESP32 firmware validation |
| Move queue overflow | **ROOT CAUSE FOUND** | Same cause as stepper timing — excessive step rate |
| H7 edge optimization | **SOLVED** | `stepper_event_full()` supports both-edges via `SF_SINGLE_SCHED` when pulse < 500ns |
| ESP32 pulse width | **RESEARCHED** | Depends on firmware: ISR=2-5µs, PCNT=12.5ns, polling=120ns |
| Load cell upgrade | **PATH DEFINED** | HX717 → RP2040 → upstream `load_cell_probe` — feasible, needs hardware mod |
| Load cell false triggers | **SOLUTION IDENTIFIED** | HX717 + SOS filter eliminates root cause |
| Upstream compatibility | **GAP** | Fork stuck on V0.11, needs port to current |

## Recommended Actions

### For Peopoly / Magneto X Users

1. **Immediate**: Test `step_pulse_duration` starting at 1µs, working down to
   100ns — validate with endstop repeatability checks
2. **Short-term**: Set correct `step_pulse_duration` for X/Y linear motor axes,
   re-enable "Stepper too far in past" safety check
3. **Medium-term**: Upgrade load cell from CS1237/STC8051 to HX717 for proper
   upstream `load_cell_probe` support
4. **Long-term**: Port Magneto X config to upstream Klipper, eliminating all
   fork workarounds

### For Upstream Klipper

1. **No code changes needed** — the step_pulse_duration mechanism already
   supports non-TMC drivers via explicit config
2. **Consider**: Adding a Magneto X example config to `config/` once pulse
   width is validated
3. **Consider**: Warning when step_pulse_duration limits achievable step rate
   below configured max_velocity
