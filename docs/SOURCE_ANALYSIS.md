# Source analysis & inclusion decisions

**Date:** 2026-07-11  
**Scope:** Every link from the original project brief, plus a full crawl of the Peopoly Magneto X wiki subtree (69 pages).  
**Live cross-check:** printer `192.168.1.214` (stock OS v1.1.3, Klippy ready).

---

## Should we dump Peopoly’s wiki into this repo?

### Recommendation: **Yes — as a labeled vendor archive, not as our docs**

| Concern | Guidance |
|---------|----------|
| Peopoly reliability | Docs are stale (setup guides lag hardware), incomplete, and hosted only by them. Archiving is rational. |
| Copyright | Wiki text is Peopoly’s. Keep under `docs/vendor-archive/` with source URL + “not authored by us” banners. Prefer **rewriting** high-value pages into first-party docs over time. |
| Trust | **Never** present the archive as ground truth. Community FAQ and live validation win conflicts. |
| What *not* to dump | Google Drive CAD binaries, TF full OS images, proprietary Magmotor blobs (D13), random Discord. |
| What we did | Snapshot of **69** pages → [`vendor-archive/peopoly-wiki/`](vendor-archive/peopoly-wiki/README.md) (2026-07-11). |

**Do dump:** firmware flash notes, electronics diagram prose, load-cell / MagXY error procedures, UUID setup, Lancer PCB notes, maintenance that describes *this* hardware.  

**Do not promote as user-facing primary docs:** long setup-guide photo essays (huge, outdated), slicer marketing pages, anything contradicted by community FAQ.

**Better long-term shape:**

```text
docs/
  DESIGN.md, RESEARCH.md, …     # our voice
  FAQ.md, MIGRATION.md, …       # rewritten truth
  vendor-archive/
    peopoly-wiki/               # frozen mirror (this dump)
    community/                  # third-party extracts we cite
```

---

## Inclusion matrix (original links)

Legend: **In** = already absorbed or now archived · **Adopt** = take patterns into our code/config · **Cite** = link only · **Skip** = low value / liability

### Peopoly / official

