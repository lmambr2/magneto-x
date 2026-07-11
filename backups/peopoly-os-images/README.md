# Peopoly official Magneto X OS images (Track A)

Downloaded from https://github.com/mypeopoly/magneto-x-os-mirror/releases

| File | Tag | Notes |
|------|-----|--------|
| magneto-x-mainsailOS-2024-4-8-v1.1.1.img.xz | v1.1.1 | Latest public full image |
| Production-unit-mainsailOS-2024-3-1-v1.1.0.img.xz | v1.1.0 | Production unit image |
| magneto-x-mainsailOS-2024-2-12-v1.0.9.img.xz | v1.0.9 | Earlier public image |

**Not committed to git** (see root `.gitignore`). Mirror via:

```bash
gh release create peopoly-os-images-archive \
  *.img.xz SHA256SUMS README.md \
  --repo lmambr2/magneto-x \
  --title "Peopoly Magneto X OS images (mirror)" \
  --notes "Mirrored from mypeopoly/magneto-x-os-mirror for preservation."
```

Live unit was on **v1.1.3** (online update) — see `backups/stock-live-*`.
