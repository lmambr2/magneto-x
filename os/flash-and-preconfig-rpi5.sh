#!/usr/bin/env bash
# Flash MainsailOS arm64 to a USB-attached Pi 5 NVMe (or SD) and preconfigure
# Wi‑Fi (headless_nm.txt) + SSH (enable + lab authorized_keys).
#
# Usage (run as root; secrets via env, not argv):
#   WIFI_SSID='MyNet' WIFI_PASSWORD='secret' \
#     sudo -E ./os/flash-and-preconfig-rpi5.sh /dev/sdX
#
# Optional env:
#   HOSTNAME=magneto          (default: magneto)
#   WIFI_REGDOMAIN=US         (default: US)
#   WIFI_HIDDEN=false
#   SSH_PUBKEY_FILE=path      (default: ~/.ssh/id_ed25519_magneto.pub of invoking user)
#   IMAGE=path/to.img.xz
#   SKIP_FLASH=1              (only write boot/root preconfig on already-flashed media)
#   PI_USER=pi
#
# Does NOT touch /dev/nvme* on the workstation (use USB enclosure → /dev/sdX).
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG_DEFAULT="${ROOT}/backups/mainsailos-images/2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz"
IMAGE="${IMAGE:-$IMG_DEFAULT}"
HOSTNAME_SET="${HOSTNAME:-magneto}"
WIFI_SSID="${WIFI_SSID:-}"
WIFI_PASSWORD="${WIFI_PASSWORD:-}"
WIFI_REGDOMAIN="${WIFI_REGDOMAIN:-US}"
WIFI_HIDDEN="${WIFI_HIDDEN:-false}"
PI_USER="${PI_USER:-pi}"
SKIP_FLASH="${SKIP_FLASH:-0}"
DEV="${1:-}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: WIFI_SSID=… WIFI_PASSWORD=… sudo -E $0 /dev/sdX" >&2
  exit 1
fi

# Real invoking user for pubkey path (sudo -E keeps env; SUDO_USER for home)
INVOKER="${SUDO_USER:-${USER}}"
INVOKER_HOME="$(getent passwd "$INVOKER" | cut -d: -f6)"
SSH_PUBKEY_FILE="${SSH_PUBKEY_FILE:-${INVOKER_HOME}/.ssh/id_ed25519_magneto.pub}"
if [[ ! -f "$SSH_PUBKEY_FILE" ]]; then
  SSH_PUBKEY_FILE="${INVOKER_HOME}/.ssh/id_ed25519.pub"
fi

if [[ -z "$DEV" || ! -b "$DEV" ]]; then
  echo "Pass whole-disk USB device, e.g. /dev/sda" >&2
  lsblk -o NAME,SIZE,TYPE,TRAN,RM,MODEL,VENDOR
  exit 2
fi

if [[ "$DEV" == *nvme* ]]; then
  echo "REFUSING $DEV — use the USB enclosure path (/dev/sdX), not host NVMe." >&2
  exit 1
fi
if [[ "$DEV" =~ p?[0-9]+$ ]] && [[ ! "$DEV" =~ nvme ]]; then
  if [[ "$DEV" =~ [0-9]$ ]]; then
    echo "REFUSING partition $DEV — pass whole disk (e.g. /dev/sda)" >&2
    exit 1
  fi
fi

TRAN=$(lsblk -dno TRAN "$DEV" 2>/dev/null || true)
if [[ "$TRAN" != "usb" ]]; then
  echo "REFUSING $DEV (TRAN=$TRAN) — expected USB enclosure/reader" >&2
  exit 1
fi

BYTES=$(blockdev --getsize64 "$DEV")
# 16 GB – 2 TiB (NVMe HAT SSDs)
if [[ "$BYTES" -lt 14000000000 || "$BYTES" -gt 2200000000000 ]]; then
  echo "REFUSING unexpected size ${BYTES} for $DEV" >&2
  exit 1
fi

if [[ -z "$WIFI_SSID" || -z "$WIFI_PASSWORD" ]]; then
  echo "Set WIFI_SSID and WIFI_PASSWORD in the environment." >&2
  exit 2
fi
if [[ ! -f "$SSH_PUBKEY_FILE" ]]; then
  echo "Missing SSH public key: $SSH_PUBKEY_FILE" >&2
  exit 2
fi
if [[ ! -f "$IMAGE" ]]; then
  echo "Missing image: $IMAGE" >&2
  echo "  ./os/download-mainsailos.sh rpi5" >&2
  exit 1
fi

PUBKEY="$(tr -d '\r\n' < "$SSH_PUBKEY_FILE")"

