#!/usr/bin/env python3
"""Magneto X config / package policy linter.

High-signal footguns for the deployable config package, macros, Moonraker
snippets, and Orca start G-code. Exit 0 on pass, 1 on failure.

Usage:
  python3 scripts/check_config_policy.py [repo_root]
  python3 scripts/check_config_policy.py --self-test
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

MACRO_RE = re.compile(
    r"^\s*\[gcode_macro\s+([^\]]+?)\s*\]",
    re.IGNORECASE | re.MULTILINE,
)


def repo_root_from(arg: Path | None) -> Path:
    if arg is not None:
        return arg.resolve()
    return Path(__file__).resolve().parent.parent


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def active_lines(text: str) -> list[str]:
    """Lines that are not full-line comments (strip trailing inline comments not done)."""
    out: list[str] = []
    for line in text.splitlines():
        if line.lstrip().startswith("#"):
            continue
        out.append(line)
    return out


def active_text(text: str) -> str:
    return "\n".join(active_lines(text))


def find_macro_bodies(text: str) -> dict[str, str]:
    """Map macro name -> body text until next [section]."""
    bodies: dict[str, str] = {}
    matches = list(MACRO_RE.finditer(text))
    for i, m in enumerate(matches):
        name = m.group(1).strip()
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        # also stop at non-macro sections
        rest = text[start:end]
        sec = re.search(r"^\s*\[(?!gcode_macro)", rest, re.MULTILINE | re.IGNORECASE)
        if sec:
            rest = rest[: sec.start()]
        bodies[name] = rest
    return bodies


def check_save_config_block(text: str, rel: str = "config") -> list[str]:
    """Validate Klipper #*# SAVE_CONFIG autosave format if present."""
    errors: list[str] = []
    header = (
        "#*# <---------------------- SAVE_CONFIG ---------------------->\n"
        "#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.\n"
        "#*#\n"
    )
    pos = text.find("#*# <---------------------- SAVE_CONFIG")
    if pos < 0:
        return errors

    # Header must match Klipper AUTOSAVE_HEADER structure
    if header.strip() not in text[pos : pos + len(header) + 20].replace("\r\n", "\n"):
        # softer: require first three header lines
        block_start = text[pos:]
        lines = block_start.splitlines()
        if not lines[0].startswith("#*# <---------------------- SAVE_CONFIG"):
            errors.append(f"{rel}: SAVE_CONFIG header line malformed")
        if len(lines) < 3 or "DO NOT EDIT THIS BLOCK" not in lines[1]:
            errors.append(f"{rel}: SAVE_CONFIG missing DO NOT EDIT line")
        if len(lines) < 3 or lines[2].strip() not in ("#*#", "#*# "):
            # allow exact '#*#'
            if len(lines) < 3 or not re.match(r"^#\*#\s*$", lines[2]):
                errors.append(f"{rel}: SAVE_CONFIG header must end with bare #*# line")

    # Every autosave line must start with '#*# ' (hash-star-hash-space) or be empty after header
    in_block = False
    for i, line in enumerate(text.splitlines(), 1):
        if line.startswith("#*# <---------------------- SAVE_CONFIG"):
            in_block = True
            continue
        if not in_block:
            continue
        if not line.strip():
            continue
        if not line.startswith("#*#"):
            errors.append(f"{rel}:{i}: SAVE_CONFIG line must start with #*#")
            continue
        if len(line) >= 4 and not line.startswith("#*# "):
            errors.append(
                f"{rel}:{i}: SAVE_CONFIG line must be '#*# ' + content (space required)"
            )

    # If bed_mesh default present, require version/points/x_count
    if "[bed_mesh default]" in text or "#*# [bed_mesh default]" in text:
        for key in ("version", "points", "x_count", "y_count", "min_x", "max_x"):
            if not re.search(rf"#\*#\s*{key}\s*=", text):
                errors.append(f"{rel}: bed_mesh default missing {key} =")

    return errors


def check_moonraker_snippet(path: Path) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        return [f"missing {path}"]
    text = read(path)
    # Must not have uncommented [update_manager klipper] (v0.8 conflict)
    for i, line in enumerate(text.splitlines(), 1):
        stripped = line.lstrip()
        if stripped.startswith("#"):
            continue
        bare = line.split("#", 1)[0].strip()
        if re.match(r"\[update_manager\s+klipper\]", bare, re.IGNORECASE):
            errors.append(
                f"{path.name}:{i}: active [update_manager klipper] forbidden on "
                f"Moonraker v0.8 (use git remote on ~/klipper instead)"
            )
    # Should mention magneto-x-klipper and the conflict
    if "magneto-x-klipper" not in text and "lmambr2/magneto-x-klipper" not in text:
        errors.append(f"{path.name}: should document lmambr2/magneto-x-klipper remote")
    if "already added" not in text and "v0.8" not in text:
        errors.append(f"{path.name}: should document Moonraker v0.8 klipper conflict")
    return errors


