#!/usr/bin/env bash
# Flash a MainsailOS image to a USB SD reader.
#
# Usage:
#   BOARD=rpi5     sudo ./os/flash-mainsailos-sd.sh [/dev/sdX]
#   BOARD=opi-zero2 sudo ./os/flash-mainsailos-sd.sh [/dev/sdX]
#   sudo ./os/flash-mainsailos-sd.sh /dev/sdX /path/to/image.img.xz
#
# Default BOARD=rpi5 (Raspberry Pi arm64 — Pi 3/4/5).
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${BOARD:-rpi5}"
IMG_DIR="${ROOT}/backups/mainsailos-images"

declare -A DEFAULT_IMG=(
  [rpi5]="${IMG_DIR}/2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz"
  [rpi]="${IMG_DIR}/2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz"
  [opi-zero2]="${IMG_DIR}/2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz"
  [opi2]="${IMG_DIR}/2026-05-06-MainsailOS-armbian-orangepi_zero2-trixie-3.0.0.img.xz"
)

DEV=""
IMG=""

# Parse: optional device, optional image path
for arg in "$@"; do
  if [[ -b "$arg" ]]; then
    DEV="$arg"
  elif [[ -f "$arg" ]]; then
    IMG="$arg"
  else
    echo "Unknown arg (not a block device or file): $arg" >&2
    exit 2
  fi
done

if [[ -z "${IMG}" ]]; then
  IMG="${DEFAULT_IMG[${BOARD}]:-}"
fi
if [[ -z "${IMG}" || ! -f "${IMG}" ]]; then
  echo "Missing image for BOARD=${BOARD}" >&2
  echo "  expected: ${DEFAULT_IMG[${BOARD}]:-(unknown board)}" >&2
  echo "  download: ./os/download-mainsailos.sh ${BOARD}" >&2
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo BOARD=${BOARD} $0 [/dev/sdX]" >&2
  exit 1
fi

if [[ -z "$DEV" ]]; then
  mapfile -t cands < <(lsblk -dno NAME,SIZE,TRAN,RM,TYPE | awk '
    $3=="usb" && $4==1 && $5=="disk" {
      s=$2; gsub(/G/,"",s);
      if (s+0 >= 14 && s+0 <= 512) print "/dev/"$1
    }')
  if [[ ${#cands[@]} -ne 1 ]]; then
    echo "Could not auto-select device (found ${#cands[@]}). Pass explicitly:" >&2
    lsblk -o NAME,SIZE,TYPE,TRAN,RM,MODEL
    echo "Usage: sudo BOARD=${BOARD} $0 /dev/sdX" >&2
    exit 1
  fi
  DEV="${cands[0]}"
fi

if [[ ! -b "$DEV" ]]; then
  echo "Not a block device: $DEV" >&2
  exit 1
fi

if [[ "$DEV" == *nvme* ]]; then
  echo "REFUSING nvme device $DEV" >&2
  exit 1
fi
if [[ "$DEV" =~ [0-9]$ ]] && [[ ! "$DEV" =~ mmcblk[0-9]+$ ]]; then
  # partitions like sda1 (allow whole-disk mmcblk without trailingp)
  if [[ "$DEV" =~ p[0-9]+$ ]] || [[ "$DEV" =~ sd[a-z][0-9]+$ ]]; then
    echo "REFUSING partition $DEV — pass whole disk (e.g. /dev/sda)" >&2
    exit 1
  fi
fi

BYTES=$(blockdev --getsize64 "$DEV")
# 16GB–512GB cards
if [[ "$BYTES" -lt 14000000000 || "$BYTES" -gt 550000000000 ]]; then
  echo "REFUSING unexpected size ${BYTES} bytes for $DEV" >&2
  lsblk -o NAME,SIZE,TRAN,RM,MODEL "$DEV"
  exit 1
fi

TRAN=$(lsblk -dno TRAN "$DEV" 2>/dev/null || true)
RM=$(lsblk -dno RM "$DEV" 2>/dev/null || true)
if [[ "$TRAN" != "usb" || "$RM" != "1" ]]; then
  echo "REFUSING $DEV (TRAN=$TRAN RM=$RM) — expected removable USB SD reader" >&2
  exit 1
fi

echo "=== SAFETY SUMMARY ==="
echo "Board:  ${BOARD}"
echo "Image:  $IMG"
echo "Target: $DEV ($(numfmt --to=iec "$BYTES")) TRAN=$TRAN"
lsblk -o NAME,SIZE,TYPE,TRAN,RM,MODEL,MOUNTPOINT "$DEV"
echo

if [[ -f "${IMG}.sha256" ]]; then
  echo "Verifying image checksum…"
  (cd "$(dirname "$IMG")" && sha256sum -c "$(basename "$IMG").sha256" 2>/dev/null) \
    || echo "WARN: sha256 -c failed format; continuing if you verified manually"
elif [[ -f "${IMG}.xz.sha256" ]]; then
  (cd "$(dirname "$IMG")" && sha256sum -c "$(basename "$IMG").xz.sha256" 2>/dev/null) || true
fi

for p in "${DEV}"[0-9] "${DEV}"p[0-9]; do
  [[ -b "$p" ]] && umount "$p" 2>/dev/null || true
done

echo
echo "=== WRITING (destroys all data on $DEV) ==="
xzcat "$IMG" | dd of="$DEV" bs=4M status=progress conv=fsync iflag=fullblock
sync
sleep 2
partprobe "$DEV" 2>/dev/null || true
echo
echo "=== DONE ==="
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DEV"
echo "Safe to eject: udisksctl power-off -b $DEV"
echo "Next: docs/RPI5_BRINGUP.md (Pi) or docs/CLEAN_OS_REFRESH.md (OPi)"
