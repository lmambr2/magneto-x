#!/usr/bin/env bash
# Install KlipperCortex (edge spaghetti detection) for Magneto X.
# Upstream: https://github.com/Vladush/KlipperCortex (MIT)
#
# On-device vision → pauses print via Moonraker when confidence ≥ threshold.
# Prefers Pi 4/5 (more RAM). Orange Pi Zero 2 may OOM — use --dry-run first.
#
# Usage:
#   ./os/install-klipper-cortex.sh
#   ./os/install-klipper-cortex.sh --dry-run
#   ./os/install-klipper-cortex.sh --no-service   # clone+venv only
#   ./os/install-klipper-cortex.sh --enable       # enable systemd unit after install
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KC_HOME="${KC_HOME:-${HOME}/klipper_cortex}"
KC_REPO="${KC_REPO:-https://github.com/Vladush/KlipperCortex.git}"
DRY_RUN=0
NO_SERVICE=0
ENABLE_SVC=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-service) NO_SERVICE=1 ;;
    --enable) ENABLE_SVC=1 ;;
    -h|--help)
      sed -n '1,22p' "$0"
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

echo "=== KlipperCortex install ==="
echo "  HOME=${KC_HOME}  user=${USER}"

run() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

# Clone
if [[ ! -d "${KC_HOME}/.git" ]]; then
  run git clone --depth 1 "${KC_REPO}" "${KC_HOME}"
elif [[ "${DRY_RUN}" -eq 0 ]]; then
  echo "Using existing ${KC_HOME}"
  (cd "${KC_HOME}" && git pull --ff-only) || true
fi

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: python3 -m venv ${KC_HOME}/.venv && pip install -r requirements.txt"
  echo "DRY: download_models.py --model 3"
  echo "DRY: install systemd unit (disabled until .vmfb exists)"
  echo "=== dry-run finished ==="
  exit 0
fi

# venv + deps
if [[ ! -d "${KC_HOME}/.venv" ]]; then
  python3 -m venv "${KC_HOME}/.venv"
fi
# shellcheck disable=SC1091
source "${KC_HOME}/.venv/bin/activate"
pip install --upgrade pip
pip install -r "${KC_HOME}/requirements.txt"

# Download a spaghetti-oriented model (TFLite). Compile to .vmfb separately.
mkdir -p "${KC_HOME}/models"
if [[ ! -f "${KC_HOME}/models/model.tflite" && ! -f "${KC_HOME}/models/spaghetti_v2.tflite" \
      && ! -f "${KC_HOME}/models/model.onnx" ]]; then
  echo "Downloading Obico legacy spaghetti TFLite (model 3)…"
  (cd "${KC_HOME}" && python3 scripts/download_models.py --model 3) || true
fi

# Prefer any existing .vmfb
MODEL_PATH=""
for f in \
  "${KC_HOME}/models/model.vmfb" \
  "${KC_HOME}/models/spaghetti_v2.vmfb" \
  "${KC_HOME}"/models/*cortex*.vmfb \
  "${KC_HOME}"/models/*.vmfb
do
  if [[ -f "$f" ]]; then
    MODEL_PATH="$f"
    break
  fi
done

if [[ -z "${MODEL_PATH}" ]]; then
  echo
  echo "NOTE: No compiled IREE model (*.vmfb) found yet."
  echo "  Runtime requires a .vmfb. On a build machine / Pi with Docker:"
  echo "    cd ${KC_HOME}"
  echo "    docker build -t iree-cross-compiler ."
  echo "    # Pi 5 (cortex-a76) example — check compile_model.sh for arch flags:"
  echo "    bash scripts/compile_model.sh models/model.tflite cortex-a76"
  echo "  Then re-run: $0 --enable"
  echo "  Docs: https://github.com/Vladush/KlipperCortex/blob/main/docs/compilation.md"
  MODEL_PATH="${KC_HOME}/models/model.vmfb"  # placeholder path for unit file
fi

deactivate 2>/dev/null || true

# Systemd unit
if [[ "${NO_SERVICE}" -eq 0 ]]; then
  UNIT_SRC="${ROOT}/os/klipper-cortex.service"
  UNIT_TMP="$(mktemp)"
  sed \
    -e "s|REPLACE_USER|${USER}|g" \
    -e "s|REPLACE_HOME|${HOME}|g" \
    -e "s|MODEL_PATH=.*|Environment=MODEL_PATH=${MODEL_PATH}|g" \
    "${UNIT_SRC}" > "${UNIT_TMP}"
  # Fix MODEL_PATH line properly
  sed -i "s|Environment=MODEL_PATH=.*|Environment=MODEL_PATH=${MODEL_PATH}|" "${UNIT_TMP}"

  if sudo -n true 2>/dev/null; then
    sudo cp "${UNIT_TMP}" /etc/systemd/system/klipper-cortex.service
    sudo systemctl daemon-reload
    if [[ "${ENABLE_SVC}" -eq 1 && -f "${MODEL_PATH}" ]]; then
      sudo systemctl enable --now klipper-cortex.service
      echo "Service klipper-cortex enabled and started"
    else
      sudo systemctl enable klipper-cortex.service 2>/dev/null || true
      sudo systemctl disable --now klipper-cortex.service 2>/dev/null || true
      echo "Service installed but left disabled until a .vmfb model exists (or use --enable)"
    fi
  else
    mkdir -p "${HOME}/.config/systemd/user" 2>/dev/null || true
    cp "${UNIT_TMP}" "${HOME}/klipper-cortex.service"
    echo "Wrote ${HOME}/klipper-cortex.service — install with:"
    echo "  sudo cp ~/klipper-cortex.service /etc/systemd/system/klipper-cortex.service"
    echo "  sudo systemctl daemon-reload"
    echo "  sudo systemctl enable --now klipper-cortex   # after model compile"
  fi
  rm -f "${UNIT_TMP}"
fi

echo
echo "=== KlipperCortex install finished ==="
echo "  Tree:     ${KC_HOME}"
echo "  Venv:     ${KC_HOME}/.venv"
echo "  Camera:   http://127.0.0.1/webcam/?action=snapshot  (crowsnest)"
echo "  Moonraker: 127.0.0.1:7125  → pause on detect"
echo "  Model:    ${MODEL_PATH}"
if [[ ! -f "${MODEL_PATH}" ]]; then
  echo "  STATUS:   waiting for IREE .vmfb compile (see above)"
else
  echo "  STATUS:   model present — start with: sudo systemctl start klipper-cortex"
fi
echo "  Manual:   cd ${KC_HOME} && source .venv/bin/activate && python3 src/inference_loop.py"
echo "  Upstream: https://github.com/Vladush/KlipperCortex"