def check_orca_snippets(orca_dir: Path) -> list[str]:
    errors: list[str] = []
    start = orca_dir / "machine_start_gcode.txt"
    end = orca_dir / "machine_end_gcode.txt"
    if not start.is_file():
        errors.append("slicer/orca/machine_start_gcode.txt missing")
        return errors
    st = read(start)
    # Active (non-;-comment) must call PRINT_START with EXTRUDER and BED
    active = [
        ln
        for ln in st.splitlines()
        if ln.strip() and not ln.strip().startswith(";")
    ]
    joined = "\n".join(active)
    if "PRINT_START" not in joined:
        errors.append("orca start G-code must call PRINT_START")
    if not re.search(r"PRINT_START\s+.*EXTRUDER\s*=", joined, re.IGNORECASE | re.DOTALL):
        # allow single line
        if not re.search(r"PRINT_START.*EXTRUDER=", joined, re.IGNORECASE):
            errors.append("orca start G-code must pass EXTRUDER= to PRINT_START")
    if not re.search(r"PRINT_START.*BED=", joined, re.IGNORECASE):
        errors.append("orca start G-code must pass BED= to PRINT_START")
    if end.is_file():
        et = read(end)
        et_active = [
            ln for ln in et.splitlines() if ln.strip() and not ln.strip().startswith(";")
        ]
        if not any("PRINT_END" in ln for ln in et_active):
            errors.append("orca end G-code must call PRINT_END")
    else:
        errors.append("slicer/orca/machine_end_gcode.txt missing")
    return errors


def check_macros(macros_path: Path) -> list[str]:
    errors: list[str] = []
    if not macros_path.is_file():
        return ["macros.cfg missing"]
    text = read(macros_path)
    bodies = find_macro_bodies(text)

    required = (
        "PRINT_START",
        "PRINT_END",
        "FULL_CALIBRATE",
        "FULL_CALIBRATE_BED",
        "MESH_LOAD",
        "LEVEL_BED",
    )
    for name in required:
        if name not in bodies:
            errors.append(f"macros.cfg: missing [gcode_macro {name}]")

    # Exactly zero BED_MESH_CALIBRATE in macros (KAMP owns it)
    bmc = [n for n in bodies if n.upper() == "BED_MESH_CALIBRATE"]
    if bmc:
        errors.append(
            "macros.cfg: must not define BED_MESH_CALIBRATE (owned by KAMP Adaptive_Meshing)"
        )

    ps = bodies.get("PRINT_START", "")
    for token in ("LM_ENABLE", "QUAD_GANTRY_LEVEL", "BED_MESH_CALIBRATE", "LINE_PURGE"):
        if token not in ps:
            errors.append(f"PRINT_START: missing {token}")
    for token in ("params.EXTRUDER", "params.BED", "params.MESH", "params.PURGE"):
        if token not in ps:
            errors.append(f"PRINT_START: missing parametric {token}")
    if "SMART_PARK" not in ps:
        errors.append("PRINT_START: missing SMART_PARK (park near print while nozzle heats)")

    qgl = bodies.get("QUAD_GANTRY_LEVEL", "")
    if "LM_ENABLE" not in qgl:
        errors.append("QUAD_GANTRY_LEVEL: missing LM_ENABLE (bare LEVEL_BED/panel QGL needs MagXY)")
    lb = bodies.get("LEVEL_BED", "")
    if "LM_ENABLE" not in lb and "QUAD_GANTRY_LEVEL" not in lb:
        errors.append("LEVEL_BED: must LM_ENABLE or call QUAD_GANTRY_LEVEL (which enables MagXY)")

    cbm = bodies.get("CREATE_BED_MESH", "")
    if "M190" not in cbm and "params.BED" not in cbm:
        errors.append("CREATE_BED_MESH: should support bed heat (params.BED / M190)")
    if "LM_ENABLE" not in cbm:
        errors.append("CREATE_BED_MESH: missing LM_ENABLE")

    fc = bodies.get("FULL_CALIBRATE", "")
    for token in ("LM_ENABLE", "G28", "QUAD_GANTRY_LEVEL", "BED_MESH_CALIBRATE"):
        if token not in fc:
            errors.append(f"FULL_CALIBRATE: missing {token}")
    if "params.SAVE" not in fc:
        errors.append("FULL_CALIBRATE: missing params.SAVE")
    if "SAVE_CONFIG" not in fc:
        errors.append("FULL_CALIBRATE: missing SAVE_CONFIG path")
    if "M190" not in fc and "params.BED" not in fc:
        errors.append("FULL_CALIBRATE: should support bed heat (params.BED / M190)")

    if "MAGNETO_MANAGER_VERSION" not in bodies:
        errors.append("macros.cfg: missing MAGNETO_MANAGER_VERSION (clear MagXY version macro)")

    pe = bodies.get("PRINT_END", "")
    if "delay_disable_motor" not in pe and "LM_DISABLE" not in pe:
        errors.append("PRINT_END: should schedule MagXY disable")

    # Jinja parse of gcode bodies (best-effort)
    try:
        from jinja2 import BaseLoader, Environment

        env = Environment(loader=BaseLoader())
        for name, body in bodies.items():
            # Extract only gcode: block loosely — entire body is ok for parse of {% %}
            snippets = re.findall(r"\{%.*?%\}|\{\{.*?\}\}", body, re.DOTALL)
            if not snippets and "{%" not in body:
                continue
            try:
                env.parse(body)
            except Exception as e:
                errors.append(f"macros.cfg [{name}]: jinja parse error: {e}")
    except ImportError:
        pass  # jinja2 optional for this check when not installed

    return errors


