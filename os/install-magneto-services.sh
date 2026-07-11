#!/usr/bin/env bash
# Install hardened magneto-manager onto a MainsailOS/Armbian host.
# Run as the klipper user (usually "pi").
#
# PR-M4: refuses stock/unhardened manager copies.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HARDENED_SRC="${ROOT}/os/magneto-manager/magneto-manager.py"
DEST_MGR="${HOME}/magneto-manager"
DEST_AUTO="${HOME}/auto-uuid"
WITH_MAGMOTOR=0

for arg in "$@"; do
  case "$arg" in
    --with-magmotor) WITH_MAGMOTOR=1 ;;
    -h|--help)
      echo "Usage: $0 [--with-magmotor]"
      echo "  Installs hardened manager from os/magneto-manager/ only."
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "${HARDENED_SRC}" ]]; then
  echo "ERROR: missing hardened manager at ${HARDENED_SRC}" >&2
  exit 1
fi

if ! grep -q 'MAGNETO_MANAGER_HARDENED' "${HARDENED_SRC}"; then
  echo "ERROR: ${HARDENED_SRC} is not marked hardened (MAGNETO_MANAGER_HARDENED)." >&2
  echo "Refusing to install stock / unhardened magneto-manager." >&2
  exit 1
fi

echo "Installing hardened magneto-manager from ${HARDENED_SRC}"
mkdir -p "${DEST_MGR}"
cp -a "${HARDENED_SRC}" "${DEST_MGR}/magneto-manager.py"
chmod 755 "${DEST_MGR}/magneto-manager.py"

# Optional: Magmotor / helper scripts from local Peopoly tree (not in public git)
if [[ "${WITH_MAGMOTOR}" -eq 1 ]]; then
  SRC_UPDATE="${ROOT}/magnetox-os-update/auto-uuid"
  if [[ ! -d "${SRC_UPDATE}" ]]; then
    echo "ERROR: --with-magmotor requires ${SRC_UPDATE}" >&2
    echo "Clone mypeopoly/magnetox-os-update locally (gitignored)." >&2
    exit 1
  fi
  echo "Copying auto-uuid helpers (including proprietary binaries if present)…"
  mkdir -p "${DEST_AUTO}"
  cp -a "${SRC_UPDATE}/." "${DEST_AUTO}/"
  chmod +x "${DEST_AUTO}"/*.sh 2>/dev/null || true
  chmod +x "${DEST_AUTO}/Magmotor" "${DEST_AUTO}/MagnetoWifiHelper" 2>/dev/null || true
fi

# Runtime deps (no Qt unless --with-magmotor)
if command -v apt-get >/dev/null; then
  sudo apt-get update
  PKGS=(python3-flask python3-serial curl jq)
  if [[ "${WITH_MAGMOTOR}" -eq 1 ]]; then
    PKGS+=(libqt5serialport5 libqt5widgets5 libqt5gui5 libqt5core5a)
  fi
  sudo apt-get install -y "${PKGS[@]}" || true
fi

SERVICE_FILE="/etc/systemd/system/magneto-manager.service"
sudo tee "${SERVICE_FILE}" >/dev/null <<EOF
[Unit]
Description=Magneto X manager (hardened MagXY serial bridge)
After=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${DEST_MGR}
Environment=HOME=${HOME}
Environment=MAGNETO_MANAGER_HOST=127.0.0.1
Environment=MAGNETO_MANAGER_PORT=8880
Environment=MAGNETO_CONFIG_PATH=${HOME}/printer_data/config/magneto_device.cfg
Environment=MAGNETO_KLIPPY_PYTHON=${HOME}/klippy-env/bin/python
Environment=MAGNETO_KLIPPER_DIR=${HOME}/klipper
ExecStart=/usr/bin/python3 ${DEST_MGR}/magneto-manager.py
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now magneto-manager.service
echo "magneto-manager status:"
systemctl --no-pager --full status magneto-manager.service || true

echo
echo "Done (hardened)."
echo "  curl -s http://127.0.0.1:8880/health"
echo "  curl -s 'http://127.0.0.1:8880/send_command?command=ENABLE'"
echo "Bind is 127.0.0.1 — not reachable from LAN by default."
