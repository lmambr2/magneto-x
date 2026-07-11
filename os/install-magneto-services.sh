#!/usr/bin/env bash
# Install Peopoly magneto-manager helpers onto a modern MainsailOS/Armbian host.
# Run on the Orange Pi as the klipper user (usually "pi" or "mainsail").
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_UPDATE="${ROOT}/magnetox-os-update/auto-uuid"
DEST_AUTO="${HOME}/auto-uuid"
DEST_MGR="${HOME}/magneto-manager"

if [[ ! -d "${SRC_UPDATE}" ]]; then
  echo "Missing ${SRC_UPDATE}. Clone mypeopoly/magnetox-os-update next to this script's parent."
  exit 1
fi

echo "Installing MagXY helpers from ${SRC_UPDATE}"
mkdir -p "${DEST_AUTO}" "${DEST_MGR}"
cp -a "${SRC_UPDATE}/." "${DEST_AUTO}/"
chmod +x "${DEST_AUTO}"/*.sh 2>/dev/null || true
chmod +x "${DEST_AUTO}/Magmotor" "${DEST_AUTO}/MagnetoWifiHelper" 2>/dev/null || true

# Python manager (prefer repo root magneto-manager-tool if present)
if [[ -f "${ROOT}/magneto-manager-tool/magneto-manager.py" ]]; then
  cp -a "${ROOT}/magneto-manager-tool/magneto-manager.py" "${DEST_MGR}/"
elif [[ -f "${DEST_AUTO}/magneto-manager.py" ]]; then
  cp -a "${DEST_AUTO}/magneto-manager.py" "${DEST_MGR}/"
fi

# Runtime deps
if command -v apt-get >/dev/null; then
  sudo apt-get update
  sudo apt-get install -y python3-flask python3-serial python3-serial-asyncio \
    curl jq \
    libqt5serialport5 libqt5widgets5 libqt5gui5 libqt5core5a || true
fi

# systemd unit for magneto-manager (HTTP :8880)
SERVICE_FILE="/etc/systemd/system/magneto-manager.service"
sudo tee "${SERVICE_FILE}" >/dev/null <<EOF
[Unit]
Description=Magneto X manager (UUID + linear motor serial bridge)
After=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${DEST_MGR}
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
echo "Done. Verify: curl -s http://127.0.0.1:8880/get_os_version"
echo "Magmotor GUI: ${DEST_AUTO}/Magmotor (needs DISPLAY / KlipperScreen session)"
