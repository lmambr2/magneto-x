#!/usr/bin/env bash
# Inject Magneto first-boot (HelixScreen + full postinstall) onto a flashed
# MainsailOS rootfs (USB NVMe/SD still attached to the workstation).
#
# Usage (as root):
#   sudo ./os/inject-firstboot-to-image.sh /dev/sda
#   sudo ./os/inject-firstboot-to-image.sh /dev/sda2   # root partition only
#
# After inject: power-off media, seat in Pi, power on with network.
# First boot runs HelixScreen + stack in the background (~15–40 min).
# Log on Pi: /home/pi/firstboot-magneto.log
#
set -euo pipefail

ROOT_REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEV="${1:-}"
PI_USER="${PI_USER:-pi}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0 /dev/sdX" >&2
  exit 1
fi
if [[ -z "$DEV" || ! -b "$DEV" ]]; then
  echo "Pass whole disk (/dev/sda) or root partition (/dev/sda2)" >&2
  exit 2
fi
if [[ "$DEV" == *nvme* && "$DEV" != *usb* ]]; then
  # whole-disk nvme on host is dangerous; allow only if clearly a partition path we won't use
  if [[ ! "$DEV" =~ p[0-9]+$ ]]; then
    echo "REFUSING host-like nvme $DEV" >&2
    exit 1
  fi
fi

# Resolve rootfs partition
ROOTFS=""
if [[ -b "${DEV}2" ]]; then
  ROOTFS="${DEV}2"
  BOOT="${DEV}1"
elif [[ -b "${DEV}p2" ]]; then
  ROOTFS="${DEV}p2"
  BOOT="${DEV}p1"
elif lsblk -n -o FSTYPE "$DEV" 2>/dev/null | grep -q ext4; then
  ROOTFS="$DEV"
  BOOT=""
else
  echo "Could not find ext4 root on $DEV" >&2
  lsblk "$DEV"
  exit 1
fi

MNT="$(mktemp -d /tmp/mos-inject.XXXXXX)"
cleanup() {
  umount "${MNT}/boot" 2>/dev/null || true
  umount "$MNT" 2>/dev/null || true
  rmdir "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

echo "Mounting rootfs $ROOTFS → $MNT"
for _ in 1 2 3 4 5; do
  mount -o rw "$ROOTFS" "$MNT" && break
  sleep 1
done
mountpoint -q "$MNT" || { echo "mount failed"; exit 1; }

HOME_DIR="${MNT}/home/${PI_USER}"
if [[ ! -d "$HOME_DIR" ]]; then
  echo "ERROR: missing ${HOME_DIR}" >&2
  exit 1
fi
ref_uid="$(stat -c %u "$HOME_DIR")"
ref_gid="$(stat -c %g "$HOME_DIR")"

# First-boot scripts
install -d -m 755 "${HOME_DIR}/magneto-firstboot"
install -m 755 "${ROOT_REPO}/os/firstboot-magneto.sh" \
  "${HOME_DIR}/magneto-firstboot/firstboot-magneto.sh"
chown -R "${ref_uid}:${ref_gid}" "${HOME_DIR}/magneto-firstboot"

# systemd unit (system-wide)
install -m 644 "${ROOT_REPO}/os/magneto-firstboot.service" \
  "${MNT}/etc/systemd/system/magneto-firstboot.service"
mkdir -p "${MNT}/etc/systemd/system/multi-user.target.wants"
ln -sfn /etc/systemd/system/magneto-firstboot.service \
  "${MNT}/etc/systemd/system/multi-user.target.wants/magneto-firstboot.service"

# Passwordless sudo for first-boot apt/systemctl (MainsailOS often already has this)
SUDOERS_D="${MNT}/etc/sudoers.d"
mkdir -p "$SUDOERS_D"
cat > "${SUDOERS_D}/010-magneto-firstboot" <<EOF
# Temporary for Magneto first-boot postinstall (HelixScreen + stack).
# Remove after firstboot: sudo rm /etc/sudoers.d/010-magneto-firstboot
${PI_USER} ALL=(ALL) NOPASSWD:ALL
EOF
chmod 440 "${SUDOERS_D}/010-magneto-firstboot"

# Drop a marker so user knows firstboot is armed
mkdir -p "${HOME_DIR}/.config"
echo "armed $(date -Is)" > "${HOME_DIR}/.config/magneto-firstboot-armed"
chown -R "${ref_uid}:${ref_gid}" "${HOME_DIR}/.config"
# ensure "done" marker is absent
rm -f "${HOME_DIR}/.config/magneto-firstboot-done"

# --- Display: force HDMI so stock panel comes up even if EDID is late ---
write_display_config() {
  local cfg="$1"
  [[ -f "$cfg" ]] || return 0
  if ! grep -q 'magneto-display' "$cfg" 2>/dev/null; then
    cat >> "$cfg" <<'EOF'

# --- magneto-display (stock HDMI + USB touch panel) ---
# Force HDMI so the panel is available even if EDID is late.
# Do not hard-code a CVT mode — wrong modeline blanks the stock 7".
hdmi_force_hotplug=1
EOF
    echo "Appended display hints to $cfg"
  else
    echo "Display block already present in $cfg"
  fi
}

if [[ -n "${BOOT:-}" && -b "$BOOT" ]]; then
  mkdir -p "${MNT}/boot"
  if mount -o rw "$BOOT" "${MNT}/boot" 2>/dev/null; then
    write_display_config "${MNT}/boot/config.txt"
    # ensure ssh still enabled
    touch "${MNT}/boot/ssh"
    sync
    umount "${MNT}/boot"
  fi
elif [[ -f "${MNT}/boot/firmware/config.txt" ]]; then
  write_display_config "${MNT}/boot/firmware/config.txt"
elif [[ -f "${MNT}/boot/config.txt" ]]; then
  write_display_config "${MNT}/boot/config.txt"
fi

# Prefer graphical multi-user if available after Helix installs
# (unit only; Helix package sets its own service)

sync
echo
echo "=== Injected Magneto first-boot ==="
echo "  Scripts:  /home/${PI_USER}/magneto-firstboot/"
echo "  Unit:     magneto-firstboot.service (enabled)"
echo "  Sudoers:  /etc/sudoers.d/010-magneto-firstboot (NOPASSWD — remove after install)"
echo "  On boot:  waits for network → clone magneto-x → postinstall (Helix + cam + …)"
echo "  Log:      /home/${PI_USER}/firstboot-magneto.log"
echo
echo "Safe eject: udisksctl power-off -b ${DEV%[0-9]*}  (or whole disk you used)"
echo "Then seat NVMe, power Pi, wait. Panel wizard may appear after Helix finishes."