def check_kamp(config: Path) -> list[str]:
    errors: list[str] = []
    settings = config / "KAMP_Settings.cfg"
    if not settings.is_file():
        return ["KAMP_Settings.cfg missing"]
    text = read(settings)
    # Adaptive_Meshing must be active include
    active = active_text(text)
    if not re.search(
        r"\[include\s+\./KAMP/Adaptive_Meshing\.cfg\]", active, re.IGNORECASE
    ):
        errors.append("KAMP_Settings.cfg: Adaptive_Meshing.cfg must be enabled by default")
    if not re.search(r"\[include\s+\./KAMP/Line_Purge\.cfg\]", active, re.IGNORECASE):
        errors.append("KAMP_Settings.cfg: Line_Purge.cfg must be enabled by default")

    # Only one BED_MESH_CALIBRATE across package (except stock refs)
    bmc_files: list[str] = []
    for path in sorted(config.rglob("*.cfg")):
        if ".stock" in path.name or "stock-v" in path.name:
            continue
        t = read(path)
        if re.search(
            r"^\s*\[gcode_macro\s+BED_MESH_CALIBRATE\s*\]",
            t,
            re.IGNORECASE | re.MULTILINE,
        ):
            bmc_files.append(str(path.relative_to(config)))
    if len(bmc_files) != 1:
        errors.append(
            f"expected exactly one BED_MESH_CALIBRATE macro, found {bmc_files}"
        )
    elif "KAMP/Adaptive_Meshing.cfg" not in bmc_files[0].replace("\\", "/"):
        errors.append(
            f"BED_MESH_CALIBRATE must live in KAMP/Adaptive_Meshing.cfg, found {bmc_files}"
        )
    return errors


