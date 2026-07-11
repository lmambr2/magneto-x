#!/usr/bin/env bash
# Install HelixScreen (open-source touch UI + first-run wizard) for Magneto X.
#
# Upstream: https://github.com/prestonbrown/helixscreen (GPL-3.0)
# Docs:     https://helixscreen.org/installation/
#
# Default local panel for clean OS (1B). Provides on-screen first-run wizard
# (touch cal, language, Wi‑Fi, Moonraker host, heaters/fans) — closer to the
# Peopoly appliance UX than stock MainsailOS console or plain KlipperScreen.
#
# Run as the klipper user (usually pi), with network for download + apt.
#
# Usage:
#   ./os/install-helixscreen.sh
#   ./os/install-helixscreen.sh --dry-run
#   ./os/install-helixscreen.sh --update
#   HELIX_INSTALL_URL=... ./os/install-helixscreen.sh   # pin installer URL
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELIX_INSTALL_URL="${HELIX_INSTALL_URL:-https://raw.githubusercontent.com/prestonbrown/helixscreen/main/scripts/install.sh}"
DRY_RUN=0
UPDATE=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --update) UPDATE=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)
      sed -n '1,25p' "$0"
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

echo "=== HelixScreen install ==="
echo "  User=$(whoami) HOME=${HOME}"
echo "  Installer: ${HELIX_INSTALL_URL}"

# NetworkManager improves on-panel Wi‑Fi wizard reliability
if command -v apt-get >/dev/null; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: apt-get install -y network-manager curl ca-certificates"
  else
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
      network-manager curl ca-certificates || true
    sudo systemctl enable NetworkManager.service 2>/dev/null \
      || sudo systemctl enable network-manager.service 2>/dev/null || true
    sudo systemctl start NetworkManager.service 2>/dev/null \
      || sudo systemctl start network-manager.service 2>/dev/null || true
  fi
fi

# Stop legacy panel UIs so HelixScreen owns HDMI/touch
stop_legacy_panel() {
  for svc in KlipperScreen klipperscreen; do
    if systemctl list-unit-files "${svc}.service" >/dev/null 2>&1 \
       || systemctl cat "${svc}.service" >/dev/null 2>&1; then
      if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "DRY: systemctl stop/disable ${svc}.service"
      else
        sudo systemctl stop "${svc}.service" 2>/dev/null || true
        sudo systemctl disable "${svc}.service" 2>/dev/null || true
      fi
    fi
  done
}

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "DRY: download + run HelixScreen install.sh"
  if [[ "${UNINSTALL}" -eq 1 ]]; then
    echo "DRY: install.sh --uninstall"
  elif [[ "${UPDATE}" -eq 1 ]]; then
    echo "DRY: install.sh --update"
  else
    echo "DRY: install.sh (fresh install; platform auto-detect)"
  fi
  stop_legacy_panel
  echo "DRY: systemctl enable --now helixscreen (if systemd unit present)"
  echo
  echo "=== HelixScreen dry-run finished ==="
  exit 0
fi

stop_legacy_panel

TMP="$(mktemp -d "${TMPDIR:-/tmp}/helix-install.XXXXXX")"
cleanup() { rm -rf "${TMP}"; }
trap cleanup EXIT

INSTALLER="${TMP}/install.sh"
echo "Downloading HelixScreen installer…"
if command -v curl >/dev/null; then
  curl -fsSL "${HELIX_INSTALL_URL}" -o "${INSTALLER}"
elif command -v wget >/dev/null; then
  wget -qO "${INSTALLER}" "${HELIX_INSTALL_URL}"
else
  echo "ERROR: need curl or wget to fetch HelixScreen installer" >&2
  exit 1
fi
chmod +x "${INSTALLER}"

ARGS=()
if [[ "${UNINSTALL}" -eq 1 ]]; then
  ARGS+=(--uninstall)
elif [[ "${UPDATE}" -eq 1 ]]; then
  ARGS+=(--update)
fi

echo "Running upstream HelixScreen installer ${ARGS[*]:-}…"
# Official installer is POSIX sh; runs platform detect + downloads release zip
sh "${INSTALLER}" ${ARGS[@]+"${ARGS[@]}"}

# Groups for input/video (touch + DRM); re-login may be required
sudo usermod -aG video,input,render,netdev "${USER}" 2>/dev/null || true

# Ensure service is enabled when systemd path was used
if systemctl cat helixscreen.service >/dev/null 2>&1; then
  sudo systemctl enable helixscreen.service 2>/dev/null || true
  sudo systemctl restart helixscreen.service 2>/dev/null || {
    echo "WARN: helixscreen.service failed to start"
    echo "      journalctl -u helixscreen -b --no-pager | tail -80"
  }
fi

echo
echo "=== HelixScreen install finished ==="
echo "  Service:  systemctl status helixscreen"
echo "  Logs:     journalctl -u helixscreen -f"
echo "  Config:   ~/printer_data/config/helixscreen/  (or ~/helixscreen/config/)"
echo "  Wizard:   first boot on the panel → touch, language, Wi‑Fi, Moonraker"
echo "  Docs:     https://helixscreen.org/  |  https://github.com/prestonbrown/helixscreen"
echo "  NOTE: first network still needs one offline path before this install"
echo "        (keyboard nmtui, Ethernet, or MainsailOS boot-partition Wi‑Fi)."
echo "  Reboot once if the panel is blank after install."
