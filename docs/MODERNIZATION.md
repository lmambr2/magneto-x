# Magneto X modernization guide

## Goals

- Run **current Klipper** (your fork), not Peopoly’s May-2023 snapshot.
- Keep only the **minimum Magneto-specific host code**.
- Use a **maintainable Orange Pi Zero 2 image** (MainsailOS / Armbian).
- Clean configs (no duplicate macros, fixed linear-motor command names).
- **No commits/PRs to upstream Klipper3d.**

## Workspace layout

```
Projects/magneto-x/
├── klipper/                 # lmambr2/magneto-x-klipper (magneto-x or magneto-x-kalico)
├── config/                  # Printer configs ready to deploy
├── docs/                    # This research + guides
├── os/                      # Host image / service install notes
├── peopoly-klipper/         # Reference clone of mypeopoly/Klipper
├── magneto-x-klipper-config/
├── magnetox-os-update/      # Manager + Magmotor binaries
└── community/               # Community reference clones
```

## Klipper branches (A/B tracks)

| Branch | Base | When |
|--------|------|------|
| **`magneto-x`** (default) | Klipper3d | First recovery / most owners |
| **`magneto-x-kalico`** | Kalico | Optional A/B for danger_options, MPC, etc. |

Full switch guide: [TRACKS.md](TRACKS.md) and in-tree `docs/TRACKS.md`.

### Ported extras (both tracks)

| Module | Path | Notes |
|--------|------|-------|
| Load-cell latch | `klippy/extras/magneto_load_cell.py` | Cleaned; `CLEAR_LOAD_CELL`/`LC28`; auto-clear on probe home |
| Shell command | `klippy/extras/gcode_shell_command.py` | Vendored on mainline; **native on Kalico** |
| Homing sticky (D7) | `klippy/extras/homing.py` | Clear + one retry + hard fail |
| Stepper past | `src/stepper.c` + `src/Kconfig` | Optional `MAGNETO_RELAX_STEPPER_PAST` |

### Build Octopus (main MCU)

SSH on printer (or cross-build):

```bash
cd ~/klipper
git remote add mine https://github.com/lmambr2/magneto-x-klipper.git   # once
git fetch mine
git checkout magneto-x   # or magneto-x-kalico for Kalico track

make menuconfig
```

Recommended menuconfig (verify against your board silkscreen):

- Architecture: **STM32**
- Processor: **STM32H723** (stock wiki says H732 package / H723 silicon family — match Peopoly’s working `.bin` if unsure)
- Bootloader offset: **128KiB bootloader** (typical Octopus SD flash)
- Communication: **USB (on PA11/PA12)**  
- Enable **extra low-level options** → enable **Magneto X: relax 'Stepper too far in past' shutdown**

```bash
make clean
make
# out/klipper.bin → rename firmware.bin → TF card on Octopus → reset
```

### Build Lancer toolhead (RP2040 / CAN)

```bash
make menuconfig
# RP2040, Communication: CAN bus, Speed 250000 (stock Linux Hub)
make clean && make
# out/klipper.uf2 → hold BOOT, Type-C to PC, copy to RPI_RP2
```

Then set `canbus_uuid` in `magneto_device.cfg`. Host `can0` must also be **250000**.

### Install host Klippy from the fork

```bash
# Stop services first
sudo systemctl stop klipper

cd ~
# Prefer a clean clone of YOUR fork, not mypeopoly
mv klipper klipper-peopoly-backup
git clone -b magneto-x https://github.com/lmambr2/magneto-x-klipper.git klipper
# Kalico A/B:  -b magneto-x-kalico

# Reuse existing venv if present
~/klippy-env/bin/pip install -r ~/klipper/scripts/klippy-requirements.txt

sudo systemctl start klipper
```

Or point KIAUH / custom update manager at `https://github.com/lmambr2/magneto-x-klipper` branch `magneto-x` or `magneto-x-kalico`.

### Moonraker update manager (optional)

```ini
[update_manager klipper]
type: git_repo
path: ~/klipper
origin: https://github.com/lmambr2/magneto-x-klipper.git
primary_branch: magneto-x
# primary_branch: magneto-x-kalico
managed_services: klipper
```

## Config deploy

1. Backup `~/printer_data/config`.
2. Copy files from this repo’s `config/` directory.
3. Edit `magneto_device.cfg` with **your** USB serial id and CAN UUID.
4. In `mainsail.cfg` / `client.cfg`, **comment out** stock `PAUSE`/`RESUME` if present (FAQ).
5. `FIRMWARE_RESTART`.

## Linear motors still depend on magneto-manager

Until MagXY is driven some other way, keep:

- Flask `magneto-manager` on port **8880**
- ESP32 USB serial visible as “USB Serial”
- Macros `LM_ENABLE` / `LM_DISABLE` → `curl` → manager

Binaries live in Peopoly’s `magnetox-os-update/auto-uuid/` (`Magmotor`, scripts).  
See `os/install-magneto-services.sh`.

## What we deliberately did *not* do

- Did not reimplement MotionG closed-loop inside Klipper.
- Did not replace the digital load-cell with upstream `load_cell_probe` (wrong electrical interface).
- Did not force-push or PR to Klipper3d.
- Did not claim Peopoly’s squashed `master` is a usable merge base (use Peopoly’s `magneto-x` branch for archaeology; ship from `lmambr2/magneto-x-klipper` branch `magneto-x`).

## Verification checklist

- [ ] `status` / Mainsail shows ready, both MCUs connected  
- [ ] `LM_ENABLE` → motors armed (ESP32 LEDs green)  
- [ ] `G28 X` / `G28 Y`  
- [ ] `CLEAR_LOAD_CELL` then `G28 Z`  
- [ ] `QUAD_GANTRY_LEVEL`  
- [ ] Short print with `PRINT_START` / `PRINT_END`  
- [ ] Pause / resume once (no double-macro errors)  
