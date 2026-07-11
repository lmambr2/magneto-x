#!/usr/bin/env bash
# Restore lab/device identity after a clean MainsailOS flash + postinstall.
#
# Usage:
#   ./os/restore-after-clean-os.sh /path/to/pre-clean-os-backup-dir
#
# Safe for Path A (Trixie/MainsailOS 3): does NOT overwrite stock moonraker.conf
# or other host-managed files with Peopoly bridge dumps.
#
# Prefer:
#   magneto_device.cfg   (required)
#   printer.cfg          (optional — has SAVE_CONFIG mesh)
#   printer_data_config.tgz is extracted to a staging dir; only allowlisted
#   files are copied (never moonraker.conf / crowsnest / sonar from old image).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP="${1:-}"
CFG="${HOME}/printer_data/config"

# Files safe to restore from a C1/Peopoly backup onto clean OS
ALLOW_RESTORE=(
  magneto_device.cfg
  printer.cfg
  macros.cfg
  mainsail.cfg
  KAMP_Settings.cfg
  shell_command.cfg
  magneto_toolhead.cfg
  KlipperScreen.conf
)

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

copy_if_present() {
  local src="$1" dest="$2"
  if [[ -f "${src}" ]]; then
    mkdir -p "$(dirname "${dest}")"
    cp -a "${src}" "${dest}"
    echo "  restored $(basename "${dest}")"
    return 0
  fi
  return 1
}

# 1) Device IDs
if ! copy_if_present "${BACKUP}/magneto_device.cfg" "${CFG}/magneto_device.cfg"; then
  echo "WARN: no magneto_device.cfg in backup — edit ${CFG}/magneto_device.cfg by hand" >&2
fi

# 2) Optional full tarball → stage, then allowlist only
if [[ -f "${BACKUP}/printer_data_config.tgz" ]]; then
  STAGE="$(mktemp -d "${TMPDIR:-/tmp}/magneto-restore.XXXXXX")"
  cleanup() { rm -rf "${STAGE}"; }
  trap cleanup EXIT
  echo "Staging tarball (selective restore — skips moonraker.conf)..."
  tar xzf "${BACKUP}/printer_data_config.tgz" -C "${STAGE}"
  # tarball root is usually "config/"
  SRC_CFG="${STAGE}/config"
  if [[ ! -d "${SRC_CFG}" ]]; then
    # flat dump
    SRC_CFG="${STAGE}"
  fi
  for f in "${ALLOW_RESTORE[@]}"; do
    if [[ -f "${SRC_CFG}/${f}" ]]; then
      copy_if_present "${SRC_CFG}/${f}" "${CFG}/${f}" || true
    fi
  done
  if [[ -d "${SRC_CFG}/KAMP" ]]; then
    mkdir -p "${CFG}/KAMP"
    cp -a "${SRC_CFG}/KAMP/." "${CFG}/KAMP/"
    echo "  restored KAMP/"
  fi
  if [[ -d "${SRC_CFG}/optional" ]]; then
    mkdir -p "${CFG}/optional"
    # only origin_move by default (stock XY optional)
    if [[ -f "${SRC_CFG}/optional/origin_move.cfg" ]]; then
      cp -a "${SRC_CFG}/optional/origin_move.cfg" "${CFG}/optional/origin_move.cfg"
      echo "  restored optional/origin_move.cfg"
    fi
  fi
  # Explicitly never restore these from Peopoly backup
  for skip in moonraker.conf crowsnest.conf sonar.conf moonraker-secrets.ini; do
    if [[ -f "${SRC_CFG}/${skip}" ]]; then
      echo "  SKIP ${skip} (host-managed; keep MainsailOS defaults)"
    fi
  done
elif [[ -f "${BACKUP}/printer.cfg" ]]; then
  copy_if_present "${BACKUP}/printer.cfg" "${CFG}/printer.cfg"
fi

# 3) Overlay current package (repo HEAD wins for macros/KAMP)
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
  # Keep restored printer.cfg + magneto_device.cfg (do not overlay placeholders)
fi

# Timelapse: never replace a real component symlink with stub
if [[ -L "${CFG}/timelapse.cfg" ]]; then
  echo "Keeping existing timelapse.cfg symlink"
elif [[ -f "${HOME}/moonraker-timelapse/klipper_macro/timelapse.cfg" ]]; then
  ln -sfn "${HOME}/moonraker-timelapse/klipper_macro/timelapse.cfg" "${CFG}/timelapse.cfg"
  echo "Linked real moonraker-timelapse macros"
elif [[ -f "${ROOT}/config/timelapse.cfg" ]]; then
  cp -a "${ROOT}/config/timelapse.cfg" "${CFG}/timelapse.cfg"
  echo "Installed package timelapse stub"
fi

echo
echo "Next:"
echo "  curl -s http://127.0.0.1:8880/health"
echo "  ${ROOT}/scripts/preflight-magneto.sh"
echo "  FIRMWARE_RESTART in Mainsail → LM_ENABLE → home"
echo "=== done ==="