echo "=== FLASH + PRECONFIG ==="
echo "Image:    $IMAGE"
echo "Target:   $DEV ($(numfmt --to=iec "$BYTES")) TRAN=$TRAN"
echo "Hostname: $HOSTNAME_SET"
echo "Wi‑Fi:    SSID=${WIFI_SSID} REG=${WIFI_REGDOMAIN} HIDDEN=${WIFI_HIDDEN}"
echo "SSH key:  $SSH_PUBKEY_FILE"
echo "User:     $PI_USER (authorized_keys + ssh enabled)"
lsblk -o NAME,SIZE,TYPE,TRAN,RM,MODEL,MOUNTPOINT "$DEV"
echo

# Unmount any partitions
for p in "${DEV}"[0-9] "${DEV}"p[0-9]; do
  [[ -b "$p" ]] || continue
  umount "$p" 2>/dev/null || true
  udisksctl unmount -b "$p" 2>/dev/null || true
done

if [[ "$SKIP_FLASH" != "1" ]]; then
  if [[ -f "${IMAGE}.sha256" ]]; then
    echo "Verifying checksum…"
    (cd "$(dirname "$IMAGE")" && sha256sum -c "$(basename "$IMAGE").sha256") || true
  fi
  echo "=== WRITING IMAGE (destroys all data on $DEV) ==="
  xzcat "$IMAGE" | dd of="$DEV" bs=4M status=progress conv=fsync iflag=fullblock
  sync
  sleep 2
  partprobe "$DEV" 2>/dev/null || true
  sleep 1
else
  echo "SKIP_FLASH=1 — not rewriting image"
fi

# Resolve partitions (sda1/sda2 or mmcblk0p1 style)
BOOT=""
ROOTFS=""
if [[ -b "${DEV}1" ]]; then
  BOOT="${DEV}1"
  ROOTFS="${DEV}2"
elif [[ -b "${DEV}p1" ]]; then
  BOOT="${DEV}p1"
  ROOTFS="${DEV}p2"
else
  echo "ERROR: no partitions on $DEV after flash" >&2
  lsblk "$DEV"
  exit 1
fi

