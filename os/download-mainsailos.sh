#!/usr/bin/env bash
# Download MainsailOS images into backups/mainsailos-images/ (gitignored).
#
# Usage:
#   ./os/download-mainsailos.sh rpi5      # Raspberry Pi arm64 (Pi 3/4/5) — recommended
#   ./os/download-mainsailos.sh opi-zero2
#   ./os/download-mainsailos.sh list
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT}/backups/mainsailos-images"
RELEASE_TAG="${MAINSAILOS_TAG:-3.0.0}"
BASE="https://github.com/mainsail-crew/MainsailOS/releases/download/${RELEASE_TAG}"

# Image basenames for tag 3.0.0 (update when bumping MAINSAILOS_TAG)
declare -A IMAGES=(
  [rpi5]="2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz"
  [rpi]="2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz"
  [opi-zero2]="2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz"
  [opi2]="2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz"
)

BOARD="${1:-}"
if [[ -z "${BOARD}" || "${BOARD}" == "list" || "${BOARD}" == "-h" || "${BOARD}" == "--help" ]]; then
  echo "Usage: $0 <board>"
  echo "Boards:"
  for k in "${!IMAGES[@]}"; do
    echo "  $k  →  ${IMAGES[$k]}"
  done
  echo
  echo "Images land in: ${DEST}"
  echo "Override release: MAINSAILOS_TAG=3.0.0 $0 rpi5"
  exit 0
fi

NAME="${IMAGES[${BOARD}]:-}"
if [[ -z "${NAME}" ]]; then
  echo "Unknown board: ${BOARD} (try: $0 list)" >&2
  exit 2
fi

mkdir -p "${DEST}"
cd "${DEST}"

echo "=== MainsailOS download ==="
echo "  board=${BOARD}"
echo "  file=${NAME}"
echo "  dest=${DEST}"

if [[ ! -f "${NAME}.sha256" ]]; then
  echo "Fetching checksum…"
  curl -fL --progress-bar -o "${NAME}.sha256" "${BASE}/${NAME}.sha256" \
    || curl -fL --progress-bar -o "${NAME}.sha256" "${BASE}/${NAME}.xz.sha256" \
    || true
fi

if [[ -f "${NAME}" ]]; then
  echo "Image already present: ${NAME}"
else
  echo "Downloading (large)…"
  curl -fL --progress-bar -o "${NAME}.partial" "${BASE}/${NAME}"
  mv "${NAME}.partial" "${NAME}"
fi

if [[ -f "${NAME}.sha256" ]]; then
  echo "Verifying…"
  # sha256 file may list bare name or path
  if ! sha256sum -c "${NAME}.sha256" 2>/dev/null; then
    # try matching first field only
    EXP="$(awk 'NF>=1 {print $1; exit}' "${NAME}.sha256")"
    GOT="$(sha256sum "${NAME}" | awk '{print $1}')"
    if [[ -n "${EXP}" && "${EXP}" == "${GOT}" ]]; then
      echo "OK ${NAME}"
    else
      echo "WARN: checksum mismatch or format issue — verify manually" >&2
      echo "  expected=${EXP}"
      echo "  got=${GOT}"
    fi
  fi
else
  echo "WARN: no .sha256 file — skipped verify"
fi

echo
echo "Flash with:"
echo "  BOARD=${BOARD} sudo ./os/flash-mainsailos-sd.sh /dev/sdX"
echo "See docs/RPI5_BRINGUP.md"
