#!/usr/bin/env python3
"""Resolve Klipper [include …] graph for the Magneto X config package.

Exit 0 if every include reachable from printer.cfg (and optional alternate
roots) exists under the package directory. Exit 1 on missing includes or
policy violations in deployable files.

Usage:
  python3 scripts/check_includes.py [config_dir]
  python3 scripts/check_includes.py --self-test
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Active include: allow trailing end-of-line comments after ]
INCLUDE_RE = re.compile(
    r"^\s*\[include\s+([^\]]+?)\]\s*(?:#.*)?$",
    re.IGNORECASE | re.MULTILINE,
)
# Commented include still documents optional paths we may want to verify exist
COMMENTED_INCLUDE_RE = re.compile(
    r"^\s*#\s*\[include\s+([^\]]+?)\]\s*(?:#.*)?$",
    re.IGNORECASE | re.MULTILINE,
)

# Files that are reference-only (not deployable); skipped for policy greps
STOCK_GLOBS = ("*.stock*", "*.stock-*.cfg", "*stock-v*")


def is_stock_reference(path: Path) -> bool:
    name = path.name
    if ".stock" in name or name.endswith(".stock.cfg"):
        return True
    if "stock-v" in name:
        return True
    return False


def resolve_include(base_file: Path, include_arg: str, package_root: Path) -> Path:
    """Resolve an include path relative to the including file, then package root."""
    raw = include_arg.strip().strip('"').strip("'")
    # Klipper resolves relative to the config directory (and nested includes
    # relative to the including file's directory in practice for ./ paths).
    candidates = []
    if raw.startswith("./") or raw.startswith("../"):
        candidates.append((base_file.parent / raw).resolve())
    candidates.append((base_file.parent / raw).resolve())
    candidates.append((package_root / raw).resolve())
    # Also try basename under package root
    candidates.append((package_root / Path(raw).name).resolve())
    for c in candidates:
        try:
            c.relative_to(package_root.resolve())
        except ValueError:
            continue
        if c.is_file():
            return c
    # Prefer package_root-relative path for error messages
    return (package_root / raw).resolve()


def walk_includes(
    package_root: Path,
    entry: str = "printer.cfg",
    follow_commented: bool = False,
) -> tuple[set[Path], list[str]]:
    """Return (resolved_files, missing_include_errors)."""
    package_root = package_root.resolve()
    entry_path = (package_root / entry).resolve()
    errors: list[str] = []
    if not entry_path.is_file():
        return set(), [f"entry missing: {entry_path}"]

    seen: set[Path] = set()
    queue: list[Path] = [entry_path]

    while queue:
        current = queue.pop(0)
        if current in seen:
            continue
        seen.add(current)
        text = current.read_text(encoding="utf-8", errors="replace")
        patterns = [INCLUDE_RE]
        if follow_commented:
            patterns.append(COMMENTED_INCLUDE_RE)
        for pattern in patterns:
            for match in pattern.finditer(text):
                # Skip active includes that are also mid-line comments? INCLUDE_RE
                # already requires line-start optional spaces then [.
                # For active pattern, skip if the line is commented:
                line_start = text.rfind("\n", 0, match.start()) + 1
                line = text[line_start : text.find("\n", match.start())]
                if pattern is INCLUDE_RE and line.lstrip().startswith("#"):
                    continue
                inc = match.group(1).strip()
                target = resolve_include(current, inc, package_root)
                if not target.is_file():
                    errors.append(
                        f"missing include {inc!r} from {current.relative_to(package_root)}"
                    )
                    continue
                if target not in seen:
                    queue.append(target)
    return seen, errors


def _active_section_present(text: str, section: str) -> bool:
    """True if an uncommented [section] or [section …] line exists."""
    pat = re.compile(
        rf"^\s*\[{re.escape(section)}(?:\s+[^\]]*)?\]\s*(?:#.*)?$",
        re.IGNORECASE,
    )
    for line in text.splitlines():
        if line.lstrip().startswith("#"):
            continue
        bare = line.split("#", 1)[0].rstrip()
        if pat.match(bare):
            return True
    return False


def magxy_path_check(package_root: Path, resolved_files: set[Path] | None = None) -> list[str]:
    """MagXY must be reachable via native module and/or *active* shell fallbacks.

    Commented-out [gcode_shell_command LINEAR_MOTOR_*] stubs must not satisfy CI
    (that was a false green when only PR-K7 native MagXY is enabled).
    """
    errors: list[str] = []
    package_root = package_root.resolve()
    has_module = False
    active_shells: set[str] = set()

    # Prefer files in the include graph; fall back to whole package scan
    paths: list[Path]
    if resolved_files:
        paths = sorted(resolved_files)
    else:
        paths = sorted(package_root.rglob("*.cfg"))

    for path in paths:
        if is_stock_reference(path):
            continue
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if _active_section_present(text, "magneto_linear_motor"):
            has_module = True
        for line in text.splitlines():
            if line.lstrip().startswith("#"):
                continue
            bare = line.split("#", 1)[0].strip()
            m = re.match(
                r"\[gcode_shell_command\s+(LINEAR_MOTOR_ENABLE|LINEAR_MOTOR_DISABLE)\s*\]",
                bare,
                re.IGNORECASE,
            )
            if m:
                active_shells.add(m.group(1).upper())

    need = {"LINEAR_MOTOR_ENABLE", "LINEAR_MOTOR_DISABLE"}
    if has_module:
        return errors  # native MagXY is sufficient; shells optional
    if active_shells >= need:
        return errors
    missing = sorted(need - active_shells)
    errors.append(
        "MagXY path: need active [magneto_linear_motor] OR uncommented "
        f"[gcode_shell_command LINEAR_MOTOR_ENABLE/DISABLE] "
        f"(missing active shells: {', '.join(missing)}; "
        "commented stubs do not count)"
    )
    return errors


def policy_check(package_root: Path) -> list[str]:
    """Policy for deployable configs (excludes stock reference files)."""
    errors: list[str] = []
    package_root = package_root.resolve()
    for path in sorted(package_root.rglob("*.cfg")):
        if is_stock_reference(path):
            continue
        # optional/ and stock refs ok; all other .cfg are deployable
        text = path.read_text(encoding="utf-8", errors="replace")
        rel = path.relative_to(package_root)

        if re.search(r"hello_world", text, re.IGNORECASE):
            errors.append(f"{rel}: contains hello_world (demo shell not allowed)")

        # Forbidden: production shell command named LINER_MOTOR_*
        if re.search(
            r"^\s*\[gcode_shell_command\s+LINER_MOTOR_",
            text,
            re.IGNORECASE | re.MULTILINE,
        ):
            errors.append(f"{rel}: defines LINER_MOTOR_* shell command (use LINEAR_*)")

        if path.name == "mainsail.cfg" or path.name == "client.cfg":
            # Active [gcode_macro PAUSE] / RESUME forbidden
            for macro in ("PAUSE", "RESUME"):
                if re.search(
                    rf"^\s*\[gcode_macro\s+{macro}\s*\]",
                    text,
                    re.IGNORECASE | re.MULTILINE,
                ):
                    errors.append(
                        f"{rel}: must not define [gcode_macro {macro}] "
                        f"(owned by macros.cfg)"
                    )

    # Probe speed band on active motion files
    for motion in ("motion_xy_stock.cfg", "optional/origin_move.cfg"):
        mp = package_root / motion
        if not mp.is_file():
            continue
        text = mp.read_text(encoding="utf-8", errors="replace")
        # Find [probe] section speed
        m = re.search(
            r"\[probe\](.*?)(?:\n\[|\Z)",
            text,
            re.IGNORECASE | re.DOTALL,
        )
        if not m:
            errors.append(f"{motion}: missing [probe] section")
            continue
        sm = re.search(r"^\s*speed\s*[:=]\s*([0-9.]+)", m.group(1), re.MULTILINE)
        if not sm:
            errors.append(f"{motion}: [probe] missing speed")
            continue
        speed = float(sm.group(1))
        if speed < 0.5 or speed > 1.0:
            errors.append(
                f"{motion}: probe speed {speed} outside 0.5–1.0 mm/s band"
            )

    # Required files for package
    for req in (
        "printer.cfg",
        "mainsail.cfg",
        "macros.cfg",
        "shell_command.cfg",
        "magneto_device.cfg",
        "magneto_toolhead.cfg",
        "motion_xy_stock.cfg",
        "optional/origin_move.cfg",
        "README.md",
    ):
        if not (package_root / req).is_file():
            errors.append(f"required file missing: {req}")

    # OriginMove pin pattern: X uses PF13 (Driver1), Y uses PG0 (Driver0)
    om = package_root / "optional" / "origin_move.cfg"
    if om.is_file():
        ot = om.read_text(encoding="utf-8", errors="replace")
        if "step_pin: PF13" not in ot and "step_pin:PF13" not in ot:
            errors.append("optional/origin_move.cfg: expected X on Driver1 (PF13)")
        if "step_pin: PG0" not in ot and "step_pin:PG0" not in ot:
            errors.append("optional/origin_move.cfg: expected Y on Driver0 (PG0)")

    return errors


def run_checks(package_root: Path) -> int:
    package_root = package_root.resolve()
    print(f"Package root: {package_root}")
    files, missing = walk_includes(package_root, "printer.cfg", follow_commented=False)
    # Also ensure commented optional origin_move path exists
    _, opt_missing = walk_includes(package_root, "printer.cfg", follow_commented=True)
    # Only keep optional-path misses that are for origin_move
    opt_missing = [e for e in opt_missing if "origin_move" in e or "optional" in e]

    print(f"Resolved {len(files)} file(s) from printer.cfg active includes:")
    for f in sorted(files, key=lambda p: str(p)):
        print(f"  OK  {f.relative_to(package_root)}")

    errors = list(missing) + list(opt_missing) + policy_check(package_root)
    errors.extend(magxy_path_check(package_root, files))

    if errors:
        print("\nFAILURES:")
        for e in errors:
            print(f"  FAIL  {e}")
        return 1
    print("\nAll include and policy checks passed.")
    return 0


def self_test() -> int:
    """Tiny synthetic package exercises the walker."""
    import tempfile

    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        (root / "printer.cfg").write_text(
            "[include a.cfg]  # trailing comment ok\n"
            "# [include optional/b.cfg]\n",
            encoding="utf-8",
        )
        (root / "a.cfg").write_text("# no nested includes\n", encoding="utf-8")
        (root / "optional").mkdir()
        (root / "optional" / "b.cfg").write_text("# empty\n", encoding="utf-8")
        files, missing = walk_includes(root, "printer.cfg", follow_commented=False)
        if missing:
            print("self-test fail: unexpected missing", missing)
            return 1
        if len(files) != 2:
            print("self-test fail: expected 2 files", files)
            return 1
        files2, missing2 = walk_includes(root, "printer.cfg", follow_commented=True)
        if missing2:
            print("self-test fail: commented include missing", missing2)
            return 1
        if len(files2) < 3:
            print("self-test fail: expected optional followed", files2)
            return 1
        # Nested relative include with trailing comment
        (root / "sub").mkdir()
        (root / "printer.cfg").write_text(
            "[include sub/nest.cfg]\n", encoding="utf-8"
        )
        (root / "sub" / "nest.cfg").write_text(
            "[include ./leaf.cfg]   # relative\n", encoding="utf-8"
        )
        (root / "sub" / "leaf.cfg").write_text("# leaf\n", encoding="utf-8")
        files3, missing3 = walk_includes(root, "printer.cfg")
        if missing3 or len(files3) != 3:
            print("self-test fail: relative nest", files3, missing3)
            return 1
        # Missing include detection
        (root / "printer.cfg").write_text("[include nope.cfg]\n", encoding="utf-8")
        _, missing4 = walk_includes(root, "printer.cfg")
        if not missing4:
            print("self-test fail: should report missing nope.cfg")
            return 1
    print("self-test OK")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "config_dir",
        nargs="?",
        default=None,
        help="Path to config package (default: <repo>/config)",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="Run built-in walker self-test and exit",
    )
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    if args.config_dir:
        root = Path(args.config_dir)
    else:
        root = Path(__file__).resolve().parent.parent / "config"
    return run_checks(root)


if __name__ == "__main__":
    sys.exit(main())
