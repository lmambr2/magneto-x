# Full disk image (live unit)

- **File:** `mmcblk1.img.gz` (~957 MiB compressed)
- **Source:** `/dev/mmcblk1` on mainsailos (29.1 GiB TF), crash-consistent live `dd | gzip -1`
- **Captured:** 2026-07-11
- **Not in git** (too large). Keep local or attach to a GitHub Release.

## Restore (destructive)

```bash
# WARNING: wipes target card
gunzip -c mmcblk1.img.gz | sudo dd of=/dev/sdX bs=4M status=progress
sync
```

Prefer Peopoly factory OS images + `../config/` overlay unless you need bit-identical recovery of this exact card.
