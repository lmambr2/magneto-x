#!/usr/bin/env bash
# Install Klippain Shake&Tune (Frix-x/klippain-shaketune) for Magneto X.
# https://github.com/Frix-x/klippain-shaketune
#
# Clones upstream, installs Python deps into ~/klippy-env, links into Klipper
# extras, adds Moonraker update_manager entry, ensures [shaketune] config.
#
# Usage:
#   ./os/install-shaketune.sh
#   ./os/install-shaketune.sh --dry-run
#   ./os/install-shaketune.sh --configure-only   # conf + moonraker only
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ST_HOME="${ST_HOME:-${HOME}/klippain_shaketune}"
ST_REPO="${ST_REPO:-https://github.com/Frix-x/klippain-shaketune.git}"
KLIPPER_PATH="${KLIPPER_PATH:-${HOME}/klipper}"
KLIPPY_VENV="${KLIPPY_VENV:-${HOME}/klippy-env}"
CFG_DEST="${HOME}/printer_data/config"
DRY_RUN=0
CONFIGURE_ONLY=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --configure-only) CONFIGURE_ONLY=1 ;;
    -h|--help)
      sed -n '1,18p' "$0"
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

echo "=== Klippain Shake&Tune install ==="

run() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

ensure_config() {
  local cfg="${CFG_DEST}/optional/shaketune.cfg"
  mkdir -p "${CFG_DEST}/optional"
  if [[ -f "${ROOT}/config/optional/shaketune.cfg" ]]; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "DRY: deploy shaketune.cfg"
    else
      cp -a "${ROOT}/config/optional/shaketune.cfg" "${cfg}"
      echo "Deployed ${cfg}"
    fi
  fi

  local printer="${CFG_DEST}/printer.cfg"
  if [[ -f "${printer}" ]]; then
    if ! grep -qE '^\[include optional/shaketune\.cfg\]' "${printer}" \
       && ! grep -qE '^\[shaketune\]' "${printer}"; then
      if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "DRY: add [include optional/shaketune.cfg] to printer.cfg"
      else
        {
          echo ""
          echo "# Klippain Shake&Tune (install-shaketune.sh)"
          echo "[include optional/shaketune.cfg]"
        } >> "${printer}"
        echo "Added shaketune include to printer.cfg"
      fi
    else
      echo "printer.cfg already references shaketune"
    fi
  fi

  local mr="${CFG_DEST}/moonraker.conf"
  local snip="${ROOT}/config/moonraker-shaketune.conf.snippet"
  if [[ -f "${mr}" && -f "${snip}" ]]; then
    if grep -qE '^\[update_manager Klippain-ShakeTune\]' "${mr}" 2>/dev/null; then
      echo "Moonraker already has Klippain-ShakeTune updater"
    elif [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "DRY: append Shake&Tune update_manager to moonraker.conf"
    else
      {
        echo ""
        cat "${snip}"
      } >> "${mr}"
      echo "Appended Shake&Tune update_manager to moonraker.conf"
    fi
  fi
}

if [[ "${CONFIGURE_ONLY}" -eq 1 ]]; then
  ensure_config
  echo "=== configure-only done (FIRMWARE_RESTART / moonraker restart may be needed) ==="
  exit 0
fi

# System packages (openblas for numpy)
if command -v apt-get >/dev/null; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: apt-get install -y libopenblas-dev"
  elif sudo -n true 2>/dev/null; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libopenblas-dev || true
  else
    echo "NOTE: if pip fails later, run: sudo apt install -y libopenblas-dev"
  fi
fi

# Clone
if [[ ! -d "${ST_HOME}/.git" ]]; then
  run git clone --depth 1 "${ST_REPO}" "${ST_HOME}"
elif [[ "${DRY_RUN}" -eq 0 ]]; then
  echo "Using existing ${ST_HOME}"
  (cd "${ST_HOME}" && git pull --ff-only) || true
fi

if [[ ! -d "${KLIPPER_PATH}/klippy" ]]; then
  echo "ERROR: Klipper not found at ${KLIPPER_PATH}" >&2
  exit 1
fi
if [[ ! -x "${KLIPPY_VENV}/bin/pip" ]]; then
  echo "ERROR: Klipper venv not found at ${KLIPPY_VENV}" >&2
  exit 1
fi

# Python deps into klippy-env
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: ${KLIPPY_VENV}/bin/pip install -r ${ST_HOME}/requirements.txt"
else
  "${KLIPPY_VENV}/bin/pip" install --upgrade pip
  "${KLIPPY_VENV}/bin/pip" install -r "${ST_HOME}/requirements.txt"
fi

# Link module into Klipper extras
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: ln -sfn ${ST_HOME}/shaketune ${KLIPPER_PATH}/klippy/extras/shaketune"
else
  ln -sfn "${ST_HOME}/shaketune" "${KLIPPER_PATH}/klippy/extras/shaketune"
  echo "Linked ${KLIPPER_PATH}/klippy/extras/shaketune → ${ST_HOME}/shaketune"
fi

ensure_config

# Restart services
if [[ "${DRY_RUN}" -eq 0 ]]; then
  if sudo -n true 2>/dev/null; then
    sudo systemctl restart klipper moonraker 2>/dev/null || true
  else
    # Moonraker API when no passwordless sudo
    curl -sf -X POST http://127.0.0.1:7125/machine/services/restart \
      -H 'Content-Type: application/json' -d '{"service":"klipper"}' >/dev/null 2>&1 || true
    curl -sf -X POST http://127.0.0.1:7125/server/restart >/dev/null 2>&1 || true
    curl -sf http://127.0.0.1:7125/printer/gcode/script \
      -d 'script=FIRMWARE_RESTART' >/dev/null 2>&1 || true
  fi
fi

echo
echo "=== Shake&Tune install finished ==="
echo "  Repo:    ${ST_HOME}"
echo "  Module:  ${KLIPPER_PATH}/klippy/extras/shaketune"
echo "  Config:  [include optional/shaketune.cfg] in printer.cfg"
echo "  Docs:    https://github.com/Frix-x/klippain-shaketune"
echo "  Macros:  AXES_SHAPER_CALIBRATION, BELTS_SHAPER_CALIBRATION, ..."
echo "  MagXY:   LM_ENABLE + G28 before resonance macros"
echo "  Results: ~/printer_data/config/ShakeTune_results"
