#!/usr/bin/env bash
# Pre-flight checks before first LM_ENABLE / S3 validation.
# Run on the printer host as the klipper user. Exit 0 if all critical checks pass.
set -uo pipefail

FAIL=0
WARN=0

ok()   { echo "  OK  $*"; }
warn() { echo "  WARN $*"; WARN=$((WARN + 1)); }
bad()  { echo "  FAIL $*"; FAIL=$((FAIL + 1)); }

echo "=== Magneto X preflight ==="
echo "host=$(hostname) user=$(whoami) date=$(date -u +%Y-%m-%dT%H:%MZ)"
echo

echo "-- USB / serial --"
if command -v lsusb >/dev/null; then
  if lsusb 2>/dev/null | grep -qi '1d50:606f'; then
    ok "gs_usb CAN adapter 1d50:606f present"
  else
    warn "1d50:606f not seen (hub unplugged or different adapter?)"
  fi
  if lsusb 2>/dev/null | grep -qi '1a86:7523\|CH340\|QinHeng'; then
    ok "CH340 / ESP32 serial candidate present"
  else
    warn "no CH340-like device (MagXY ESP32 USB?)"
  fi
  if ls /dev/serial/by-id/usb-Klipper_stm32h723* >/dev/null 2>&1; then
    ok "Octopus Klipper serial by-id present"
  else
    warn "no usb-Klipper_stm32h723* (MCU off / wrong firmware id)"
  fi
else
  warn "lsusb not installed"
fi

echo
echo "-- CAN --"
if ip link show can0 >/dev/null 2>&1; then
  DET=$(ip -d link show can0 2>/dev/null || true)
  if echo "$DET" | grep -q 'bitrate 250000'; then
    ok "can0 up @ 250000"
  else
    bad "can0 present but bitrate not 250000 — check: $DET"
  fi
  QLEN=$(cat /sys/class/net/can0/tx_queue_len 2>/dev/null || echo "?")
  if [[ "$QLEN" -ge 512 ]] 2>/dev/null; then
    ok "can0 txqueuelen=$QLEN"
  else
    warn "can0 txqueuelen=$QLEN (recommend 512: ip link set can0 txqueuelen 512)"
  fi
else
  bad "can0 interface missing"
fi

echo
echo "-- magneto-manager --"
if curl -sf --max-time 2 http://127.0.0.1:8880/health >/dev/null; then
  ok "manager /health responds on 127.0.0.1:8880"
  BODY=$(curl -s --max-time 2 http://127.0.0.1:8880/health || true)
  echo "       $BODY"
else
  bad "manager not reachable at http://127.0.0.1:8880/health"
fi
CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 \
  'http://127.0.0.1:8880/send_command?command=RTU' || echo 000)
if [[ "$CODE" == "400" ]]; then
  ok "manager rejects RTU (hardened allowlist)"
elif [[ "$CODE" == "000" ]]; then
  warn "could not probe allowlist (manager down?)"
else
  warn "send_command RTU returned HTTP $CODE (expect 400 if hardened)"
fi

echo
echo "-- Klipper tree --"
if [[ -f "${HOME}/klipper/klippy/extras/magneto_linear_motor.py" ]]; then
  ok "magneto_linear_motor.py present (PR-K7)"
else
  bad "missing ~/klipper/.../magneto_linear_motor.py — wrong track/clone?"
fi
if [[ -f "${HOME}/klipper/klippy/extras/magneto_load_cell.py" ]]; then
  ok "magneto_load_cell.py present"
else
  bad "missing magneto_load_cell.py"
fi
if [[ -x "${HOME}/klippy-env/bin/python" ]]; then
  ok "klippy-env present"
else
  warn "klippy-env missing"
fi

echo
echo "-- Config package --"
CFG="${HOME}/printer_data/config"
if [[ -f "${CFG}/printer.cfg" ]]; then
  ok "printer.cfg at $CFG"
  if grep -q 'magneto_linear_motor' "${CFG}/printer.cfg" 2>/dev/null; then
    ok "printer.cfg references magneto_linear_motor"
  else
    warn "no magneto_linear_motor in printer.cfg"
  fi
  if grep -qE 'REDACTED|CHANGE_ME|your-serial|xxxxxxxx' "${CFG}/magneto_device.cfg" 2>/dev/null; then
    warn "magneto_device.cfg still has placeholders — fill serial/UUID"
  fi
else
  bad "no $CFG/printer.cfg"
fi

echo
echo "-- Services --"
for s in klipper moonraker magneto-manager; do
  if systemctl is-active --quiet "$s" 2>/dev/null; then
    ok "systemctl $s active"
  else
    warn "systemctl $s not active"
  fi
done

echo
if [[ "$FAIL" -eq 0 ]]; then
  echo "RESULT: PASS ($WARN warning(s)) — safe to try FIRMWARE_RESTART / LM_ENABLE carefully"
  exit 0
else
  echo "RESULT: FAIL ($FAIL failure(s), $WARN warning(s)) — fix before motion"
  exit 1
fi
