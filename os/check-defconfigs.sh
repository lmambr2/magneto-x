#!/usr/bin/env bash
# PR-M6 / PR-K4: assert defconfig fragments exist and Lancer never enables relax.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OCT="${ROOT}/os/defconfig-octopus-magneto"
LAN="${ROOT}/os/defconfig-lancer-magneto"
fail=0

for f in "$OCT" "$LAN"; do
  if [[ ! -f "$f" ]]; then
    echo "MISSING $f" >&2
    fail=1
  fi
done

if [[ -f "$OCT" ]]; then
  grep -q 'CONFIG_MACH_STM32H723=y' "$OCT" || { echo "Octopus: missing H723"; fail=1; }
  grep -q 'CONFIG_STM32_CLOCK_REF_25M=y' "$OCT" || { echo "Octopus: missing 25M crystal"; fail=1; }
  if grep -qE '^CONFIG_MAGNETO_RELAX_STEPPER_PAST=y' "$OCT"; then
    echo "Octopus: relax must not be y until S3 A/B" >&2
    fail=1
  fi
fi

if [[ -f "$LAN" ]]; then
  grep -q 'CONFIG_CANBUS_FREQUENCY=250000' "$LAN" || { echo "Lancer: need 250000 CAN"; fail=1; }
  if grep -qE '^CONFIG_MAGNETO_RELAX_STEPPER_PAST=y' "$LAN"; then
    echo "Lancer: MAGNETO_RELAX must not be enabled" >&2
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "OK: defconfig fragments"