def check_printer_cfg(config: Path) -> list[str]:
    errors: list[str] = []
    pc = config / "printer.cfg"
    if not pc.is_file():
        return ["printer.cfg missing"]
    text = read(pc)
    active = active_text(text)

    if not re.search(r"^\s*\[exclude_object\]", active, re.MULTILINE | re.IGNORECASE):
        errors.append("printer.cfg: missing [exclude_object]")
    if not re.search(r"^\s*\[magneto_linear_motor\]", active, re.MULTILINE | re.IGNORECASE):
        errors.append("printer.cfg: missing [magneto_linear_motor]")

    # Exactly one active motion include
    origin = bool(
        re.search(
            r"^\s*\[include\s+optional/origin_move\.cfg\s*\]",
            active,
            re.MULTILINE | re.IGNORECASE,
        )
    )
    stock = bool(
        re.search(
            r"^\s*\[include\s+motion_xy_stock\.cfg\s*\]",
            active,
            re.MULTILINE | re.IGNORECASE,
        )
    )
    if origin == stock:
        errors.append(
            "printer.cfg: enable exactly one of optional/origin_move.cfg "
            f"or motion_xy_stock.cfg (origin={origin}, stock={stock})"
        )

    # Probe speed via included motion file
    motion = (
        config / "optional" / "origin_move.cfg"
        if origin
        else config / "motion_xy_stock.cfg"
    )
    if motion.is_file():
        mt = read(motion)
        m = re.search(r"\[probe\](.*?)(?:\n\[|\Z)", mt, re.IGNORECASE | re.DOTALL)
        if m:
            sm = re.search(r"^\s*speed\s*[:=]\s*([0-9.]+)", m.group(1), re.MULTILINE)
            if sm:
                speed = float(sm.group(1))
                if speed > 0.5:
                    errors.append(
                        f"{motion.name}: probe speed {speed} > 0.5 (load-cell accuracy)"
                    )
            zo = re.search(r"^\s*z_offset\s*[:=]\s*(\S+)", m.group(1), re.MULTILINE)
            if not zo:
                errors.append(f"{motion.name}: [probe] missing z_offset")

    # heater_bed min_temp must not be Peopoly -200 (masks open sensor)
    pc_text = read(pc)
    hm = re.search(
        r"\[heater_bed\](.*?)(?:\n\[|\Z)", pc_text, re.IGNORECASE | re.DOTALL
    )
    if hm:
        mt = re.search(r"^\s*min_temp\s*[:=]\s*(-?[0-9.]+)", hm.group(1), re.MULTILINE)
        if mt and float(mt.group(1)) < 0:
            errors.append(
                f"printer.cfg: heater_bed min_temp {mt.group(1)} < 0 "
                "(use >= 0; Peopoly -200 masks sensor faults)"
            )

    # CANCEL LM_DISABLE in mainsail
    ms = config / "mainsail.cfg"
    if ms.is_file():
        mt = read(ms)
        if "LM_DISABLE" not in mt:
            errors.append("mainsail.cfg: CANCEL_PRINT path should LM_DISABLE MagXY")

    # Timelapse stub or real must define TIMELAPSE_TAKE_FRAME (soft or real)
    tl = config / "timelapse.cfg"
    if tl.is_file():
        tt = read(tl)
        if not re.search(
            r"^\s*\[gcode_macro\s+TIMELAPSE_TAKE_FRAME\s*\]",
            tt,
            re.IGNORECASE | re.MULTILINE,
        ):
            errors.append(
                "timelapse.cfg: must define TIMELAPSE_TAKE_FRAME "
                "(stub no-op or real moonraker-timelapse macros)"
            )

    return errors


def check_manager_source(mgr: Path) -> list[str]:
    errors: list[str] = []
    if not mgr.is_file():
        return ["magneto-manager.py missing"]
    text = read(mgr)
    if "MAGNETO_MANAGER_HARDENED" not in text:
        errors.append("manager: missing MAGNETO_MANAGER_HARDENED marker")
    if "ALLOWED_SERIAL_COMMANDS" not in text:
        errors.append("manager: missing ALLOWED_SERIAL_COMMANDS")
    if re.search(r"subprocess\.[A-Za-z_]+\([^)]*shell\s*=\s*True", text):
        errors.append("manager: shell=True forbidden")
    if 'MAGNETO_MANAGER_HOST", "127.0.0.1"' not in text and (
        'MAGNETO_MANAGER_HOST", \'127.0.0.1\'' not in text
    ):
        # default bind
        if '"127.0.0.1"' not in text:
            errors.append("manager: default bind should prefer 127.0.0.1")
    return errors


def check_defconfigs(repo: Path) -> list[str]:
    """Expand defconfig policy; optional cross-check vs klipper Kconfig."""
    errors: list[str] = []
    octo = repo / "os" / "defconfig-octopus-magneto"
    lan = repo / "os" / "defconfig-lancer-magneto"
    for f in (octo, lan):
        if not f.is_file():
            errors.append(f"missing {f.relative_to(repo)}")
    if lan.is_file():
        t = read(lan)
        if "CONFIG_CANBUS_FREQUENCY=250000" not in t:
            errors.append("lancer defconfig: need CAN 250000")
        if re.search(r"^CONFIG_MAGNETO_RELAX_STEPPER_PAST=y", t, re.MULTILINE):
            errors.append("lancer defconfig: RELAX must not be y")
    if octo.is_file():
        t = read(octo)
        if "CONFIG_MACH_STM32H723=y" not in t:
            errors.append("octopus defconfig: need H723")
        if re.search(r"^CONFIG_MAGNETO_RELAX_STEPPER_PAST=y", t, re.MULTILINE):
            errors.append("octopus defconfig: RELAX must not be y until validated")

    kconfig = repo / "klipper" / "src" / "Kconfig"
    if kconfig.is_file():
        kt = read(kconfig)
        if "MAGNETO" in kt or "magneto" in kt.lower():
            # soft check: relax option documented
            pass
        # If magnet extras Kconfig fragment exists
        for cand in (
            repo / "klipper" / "src" / "magneto" / "Kconfig",
            repo / "klipper" / "magneto" / "Kconfig",
        ):
            if cand.is_file() and "RELAX" in read(cand):
                break
    return errors


