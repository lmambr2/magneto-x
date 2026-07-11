#!/usr/bin/env python3
"""Hardened Magneto X manager — MagXY serial bridge + UUID helpers.

PR-M4 target API (bind localhost by default):

  GET /send_command?command=ENABLE|DISABLE
  GET /health
  GET /get_os_version
  GET /connect_lm
  GET /get-ip
  GET /get-mcu-uuid  GET /set-mcu-uuid
  GET /get-can-uuid  GET /set-can-uuid

Security:
  - Bind 127.0.0.1 unless MAGNETO_MANAGER_HOST overrides
  - /send_command allowlists ENABLE/DISABLE only
  - No shell=True on request-influenced paths
  - Paths from env / $HOME (no hardcoded /home/pi)

Marker (install script checks this string): MAGNETO_MANAGER_HARDENED=1
"""

from __future__ import annotations

import glob
import os
import re
import shutil
import socket
import subprocess
import sys

from flask import Flask, jsonify, request

# Install script greps for this exact token:
MAGNETO_MANAGER_HARDENED = 1

VERSION_STR = os.environ.get(
    "MAGNETO_MANAGER_VERSION", "magneto-x/hardened-1"
)

HOME = os.path.expanduser("~")
CONFIG_PATH = os.environ.get(
    "MAGNETO_CONFIG_PATH",
    os.path.join(HOME, "printer_data", "config", "magneto_device.cfg"),
)
BACKUP_PATH = CONFIG_PATH + ".bak"

KLIPPY_PYTHON = os.environ.get(
    "MAGNETO_KLIPPY_PYTHON",
    os.path.join(HOME, "klippy-env", "bin", "python"),
)
KLIPPER_SCRIPTS = os.environ.get(
    "MAGNETO_KLIPPER_DIR",
    os.path.join(HOME, "klipper"),
)
CANBUS_QUERY = os.path.join(KLIPPER_SCRIPTS, "scripts", "canbus_query.py")
CAN_IFACE = os.environ.get("MAGNETO_CAN_IFACE", "can0")

BIND_HOST = os.environ.get("MAGNETO_MANAGER_HOST", "127.0.0.1")
BIND_PORT = int(os.environ.get("MAGNETO_MANAGER_PORT", "8880"))

# Serial commands allowed on /send_command (case-insensitive after strip).
ALLOWED_SERIAL_COMMANDS = frozenset({"ENABLE", "DISABLE"})

SERIAL_BAUD = 115200
SERIAL_MATCH = os.environ.get("MAGNETO_SERIAL_MATCH", "USB Serial")

app = Flask(__name__)
serial_connection = None


def connect_to_serial():
    """Open first serial port whose description contains SERIAL_MATCH."""
    try:
        import serial
        import serial.tools.list_ports
    except ImportError:
        app.logger.error("pyserial not installed")
        return None
    for port in serial.tools.list_ports.comports():
        desc = port.description or ""
        if SERIAL_MATCH in desc:
            try:
                return serial.Serial(port.device, SERIAL_BAUD)
            except Exception as exc:
                app.logger.warning("connect %s failed: %s", port.device, exc)
    return None


def ensure_serial():
    """Return open connection; reconnect once if needed."""
    global serial_connection
    if serial_connection is not None:
        try:
            if serial_connection.is_open:
                return serial_connection
        except Exception:
            pass
        try:
            serial_connection.close()
        except Exception:
            pass
        serial_connection = None
    serial_connection = connect_to_serial()
    return serial_connection


def run_argv(argv, timeout=30):
    """Run fixed argv list — never invoke a shell."""
    try:
        out = subprocess.check_output(
            argv,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            shell=False,
        )
        return out.decode("utf-8", errors="replace")
    except subprocess.CalledProcessError as e:
        return e.output.decode("utf-8", errors="replace")
    except FileNotFoundError as e:
        return f"error: {e}"
    except subprocess.TimeoutExpired:
        return "error: command timed out"


def extract_uuids(output):
    return re.findall(r"canbus_uuid=(\w+)", output)


def backup_config(path=None):
    path = path or CONFIG_PATH
    shutil.copy2(path, path + ".backup")
    shutil.copy2(path, BACKUP_PATH)


def set_can_uuid_in_file(path, uuid):
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()
    found = False
    for i, line in enumerate(lines):
        if "canbus_uuid:" in line:
            lines[i] = f"canbus_uuid: {uuid}\n"
            found = True
            break
    if not found:
        lines.append(f"\ncanbus_uuid: {uuid}\n")
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(lines)
        f.flush()
        os.fsync(f.fileno())


def set_mcu_serial_in_file(path, device):
    with open(path, encoding="utf-8") as f:
        content = f.readlines()
    mcu_section = False
    for index, line in enumerate(content):
        if line.strip() == "[mcu]":
            mcu_section = True
            j = index
            while j < len(content) and content[j].strip() != "":
                if content[j].lstrip().startswith("serial:"):
                    content[j] = f"serial: {device}\n"
                    break
                j += 1
            else:
                content.insert(index + 1, f"serial: {device}\n")
            break
    if not mcu_section:
        content.append("\n[mcu]\n")
        content.append(f"serial: {device}\n")
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(content)
        f.flush()
        os.fsync(f.fileno())


@app.route("/health", methods=["GET"])
def health():
    conn = ensure_serial()
    if conn is None:
        return jsonify({"serial": "disconnected", "port": None})
    port = getattr(conn, "port", None)
    return jsonify({"serial": "connected", "port": port})


