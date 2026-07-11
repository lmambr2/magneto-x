#!/usr/bin/env bash
# Install / enable KlipperScreen for Magneto X local panel (HDMI + USB touch).
#
# Default for clean OS (1B): stock MainsailOS boots to console; this restores a
# local touch UI (printer control + NetworkManager Wi‑Fi panel) closer to the
# Peopoly appliance experience — without proprietary Magmotor/WifiHelper.
#
# Run as the klipper user (usually pi), with network for apt/git/pip.
# Usage:
#   ./os/install-klipperscreen.sh
#   ./os/install-klipperscreen.sh --dry-run
#   BACKEND=W ./os/install-klipperscreen.sh   # Wayland/cage if X fails on your board
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KS_HOME="${KS_HOME:-${HOME}/KlipperScreen}"
KS_REPO="${KS_REPO:-https://github.com/KlipperScreen/KlipperScreen.git}"
KS_BRANCH="${KS_BRANCH:-master}"
# X11 is the safer default on Orange Pi Zero 2; set BACKEND=W for cage/Wayland
BACKEND="${BACKEND:-X}"
DRY_RUN=0
START=1

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-start) START=0 ;;
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

if [[ "${EUID:-}" -eq 0 ]]; then
  echo "ERROR: do not run as root; run as pi (or your klipper user)" >&2
  exit 1
fi

run() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

echo "=== KlipperScreen install (backend=${BACKEND}) ==="

# --- packages: display + touch + NetworkManager (Wi‑Fi panel) ---
if command -v apt-get >/dev/null; then
  PKGS=(
    git curl
    # X11 path (default)
    xinit xinput x11-xserver-utils
    xserver-xorg-input-evdev xserver-xorg-input-libinput
    xserver-xorg-legacy xserver-xorg-video-fbdev
    # GTK / build for KS venv
    libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev
    gir1.2-gtk-3.0 librsvg2-common libopenjp2-7 libdbus-glib-1-dev
    autoconf python3-venv
    # Network panel (same as Peopoly-style on-screen Wi‑Fi)
    network-manager
    policykit-1
  )
  if [[ "${BACKEND}" =~ ^[wW]$ ]]; then
    PKGS+=(cage seatd)
  fi
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: sudo apt-get update && apt-get install -y ${PKGS[*]}"
  else
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKGS[@]}" || true
  fi
fi

# Prefer NetworkManager for KlipperScreen network panel
if [[ "${DRY_RUN}" -eq 0 ]]; then
  if systemctl list-unit-files network-manager.service >/dev/null 2>&1 \
     || systemctl list-unit-files NetworkManager.service >/dev/null 2>&1; then
    sudo systemctl enable NetworkManager.service 2>/dev/null \
      || sudo systemctl enable network-manager.service 2>/dev/null || true
    sudo systemctl start NetworkManager.service 2>/dev/null \
      || sudo systemctl start network-manager.service 2>/dev/null || true
  fi
  # Common on Armbian/MainsailOS — avoid fighting NM when present
  sudo systemctl disable --now dhcpcd 2>/dev/null || true
  sudo systemctl disable --now NetworkManager-wait-online.service 2>/dev/null || true
fi

# --- clone KlipperScreen ---
if [[ ! -d "${KS_HOME}/.git" ]]; then
  run git clone --depth 1 -b "${KS_BRANCH}" "${KS_REPO}" "${KS_HOME}"
elif [[ "${DRY_RUN}" -eq 0 ]]; then
  echo "Using existing ${KS_HOME}"
  (cd "${KS_HOME}" && git fetch --depth 1 origin "${KS_BRANCH}" && git checkout "${KS_BRANCH}" && git pull --ff-only) || true
fi

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: noninteractive KlipperScreen-install.sh (SERVICE=Y BACKEND=${BACKEND} NETWORK=n)"
  echo "DRY: enable/start KlipperScreen.service"
  echo "DRY: deploy config/KlipperScreen.conf if present"
  exit 0
fi

if [[ ! -x "${KS_HOME}/scripts/KlipperScreen-install.sh" ]]; then
  echo "ERROR: missing ${KS_HOME}/scripts/KlipperScreen-install.sh" >&2
  exit 1
fi

# Official installer is interactive unless env vars are set.
# NETWORK=n: we already installed NetworkManager above (their path reboots).
# SERVICE=Y: systemd unit + graphical backend + multi-user target
# START controlled by us after config deploy
export SERVICE=Y
export NETWORK=n
export BACKEND
export START=0

echo "Running upstream KlipperScreen installer (noninteractive)…"
# shellcheck disable=SC1091
bash "${KS_HOME}/scripts/KlipperScreen-install.sh"

# Groups for serial/touch/network (idempotent)
sudo usermod -aG tty,netdev,video,input,render "${USER}" 2>/dev/null || true
sudo groupadd -f klipperscreen 2>/dev/null || true
sudo usermod -aG klipperscreen,network "${USER}" 2>/dev/null || true

# Package conf (Moonraker localhost defaults; panel regenerates #~# blocks)
CFG_DEST="${HOME}/printer_data/config"
if [[ -d "${CFG_DEST}" && -f "${ROOT}/config/KlipperScreen.conf" ]]; then
  if [[ ! -f "${CFG_DEST}/KlipperScreen.conf" ]] \
     || ! grep -q '\[main\]' "${CFG_DEST}/KlipperScreen.conf" 2>/dev/null; then
    cp -a "${ROOT}/config/KlipperScreen.conf" "${CFG_DEST}/KlipperScreen.conf"
    echo "Deployed ${CFG_DEST}/KlipperScreen.conf"
  fi
fi

# Ensure unit is enabled; multi-user is already set by upstream install
sudo systemctl unmask KlipperScreen.service 2>/dev/null || true
sudo systemctl daemon-reload
sudo systemctl enable KlipperScreen.service

if [[ "${START}" -eq 1 ]]; then
  sudo systemctl restart KlipperScreen.service || {
    echo "WARN: KlipperScreen.service failed to start — check: journalctl -u KlipperScreen -b --no-pager | tail -80"
    echo "      Display/touch: ls /dev/input/event* ; loginctl ; systemctl status KlipperScreen"
  }
fi

echo
echo "=== KlipperScreen install finished ==="
echo "  Service: systemctl status KlipperScreen"
echo "  Config:  ~/printer_data/config/KlipperScreen.conf"
echo "  Wi‑Fi:   Settings → Network in KlipperScreen (NetworkManager)"
echo "  NOTE: re-login (or reboot) so new groups (tty/netdev/input) apply"
echo "  First boot still needs one network path (keyboard nmtui, Ethernet,"
echo "  or preconfigured Wi‑Fi) before apt can install packages."
