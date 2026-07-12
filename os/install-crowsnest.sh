#!/usr/bin/env bash
# Install / enable Crowsnest for the stock Magneto X USB webcam.
#
# Stock hardware: Microdia / UVC 1080p (lab: 0c45:6366) + Mainsail /webcam proxy.
# Part of full-hardware postinstall (default ON).
#
# Usage:
#   ./os/install-crowsnest.sh
#   ./os/install-crowsnest.sh --dry-run
#   ./os/install-crowsnest.sh --configure-only   # conf + moonraker only
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CN_HOME="${CN_HOME:-${HOME}/crowsnest}"
CN_REPO="${CN_REPO:-https://github.com/mainsail-crew/crowsnest.git}"
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
  echo "ERROR: run as pi (or klipper user), not root" >&2
  exit 1
fi

echo "=== Crowsnest / Magneto webcam ==="

# video group for V4L
if command -v groups >/dev/null && ! groups | grep -qw video; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: usermod -aG video ${USER}"
  else
    sudo usermod -aG video "${USER}" || true
    echo "NOTE: added ${USER} to video — re-login recommended"
  fi
fi

# v4l tools for probing
if command -v apt-get >/dev/null; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: apt-get install -y v4l-utils"
  else
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y v4l-utils 2>/dev/null || true
  fi
fi

