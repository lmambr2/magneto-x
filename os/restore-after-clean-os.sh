#!/usr/bin/env bash
# Restore lab/device identity after a clean MainsailOS flash + postinstall.
# Usage:
#   ./os/restore-after-clean-os.sh /path/to/pre-clean-os-backup-dir
#   ./os/restore-after-clean-os.sh ~/pre-clean-os
#
# Expects backup dir to contain at least:
#   magneto_device.cfg
#   printer_data_config.tgz   (optional full config restore)
#   printer.cfg              (optional — merges SAVE_CONFIG mesh if present)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP="${1:-}"
CFG="${HOME}/printer_data/config"

if [[ -z "${BACKUP}" || ! -d "${BACKUP}" ]]; then
  echo "Usage: $0 /path/to/pre-clean-os-backup-dir" >&2
  exit 2
fi

if [[ ! -d "${CFG}" ]]; then
  echo "ERROR: ${CFG} missing — run MainsailOS first boot / postinstall first" >&2
  exit 1
fi

echo "=== restore-after-clean-os ==="
echo "BACKUP=${BACKUP}"
echo "CFG=${CFG}"

# Device IDs first (required for CAN/USB MCU)
if [[ -f "${BACKUP}/magneto_device.cfg" ]]; then
  cp -a "${BACKUP}/magneto_device.cfg" "${CFG}/magneto_device.cfg"
  echo "Restored magneto_device.cfg"
else
  echo "WARN: no magneto_device.cfg in backup — edit ${CFG}/magneto_device.cfg by hand" >&2
fi

# Optional full config tarball (overwrites package defaults — review after)
if [[ -f "${BACKUP}/printer_data_config.tgz" ]]; then
  echo "Extracting full config tarball into ~/printer_data (keeps other dirs)..."
  tar xzf "${BACKUP}/printer_data_config.tgz" -C "${HOME}/printer_data"
  echo "Extracted printer_data/config from tarball"
elif [[ -f "${BACKUP}/printer.cfg" ]]; then
  # Prefer package macros from ~/magneto-x if present, but keep device printer SAVE_CONFIG
  cp -a "${BACKUP}/printer.cfg" "${CFG}/printer.cfg"
  echo "Restored printer.cfg (includes SAVE_CONFIG mesh if any)"
fi

# Re-apply current package overlays from this repo (macros/KAMP/mainsail) if tree exists
if [[ -d "${ROOT}/config" ]]; then
  echo "Overlaying package macros/KAMP/mainsail from ${ROOT}/config ..."
  for f in macros.cfg mainsail.cfg KAMP_Settings.cfg shell_command.cfg; do
    if [[ -f "${ROOT}/config/${f}" ]]; then
      cp -a "${ROOT}/config/${f}" "${CFG}/${f}"
      echo "  overlay ${f}"
    fi
  done
  if [[ -d "${ROOT}/config/KAMP" ]]; then
    mkdir -p "${CFG}/KAMP"
    cp -a "${ROOT}/config/KAMP/." "${CFG}/KAMP/"
    echo "  overlay KAMP/"
  fi
  if [[ -f "${ROOT}/config/optional/origin_move.cfg" ]]; then
    mkdir -p "${CFG}/optional"
    cp -a "${ROOT}/config/optional/origin_move.cfg" "${CFG}/optional/origin_move.cfg"
    echo "  overlay optional/origin_move.cfg"
  fi
fi

# Do not clobber a real timelapse symlink with package stub
if [[ -L "${CFG}/timelapse.cfg" ]]; then
  echo "Keeping existing timelapse.cfg symlink"
elif [[ -f "${ROOT}/config/timelapse.cfg" ]]; then
  cp -a "${ROOT}/config/timelapse.cfg" "${CFG}/timelapse.cfg"
  echo "Installed package timelapse stub (replace with moonraker-timelapse link when ready)"
fi

echo
echo "Next:"
echo "  curl -s http://127.0.0.1:8880/health"
echo "  ${ROOT}/scripts/preflight-magneto.sh"
echo "  FIRMWARE_RESTART in Mainsail → LM_ENABLE → home"
echo "=== done ==="