def check_md_links(repo: Path, roots: list[Path]) -> list[str]:
    """Relative markdown links must resolve (no network)."""
    errors: list[str] = []
    link_re = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
    for root in roots:
        if not root.exists():
            continue
        paths = [root] if root.is_file() else sorted(root.rglob("*.md"))
        for path in paths:
            if not path.is_file():
                continue
            # skip huge vendor dumps for speed? still useful — vendor archive ok
            text = read(path)
            for m in link_re.finditer(text):
                url = m.group(2).strip()
                if url.startswith(("http://", "https://", "mailto:", "#")):
                    continue
                # strip anchor
                file_part = url.split("#", 1)[0].split("?", 1)[0]
                if not file_part:
                    continue
                target = (path.parent / file_part).resolve()
                try:
                    target.relative_to(repo.resolve())
                except ValueError:
                    # outside repo
                    if not target.exists():
                        errors.append(
                            f"{path.relative_to(repo)}: broken link {url!r}"
                        )
                    continue
                if not target.exists():
                    errors.append(
                        f"{path.relative_to(repo)}: broken relative link {url!r}"
                    )
    return errors


def run_all(repo: Path) -> list[str]:
    repo = repo.resolve()
    config = repo / "config"
    errors: list[str] = []
    errors += check_macros(config / "macros.cfg")
    errors += check_kamp(config)
    errors += check_printer_cfg(config)
    errors += check_moonraker_snippet(config / "moonraker-update-manager.conf.snippet")
    errors += check_orca_snippets(repo / "slicer" / "orca")
    errors += check_manager_source(repo / "os" / "magneto-manager" / "magneto-manager.py")
    errors += check_defconfigs(repo)

    # SAVE_CONFIG on any printer.cfg in package (usually none) + sample fixtures skipped
    for path in config.rglob("*.cfg"):
        t = read(path)
        if "SAVE_CONFIG" in t and "#*#" in t:
            errors += check_save_config_block(t, str(path.relative_to(repo)))

    # Markdown relative links (core docs only — vendor archive often has dead upstream links)
    md_roots = [
        repo / "README.md",
        repo / "CHANGELOG.md",
        repo / "CONTRIBUTING.md",
        repo / "AGENTS.md",
        repo / "docs" / "FAQ.md",
        repo / "docs" / "STATUS.md",
        repo / "docs" / "MIGRATION.md",
        repo / "config" / "README.md",
        repo / "slicer" / "README.md",
        repo / "slicer" / "orca" / "README.md",
    ]
    errors += check_md_links(repo, md_roots)
    return errors


def self_test() -> int:
    import tempfile

    # SAVE_CONFIG format
    good = (
        "foo\n"
        "#*# <---------------------- SAVE_CONFIG ---------------------->\n"
        "#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.\n"
        "#*#\n"
        "#*# [bed_mesh default]\n"
        "#*# version = 1\n"
        "#*# points =\n"
        "#*# \t-0.1, -0.2\n"
        "#*# x_count = 2\n"
        "#*# y_count = 1\n"
        "#*# min_x = 0.0\n"
        "#*# max_x = 1.0\n"
    )
    bad = good.replace("#*# version", "#*#version")  # missing space after #*#
    e1 = check_save_config_block(good, "good")
    if e1:
        print("self-test fail good block", e1)
        return 1
    e2 = check_save_config_block(bad, "bad")
    if not e2:
        print("self-test fail: expected errors on bad block")
        return 1

    with tempfile.TemporaryDirectory() as td:
        # empty policy on empty repo should report missing macros etc.
        root = Path(td)
        errs = run_all(root)
        if not errs:
            print("self-test fail: expected errors on empty repo")
            return 1
    print("self-test OK")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "repo_root",
        nargs="?",
        default=None,
        help="Repository root (default: parent of scripts/)",
    )
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    repo = repo_root_from(Path(args.repo_root) if args.repo_root else None)
    print(f"Policy root: {repo}")
    errors = run_all(repo)
    if errors:
        print("FAILURES:")
        for e in errors:
            print(f"  FAIL  {e}")
        return 1
    print("All config policy checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
