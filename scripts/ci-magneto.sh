#!/usr/bin/env bash
# Umbrella CI / local gate: config includes, policy, lint, unit tests, defconfigs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== check_includes =="
python3 scripts/check_includes.py config

echo "== check_config_policy =="
python3 scripts/check_config_policy.py "$ROOT"

echo "== check_md_links =="
python3 scripts/check_md_links.py "$ROOT"

echo "== defconfigs =="
bash os/check-defconfigs.sh

echo "== postinstall dry-run =="
bash os/postinstall-magneto.sh --dry-run

echo "== shell syntax (bash -n) =="
for sh in scripts/*.sh os/*.sh; do
  [[ -f "$sh" ]] || continue
  bash -n "$sh"
  echo "  OK  $sh"
done

echo "== shellcheck (if installed) =="
if command -v shellcheck >/dev/null 2>&1; then
  # SC1091: sourced files may be host-only; SC2317: unreachable in dry-run branches
  shellcheck -x -e SC1091,SC2317 scripts/*.sh os/*.sh
  echo "  OK  shellcheck"
else
  echo "  SKIP  shellcheck not installed (apt/brew install shellcheck)"
fi

echo "== ruff (if installed) =="
if command -v ruff >/dev/null 2>&1; then
  ruff check os/magneto-manager scripts tests
  echo "  OK  ruff"
elif [[ -x .venv-test/bin/ruff ]]; then
  .venv-test/bin/ruff check os/magneto-manager scripts tests
  echo "  OK  ruff (.venv-test)"
else
  echo "  SKIP  ruff not installed (pip install ruff)"
fi

echo "== unit tests =="
if [[ -x .venv-test/bin/python ]]; then
  PY=.venv-test/bin/python
elif python3 -c 'import flask' 2>/dev/null; then
  PY=python3
else
  python3 -m venv .venv-test
  .venv-test/bin/pip install -q -r requirements-dev.txt
  PY=.venv-test/bin/python
fi
# Ensure jinja2 for macro parse tests when using bare flask-only env
"$PY" -c 'import jinja2' 2>/dev/null || "$PY" -m pip install -q jinja2
"$PY" -m unittest discover -s tests -v -p 'test_*.py'

if [[ -d klipper/.git ]] || [[ -f klipper/scripts/magneto_guard.py ]]; then
  echo "== klipper magneto_guard (if tree present) =="
  (cd klipper && python3 scripts/magneto_guard.py && python3 -m unittest discover -s tests/magneto -v) || true
fi

echo "ci-magneto: OK"