@app.route("/get_os_version", methods=["GET"])
def get_os_version():
    return jsonify({"version": VERSION_STR})


@app.route("/connect_lm", methods=["GET"])
def connect_lm():
    global serial_connection
    serial_connection = connect_to_serial()
    if serial_connection is None:
        return jsonify({"error": "No device found"}), 503
    return jsonify({"connected": serial_connection.port})


@app.route("/send_command", methods=["GET"])
def send_command():
    raw = request.args.get("command")
    if raw is None or str(raw).strip() == "":
        return jsonify({"error": "missing command"}), 400
    cmd = str(raw).strip().upper()
    # Reject multi-token / injection attempts
    if any(c in cmd for c in ("\n", "\r", ";", "|", "&", " ")):
        return jsonify({"error": "command not allowed"}), 400
    if cmd not in ALLOWED_SERIAL_COMMANDS:
        return jsonify({"error": "command not allowed"}), 400

    conn = ensure_serial()
    if conn is None:
        return jsonify({"error": "Serial port not connected"}), 503
    try:
        conn.write((cmd + "\n").encode("ascii"))
        return jsonify({"suc": "Send success"})
    except Exception:
        # one reconnect retry
        conn = ensure_serial()
        if conn is None:
            return jsonify({"error": "Serial port not connected"}), 503
        try:
            conn.write((cmd + "\n").encode("ascii"))
            return jsonify({"suc": "Send success"})
        except Exception as e:
            return jsonify({"error": f"Send failed: {e}"}), 503


@app.route("/auto_resize_filesystem", methods=["GET"])
def auto_resize_filesystem():
    if os.environ.get("MAGNETO_ALLOW_RESIZE") != "1":
        return (
            jsonify(
                {
                    "error": "resize disabled; set MAGNETO_ALLOW_RESIZE=1 to enable"
                }
            ),
            403,
        )
    # Fixed argv only — no user input
    out = run_argv(
        ["systemctl", "start", "orangepi-resize-filesystem.service"]
    )
    return jsonify({"success": out})


@app.route("/get-ip", methods=["GET"])
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return jsonify({"ip": ip})


@app.route("/get-mcu-uuid", methods=["GET"])
def get_mcu_uuid():
    devices = sorted(glob.glob("/dev/serial/by-id/*"))
    for device in devices:
        if "usb-Klipper" in device or "Klipper_stm32" in device:
            return jsonify({"mcu-uuid": device})
    return jsonify({"error": "No MCU serial device found"}), 404


@app.route("/set-mcu-uuid", methods=["GET"])
def set_mcu_uuid():
    if not os.path.exists(CONFIG_PATH):
        return jsonify({"error": f"Config file not found: {CONFIG_PATH}"}), 404
    devices = sorted(glob.glob("/dev/serial/by-id/*"))
    for device in devices:
        if "usb-Klipper" in device or "Klipper_stm32" in device:
            backup_config()
            set_mcu_serial_in_file(CONFIG_PATH, device)
            return jsonify({"mcu-uuid-success": device})
    return jsonify({"error": "No MCU uuid found"}), 404


@app.route("/get-can-uuid", methods=["GET"])
def get_can_uuid():
    if not os.path.isfile(CANBUS_QUERY):
        return jsonify({"error": f"canbus_query not found: {CANBUS_QUERY}"}), 500
    if not os.path.isfile(KLIPPY_PYTHON):
        # fall back to system python3
        py = sys.executable
    else:
        py = KLIPPY_PYTHON
    output = run_argv([py, CANBUS_QUERY, CAN_IFACE])
    uuids = extract_uuids(output)
    return jsonify({"can-uuids": uuids, "raw": output[-500:]})


@app.route("/set-can-uuid", methods=["GET"])
def set_can_uuid():
    if not os.path.exists(CONFIG_PATH):
        return jsonify({"error": f"{CONFIG_PATH} not found!"}), 404
    if not os.path.isfile(CANBUS_QUERY):
        return jsonify({"error": f"canbus_query not found: {CANBUS_QUERY}"}), 500
    py = KLIPPY_PYTHON if os.path.isfile(KLIPPY_PYTHON) else sys.executable
    output = run_argv([py, CANBUS_QUERY, CAN_IFACE])
    uuids = extract_uuids(output)
    if len(uuids) == 0:
        return jsonify({"error": "no canbus uuid found", "raw": output[-300:]}), 404
    if len(uuids) > 1:
        return (
            jsonify(
                {
                    "error": "multiple canbus uuids; set manually",
                    "can-uuids": uuids,
                }
            ),
            409,
        )
    uuid_to_use = uuids[0]
    backup_config()
    set_can_uuid_in_file(CONFIG_PATH, uuid_to_use)
    return jsonify({"suc": "set canbus uuid successful", "canbus_uuid": uuid_to_use})


def main():
    global serial_connection
    if BIND_HOST in ("0.0.0.0", "::", "[::]"):
        print(
            f"WARNING: MAGNETO_MANAGER_HOST={BIND_HOST} exposes MagXY API on all "
            "interfaces — prefer 127.0.0.1",
            file=sys.stderr,
        )
    serial_connection = connect_to_serial()
    if serial_connection is None:
        print("No MagXY serial device found at start (will retry on send)")
    else:
        print(f"Connected {serial_connection.port}")
    print(
        f"magneto-manager hardened={MAGNETO_MANAGER_HARDENED} "
        f"bind={BIND_HOST}:{BIND_PORT} config={CONFIG_PATH}"
    )
    app.run(host=BIND_HOST, port=BIND_PORT, threaded=True)


if __name__ == "__main__":
    main()
