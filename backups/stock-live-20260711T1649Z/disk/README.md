# Live disk image attempt (partial)

- **File:** `mmcblk1.img.gz` (~957 MiB compressed)
- **Captured:** 2026-07-11 from `mainsailos` `/dev/mmcblk1` via `sudo dd | gzip -1`
- **Result:** **INCOMPLETE** — `dd` aborted with **Input/output error** after ~3.96 GiB of ~29.1 GiB disk (`944+1` records). `gzip -t` still passes on the partial stream.
- **SHA256:** see `SHA256SUMS`

This is **not** a reliable full-card restore image. Prefer:

1. Peopoly factory OS: https://github.com/lmambr2/magneto-x/releases/tag/peopoly-os-images-archive  
2. File-level live backup: parent directory (`config/`, `auto-uuid/`, host inventory)

If a full `dd` is needed later, use a different card reader/host, check `dmesg` for TF errors, or image offline with the card removed from the OPi.
