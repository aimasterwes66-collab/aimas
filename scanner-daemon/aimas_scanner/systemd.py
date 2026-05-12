#!/usr/bin/env python3
"""systemd unit generator for AIMAS Scanner Daemon.

Generates user-level and system-level systemd service files
for running the scanner in continuous watch mode.
"""

import os
from pathlib import Path
from typing import Optional


USER_UNIT_DIR = Path.home() / ".config" / "systemd" / "user"
SYSTEM_UNIT_DIR = Path("/etc/systemd/system")


SYSTEMD_UNIT_TEMPLATE = """[Unit]
Description=AIMAS Intent Scanner Daemon
Documentation=https://github.com/aimasterwes66-collab/aimas
After=network.target ollama.service

[Service]
Type=simple
ExecStart={exec_start}
Restart=always
RestartSec=10
Environment="PATH={path}"

[Install]
WantedBy=default.target
"""

TIMER_TEMPLATE = """[Unit]
Description=AIMAS Scanner Periodic Convergence

[Timer]
OnBootSec=60
OnUnitActiveSec={interval}s
AccuracySec=1s

[Install]
WantedBy=timers.target
"""


class SystemdGenerator:
    """Generate and install systemd units for the scanner daemon."""

    def __init__(self, user_mode: bool = True):
        self.user_mode = user_mode
        self.unit_dir = USER_UNIT_DIR if user_mode else SYSTEM_UNIT_DIR

    def generate_service(
        self,
        watch_dir: str = "~/.config/aimas/intent",
        interval: int = 300,
        python_path: Optional[str] = None,
    ) -> str:
        """Generate a systemd service unit string."""
        watch_dir = os.path.expanduser(watch_dir)
        scanner_path = self._find_scanner_path()

        if python_path is None:
            python_path = os.path.expanduser("~/.local/bin/aimas-scanner")
            if not Path(python_path).exists():
                python_path = "python3 -m aimas_scanner"

        exec_start = f"{python_path} --daemon --watch {watch_dir}"
        path_env = os.environ.get("PATH", "/usr/local/bin:/usr/bin:/bin")

        return SYSTEMD_UNIT_TEMPLATE.format(
            exec_start=exec_start,
            path=path_env,
        )

    def generate_timer(self, interval: int = 300) -> str:
        """Generate a systemd timer unit for periodic convergence."""
        return TIMER_TEMPLATE.format(interval=interval)

    def install(self, watch_dir: str = "~/.config/aimas/intent", interval: int = 300) -> None:
        """Write unit files to the appropriate systemd directory."""
        self.unit_dir.mkdir(parents=True, exist_ok=True)

        service_content = self.generate_service(watch_dir, interval)
        timer_content = self.generate_timer(interval)

        service_path = self.unit_dir / "aimas-scanner.service"
        timer_path = self.unit_dir / "aimas-scanner.timer"

        service_path.write_text(service_content)
        timer_path.write_text(timer_content)

        print(f"[SYSTEMD] Installed: {service_path}")
        print(f"[SYSTEMD] Installed: {timer_path}")

        if self.user_mode:
            print("\n# Enable with:")
            print("  systemctl --user daemon-reload")
            print("  systemctl --user enable aimas-scanner.service")
            print("  systemctl --user start aimas-scanner.service")
            print("\n# Or use the timer for periodic runs:")
            print("  systemctl --user enable aimas-scanner.timer")
            print("  systemctl --user start aimas-scanner.timer")
        else:
            print("\n# Enable with:")
            print("  sudo systemctl daemon-reload")
            print("  sudo systemctl enable aimas-scanner.service")
            print("  sudo systemctl start aimas-scanner.service")

    def uninstall(self) -> None:
        """Remove installed unit files."""
        service_path = self.unit_dir / "aimas-scanner.service"
        timer_path = self.unit_dir / "aimas-scanner.timer"

        for p in (service_path, timer_path):
            if p.exists():
                p.unlink()
                print(f"[SYSTEMD] Removed: {p}")

    def _find_scanner_path(self) -> str:
        """Find the aimas_scanner module path for ExecStart."""
        # Try to find the scanner package
        try:
            import aimas_scanner
            module_dir = Path(aimas_scanner.__file__).parent
            return str(module_dir.parent)
        except Exception:
            return os.path.expanduser("~/Desktop/aimas/scanner-daemon")
