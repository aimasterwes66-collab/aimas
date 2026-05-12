#!/usr/bin/env python3
"""Actuator — resolves capabilities to install commands and executes them.

Follows the fallback order:
    apt → script → pipx → cargo → go → brew → docker → binary

Phase 1: static capability → command mapping (no LLM yet).
Phase 2: will integrate LLM for fuzzy capability resolution.
"""

import os
import subprocess
import json
from typing import Any

from aimas_scanner.mutation_log import MutationLog


# Static registry: capability name → preferred install method and command
# In Phase 2 this will be dynamically populated from tool-list/*.json
CAPABILITY_REGISTRY = {
    # Shell & terminal
    "zsh":          {"method": "apt", "command": "sudo apt install zsh -y"},
    "tmux":         {"method": "apt", "command": "sudo apt install tmux -y"},
    "fzf":          {"method": "apt", "command": "sudo apt install fzf -y"},
    "eza":          {"method": "cargo", "command": "cargo install eza"},
    "bat":          {"method": "apt", "command": "sudo apt install bat -y"},
    "ripgrep":      {"method": "apt", "command": "sudo apt install ripgrep -y"},
    "fd":           {"method": "apt", "command": "sudo apt install fd-find -y && sudo ln -sf $(which fdfind) /usr/local/bin/fd"},
    "starship":     {"method": "script", "command": "curl -sS https://starship.rs/install.sh | sh -s -- -y"},
    "zoxide":       {"method": "script", "command": "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"},
    "procs":        {"method": "cargo", "command": "cargo install procs"},
    "dust":         {"method": "cargo", "command": "cargo install du-dust"},
    "btm":          {"method": "cargo", "command": "cargo install bottom"},
    "hyperfine":    {"method": "cargo", "command": "cargo install hyperfine"},
    "tokei":        {"method": "cargo", "command": "cargo install tokei"},
    "bandwhich":    {"method": "cargo", "command": "cargo install bandwhich"},
    "xsv":          {"method": "cargo", "command": "cargo install xsv"},
    "sd":           {"method": "cargo", "command": "cargo install sd"},
    "choose":       {"method": "cargo", "command": "cargo install choose"},

    # DevOps
    "docker":       {"method": "script", "command": "curl -fsSL https://get.docker.com | sh"},
    "kubectl":      {"method": "apt", "command": "sudo apt install kubectl -y"},
    "terraform":    {"method": "apt", "command": "sudo apt install terraform -y"},
    "ansible":      {"method": "apt", "command": "sudo apt install ansible -y"},
    "helm":         {"method": "script", "command": "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"},
    "k9s":          {"method": "script", "command": "curl -sS https://webinstall.dev/k9s | bash"},
    "aws-cli":      {"method": "script", "command": "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip && unzip -o awscliv2.zip && sudo ./aws/install && rm -rf aws awscliv2.zip"},

    # Languages
    "go":           {"method": "binary", "command": "curl -LO https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && rm -f go1.23.4.linux-amd64.tar.gz"},
    "rust":         {"method": "script", "command": "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"},
    "node":         {"method": "script", "command": "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"},
    "deno":         {"method": "script", "command": "curl -fsSL https://deno.land/install.sh | sh"},
    "bun":          {"method": "script", "command": "curl -fsSL https://bun.sh/install | bash"},
    "sdkman":       {"method": "script", "command": "curl -s 'https://get.sdkman.io' | bash"},
    "uv":           {"method": "script", "command": "curl -LsSf https://astral.sh/uv/install.sh | sh"},

    # AI / ML
    "ollama":       {"method": "script", "command": "curl -fsSL https://ollama.com/install.sh | sh"},
    "pipx":         {"method": "apt", "command": "sudo apt install pipx -y"},

    # Go-based tools
    "lazygit":      {"method": "go", "command": "go install github.com/jesseduffield/lazygit@latest"},
    "ghq":          {"method": "go", "command": "go install github.com/x-motemen/ghq@latest"},
    "mods":         {"method": "go", "command": "go install github.com/charmbracelet/mods@latest"},
    "gum":          {"method": "go", "command": "go install github.com/charmbracelet/gum@latest"},
    "gdu":          {"method": "go", "command": "go install github.com/dundee/gdu/v5/cmd/gdu@latest"},
    "viddy":        {"method": "go", "command": "go install github.com/sachaos/viddy@latest"},
    "age":          {"method": "go", "command": "go install filippo.io/age/cmd/age@latest"},

    # Scraping
    "yt-dlp":       {"method": "pipx", "command": "pipx install yt-dlp"},
    "rclone":       {"method": "script", "command": "curl https://rclone.org/install.sh | sudo bash"},
    "gallery-dl":   {"method": "pipx", "command": "pipx install gallery-dl"},

    # Content creation
    "ffmpeg":       {"method": "apt", "command": "sudo apt install ffmpeg -y"},
    "obs-studio":   {"method": "apt", "command": "sudo apt install obs-studio -y"},
    "kdenlive":     {"method": "apt", "command": "sudo apt install kdenlive -y"},
    "shotcut":      {"method": "apt", "command": "sudo apt install shotcut -y"},
    "handbrake":    {"method": "apt", "command": "sudo apt install handbrake -y"},
    "blender":      {"method": "apt", "command": "sudo apt install blender -y"},
    "gimp":         {"method": "apt", "command": "sudo apt install gimp -y"},
    "inkscape":     {"method": "apt", "command": "sudo apt install inkscape -y"},
    "krita":        {"method": "apt", "command": "sudo apt install krita -y"},
    "audacity":     {"method": "apt", "command": "sudo apt install audacity -y"},
    "darktable":    {"method": "apt", "command": "sudo apt install darktable -y"},

    # Network
    "nmap":         {"method": "apt", "command": "sudo apt install nmap -y"},
    "wireshark":    {"method": "apt", "command": "sudo apt install wireshark -y"},
    "tcpdump":      {"method": "apt", "command": "sudo apt install tcpdump -y"},
    "iperf3":       {"method": "apt", "command": "sudo apt install iperf3 -y"},
    "socat":        {"method": "apt", "command": "sudo apt install socat -y"},
    "ufw":          {"method": "apt", "command": "sudo apt install ufw -y"},
    "aria2":        {"method": "apt", "command": "sudo apt install aria2 -y"},

    # Editors
    "neovim":       {"method": "apt", "command": "sudo apt install neovim -y"},
    "git":          {"method": "apt", "command": "sudo apt install git -y"},
    "jq":           {"method": "apt", "command": "sudo apt install jq -y"},

    # pipx tools
    "poetry":       {"method": "pipx", "command": "pipx install poetry"},
    "pdm":          {"method": "pipx", "command": "pipx install pdm"},
    "httpie":       {"method": "pipx", "command": "pipx install httpie"},
    "glances":      {"method": "pipx", "command": "pipx install glances"},
    "tldr":         {"method": "pipx", "command": "pipx install tldr"},
    "black":        {"method": "pipx", "command": "pipx install black"},
    "ruff":         {"method": "pipx", "command": "pipx install ruff"},
    "mypy":         {"method": "pipx", "command": "pipx install mypy"},
}


