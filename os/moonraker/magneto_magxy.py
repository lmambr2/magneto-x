# Moonraker component: MagXY ENABLE/DISABLE proxy (PR-A8 lite)
#
# Optional alternative to calling magneto-manager only from Klipper.
# Preferred path remains [magneto_linear_motor] in Klipper (PR-K7).
#
# Install:
#   mkdir -p ~/moonraker/moonraker/components
#   cp os/moonraker/magneto_magxy.py ~/moonraker/moonraker/components/
#   # or: ln -s ~/magneto-x/os/moonraker/magneto_magxy.py \
#   #          ~/moonraker/moonraker/components/magneto_magxy.py
# moonraker.conf:
#   [magneto_magxy]
#   manager_url: http://127.0.0.1:8880
#
# Endpoints (GET):
#   /server/magneto_magxy/status
#   /server/magneto_magxy/enable
#   /server/magneto_magxy/disable
#   /server/magneto_magxy/health
#
# Only ENABLE/DISABLE are forwarded — same allowlist spirit as hardened manager.

from __future__ import annotations

import logging
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Dict

# Moonraker loads components from moonraker.components.*


class MagnetoMagxy:
    def __init__(self, config: Any) -> None:
        self.server = config.get_server()
        self.manager_url = (
            config.get("manager_url", "http://127.0.0.1:8880").rstrip("/")
        )
        self.timeout = config.getfloat("timeout", 3.0)
        self.server.register_endpoint(
            "/server/magneto_magxy/status", ["GET"], self._handle_status
        )
        self.server.register_endpoint(
            "/server/magneto_magxy/enable", ["GET", "POST"], self._handle_enable
        )
        self.server.register_endpoint(
            "/server/magneto_magxy/disable", ["GET", "POST"], self._handle_disable
        )
        self.server.register_endpoint(
            "/server/magneto_magxy/health", ["GET"], self._handle_health
        )
        logging.info(
            "magneto_magxy: proxy → %s (optional A8; prefer Klipper magneto_linear_motor)",
            self.manager_url,
        )

    def _http(self, path: str, query: Dict[str, str] | None = None):
        q = ("?" + urllib.parse.urlencode(query)) if query else ""
        url = f"{self.manager_url}{path}{q}"
        try:
            with urllib.request.urlopen(url, timeout=self.timeout) as resp:
                body = resp.read().decode("utf-8", errors="replace")
                return resp.getcode(), body
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", errors="replace")
            return e.code, body
        except Exception as e:
            return 503, str(e)

    async def _handle_status(self, web_request):
        return {
            "manager_url": self.manager_url,
            "note": "Prefer [magneto_linear_motor] in Klipper for MagXY",
        }

    async def _handle_health(self, web_request):
        code, body = self._http("/health")
        return {"http_status": code, "body": body}

    async def _handle_enable(self, web_request):
        code, body = self._http("/send_command", {"command": "ENABLE"})
        if code != 200:
            raise self.server.error(f"ENABLE failed HTTP {code}: {body}", code)
        return {"result": "ok", "body": body}

    async def _handle_disable(self, web_request):
        code, body = self._http("/send_command", {"command": "DISABLE"})
        if code != 200:
            raise self.server.error(f"DISABLE failed HTTP {code}: {body}", code)
        return {"result": "ok", "body": body}


def load_component(config: Any) -> MagnetoMagxy:
    return MagnetoMagxy(config)
