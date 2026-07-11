# Project naming (discoverability)

Other Magneto X owners should find this by searching **Magneto**, **Magneto X**, or **MagXY**.

## Official Peopoly (leave alone)

| Repo | Owner |
|------|--------|
| `mypeopoly/Klipper` | Vendor Klipper tree (old base) |
| `mypeopoly/magneto-x-klipper-config` | Vendor configs |
| `mypeopoly/magnetox-os-update` | Vendor OS update package |
| `mypeopoly/magneto-x-os-mirror` | Vendor image tags |

We deliberately use **adjacent but distinct** names so search still hits “magneto-x”, without looking like Peopoly official.

## Our names (settled)

| Role | GitHub name | Branch / notes |
|------|-------------|----------------|
| **Umbrella project** (docs, config, host tooling) | **`magneto-x`** | Default branch `main` |
| **Klipper fork** (modern host + MCU + Magneto extras) | **`magneto-x-klipper`** | Default **`magneto-x`** (Klipper3d); optional **`magneto-x-kalico`** (Kalico A/B) |
| Optional later split | `magneto-x-config` | Only if configs outgrow the umbrella |
| Optional later split | `magneto-x-host` | Only if image/build automation gets large |

### Why these names

- **`magneto-x`** — matches how the printer is sold and how people search Discord/GitHub.
- **`magneto-x-klipper`** — same prefix + role; clear that it is a Klipper tree, not Peopoly’s `Klipper` repo.
- Avoid bare **`klipper`** under a personal account (looks like a random upstream mirror; bad for search and accidental PRs to Klipper3d).
- Avoid **`peopoly-*`** (implies affiliation).
- Suffix **modern** is optional in prose (“Magneto X modern stack”) but **not** required in the repo name; “magneto-x-klipper” already implies community/modern if the README says so.

### GitHub descriptions (copy-paste)

**magneto-x**
```
Community modernization for the Peopoly Magneto X: design docs, printer configs, and Orange Pi host tooling. Not affiliated with Peopoly.
```

**magneto-x-klipper**
```
Modern Klipper for Peopoly Magneto X (MagXY linear motors + Lancer toolhead). Personal/community fork — do not PR these changes to Klipper3d.
```

### Topics / tags (GitHub)

```
3d-printing  klipper  magneto-x  peopoly  magxy  mainsail  orange-pi  fdm
```

### Local paths (this machine)

| Path | Maps to |
|------|---------|
| `Projects/magneto-x/` | Umbrella → GitHub `lmambr2/magneto-x` |
| `Projects/magneto-x/klipper/` | Fork → GitHub `lmambr2/magneto-x-klipper` (rename from `klipper`) |

### Moonraker / KIAUH origin strings (after rename)

```ini
[update_manager klipper]
type: git_repo
path: ~/klipper
origin: https://github.com/lmambr2/magneto-x-klipper.git
primary_branch: magneto-x
# For Kalico A/B track instead:
# primary_branch: magneto-x-kalico
managed_services: klipper
```

See [TRACKS.md](TRACKS.md) for switching and dual-tree A/B.

### Rename on GitHub (when ready)

```bash
# On the Klipper clone currently pointed at lmambr2/klipper:
gh repo rename magneto-x-klipper --repo lmambr2/klipper
git remote set-url origin https://github.com/lmambr2/magneto-x-klipper.git
git push -u origin magneto-x

# Create umbrella repo from this workspace:
# gh repo create lmambr2/magneto-x --public --source=. --remote=origin --push
```

GitHub keeps redirects from the old `klipper` name for a while; still update bookmarks and Moonraker.
