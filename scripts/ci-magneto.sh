#!/usr/bin/env bash
# Umbrella CI / local gate: config includes, manager tests, defconfigs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== check_includes =="
python3 scripts/check_includes.py config

echo "== defconfigs =="
bash os/check-defconfigs.sh

echo "== unit tests =="
if [[ -x .venv-test/bin/python ]]; then
  PY=.venv-test/bin/python
elif python3 -c 'import flask' 2>/dev/null; then
  PY=python3
else
  python3 -m venv .venv-test
  .venv-test/bin/pip install -q flask
  PY=.venv-test/bin/python
fi
"$PY" -m unittest discover -s tests -v -p 'test_*.py'

if [[ -d klipper/.git ]] || [[ -f klipper/scripts/magneto_guard.py ]]; then
  echo "== klipper magneto_guard (if tree present) =="
  (cd klipper && python3 scripts/magneto_guard.py && python3 -m unittest discover -s tests/magneto -v) || true
fi

echo "ci-magneto: OK"
