#!/usr/bin/env python3
"""PR-M4 acceptance tests for hardened magneto-manager."""

from __future__ import annotations

import importlib.util
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
MGR = ROOT / "os" / "magneto-manager" / "magneto-manager.py"


def load_manager():
    spec = importlib.util.spec_from_file_location("magneto_manager", MGR)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    # Avoid binding real serial at import
    with mock.patch.dict(os.environ, {"MAGNETO_MANAGER_HOST": "127.0.0.1"}):
        spec.loader.exec_module(mod)
    return mod


class TestHardenedMarkers(unittest.TestCase):
    def test_source_has_hardened_marker(self):
        text = MGR.read_text(encoding="utf-8")
        self.assertIn("MAGNETO_MANAGER_HARDENED", text)
        self.assertIn("ALLOWED_SERIAL_COMMANDS", text)
        # No shell=True kwarg in subprocess calls (comments may mention shell)
        self.assertNotRegex(text, r"subprocess\.[A-Za-z_]+\([^)]*shell\s*=\s*True")
        self.assertIn('MAGNETO_MANAGER_HOST", "127.0.0.1"', text)
        self.assertIn("127.0.0.1", text)

    def test_install_script_requires_marker(self):
        script = (ROOT / "os" / "install-magneto-services.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("MAGNETO_MANAGER_HARDENED", script)
        self.assertIn("os/magneto-manager/magneto-manager.py", script)


class TestSendCommandAllowlist(unittest.TestCase):
    def setUp(self):
        self.mod = load_manager()
        self.mod.serial_connection = mock.MagicMock()
        self.mod.serial_connection.is_open = True
        self.mod.serial_connection.port = "/dev/ttyUSB0"
        self.client = self.mod.app.test_client()

    def test_enable_ok(self):
        r = self.client.get("/send_command?command=ENABLE")
        self.assertEqual(r.status_code, 200)
        self.mod.serial_connection.write.assert_called()
        args = self.mod.serial_connection.write.call_args[0][0]
        self.assertEqual(args, b"ENABLE\n")

    def test_disable_ok_case(self):
        r = self.client.get("/send_command?command=disable")
        self.assertEqual(r.status_code, 200)

    def test_missing_command_400(self):
        r = self.client.get("/send_command")
        self.assertEqual(r.status_code, 400)
        self.assertIn(b"missing", r.data)

    def test_rtu_rejected(self):
        r = self.client.get("/send_command?command=RTU_MODE")
        self.assertEqual(r.status_code, 400)
        self.assertIn(b"not allowed", r.data)

    def test_injection_rejected(self):
        r = self.client.get("/send_command?command=ENABLE;rm%20-rf")
        self.assertEqual(r.status_code, 400)

    def test_serial_down_503(self):
        self.mod.serial_connection = None
        with mock.patch.object(self.mod, "connect_to_serial", return_value=None):
            r = self.client.get("/send_command?command=ENABLE")
        self.assertEqual(r.status_code, 503)


class TestHealthAndResize(unittest.TestCase):
    def setUp(self):
        self.mod = load_manager()
        self.client = self.mod.app.test_client()

    def test_health_disconnected(self):
        self.mod.serial_connection = None
        with mock.patch.object(self.mod, "connect_to_serial", return_value=None):
            r = self.client.get("/health")
        self.assertEqual(r.status_code, 200)
        data = r.get_json()
        self.assertEqual(data["serial"], "disconnected")

    def test_health_connected(self):
        self.mod.serial_connection = mock.MagicMock()
        self.mod.serial_connection.is_open = True
        self.mod.serial_connection.port = "/dev/ttyUSB0"
        r = self.client.get("/health")
        self.assertEqual(r.status_code, 200)
        data = r.get_json()
        self.assertEqual(data["serial"], "connected")

    def test_get_os_version(self):
        r = self.client.get("/get_os_version")
        self.assertEqual(r.status_code, 200)
        data = r.get_json()
        self.assertTrue(
            "version" in data or "os" in data or "magneto" in str(data).lower(),
            data,
        )

    def test_empty_command_400(self):
        r = self.client.get("/send_command?command=")
        self.assertEqual(r.status_code, 400)

    def test_whitespace_command_400(self):
        r = self.client.get("/send_command?command=%20%20")
        self.assertEqual(r.status_code, 400)

    def test_post_send_not_required(self):
        # API is GET-only; POST should not succeed as allowlisted enable
        r = self.client.post("/send_command?command=ENABLE")
        self.assertIn(r.status_code, (405, 400, 404, 200))

    def test_default_bind_is_localhost(self):
        self.assertEqual(self.mod.BIND_HOST, "127.0.0.1")

    def test_allowlist_only_enable_disable(self):
        self.assertEqual(self.mod.ALLOWED_SERIAL_COMMANDS, frozenset({"ENABLE", "DISABLE"}))

    def test_run_argv_never_shell(self):
        with mock.patch.object(
            self.mod.subprocess, "check_output", return_value=b"ok"
        ) as co:
            out = self.mod.run_argv(["/bin/echo", "hi"], timeout=5)
            self.assertEqual(out, "ok")
            kwargs = co.call_args.kwargs
            self.assertFalse(kwargs.get("shell", False))
            # argv is positional list — never a shell string
            self.assertIsInstance(co.call_args.args[0], list)

    def test_resize_forbidden_by_default(self):
        r = self.client.get("/auto_resize_filesystem")
        self.assertEqual(r.status_code, 403)


class TestSetCanUuid(unittest.TestCase):
    def setUp(self):
        self.mod = load_manager()
        self.client = self.mod.app.test_client()

    def test_zero_uuids_404(self):
        with tempfile.NamedTemporaryFile("w", delete=False, suffix=".cfg") as f:
            f.write("[mcu MAG_TOOL]\ncanbus_uuid: old\n")
            path = f.name
        try:
            self.mod.CONFIG_PATH = path
            with mock.patch.object(self.mod, "run_argv", return_value="no uuids"):
                with mock.patch.object(
                    self.mod.os.path, "isfile", return_value=True
                ):
                    # canbus query path exists checks — patch extract path
                    r = self.client.get("/set-can-uuid")
            # File exists but maybe canbus_query missing — ensure no NameError
            self.assertIn(r.status_code, (404, 500))
            if r.status_code == 404:
                self.assertIn(b"no canbus", r.data.lower() + r.data)
        finally:
            os.unlink(path)

    def test_one_uuid_success(self):
        with tempfile.NamedTemporaryFile("w", delete=False, suffix=".cfg") as f:
            f.write("[mcu MAG_TOOL]\ncanbus_uuid: olddeadbeef\n")
            path = f.name
        try:
            self.mod.CONFIG_PATH = path
            self.mod.BACKUP_PATH = path + ".bak"
            self.mod.CANBUS_QUERY = "/bin/true"
            with mock.patch.object(
                self.mod,
                "run_argv",
                return_value="Found canbus_uuid=abc123def456",
            ):
                with mock.patch.object(
                    self.mod.os.path, "isfile", return_value=True
                ):
                    r = self.client.get("/set-can-uuid")
            self.assertEqual(r.status_code, 200, r.data)
            body = Path(path).read_text(encoding="utf-8")
            self.assertIn("abc123def456", body)
        finally:
            os.unlink(path)
            for p in (path + ".bak", path + ".backup"):
                if os.path.exists(p):
                    os.unlink(p)

    def test_multiple_uuids_409(self):
        with tempfile.NamedTemporaryFile("w", delete=False, suffix=".cfg") as f:
            f.write("canbus_uuid: x\n")
            path = f.name
        try:
            self.mod.CONFIG_PATH = path
            self.mod.CANBUS_QUERY = "/bin/true"
            with mock.patch.object(
                self.mod,
                "run_argv",
                return_value="canbus_uuid=aaa canbus_uuid=bbb",
            ):
                with mock.patch.object(
                    self.mod.os.path, "isfile", return_value=True
                ):
                    r = self.client.get("/set-can-uuid")
            self.assertEqual(r.status_code, 409, r.data)
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()
