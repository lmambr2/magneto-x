#!/usr/bin/env python3
"""Macro smoke tests + config policy / Orca / SAVE_CONFIG checkers."""

from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "scripts"))

import check_config_policy as policy  # noqa: E402

MACROS = REPO / "config" / "macros.cfg"
POLICY = REPO / "scripts" / "check_config_policy.py"


class TestMacroDefinitions(unittest.TestCase):
    def setUp(self):
        self.text = MACROS.read_text(encoding="utf-8")
        self.bodies = policy.find_macro_bodies(self.text)

    def test_required_macros_present(self):
        for name in (
            "PRINT_START",
            "PRINT_END",
            "FULL_CALIBRATE",
            "FULL_CALIBRATE_BED",
            "MESH_LOAD",
        ):
            self.assertIn(name, self.bodies, f"missing {name}")

    def test_no_bed_mesh_calibrate_in_macros(self):
        self.assertNotIn("BED_MESH_CALIBRATE", self.bodies)

    def test_print_start_parametric_and_path(self):
        ps = self.bodies["PRINT_START"]
        for tok in (
            "LM_ENABLE",
            "QUAD_GANTRY_LEVEL",
            "BED_MESH_CALIBRATE",
            "LINE_PURGE",
            "SMART_PARK",
            "params.EXTRUDER",
            "params.BED",
            "params.MESH",
            "params.PURGE",
        ):
            self.assertIn(tok, ps, f"PRINT_START missing {tok}")

    def test_create_bed_mesh_heats(self):
        cbm = self.bodies["CREATE_BED_MESH"]
        self.assertIn("LM_ENABLE", cbm)
        self.assertIn("params.BED", cbm)
        self.assertIn("M190", cbm)
        self.assertIn("BED_MESH_CALIBRATE", cbm)

    def test_manager_version_macro(self):
        self.assertIn("MAGNETO_MANAGER_VERSION", self.bodies)
        self.assertIn("MAGNETO_LINEAR_VERSION", self.bodies["MAGNETO_MANAGER_VERSION"])

    def test_full_calibrate_path(self):
        fc = self.bodies["FULL_CALIBRATE"]
        for tok in (
            "LM_ENABLE",
            "G28",
            "QUAD_GANTRY_LEVEL",
            "BED_MESH_CALIBRATE",
            "params.SAVE",
            "SAVE_CONFIG",
        ):
            self.assertIn(tok, fc, f"FULL_CALIBRATE missing {tok}")

    def test_qgl_and_level_bed_enable_magxy(self):
        qgl = self.bodies["QUAD_GANTRY_LEVEL"]
        self.assertIn("LM_ENABLE", qgl)
        self.assertIn("QUAD_GANTRY_LEVEL_BASE", qgl)
        lb = self.bodies["LEVEL_BED"]
        self.assertTrue(
            "LM_ENABLE" in lb or "QUAD_GANTRY_LEVEL" in lb,
            "LEVEL_BED must arm MagXY",
        )

    def test_full_calibrate_bed_aliases(self):
        body = self.bodies["FULL_CALIBRATE_BED"]
        self.assertIn("FULL_CALIBRATE", body)

    def test_jinja_parses(self):
        try:
            from jinja2 import BaseLoader, Environment
        except ImportError:
            self.skipTest("jinja2 not installed")
        env = Environment(loader=BaseLoader())
        for name, body in self.bodies.items():
            if "{%" not in body and "{{" not in body:
                continue
            try:
                env.parse(body)
            except Exception as e:
                self.fail(f"{name}: {e}")


class TestSaveConfigFormat(unittest.TestCase):
    def test_good_block(self):
        good = (
            "prefix\n"
            "#*# <---------------------- SAVE_CONFIG ---------------------->\n"
            "#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.\n"
            "#*#\n"
            "#*# [bed_mesh default]\n"
            "#*# version = 1\n"
            "#*# points =\n"
            "#*# \t-0.1, 0.2\n"
            "#*# x_count = 2\n"
            "#*# y_count = 1\n"
            "#*# min_x = 0.0\n"
            "#*# max_x = 10.0\n"
        )
        self.assertEqual(policy.check_save_config_block(good), [])

    def test_missing_space_after_hash(self):
        bad = (
            "#*# <---------------------- SAVE_CONFIG ---------------------->\n"
            "#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.\n"
            "#*#\n"
            "#*#[bed_mesh default]\n"
        )
        errs = policy.check_save_config_block(bad, "t")
        self.assertTrue(any("space required" in e for e in errs), errs)

    def test_freeform_comment_corrupts(self):
        # lines must still be #*#  — freeform text after #*# is ok for line prefix
        # but missing #*# space is the footgun we hit
        text = (
            "#*# <---------------------- SAVE_CONFIG ---------------------->\n"
            "#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.\n"
            "#*#\n"
            "#*# Restored from log without space? wait\n"  # has space — ok as junk key
            "#*# [bed_mesh default]\n"
            "#*# version = 1\n"
            "#*# points =\n"
            "#*# x_count = 1\n"
            "#*# y_count = 1\n"
            "#*# min_x = 0\n"
            "#*# max_x = 1\n"
        )
        # Should pass prefix rules; missing points rows ok for this checker
        errs = policy.check_save_config_block(text, "t")
        self.assertEqual(errs, [], errs)


class TestOrcaSnippets(unittest.TestCase):
    def test_start_has_print_start_params(self):
        errs = policy.check_orca_snippets(REPO / "slicer" / "orca")
        self.assertEqual(errs, [], errs)


class TestMoonrakerSnippet(unittest.TestCase):
    def test_no_active_update_manager_klipper(self):
        path = REPO / "config" / "moonraker-update-manager.conf.snippet"
        errs = policy.check_moonraker_snippet(path)
        self.assertEqual(errs, [], errs)


class TestPolicyScript(unittest.TestCase):
    def test_repo_policy_passes(self):
        proc = subprocess.run(
            [sys.executable, str(POLICY), str(REPO)],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(
            proc.returncode,
            0,
            f"policy failed:\n{proc.stdout}\n{proc.stderr}",
        )

    def test_self_test(self):
        proc = subprocess.run(
            [sys.executable, str(POLICY), "--self-test"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)


class TestKampSingleOwner(unittest.TestCase):
    def test_adaptive_enabled(self):
        errs = policy.check_kamp(REPO / "config")
        self.assertEqual(errs, [], errs)


if __name__ == "__main__":
    unittest.main()
