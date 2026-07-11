# Contributing to magneto-x

Community modernization for the Peopoly Magneto X. **Not affiliated with Peopoly.**

## Repos

| Repo | Default branch | Role |
|------|----------------|------|
| [lmambr2/magneto-x](https://github.com/lmambr2/magneto-x) | `master` | Docs, configs, host tooling |
| [lmambr2/magneto-x-klipper](https://github.com/lmambr2/magneto-x-klipper) | `magneto-x` | Host/MCU tree; optional `magneto-x-kalico` |

Read **[AGENTS.md](AGENTS.md)** and **[docs/STATUS.md](docs/STATUS.md)** first.

## Hard rules

1. **Do not open PRs** to Klipper3d/klipper or KalicoCrew with Magneto patches.
2. **No Magmotor / proprietary binaries**, secrets, or printer models in git.
3. Keep Magneto delta **minimal** and marked (`MAGNETO-X-BEGIN/END`, `magneto/MANIFEST.json`).
4. After Klipper tree changes: `python3 scripts/magneto_guard.py` and magneto unit tests.
5. After config or macro changes, run the full gate:

```bash
bash scripts/ci-magneto.sh
```

Pieces: `scripts/check_includes.py`, `scripts/check_config_policy.py` (PRINT_START / KAMP / Orca / Moonraker / SAVE_CONFIG), `scripts/check_md_links.py`, shellcheck, ruff, unittest. Optional: `pre-commit install` (see `.pre-commit-config.yaml`). Dev deps: `pip install -r requirements-dev.txt`.

## Local CI

```bash
bash scripts/ci-magneto.sh
./os/postinstall-magneto.sh --dry-run
./scripts/preflight-magneto.sh   # on printer host
```

## Pull requests

- Prefer small PRs aligned with DESIGN IDs when possible.
- Complete sentences in commit messages.
- Update STATUS.md / CHANGELOG.md when behavior ships.
- Dual-track Klipper changes: land on `magneto-x` and `magneto-x-kalico` (or document track-only).

## Config conventions

- MagXY: `[magneto_linear_motor]` (not shell).
- OriginMove is published default XY; stock XY is alternate include.
- Optional features live under `config/optional/` and stay commented in `printer.cfg`.
