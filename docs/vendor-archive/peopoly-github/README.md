# Peopoly GitHub / release archive

Frozen copies of **public** Peopoly Magneto X software as of the catalog date.

## Layout

| Path | Contents |
|------|----------|
| [CATALOG.md](CATALOG.md) | Repo HEADs, OS image Release URLs, Drive firmware links |
| `repos/*.bundle` | `git bundle` of Peopoly repos (restore: `git clone foo.bundle`) |
| `repos/*-tree.tar.gz` | Working-tree snapshots (includes files as published) |
| `checksums/SHA256SUMS` | Hashes of archived artifacts |

## OS images (~1.1 GB each)

**Not stored in this git tree.** Upstream:

https://github.com/mypeopoly/magneto-x-os-mirror/releases

To mirror onto *our* project without bloating clones:

```bash
# example: latest published image
curl -L -O https://github.com/mypeopoly/magneto-x-os-mirror/releases/download/magneto-x-mainsailOS-2024-4-8-v1.1.1/magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz
sha256sum magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz
gh release create peopoly-os-mirror-v1.1.1 ./magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz \
  --repo lmambr2/magneto-x
```

## Gaps vs a live printer dump

| Have from Peopoly public sources | Still need SSH / device |
|----------------------------------|-------------------------|
| OS images through **v1.1.1** | Machine may be **v1.1.3** (online update) |
| Stock configs, manager source, Magmotor ELFs as published | Your calibrated printer.cfg / UUIDs |
| Peopoly Klipper git tree | Built MCU `.bin` currently in flash |
| ESP32 tool-esptool stubs | Full field ESP32 dump if different |
| Wiki + Drive **links** for Octopus/Lancer FW | Actual Drive downloads (fragile; grab while they live) |

## Restore a git bundle

```bash
git clone docs/vendor-archive/peopoly-github/repos/magnetox-os-update.bundle magnetox-os-update-restored
```

## License / provenance

Artifacts originated from Peopoly public GitHub and wiki. Archived for interoperability and preservation of purchased hardware support files. Magmotor/MagnetoWifiHelper are **omitted** from public tree tarballs (proprietary). Git bundles may still historically reference them; do not re-add binaries.
