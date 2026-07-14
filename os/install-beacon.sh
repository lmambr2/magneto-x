#!/usr/bin/env bash
# Install Beacon Klipper module (beacon3d/beacon_klipper) for Magneto X alt probe path.
# https://docs.beacon3d.com/quickstart/
#
# Does NOT enable Beacon in printer.cfg (hardware conversion — see optional/beacon.cfg).
#
# Usage:
#   ./os/install-beacon.sh
#   ./os/install-beacon.sh --dry-run
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BEACON_HOME="${BEACON_HOME:-${HOME}/beacon_klipper}"
BEACON_REPO="${BEACON_REPO:-https://github.com/beacon3d/beacon_klipper.git}"
KLIPPER_PATH="${KLIPPER_PATH:-${HOME}/klipper}"
CFG_DEST="${HOME}/printer_data/config"
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '1,16p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

if [[ "${EUID:-}" -eq 0 ]]; then
  echo "ERROR: do not run as root" >&2
  exit 1
fi

echo "=== Beacon module install ==="

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: git clone ${BEACON_REPO} ${BEACON_HOME}"
  echo "DRY: ${BEACON_HOME}/install.sh"
  echo "DRY: moonraker update_manager beacon"
  echo "DRY: deploy optional/beacon.cfg"
  exit 0
fi

if [[ ! -d "${BEACON_HOME}/.git" ]]; then
  git clone "${BEACON_REPO}" "${BEACON_HOME}"
else
  (cd "${BEACON_HOME}" && git pull --ff-only) || true
fi

if [[ ! -x "${BEACON_HOME}/install.sh" ]]; then
  echo "ERROR: missing ${BEACON_HOME}/install.sh" >&2
  exit 1
fi

# Upstream installer links into klipper + pip deps (may take a while)
bash "${BEACON_HOME}/install.sh"

# Deploy package beacon config if missing
mkdir -p "${CFG_DEST}/optional"
if [[ -f "${ROOT}/config/optional/beacon.cfg" ]]; then
  if [[ ! -f "${CFG_DEST}/optional/beacon.cfg" ]]; then
    cp -a "${ROOT}/config/optional/beacon.cfg" "${CFG_DEST}/optional/beacon.cfg"
    echo "Deployed optional/beacon.cfg (edit serial + offsets before enabling)"
  else
    echo "Keeping existing ${CFG_DEST}/optional/beacon.cfg"
  fi
fi
if [[ -f "${ROOT}/config/optional/beacon_activate.md" ]]; then
  cp -a "${ROOT}/config/optional/beacon_activate.md" "${CFG_DEST}/optional/beacon_activate.md" 2>/dev/null || true
fi

# Moonraker update manager
MR="${CFG_DEST}/moonraker.conf"
if [[ -f "${MR}" ]] && ! grep -qE '^\[update_manager beacon\]' "${MR}"; then
  cat >> "${MR}" <<'EOF'

## Beacon Surface Scanner (optional probe path)
[update_manager beacon]
type: git_repo
channel: dev
path: ~/beacon_klipper
origin: https://github.com/beacon3d/beacon_klipper.git
env: ~/klippy-env/bin/python
requirements: requirements.txt
install_script: install.sh
is_system_service: False
managed_services: klipper
info_tags:
  desc=Beacon Surface Scanner
EOF
  echo "Added [update_manager beacon] to moonraker.conf"
fi

echo
echo "=== Beacon module installed ==="
echo "  Next: ls /dev/serial/by-id/usb-Beacon*"
echo "  Edit: ${CFG_DEST}/optional/beacon.cfg  (serial, x_offset, y_offset)"
echo "  Enable: [include optional/beacon.cfg]  and disable stock [probe] / magneto_load_cell"
echo "  Guide:  ${CFG_DEST}/optional/beacon_activate.md"
echo "  Docs:   https://docs.beacon3d.com/quickstart/"
echo "  Restart: FIRMWARE_RESTART after config enable"
