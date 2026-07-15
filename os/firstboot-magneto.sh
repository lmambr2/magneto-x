#!/usr/bin/env bash
# One-shot first boot on a fresh MainsailOS host: clone magneto-x, Magmotor tree,
# run full postinstall (HelixScreen panel, Crowsnest, manager, Shake&Tune, …).
#
# Installed as a systemd oneshot by inject-firstboot-to-image.sh / flash helper.
# Safe to re-run: postinstall is mostly idempotent; this unit disables itself after success.
#
set -euo pipefail

LOG="${HOME}/firstboot-magneto.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== firstboot-magneto $(date -Is) user=$(whoami) ==="

# Wait for network (Wi‑Fi via headless_nm may take a minute)
wait_net() {
  local i
  for i in $(seq 1 90); do
    if ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 \
      || ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 \
      || curl -fsS --connect-timeout 3 https://github.com >/dev/null 2>&1; then
      echo "Network OK after ${i}s"
      return 0
    fi
    sleep 2
  done
  echo "WARN: no network after ~3 min — postinstall will fail without apt/git"
  return 1
}

wait_net || true

# Passwordless sudo for long install (MainsailOS pi often has it; else prompt fails in oneshot)
if ! sudo -n true 2>/dev/null; then
  echo "WARN: passwordless sudo not available — install may hang on apt"
fi

UMBRELLA="${HOME}/magneto-x"
REPO_UMBRELLA="${REPO_UMBRELLA:-https://github.com/lmambr2/magneto-x.git}"
REPO_MAGMOTOR="${REPO_MAGMOTOR:-https://github.com/mypeopoly/magnetox-os-update.git}"

if [[ ! -d "${UMBRELLA}/.git" ]]; then
  git clone "${REPO_UMBRELLA}" "${UMBRELLA}"
else
  git -C "${UMBRELLA}" pull --ff-only || true
fi

# Magmotor local tree (not in public umbrella; auto-detected by postinstall)
if [[ ! -d "${UMBRELLA}/magnetox-os-update/.git" && ! -f "${UMBRELLA}/magnetox-os-update/auto-uuid/Magmotor" ]]; then
  git clone "${REPO_MAGMOTOR}" "${UMBRELLA}/magnetox-os-update" || true
fi

cd "${UMBRELLA}"
# Full stack defaults: HelixScreen, Crowsnest, Shake&Tune, KlipperCortex tree, Magmotor if present
bash ./os/postinstall-magneto.sh

# Tighten sudo after first boot (inject installs NOPASSWD for apt/systemctl)
if [[ -f /etc/sudoers.d/010-magneto-firstboot ]]; then
  sudo rm -f /etc/sudoers.d/010-magneto-firstboot || true
  echo "Removed temporary NOPASSWD sudoers drop-in"
fi

# Mark done
mkdir -p "${HOME}/.config"
date -Is > "${HOME}/.config/magneto-firstboot-done"
echo "=== firstboot-magneto finished $(date -Is) ==="
echo "HelixScreen should own the HDMI panel after reboot if install succeeded."
echo "If panel blank: sudo reboot once; check journalctl -u helixscreen -u magneto-firstboot"
echo "Log: ${LOG}"
