#!/usr/bin/env python3
"""Tests for scripts/check_includes.py — drives the real checker entry points."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SCRIPT = REPO / "scripts" / "check_includes.py"
CONFIG = REPO / "config"


class TestCheckIncludesRealPackage(unittest.TestCase):
    def test_script_exists(self):
        self.assertTrue(SCRIPT.is_file(), f"missing {SCRIPT}")

    def test_real_config_package_passes(self):
        """Gating: package include graph + policy on shipped config/."""
        proc = subprocess.run(
            [sys.executable, str(SCRIPT), str(CONFIG)],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(
            proc.returncode,
            0,
            f"check_includes failed:\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}",
        )
        self.assertIn("All include and policy checks passed", proc.stdout)

    def test_self_test_mode(self):
        proc = subprocess.run(
            [sys.executable, str(SCRIPT), "--self-test"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)
        self.assertIn("self-test OK", proc.stdout)

    def test_missing_include_fails(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "printer.cfg").write_text(
                "[include does_not_exist.cfg]\n", encoding="utf-8"
            )
            # Minimal stubs so policy doesn't drown the include error
            for name in (
                "mainsail.cfg",
                "macros.cfg",
                "shell_command.cfg",
                "magneto_device.cfg",
                "magneto_toolhead.cfg",
                "motion_xy_stock.cfg",
                "README.md",
            ):
                (root / name).write_text("# stub\n", encoding="utf-8")
            (root / "optional").mkdir()
            (root / "optional" / "origin_move.cfg").write_text(
                "[probe]\nspeed: 0.5\n"
                "[stepper_x]\nstep_pin: PF13\n"
                "[stepper_y]\nstep_pin: PG0\n",
                encoding="utf-8",
            )
            (root / "shell_command.cfg").write_text(
                "[gcode_shell_command LINEAR_MOTOR_ENABLE]\ncommand: true\n"
                "[gcode_shell_command LINEAR_MOTOR_DISABLE]\ncommand: true\n",
                encoding="utf-8",
            )
            (root / "motion_xy_stock.cfg").write_text(
                "[probe]\nspeed: 0.5\n", encoding="utf-8"
            )
            proc = subprocess.run(
                [sys.executable, str(SCRIPT), str(root)],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(proc.returncode, 0)
            self.assertIn("missing include", proc.stdout.lower() + proc.stderr.lower())

    def test_hello_world_policy_fails(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            # Copy real package structure is heavy; build minimal valid graph
            (root / "printer.cfg").write_text("[include shell_command.cfg]\n", encoding="utf-8")
            (root / "shell_command.cfg").write_text(
                "[gcode_shell_command LINEAR_MOTOR_ENABLE]\ncommand: true\n"
                "[gcode_shell_command LINEAR_MOTOR_DISABLE]\ncommand: true\n"
                "[gcode_shell_command hello_world]\ncommand: echo hi\n",
                encoding="utf-8",
            )
            for name in (
                "mainsail.cfg",
                "macros.cfg",
                "magneto_device.cfg",
                "magneto_toolhead.cfg",
                "README.md",
            ):
                (root / name).write_text("# stub\n", encoding="utf-8")
            (root / "motion_xy_stock.cfg").write_text(
                "[probe]\nspeed: 0.5\n", encoding="utf-8"
            )
            (root / "optional").mkdir()
            (root / "optional" / "origin_move.cfg").write_text(
                "[probe]\nspeed: 0.5\n"
                "[stepper_x]\nstep_pin: PF13\n"
                "[stepper_y]\nstep_pin: PG0\n",
                encoding="utf-8",
            )
            proc = subprocess.run(
                [sys.executable, str(SCRIPT), str(root)],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(proc.returncode, 0)
            self.assertIn("hello_world", proc.stdout)

    def test_mainsail_without_pause_resume(self):
        text = (CONFIG / "mainsail.cfg").read_text(encoding="utf-8")
        self.assertNotRegex(
            text,
            r"(?m)^\s*\[gcode_macro\s+PAUSE\s*\]",
            "mainsail.cfg must not define PAUSE",
        )
        self.assertNotRegex(
            text,
            r"(?m)^\s*\[gcode_macro\s+RESUME\s*\]",
            "mainsail.cfg must not define RESUME",
        )
        self.assertRegex(
            (CONFIG / "macros.cfg").read_text(encoding="utf-8"),
            r"(?m)^\s*\[gcode_macro\s+PAUSE\s*\]",
        )

    def test_magxy_commented_shells_without_module_fail(self):
        """Commented LINEAR_MOTOR_* stubs must not satisfy MagXY path check."""
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "printer.cfg").write_text(
                "[include shell_command.cfg]\n"
                "[include macros.cfg]\n"
                "[include mainsail.cfg]\n"
                "[include magneto_device.cfg]\n"
                "[include magneto_toolhead.cfg]\n"
                "[include motion_xy_stock.cfg]\n",
                encoding="utf-8",
            )
            (root / "shell_command.cfg").write_text(
                "# [gcode_shell_command LINEAR_MOTOR_ENABLE]\n"
                "# command: curl ...\n"
                "# [gcode_shell_command LINEAR_MOTOR_DISABLE]\n"
                "# command: curl ...\n",
                encoding="utf-8",
            )
            for name in (
                "mainsail.cfg",
                "macros.cfg",
                "magneto_device.cfg",
                "magneto_toolhead.cfg",
                "README.md",
            ):
                (root / name).write_text("# stub\n", encoding="utf-8")
            (root / "motion_xy_stock.cfg").write_text(
                "[probe]\nspeed: 0.5\nz_offset: -0.15\n", encoding="utf-8"
            )
            (root / "optional").mkdir()
            (root / "optional" / "origin_move.cfg").write_text(
                "[probe]\nspeed: 0.5\nz_offset: -0.15\n"
                "[stepper_x]\nstep_pin: PF13\n"
                "[stepper_y]\nstep_pin: PG0\n",
                encoding="utf-8",
            )
            proc = subprocess.run(
                [sys.executable, str(SCRIPT), str(root)],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(proc.returncode, 0, proc.stdout)
            combined = proc.stdout + proc.stderr
            self.assertIn("MagXY path", combined)
            self.assertIn("commented stubs do not count", combined)

    def test_magxy_native_module_passes_without_shells(self):
        """PR-K7 [magneto_linear_motor] is sufficient without shell MagXY."""
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "printer.cfg").write_text(
                "[include shell_command.cfg]\n"
                "[include macros.cfg]\n"
                "[include mainsail.cfg]\n"
                "[include magneto_device.cfg]\n"
                "[include magneto_toolhead.cfg]\n"
                "[include motion_xy_stock.cfg]\n"
                "[magneto_linear_motor]\nbackend: http\n",
                encoding="utf-8",
            )
            (root / "shell_command.cfg").write_text(
                "# optional shells only\n"
                "# [gcode_shell_command LINEAR_MOTOR_ENABLE]\n"
                "# command: true\n"
                "# [gcode_shell_command LINEAR_MOTOR_DISABLE]\n"
                "# command: true\n",
                encoding="utf-8",
            )
            for name in (
                "mainsail.cfg",
                "macros.cfg",
                "magneto_device.cfg",
                "magneto_toolhead.cfg",
                "README.md",
            ):
                (root / name).write_text("# stub\n", encoding="utf-8")
            (root / "motion_xy_stock.cfg").write_text(
                "[probe]\nspeed: 0.5\nz_offset: -0.15\n", encoding="utf-8"
            )
            (root / "optional").mkdir()
            (root / "optional" / "origin_move.cfg").write_text(
                "[probe]\nspeed: 0.5\nz_offset: -0.15\n"
                "[stepper_x]\nstep_pin: PF13\n"
                "[stepper_y]\nstep_pin: PG0\n",
                encoding="utf-8",
            )
            proc = subprocess.run(
                [sys.executable, str(SCRIPT), str(root)],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(
                proc.returncode,
                0,
                f"expected pass with native MagXY:\n{proc.stdout}\n{proc.stderr}",
            )

    def test_probe_speed_band(self):
        for rel in ("motion_xy_stock.cfg", "optional/origin_move.cfg"):
            text = (CONFIG / rel).read_text(encoding="utf-8")
            m = __import__("re").search(
                r"\[probe\](.*?)(?:\n\[|\Z)",
                text,
                __import__("re").I | __import__("re").S,
            )
            self.assertIsNotNone(m, rel)
            sm = __import__("re").search(
                r"^\s*speed\s*[:=]\s*([0-9.]+)", m.group(1), __import__("re").M
            )
            self.assertIsNotNone(sm, rel)
            speed = float(sm.group(1))
            self.assertGreaterEqual(speed, 0.5, rel)
            self.assertLessEqual(speed, 1.0, rel)

    def test_origin_move_driver_swap(self):
        text = (CONFIG / "optional" / "origin_move.cfg").read_text(encoding="utf-8")
        # X section should use PF13 (Driver1), Y PG0 (Driver0)
        self.assertIn("step_pin: PF13", text)
        self.assertIn("step_pin: PG0", text)
        # position_max for X short axis
        self.assertRegex(text, r"\[stepper_x\][\s\S]*?position_max:\s*300")


if __name__ == "__main__":
    unittest.main()
