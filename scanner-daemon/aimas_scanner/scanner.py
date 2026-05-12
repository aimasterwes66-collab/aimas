#!/usr/bin/env python3
"""System State Graph (SSG) scanner — probes the local machine for installed tools,
package managers, services, and environment state.

All probes use stdlib subprocess or filesystem checks. No external dependencies."""

import os
import re
import subprocess
from typing import Any


class SystemScanner:
    """Build a System State Graph by probing the local environment."""

    # Tools we know how to check
    KNOWN_BINS = [
        "docker", "kubectl", "terraform", "ansible", "git", "nvim", "vim", "nano",
        "zsh", "bash", "tmux", "fzf", "eza", "bat", "ripgrep", "rg", "fd", "fdfind",
        "node", "npm", "go", "cargo", "rustup", "deno", "bun", "python3", "python",
        "uv", "pipx", "poetry", "pdm", "ollama", "starship", "zoxide", "lazygit",
        "ghq", "mods", "gum", "gdu", "viddy", "btm", "htop", "procs", "dust",
        "hyperfine", "tokei", "bore", "xsv", "sd", "choose", "rclone", "yt-dlp",
        "helm", "k9s", "aws", "nmap", "wireshark", "tcpdump", "socat", "iperf3",
        "mtr", "whois", "dig", "ssh", "ufw", "ffmpeg", "obs-studio", "blender",
        "gimp", "inkscape", "krita", "darktable", "audacity", "lmms", "godot",
        "steam", "lutris", "retroarch", "jellyfin", "pihole", "nextcloud",
    ]

    def probe(self) -> dict[str, Any]:
        return {
            "os_type": self._os_type(),
            "os_version": self._os_version(),
            "arch": self._arch(),
            "package_managers": self._package_managers(),
            "installed_bins": self._installed_bins(),
            "service_status": self._service_status(),
            "gpu_available": self._gpu_available(),
            "cuda_version": self._cuda_version(),
            "python_envs": self._python_envs(),
        }

    # ------------------------------------------------------------------
    # OS / Arch
    # ------------------------------------------------------------------
    def _os_type(self) -> str:
        try:
            with open("/etc/os-release") as f:
                return re.search(r'^ID="?([^"\n]+)"?', f.read(), re.M).group(1)
        except Exception:
            return "unknown"

    def _os_version(self) -> str:
        try:
            with open("/etc/os-release") as f:
                m = re.search(r'^VERSION_ID="?([^"\n]+)"?', f.read(), re.M)
                return m.group(1) if m else "unknown"
        except Exception:
            return "unknown"

    def _arch(self) -> str:
        try:
            return subprocess.check_output(["uname", "-m"], text=True).strip()
        except Exception:
            return "unknown"

    # ------------------------------------------------------------------
    # Package managers
    # ------------------------------------------------------------------
    def _package_managers(self) -> list[str]:
        pms = []
        checks = {
            "apt": ["apt", "--version"],
            "cargo": ["cargo", "--version"],
            "go": ["go", "version"],
            "npm": ["npm", "--version"],
            "pipx": ["pipx", "--version"],
            "docker": ["docker", "--version"],
            "uv": ["uv", "--version"],
            "brew": ["brew", "--version"],
            "nix": ["nix", "--version"],
        }
        for name, cmd in checks.items():
            if self._cmd_exists(cmd[0]):
                pms.append(name)
        return pms

    # ------------------------------------------------------------------
    # Installed binaries
    # ------------------------------------------------------------------
    def _installed_bins(self) -> dict[str, str]:
        bins = {}
        for name in self.KNOWN_BINS:
            path = self._which(name)
            if path:
                bins[name] = path
        return bins

    # ------------------------------------------------------------------
    # Services
    # ------------------------------------------------------------------
    def _service_status(self) -> dict[str, str]:
        services = {}
        for svc in ("ollama", "docker", "ssh", "systemd-resolved"):
            try:
                out = subprocess.run(
                    ["systemctl", "is-active", svc],
                    capture_output=True, text=True, timeout=5
                )
                services[svc] = out.stdout.strip()
            except Exception:
                services[svc] = "unknown"
        return services

    # ------------------------------------------------------------------
    # GPU / CUDA
    # ------------------------------------------------------------------
    def _gpu_available(self) -> bool:
        try:
            subprocess.check_output(["lspci"], text=True, timeout=5)
            result = subprocess.run(
                ["bash", "-c", "lspci | grep -i nvidia"],
                capture_output=True, text=True, timeout=5
            )
            return result.returncode == 0 and bool(result.stdout.strip())
        except Exception:
            return False

    def _cuda_version(self) -> str | None:
        try:
            out = subprocess.check_output(["nvcc", "--version"], text=True, timeout=5)
            m = re.search(r"release (\d+\.\d+)", out)
            return m.group(1) if m else None
        except Exception:
            return None

    # ------------------------------------------------------------------
    # Python envs
    # ------------------------------------------------------------------
    def _python_envs(self) -> list[str]:
        envs = []
        base = os.path.expanduser("~/.local/share/aimas/venvs")
        if os.path.isdir(base):
            for name in os.listdir(base):
                if os.path.isdir(os.path.join(base, name)):
                    envs.append(name)
        return envs

    # ------------------------------------------------------------------
    # Utilities
    # ------------------------------------------------------------------
    def _cmd_exists(self, name: str) -> bool:
        try:
            subprocess.run([name, "--version"], capture_output=True, timeout=5)
            return True
        except FileNotFoundError:
            return False
        except Exception:
            return False

    def _which(self, name: str) -> str | None:
        try:
            return subprocess.check_output(["which", name], text=True, timeout=5).strip()
        except Exception:
            return None
