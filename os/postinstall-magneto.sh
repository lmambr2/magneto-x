#!/usr/bin/env bash
# Magneto X post-install skeleton (PR-M9 lite) for a fresh MainsailOS/Armbian host.
#
# Run as the klipper user (usually pi) AFTER first boot + password change.
# Does NOT flash MCUs (decision 2A). Does NOT require network display/Magmotor.
#
# Usage:
#   ./os/postinstall-magneto.sh
#   TRACK=magneto-x-kalico ./os/postinstall-magneto.sh
#   ./os/postinstall-magneto.sh --skip-klipper-clone   # if ~/klipper already correct
#   ./os/postinstall-magneto.sh --dry-run
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TRACK="${TRACK:-magneto-x}"
REPO_KLIPPER="${REPO_KLIPPER:-https://github.com/lmambr2/magneto-x-klipper.git}"
REPO_UMBRELLA="${REPO_UMBRELLA:-https://github.com/lmambr2/magneto-x.git}"
SKIP_KLIPPER=0
DRY_RUN=0
WITH_MAGMOTOR=0

for arg in "$@"; do
  case "$arg" in
    --skip-klipper-clone) SKIP_KLIPPER=1 ;;
    --with-magmotor) WITH_MAGMOTOR=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '1,20p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

if [[ "${TRACK}" != "magneto-x" && "${TRACK}" != "magneto-x-kalico" ]]; then
  echo "TRACK must be magneto-x or magneto-x-kalico (got ${TRACK})" >&2
  exit 2
fi

run() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

echo "=== Magneto X postinstall (track=${TRACK}) ==="
echo "User=$(whoami) HOME=${HOME} ROOT=${ROOT}"

# --- packages ---
if command -v apt-get >/dev/null; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: apt-get update && apt-get install -y git curl jq python3-flask python3-serial can-utils"
  else
    sudo apt-get update
    sudo apt-get install -y git curl jq python3-flask python3-serial can-utils || true
  fi
fi

