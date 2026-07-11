# Security — shell commands & magneto-manager

## Threat model

| Threat | Impact | Mitigation (shipped) |
|--------|--------|----------------------|
| LAN hits `:8880` ENABLE/DISABLE | MagXY arm without UI | Hardened manager binds **127.0.0.1** |
| Arbitrary serial via stock `/send_command` | RTU mode, junk, bricks | Allowlist **ENABLE/DISABLE** only |
| `shell=True` + user input | Host RCE | Removed; fixed argv only |
| Filesystem resize via HTTP | Disk surprise | 403 unless `MAGNETO_ALLOW_RESIZE=1` |
| `RUN_SHELL_COMMAND PARAMS=` | argv append to curl | **PR-K5** reject PARAMS by default |
| Demo shell cmds / `LINER_*` | Footguns | Not in deployable `config/` |
| Magmotor binaries in git | License / malware vector | **Not redistributed** (D13) |
| Default SSH password | Full host | Change `pi`/`armbian` on first boot |

## Hardened manager (required for clean OS)

Source: `os/magneto-manager/magneto-manager.py`  
Install: `os/install-magneto-services.sh` (refuses unmarked stock copies).

```bash
curl -s http://127.0.0.1:8880/health
# Must fail from another host if firewall/default bind is correct
```

Override bind only if you understand the risk:

```bash
# DANGEROUS — LAN exposure
Environment=MAGNETO_MANAGER_HOST=0.0.0.0
```

## Bridge residual risk (C2)

Stock manager + localhost firewall still allows **any local** process/gcode that can HTTP to 8880 with arbitrary `command=`. Prefer C1 hardened install.

## Shell command policy

- Deploy only `LINEAR_MOTOR_ENABLE` / `DISABLE` / version curl.
- Do not set `allow_params: True` in production configs.
- Prefer manager allowlist over “smarter” macros that pass dynamic PARAMS.

## Operator hygiene

1. Change default SSH password on first boot.  
2. Prefer SSH keys; disable password auth when stable.  
3. Keep Mainsail auth enabled if the printer is on a shared LAN.  
4. Do not commit real CAN UUIDs, Wi‑Fi PSKs, or serial paths to public forks.  
5. Treat gcode from untrusted sources as hostile.

## Reporting

This is a community project. Prefer private disclosure to the repo owner for host RCE issues before public issues.