detect_video_device() {
  local d
  # Prefer by-id if present (stable)
  if [[ -d /dev/v4l/by-id ]]; then
    for d in /dev/v4l/by-id/*-index0; do
      if [[ -e "$d" ]]; then
        echo "$d"
        return 0
      fi
    done
  fi
  # Prefer capture-capable nodes: often video0 is meta, video1 is RGB
  for d in /dev/video1 /dev/video0 /dev/video2; do
    if [[ -c "$d" ]]; then
      if command -v v4l2-ctl >/dev/null; then
        if v4l2-ctl -d "$d" --all 2>/dev/null | grep -qiE 'Video Capture|video capture'; then
          echo "$d"
          return 0
        fi
      else
        echo "$d"
        return 0
      fi
    fi
  done
  # last resort
  for d in /dev/video*; do
    [[ -c "$d" ]] && { echo "$d"; return 0; }
  done
  return 1
}

deploy_conf() {
  local cfg_dest="${HOME}/printer_data/config"
  local src="${ROOT}/config/crowsnest.conf"
  local dest="${cfg_dest}/crowsnest.conf"
  local dev

  if [[ ! -d "${cfg_dest}" ]]; then
    echo "NOTE: ${cfg_dest} missing — create printer_data first"
    return 0
  fi

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: deploy ${src} → ${dest}"
    return 0
  fi

  mkdir -p "${cfg_dest}"
  if [[ -f "${dest}" ]]; then
    cp -a "${dest}" "${dest}.bak.$(date +%Y%m%d%H%M%S)" || true
  fi
  cp -a "${src}" "${dest}"

  if dev="$(detect_video_device)"; then
    # rewrite device: line under [cam 1]
    python3 - "$dest" "$dev" <<'PY'
from pathlib import Path
import sys
p, dev = Path(sys.argv[1]), sys.argv[2]
lines = p.read_text().splitlines(True)
out, in_cam = [], False
for line in lines:
    if line.strip().lower().startswith("[cam "):
        in_cam = True
        out.append(line)
        continue
    if in_cam and line.strip().startswith("["):
        in_cam = False
    if in_cam and line.strip().lower().startswith("device:"):
        out.append(f"device: {dev}\n")
        continue
    out.append(line)
p.write_text("".join(out))
print(f"crowsnest device → {dev}")
PY
  else
    echo "WARN: no /dev/video* yet — conf left at default; plug camera and re-run --configure-only"
  fi

  # Ensure log dir
  mkdir -p "${HOME}/printer_data/logs"
}

ensure_moonraker_webcam() {
  local mr="${HOME}/printer_data/config/moonraker.conf"
  local snip="${ROOT}/config/moonraker-webcam.conf.snippet"
  if [[ ! -f "${mr}" || ! -f "${snip}" ]]; then
    return 0
  fi
  if grep -qE '^\[webcam ' "${mr}" 2>/dev/null; then
    echo "Moonraker already has [webcam …] — leave as-is"
    return 0
  fi
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: append moonraker webcam snippet to ${mr}"
    return 0
  fi
  {
    echo ""
    echo "# --- Magneto stock USB camera (install-crowsnest.sh) ---"
    cat "${snip}"
  } >> "${mr}"
  echo "Appended [webcam Magneto] to moonraker.conf"
}

if [[ "${CONFIGURE_ONLY}" -eq 1 ]]; then
  deploy_conf
  ensure_moonraker_webcam
  if [[ "${DRY_RUN}" -eq 0 ]]; then
    sudo systemctl restart crowsnest.service 2>/dev/null || true
    sudo systemctl restart moonraker.service 2>/dev/null || true
  fi
  echo "=== configure-only done ==="
  exit 0
fi

# --- install crowsnest if missing ---
if systemctl cat crowsnest.service >/dev/null 2>&1 \
   || [[ -x "${CN_HOME}/bin/crowsnest" ]] \
   || command -v crowsnest >/dev/null 2>&1; then
  echo "Crowsnest already present — configuring only"
else
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "DRY: git clone ${CN_REPO} ${CN_HOME}"
    echo "DRY: CROWSNEST_UNATTENDED=1 sudo -E bash tools/install.sh"
  else
    if [[ ! -d "${CN_HOME}/.git" ]]; then
      git clone --depth 1 "${CN_REPO}" "${CN_HOME}"
    fi
    echo "Running unattended crowsnest installer (may take several minutes)…"
    # Installer expects sudo; run as user with passwordless sudo (MainsailOS pi).
    cd "${CN_HOME}"
    export CROWSNEST_UNATTENDED=1
    export CROWSNEST_ADD_CROWSNEST_MOONRAKER="${CROWSNEST_ADD_CROWSNEST_MOONRAKER:-1}"
    export BASE_USER="${USER}"
    export DEBIAN_FRONTEND=noninteractive
    # tools/install.sh refuses pure root and wants SUDO_USER — use sudo -E
    if sudo -n true 2>/dev/null; then
      sudo -E bash tools/install.sh
    else
      # Interactive sudo password once
      sudo -E bash tools/install.sh
    fi
  fi
fi

deploy_conf
ensure_moonraker_webcam

# Point crowsnest at our conf if it uses a fixed path
# Many installs use ~/printer_data/config/crowsnest.conf already (MainsailOS).
if [[ "${DRY_RUN}" -eq 0 ]]; then
  # Common env file / service drop-in
  if [[ -f /etc/default/crowsnest ]]; then
    if ! grep -q 'printer_data/config/crowsnest.conf' /etc/default/crowsnest 2>/dev/null; then
      echo "NOTE: check /etc/default/crowsnest CROWSNEST_ARGS for conf path"
    fi
  fi
  sudo systemctl enable crowsnest.service 2>/dev/null || true
  sudo systemctl restart crowsnest.service 2>/dev/null || {
    echo "WARN: crowsnest.service failed to start — see: journalctl -u crowsnest -b --no-pager | tail -40"
    echo "      Camera present? lsusb; ls -l /dev/video*"
  }
  sudo systemctl restart moonraker.service 2>/dev/null || true
fi

echo
echo "=== Crowsnest install finished ==="
echo "  Config:  ~/printer_data/config/crowsnest.conf"
echo "  Stream:  http://$(hostname -I 2>/dev/null | awk '{print $1}')/webcam/?action=stream"
echo "  Or:      http://mainsailos.local/webcam/?action=stream"
echo "  Mainsail → Settings → Webcams should list 'Magneto' after moonraker restart"
echo "  Low RAM: keep 1280x720 @ 15fps on Orange Pi Zero 2; raise in conf if free mem allows"
if [[ -c /dev/video0 ]] || [[ -c /dev/video1 ]]; then
  echo "  Devices: $(ls /dev/video* 2>/dev/null | tr '\n' ' ')"
else
  echo "  WARN: no /dev/video* — plug the stock USB camera and re-run:"
  echo "        ./os/install-crowsnest.sh --configure-only"
fi