# --- can0 @ 250k (stock Linux Hub) ---
if [[ -d /etc/systemd/network ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: install ${ROOT}/os/can0.network → /etc/systemd/network/80-can0.network"
  else
    sudo cp "${ROOT}/os/can0.network" /etc/systemd/network/80-can0.network
    sudo networkctl reload 2>/dev/null || true
    # Bring up immediately if interface exists
    if ip link show can0 >/dev/null 2>&1; then
      sudo ip link set can0 down 2>/dev/null || true
      sudo ip link set can0 up type can bitrate 250000 || \
        sudo ip link set can0 up || true
      sudo ip link set can0 txqueuelen 512 2>/dev/null || true
    else
      echo "NOTE: can0 not present yet (hub unplugged?). Network unit installed for next boot."
    fi
  fi
else
  echo "NOTE: no systemd-networkd; set can0 manually: ip link set can0 up type can bitrate 250000"
fi

# --- klipper fork ---
if [[ "${SKIP_KLIPPER}" -eq 0 ]]; then
  if [[ -d "${HOME}/klipper/.git" ]]; then
    echo "Backing up existing ~/klipper → ~/klipper.pre-magneto-postinstall"
    run mv "${HOME}/klipper" "${HOME}/klipper.pre-magneto-postinstall.$(date +%Y%m%d%H%M%S)"
  fi
  if [[ ! -d "${HOME}/klipper/.git" ]]; then
    run git clone -b "${TRACK}" "${REPO_KLIPPER}" "${HOME}/klipper"
  fi
  if [[ -x "${HOME}/klippy-env/bin/pip" ]]; then
    run "${HOME}/klippy-env/bin/pip" install -r "${HOME}/klipper/scripts/klippy-requirements.txt"
  else
    echo "NOTE: ~/klippy-env missing — install Klipper venv via MainsailOS/KIAUH first."
  fi
else
  echo "Skipping Klipper clone (--skip-klipper-clone)"
fi

# --- hardened manager ---
INSTALL_ARGS=()
if [[ "${WITH_MAGMOTOR}" -eq 1 ]]; then
  INSTALL_ARGS+=(--with-magmotor)
fi
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: ${ROOT}/os/install-magneto-services.sh ${INSTALL_ARGS[*]:-}"
else
  bash "${ROOT}/os/install-magneto-services.sh" ${INSTALL_ARGS[@]+"${INSTALL_ARGS[@]}"}
fi

# --- config package ---
CFG_DEST="${HOME}/printer_data/config"
if [[ -d "${CFG_DEST}" ]]; then
  run mkdir -p "${HOME}/printer_data/config.bak.postinstall"
  if [[ "${DRY_RUN}" -eq 0 ]]; then
    rsync -a "${CFG_DEST}/" "${HOME}/printer_data/config.bak.postinstall/" || true
    rsync -a --exclude='macros.cfg.stock*' "${ROOT}/config/" "${CFG_DEST}/"
    echo "Deployed config package to ${CFG_DEST}"
    echo "EDIT REQUIRED: ${CFG_DEST}/magneto_device.cfg (serial + canbus_uuid)"
  else
    echo "DRY: rsync config/ → ${CFG_DEST}"
  fi
else
  echo "NOTE: ${CFG_DEST} missing — create printer_data first (MainsailOS default)."
fi

# --- can0 txqueuelen persist ---
if [[ -f "${ROOT}/os/can0-txqueuelen.service" ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: install can0-txqueuelen.service"
  else
    sudo cp "${ROOT}/os/can0-txqueuelen.service" /etc/systemd/system/can0-txqueuelen.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now can0-txqueuelen.service 2>/dev/null || true
    sudo ip link set can0 txqueuelen 512 2>/dev/null || true
  fi
fi

# --- moonraker notes + timelapse ---
# Moonraker v0.8.x (Peopoly image) already owns built-in "klipper" updater.
# Do NOT append [update_manager klipper] — causes "Extension klipper already added"
# + Unparsed config option warnings. Track is the git remote on ~/klipper (above).
MR_CONF="${HOME}/printer_data/config/moonraker.conf"
SNIP="${ROOT}/config/moonraker-update-manager.conf.snippet"
if [[ -f "${MR_CONF}" ]]; then
  if grep -qE '^\[update_manager klipper\]' "${MR_CONF}" 2>/dev/null; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "DRY: strip conflicting [update_manager klipper] from moonraker.conf (v0.8 built-in)"
    else
      # Comment out conflicting section (keep a backup once)
      cp -a "${MR_CONF}" "${MR_CONF}.bak-pre-strip-um" 2>/dev/null || true
      python3 - <<'PY' "${MR_CONF}"
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = p.read_text().splitlines(True)
out = []
skip = False
for line in lines:
    if line.strip().lower() == "[update_manager klipper]":
        skip = True
        out.append("# REMOVED by postinstall-magneto.sh — conflicts with Moonraker v0.8 built-in klipper updater\n")
        out.append("# " + line if not line.startswith("#") else line)
        continue
    if skip:
        if line.startswith("[") and not line.strip().lower().startswith("[update_manager klipper]"):
            skip = False
            out.append(line)
        else:
            out.append("# " + line if line.strip() and not line.startswith("#") else line)
        continue
    out.append(line)
p.write_text("".join(out))
print("Stripped [update_manager klipper] from", p)
PY
    fi
  fi
  # Drop invalid magneto-x updater if path is not a git repo
  if grep -qE '^\[update_manager magneto-x\]' "${MR_CONF}" 2>/dev/null; then
    if [[ ! -d "${HOME}/magneto-x/.git" ]]; then
      if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "DRY: comment [update_manager magneto-x] (no .git under ~/magneto-x)"
      else
        python3 - <<'PY' "${MR_CONF}"
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = p.read_text().splitlines(True)
out, skip = [], False
for line in lines:
    if line.strip().lower() == "[update_manager magneto-x]":
        skip = True
        out.append("# REMOVED by postinstall — ~/magneto-x is not a git clone\n")
        out.append("# " + line)
        continue
    if skip:
        if line.startswith("["):
            skip = False
            out.append(line)
        else:
            out.append("# " + line if line.strip() and not line.startswith("#") else line)
        continue
    out.append(line)
p.write_text("".join(out))
print("Stripped [update_manager magneto-x] from", p)
PY
      fi
    fi
  fi
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: moonraker note — see ${SNIP} (do not merge [update_manager klipper] on v0.8)"
  else
    echo "Moonraker: klipper track is git remote on ~/klipper (branch ${TRACK}); see ${SNIP}"
  fi
elif [[ -f "${SNIP}" ]]; then
  echo "Moonraker: no moonraker.conf yet — later, do NOT paste [update_manager klipper] on v0.8; see ${SNIP}"
fi

# Timelapse: if component present, ensure printer.cfg includes macros
TL_MACRO="${HOME}/printer_data/config/timelapse.cfg"
if [[ ! -f "${TL_MACRO}" && -f "${HOME}/moonraker-timelapse/klipper_macro/timelapse.cfg" ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: link moonraker-timelapse macros → printer_data/config/timelapse.cfg"
  else
    ln -sfn "${HOME}/moonraker-timelapse/klipper_macro/timelapse.cfg" "${TL_MACRO}"
    echo "Linked timelapse.cfg macros"
  fi
fi
if [[ -f "${CFG_DEST:-}/printer.cfg" ]] && [[ -f "${TL_MACRO}" ]]; then
  if ! grep -q 'include timelapse.cfg' "${CFG_DEST}/printer.cfg" 2>/dev/null; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "DRY: add [include timelapse.cfg] to printer.cfg"
    else
      {
        echo ""
        echo "# Moonraker timelapse component macros"
        echo "[include timelapse.cfg]"
      } >> "${CFG_DEST}/printer.cfg"
      echo "Added [include timelapse.cfg] to printer.cfg"
    fi
  fi
fi

# nginx large-upload hint
if [[ -f "${ROOT}/config/optional/nginx-timeouts.conf.snippet" ]]; then
  echo "Nginx (optional): merge config/optional/nginx-timeouts.conf.snippet under http{} — see FAQ.md"
fi

# --- services ---
if [[ "${DRY_RUN}" -eq 0 ]]; then
  sudo systemctl restart magneto-manager.service 2>/dev/null || true
  sudo systemctl restart klipper.service 2>/dev/null || true
  sudo systemctl restart moonraker.service 2>/dev/null || true
fi

echo
echo "=== postinstall finished ==="
echo "Path note: this is for CLEAN MainsailOS (1B). Bridge on Peopoly image is Path C1 — see docs/MIGRATION.md"
echo "Next:"
echo "  1) Fill magneto_device.cfg UUIDs (serial + canbus_uuid)"
echo "  2) curl -s http://127.0.0.1:8880/health  and  RTU should be 400"
echo "  3) FIRMWARE_RESTART in Mainsail; LM_ENABLE; home carefully"
echo "  4) MCU flash later from same HEAD — docs/MCU_BUILD.md"
echo "  5) Fill docs/validation/S3_HARDWARE_REPORT.template.md when testing"
if [[ "${TRACK}" == "magneto-x-kalico" ]]; then
  echo "  (Kalico) optional: enable config/optional/danger_options.cfg"
fi