MNT_BOOT="$(mktemp -d /tmp/mos-boot.XXXXXX)"
MNT_ROOT="$(mktemp -d /tmp/mos-root.XXXXXX)"
cleanup() {
  umount "$MNT_BOOT" 2>/dev/null || true
  umount "$MNT_ROOT" 2>/dev/null || true
  rmdir "$MNT_BOOT" "$MNT_ROOT" 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Mounting boot $BOOT ==="
# FAT often needs a moment
for _ in 1 2 3 4 5; do
  mount -o rw "$BOOT" "$MNT_BOOT" && break
  sleep 1
done
if ! mountpoint -q "$MNT_BOOT"; then
  echo "ERROR: could not mount boot $BOOT" >&2
  exit 1
fi

echo "Boot contents (sample):"
ls "$MNT_BOOT" | head -30

# Enable SSH (Raspberry Pi / MainsailOS convention)
touch "${MNT_BOOT}/ssh"
# Some images use firmware/ subdir layout
if [[ -d "${MNT_BOOT}/firmware" ]]; then
  touch "${MNT_BOOT}/firmware/ssh"
fi

# Hostname (if supported via boot file; also set on rootfs below)
printf '%s\n' "$HOSTNAME_SET" > "${MNT_BOOT}/hostname" 2>/dev/null || true

# MainsailOS >= 2 NetworkManager headless Wi‑Fi
if [[ -f "${MNT_BOOT}/headless_nm.txt.template" ]]; then
  echo "Writing headless_nm.txt from template…"
  # shellcheck disable=SC2016
  sed \
    -e "s/^SSID=.*/SSID=\"${WIFI_SSID//\//\\/}\"/" \
    -e "s/^PASSWORD=.*/PASSWORD=\"${WIFI_PASSWORD//\//\\/}\"/" \
    -e "s/^HIDDEN=.*/HIDDEN=\"${WIFI_HIDDEN}\"/" \
    -e "s/^REGDOMAIN=.*/REGDOMAIN=\"${WIFI_REGDOMAIN}\"/" \
    "${MNT_BOOT}/headless_nm.txt.template" > "${MNT_BOOT}/headless_nm.txt"
else
  echo "No headless_nm.txt.template — writing headless_nm.txt directly…"
  cat > "${MNT_BOOT}/headless_nm.txt" <<EOF
# MainsailOS NetworkManager headless Wi‑Fi (deleted after first apply)
SSID="${WIFI_SSID}"
PASSWORD="${WIFI_PASSWORD}"
HIDDEN="${WIFI_HIDDEN}"
REGDOMAIN="${WIFI_REGDOMAIN}"
EOF
fi

# Also drop classic wpa_supplicant as belt-and-suspenders for some images
cat > "${MNT_BOOT}/wpa_supplicant.conf" <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=${WIFI_REGDOMAIN}
update_config=1

network={
    ssid="${WIFI_SSID}"
    psk="${WIFI_PASSWORD}"
    key_mgmt=WPA-PSK
}
EOF

sync
umount "$MNT_BOOT"
rmdir "$MNT_BOOT"
MNT_BOOT=""

echo "=== Mounting rootfs $ROOTFS ==="
for _ in 1 2 3 4 5; do
  mount -o rw "$ROOTFS" "$MNT_ROOT" && break
  sleep 1
done
if ! mountpoint -q "$MNT_ROOT"; then
  echo "ERROR: could not mount root $ROOTFS" >&2
  exit 1
fi

# Hostname
if [[ -d "${MNT_ROOT}/etc" ]]; then
  printf '%s\n' "$HOSTNAME_SET" > "${MNT_ROOT}/etc/hostname"
  if [[ -f "${MNT_ROOT}/etc/hosts" ]]; then
    if grep -qE '^10\.0\.0\.1|^127\.0\.1\.1' "${MNT_ROOT}/etc/hosts"; then
      sed -i -E "s/^(127\\.0\\.1\\.1)[[:space:]].*/\\1\\t${HOSTNAME_SET}/" "${MNT_ROOT}/etc/hosts" || true
    else
      echo -e "127.0.1.1\t${HOSTNAME_SET}" >> "${MNT_ROOT}/etc/hosts"
    fi
  fi
fi

# SSH authorized_keys for PI_USER
HOME_DIR="${MNT_ROOT}/home/${PI_USER}"
if [[ ! -d "$HOME_DIR" ]]; then
  # fallback: first home dir
  if [[ -d "${MNT_ROOT}/home" ]]; then
    first="$(find "${MNT_ROOT}/home" -mindepth 1 -maxdepth 1 -type d | head -1)"
    if [[ -n "$first" ]]; then
      HOME_DIR="$first"
      PI_USER="$(basename "$first")"
      echo "NOTE: using home $HOME_DIR (user $PI_USER)"
    fi
  fi
fi

if [[ -d "$HOME_DIR" ]]; then
  mkdir -p "${HOME_DIR}/.ssh"
  AUTH="${HOME_DIR}/.ssh/authorized_keys"
  touch "$AUTH"
  if ! grep -qxF "$PUBKEY" "$AUTH" 2>/dev/null; then
    echo "$PUBKEY" >> "$AUTH"
  fi
  chmod 700 "${HOME_DIR}/.ssh"
  chmod 600 "$AUTH"
  # ownership: match existing home uid/gid from image
  ref_uid="$(stat -c %u "$HOME_DIR")"
  ref_gid="$(stat -c %g "$HOME_DIR")"
  chown -R "${ref_uid}:${ref_gid}" "${HOME_DIR}/.ssh"
  echo "Installed authorized_keys for ${PI_USER} (uid ${ref_uid})"
else
  echo "WARN: no /home/${PI_USER} on image — key not installed; password SSH may still work"
fi

# Ensure sshd is enabled if systemd present
if [[ -d "${MNT_ROOT}/etc/systemd/system/multi-user.target.wants" ]]; then
  if [[ -f "${MNT_ROOT}/lib/systemd/system/ssh.service" ]]; then
    ln -sf /lib/systemd/system/ssh.service \
      "${MNT_ROOT}/etc/systemd/system/multi-user.target.wants/ssh.service" 2>/dev/null || true
  fi
  if [[ -f "${MNT_ROOT}/lib/systemd/system/sshd.service" ]]; then
    ln -sf /lib/systemd/system/sshd.service \
      "${MNT_ROOT}/etc/systemd/system/multi-user.target.wants/sshd.service" 2>/dev/null || true
  fi
fi

sync
umount "$MNT_ROOT"
rmdir "$MNT_ROOT"
MNT_ROOT=""
trap - EXIT

echo
echo "=== DONE ==="
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DEV"
echo
echo "Safe to remove: udisksctl power-off -b $DEV"
echo "Then: seat NVMe in M.2 HAT+, power Pi 5 (27W PSU), wait ~2 min for first boot."
echo "SSH:  ssh -i ~/.ssh/id_ed25519_magneto ${PI_USER}@${HOSTNAME_SET}.local"
echo "      # or scan LAN / router for hostname ${HOSTNAME_SET}"
echo "Web:  http://${HOSTNAME_SET}.local/  (Mainsail)"
echo "Next: ./os/postinstall-magneto.sh  (+ local magnetox-os-update for Magmotor)"
echo
echo "Change default password on first login if still raspberry / image default."