class Actuator:
    """Converts capabilities into executable install steps."""

    FALLBACK_ORDER = ["apt", "script", "pipx", "cargo", "go", "brew", "docker", "binary"]

    def __init__(self, state: dict[str, Any], dry_run: bool = False):
        self.state = state
        self.dry_run = dry_run
        self.plan: list[dict] = []
        self.mlog = MutationLog()

    def build_plan(self, intent: dict[str, Any]) -> list[dict]:
        """Generate an ordered list of install steps from parsed intent."""
        plan = []
        installed = set(self.state.get("installed_bins", {}).keys())

        # Process explicit capabilities
        for cap in intent.get("capabilities", []):
            for tool in cap.get("tools", []):
                name = tool.get("name", "")
                if not name:
                    continue
                # Skip if already installed
                if name in installed:
                    continue
                entry = CAPABILITY_REGISTRY.get(name)
                if not entry:
                    # Try fuzzy match
                    entry = self._fuzzy_lookup(name)
                if entry:
                    plan.append({
                        "action": "install",
                        "target": name,
                        "method": entry["method"],
                        "command": entry["command"],
                        "required": tool.get("required", True),
                    })
                else:
                    plan.append({
                        "action": "unknown",
                        "target": name,
                        "method": "none",
                        "command": "",
                        "required": tool.get("required", True),
                    })

        # Process aimas-run blocks
        for block in intent.get("run_commands", []):
            plan.append({
                "action": "run",
                "target": "<direct-block>",
                "method": "script",
                "command": block,
                "required": True,
            })

        # Sort by method priority
        plan.sort(key=lambda s: self.FALLBACK_ORDER.index(s["method"]) if s["method"] in self.FALLBACK_ORDER else 99)
        return plan

    def execute(self, plan: list[dict], verbose: bool = False) -> bool:
        """Execute the convergence plan. Returns True if all critical steps succeed."""
        all_ok = True
        for step in plan:
            if step["action"] == "unknown":
                print(f"  [SKIP] Unknown tool: {step['target']}")
                continue

            marker = f"[{step['action'].upper():6s}] {step['target']:25s}"
            if self.dry_run:
                print(f"  {marker} (dry-run)")
                continue

            print(f"  {marker} ...", end=" ", flush=True)
            try:
                if step["method"] in ("apt", "script", "binary"):
                    result = subprocess.run(
                        step["command"],
                        shell=True,
                        capture_output=not verbose,
                        text=True,
                        timeout=300,
                    )
                else:
                    result = subprocess.run(
                        step["command"],
                        shell=True,
                        capture_output=not verbose,
                        text=True,
                        timeout=120,
                    )
                if result.returncode == 0:
                    print("OK")
                    # Record mutation for rollback support
                    reverse_cmd = self._generate_reverse(step)
                    self.mlog.record(
                        operation=step["action"],
                        target=step["target"],
                        command=step["command"],
                        reverse=reverse_cmd,
                    )
                else:
                    print(f"FAIL (exit {result.returncode})")
                    if not step.get("required", True):
                        print(f"         ^ non-fatal; continuing")
                    else:
                        all_ok = False
            except subprocess.TimeoutExpired:
                print("TIMEOUT")
                all_ok = False
            except Exception as e:
                print(f"ERROR ({e})")
                all_ok = False

        return all_ok

    def _generate_reverse(self, step: dict) -> str:
        """Generate a best-effort reverse command for rollback."""
        method = step.get("method", "")
        target = step.get("target", "")
        if method == "apt":
            return f"sudo apt remove {target} -y || true"
        if method == "pipx":
            return f"pipx uninstall {target} || true"
        if method == "cargo":
            return f"cargo uninstall {target} || true"
        if method == "go":
            return f"rm -f $(go env GOPATH)/bin/{target} || true"
        if method == "docker":
            return f"docker stop {target} && docker rm {target} || true"
        return f"# Manual rollback required for {target} (method: {method})"

    def _fuzzy_lookup(self, name: str) -> dict | None:
        """Simple fuzzy matching for capability names."""
        name_lower = name.lower().replace(" ", "-").replace("_", "-")
        for key, entry in CAPABILITY_REGISTRY.items():
            if key == name_lower or name_lower in key or key in name_lower:
                return entry
        return None