| Source | Value | Inclusion |
|--------|-------|-----------|
| [mypeopoly/Klipper](https://github.com/mypeopoly/Klipper) | Real patch set on branch `magneto-x`; base `5f0d252b` | **In** — ported to `magneto-x-klipper`; keep remote for archaeology only |
| [magneto-x-klipper-config](https://github.com/mypeopoly/magneto-x-klipper-config) | Stock pin maps, MagXY rotation_distance 3.2, load-cell pins | **Adopt** into `config/` (already started); do not require “release page only” rule |
| [magnetox-os-update](https://github.com/mypeopoly/magnetox-os-update) | Manager scripts, Magmotor binary, late macros | **Adopt** open Python/scripts into hardened manager (PR-M4); **do not** ship Magmotor ELF |
| [magneto-manager-tool](https://github.com/mypeopoly/magneto-manager-tool) | Flask UUID + ENABLE/DISABLE API | **Adopt** as base for hardened manager; rewrite security |
| [magneto-x-os-mirror](https://github.com/mypeopoly/magneto-x-os-mirror) | Image tags only | **Cite** for recovery version names; LFS blobs not useful in git |
| Wiki [klipper-firmware](https://wiki.peopoly.net/en/magneto/magneto-x/klipper-firmware) | Confirms v0.11 + loadcell/linear focus | **Archived** |
| Wiki [magneto-linux-mcu-firmware](https://wiki.peopoly.net/en/magneto/magneto-x/magneto-linux-mcu-firmware) | Flash paths for host, Octopus, Lancer, loadcell, ESP32 | **Archived**; feed into `MCU_BUILD.md` |
| Wiki [design-files](https://wiki.peopoly.net/en/magneto/magneto-x/magneto-x-design-files) | Google Drive CAD links | **Cite** URLs only — do not vend large CAD in this repo |
| Wiki full subtree (69 pages) | Hardware service, MagXY, loadcell, WiFi, enclosure | **Archived** under `vendor-archive/peopoly-wiki/` |

### High-value wiki pages for *our* rewritten docs (priority extract)

| Topic | Wiki slug | Why |
|-------|-----------|-----|
| Electronics map | `magneto-x-electronic-system` | Authoritative block diagram narrative |
| Lancer PCB | `lancer-toolhead-pcb` | Pinout / CAN / loadcell path |
| Load cell FW + monitor | `loadcell-update-firmware`, `loadcell-data-monitoring` | DIP thresholds, STC8051 path |
| MagXY params / host | `parameters-introduce`, `linearmotorhost-user-guide`, `linear-motor-calibration-guide` | Closed-loop tuning |
| Error codes | `get-error-code-in-touchscreen`, `guide-to-get-linear-motor-error` | Field debug |
| UUID | `set-mcu-uuid`, `set-canbus-uuid` | Onboarding |
| TF / online update | `update-tf-image`, `update-magneto-x-online` | Migration rollback |
| Specs | `feature-and-specification` | Build volume etc. |

### Community

| Source | Value | Inclusion |
|--------|-------|-----------|
| [kaihanga FAQ](https://kaihanga.github.io/peopoly-magnetox-faq/) | Pause/resume, SSH, nginx, Beacon, dimensions, real-world fixes | **Adopt** into future `docs/FAQ.md`; text extract in `vendor-archive/community/` |
| [EmperorArthur linear motor FW](https://github.com/EmperorArthur/magneto_x_linear_motor_controller_firmware) | MIT ESP32 reverse eng: `ENABLE`/`DISABLE`, Modbus registers, ASCII/RTU modes | **Cite**; protocol used by K7/manager; optional flash after S3 (COMMUNITY_ESP32.md) |
| [EmperorArthur/magneto-x-klipper-config](https://github.com/EmperorArthur/magneto-x-klipper-config) | Fork of Peopoly config; **gpio29 runout double-check** + Arsoth button pull tweaks; still LINEAR+LINER shell | **Harvested** runout → `config/optional/runout_double_check.cfg`; not a full alt stack |
| [PlazmaZero OriginMove](https://github.com/PlazmaZero/MagnetoX-OriginMove) | XY port swap without rewiring | **Adopt** as `config/optional/origin-move.cfg` notes — **matches live printer** (X=300 Driver1, Y=400 Driver0) |
| [hazyavocado CFG](https://github.com/hazyavocado/Peopoly-MagnetoX-CFG) | Stock 1.1.4 + pause/resume via client.cfg | **Adopt** `mainsail.cfg` / client pattern for PR-M2 |
| [WilliamJamieson Magneto_x_config](https://github.com/WilliamJamieson/Magneto_x_config) | Modular configs + **Beacon** + nozzle wiper + motor macros | **Adopt** modular layout ideas; Beacon as optional profile |
| [mitant peopoly-magneto-x-config](https://github.com/mitant/peopoly-magneto-x-config) | Small `ant.cfg` (temp sensors, firmware_retraction) | **Adopt** MCU temp sensors snippet optionally |
| [nmavor Magneto-X-customize](https://github.com/nmavor/Magneto-X-customize) | SD growpart; **probe speed 0.5** improves load-cell accuracy vs 2.0 | **Adopt** probe speed guidance (live cfg uses 2 — candidate fix) |
| [Schmudus My-Magneto-X](https://github.com/Schmudus/My-Magneto-X) | Full alt stack: Pi5 + Kalico + toolhead swaps + Beacon; **CAN 250k + txqueuelen 512** | **Cite heavily** in migration/alt-hardware; equal Kalico track is now supported, Pi5 still alt. Text extract archived. Confirms stock CAN **250000**. |
| [lmambr2/magneto-x-klipper `claude/analyze-magneto-x-issues-08j9x`](https://github.com/lmambr2/magneto-x-klipper/tree/claude/analyze-magneto-x-issues-08j9x) | Prior agent analysis: Peopoly delta, stepper timing theory, HX717 upgrade path | **Harvest only** — see `docs/vendor-archive/community/CLAUDE_BRANCH_REVIEW.md`. Correct on step/dir + digital latch; **wrong** that default 2 µs pulse is field reality (configs already 200 ns). Do not merge branch into product. |
| [JMack89427 magneto_klipper](https://github.com/JMack89427/magneto_klipper) | Accidental home-directory dump | **Skip** as source of truth |

---

## Critical findings that change *our* design assumptions

### 1. Stock CAN is 250 kbit, not 1 Mbit

- Live `192.168.1.214`: `can0` **gs_usb**, **bitrate 250000**  
- Schmudus: deliberately stays at 250k / txqueuelen 512 on Magneto Linux-CAN hub; 1M only without that hub  
- **Action:** fix `OS_IMAGE.md` / DESIGN / `can0.network` defaults to **250000** for stock hardware; document 1M as alternate.

### 2. OriginMove-style XY is common (including this machine)

Live `printer.cfg` already has X = Driver1 (300 mm), Y = Driver0 (400 mm), QGL points flipped. Stock Peopoly docs show the other orientation.  
**Action:** ship both profiles: `stock-xy` vs `origin-move-xy`.

### 3. Probe speed 2.0 is too fast for stock load cell

nmavor data: stddev ~0.014 @ 2.0 mm/s → ~0.004 @ 0.5 mm/s. Live machine uses `speed: 2`.  
**Action:** default probe speed **0.5–1.0** in our config package.

### 4. Schmudus path proves MagXY is separable from toolhead MCU

After toolhead swaps they keep MagXY (ESP32 + movers) and `auto-uuid` / ENABLE path; load cell often dies → Beacon.  
**Action:** DESIGN already treats MagXY outside Klipper; add optional “Beacon profile” and “stock load-cell profile”.

### 5. EmperorArthur protocol is enough for a future native module

ASCII commands `ENABLE` / `DISABLE`, Modbus controlword `0xF002`, modes ASCII / RTU_GATEWAY / RTU_MIXED. Manager’s curl path is a thin wrapper.  
**Action:** PR-K7 / A8 still valid; use this as the protocol reference, not Peopoly closed source.

### 6. Wiki volume is mostly service manuals

~70 pages; setup-guide alone is huge and outdated (community FAQ already says so). Archive > rewrite selectively.

---

## Per-source deep notes (read status)

| Link | Read depth this pass |
|------|----------------------|
| Peopoly wiki Magneto X subtree | **Full crawl** 69/69; text archived |
| mypeopoly Klipper / config / OS / manager | **Deep** (prior + rechecked) |
| kaihanga FAQ | **Full** text archive |
| EmperorArthur firmware | **README + all src/** (~1k LOC) |
| Schmudus PDF v2.5.9 | **Full** text extract (607 lines) |
| PlazmaZero OriginMove | **Full** README |
| hazyavocado CFG | **Configs + README** |
| WilliamJamieson backup | **Layout + beacon/homing samples** |
| mitant ant.cfg | **Full** |
| nmavor README | **Full** |
| JMack dump | **Skip** (no clean signal) |
| Design-files Drive links | **Not downloaded** (CAD; cite only) |

---

## What to put in git vs not

| Put in `magneto-x` repo | Keep out of git |
|-------------------------|-----------------|
| Wiki **text** archive + index | Full TF **OS images** |
| Community **extracts** we cite | Magmotor / WifiHelper **binaries** |
| Optional config profiles | Large CAD/STEP from Drive |
| Scripts to **re-fetch** archive | Discord dumps wholesale |
| Attribution / license notes | Claiming Peopoly affiliation |

Suggested add to `.gitignore` only if someone tries to commit image blobs; text archive should be **tracked**.

---

## Concrete next inclusion tasks (ordered)

1. **PR-M1b** — commit `docs/vendor-archive/` + this file; link from README.  
2. **Fix CAN default** to 250000 for stock hub (docs + `os/can0.network`).  
3. **PR-M2** — parse-ready config: mainsail/client pause pattern (hazyavocado), probe speed 0.5–1.0 (nmavor), optional OriginMove profile (PlazmaZero + live machine).  
4. **Rewrite** top 10 wiki pages into `docs/` (electronics, loadcell, MagXY errors, UUID, MCU flash).  
5. **Document** Schmudus as “advanced alt stack” (Pi/Kalico/Beacon) — not default.  
6. **Protocol sheet** from EmperorArthur for MagXY ENABLE path.  

---

## Bottom line

- **Yes, dump the wiki** — we already captured it under `docs/vendor-archive/peopoly-wiki/`.  
- Treat it as **insurance + raw material**, not as the product manual.  
- Community sources are where **usable** modernization lives; Peopoly sources are where **hardware facts** hide.  
- Your live printer already validates several community corrections (CAN 250k, OriginMove XY, stock old Klipper).
