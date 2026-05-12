#!/usr/bin/env python3
"""TUI Dashboard for AIMAS Scanner Daemon.

A simple terminal dashboard showing system state, recent mutations,
and convergence status. Uses only stdlib formatting (no external deps).

Usage:
    python3 -m aimas_scanner.dashboard
"""

import os
import sys
import time
from pathlib import Path

# Ensure package importable
_SCRIPT_DIR = Path(__file__).parent
_PACKAGE_ROOT = _SCRIPT_DIR.parent
if str(_PACKAGE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PACKAGE_ROOT))

from aimas_scanner.scanner import SystemScanner
from aimas_scanner.mutation_log import MutationLog


class Dashboard:
    """Simple text-based dashboard for AIMAS system state."""

    def __init__(self):
        self.scanner = SystemScanner()
        self.mlog = MutationLog()
        self.width = 70

    def _hr(self, char: str = "═") -> str:
        return char * self.width

    def _center(self, text: str, char: str = " ") -> str:
        pad = (self.width - len(text)) // 2
        return char * pad + text + char * (self.width - len(text) - pad)

    def _row(self, label: str, value: str, color: str = "") -> str:
        return f"  {label:20s} {value}"

    def render(self, refresh: bool = False) -> str:
        """Render the dashboard as a multi-line string."""
        state = self.scanner.probe()
        report = self.mlog.generate_report()

        lines = []
        lines.append("")
        lines.append(self._hr("╔"))
        lines.append(self._center(" AIMAS SYSTEM DASHBOARD ", "║"))
        lines.append(self._hr("╠"))
        lines.append(self._center(" System State ", "║"))
        lines.append(self._hr("╠"))
        lines.append(self._row("OS", f"{state['os_type']} {state['os_version']}"))
        lines.append(self._row("Architecture", state["arch"]))
        lines.append(self._row("GPU Available", str(state["gpu_available"])))
        lines.append(self._row("CUDA Version", state["cuda_version"] or "N/A"))
        lines.append("")
        lines.append(self._row("Package Managers", ", ".join(state["package_managers"])))
        lines.append("")
        lines.append(self._row("Installed Tools", str(len(state["installed_bins"]))))
        lines.append(self._row("Python Envs", ", ".join(state["python_envs"]) or "none"))
        lines.append("")
        lines.append(self._row("Ollama", state["service_status"].get("ollama", "unknown")))
        lines.append(self._row("Docker", state["service_status"].get("docker", "unknown")))
        lines.append(self._row("SSH", state["service_status"].get("ssh", "unknown")))
        lines.append(self._hr("╠"))
        lines.append(self._center(" Mutation Log ", "║"))
        lines.append(self._hr("╠"))
        lines.append(self._row("Total Mutations", str(report["total_mutations"])))
        lines.append(self._row("Unique Targets", str(report["unique_targets"])))
        lines.append(self._row("Last Mutation", report["last_mutation"] or "N/A"))
        lines.append("")
        if report["operations"]:
            lines.append("  Operation Breakdown:")
            for op, count in report["operations"].items():
                lines.append(f"    {op:20s} {count}")
        else:
            lines.append("  No mutations recorded yet.")
        lines.append(self._hr("╚"))
        lines.append("")
        lines.append("  Key Services:")
        lines.append(f"    Ollama:    http://localhost:11434")
        lines.append(f"    LocalAI:   http://localhost:8080")
        lines.append(f"    OpenWebUI: http://localhost:3000")
        lines.append("")
        return "\n".join(lines)

    def live(self, interval: float = 5.0) -> None:
        """Display a live-updating dashboard (Ctrl+C to exit)."""
        try:
            while True:
                os.system("clear" if os.name != "nt" else "cls")
                print(self.render())
                print(f"  Refreshing every {interval}s (Ctrl+C to exit)")
                time.sleep(interval)
        except KeyboardInterrupt:
            print("\n  Dashboard stopped.")


def main() -> int:
    import argparse
    ap = argparse.ArgumentParser(description="AIMAS Dashboard")
    ap.add_argument("--live", action="store_true", help="Live updating mode")
    ap.add_argument("--interval", type=float, default=5.0, help="Refresh interval (seconds)")
    args = ap.parse_args()

    dash = Dashboard()
    if args.live:
        dash.live(args.interval)
    else:
        print(dash.render())
    return 0


if __name__ == "__main__":
    sys.exit(main())
