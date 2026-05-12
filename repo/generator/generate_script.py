#!/usr/bin/env python3
"""
generate_script.py — AIMAS Install Script Generator
Reads JSON tool manifests and compiles them into a single installation script.
Usage:
    python generator/generate_script.py --platform apt --categories video,ai,dev
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import List, Dict, Any

REPO_ROOT = Path(__file__).parent.parent
TOOL_LIST_DIR = REPO_ROOT / "tool-list"
SCRIPTS_DIR = REPO_ROOT / "scripts"


def load_category(category: str) -> List[Dict[str, Any]]:
    filepath = TOOL_LIST_DIR / f"{category}-tools.json"
    if not filepath.exists():
        print(f"[WARN] Category file not found: {filepath}")
        return []
    with open(filepath, "r") as f:
        return json.load(f)


def pick_install_method(tool: Dict, platform: str) -> Dict[str, str]:
    methods = tool.get("install_methods", {})
    if platform in methods:
        return methods[platform]
    # Fallback order
    for fallback in ["apt", "script", "pipx", "cargo", "brew", "docker", "binary"]:
        if fallback in methods:
            return methods[fallback]
    return {}


def generate_bash(tools: List[Dict], platform: str) -> str:
    lines = [
        "#!/usr/bin/env bash",
        "# =============================================================================",
        "# AIMAS GENERATED INSTALL SCRIPT",
        "# Platform: {platform}".format(platform=platform),
        "# Generated: $(date -Iseconds)",
        "# =============================================================================",
        "set -e",
        "",
        'RED="\\033[0;31m"',
        'GREEN="\\033[0;32m"',
        'YELLOW="\\033[1;33m"',
        'BLUE="\\033[1;34m"',
        'NC="\\033[0m"',
        'info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }',
        'ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }',
        'warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }',
        'die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }',
        "",
        "info 'Updating package lists...'",
        "sudo apt-get update || true",
        "",
    ]

    for tool in tools:
        name = tool["name"]
        desc = tool.get("description", "")
        method = pick_install_method(tool, platform)
        if not method:
            lines.append(f'# SKIP: {name} — no install method for platform {platform}')
            continue

        cmd = method.get("command", "")
        deps = method.get("dependencies", [])

        lines.append(f"# --- {name} ---")
        lines.append(f"# {desc}")
        if deps:
            lines.append(f"# Dependencies: {', '.join(deps)}")
        lines.append(f"if ! command -v {name.split()[0].lower()} >/dev/null 2>&1; then")
        lines.append(f"  info 'Installing {name}...'")
        lines.append(f"  {cmd} || warn '{name} installation failed (non-fatal)'")
        lines.append("else")
        lines.append(f"  ok '{name} already present'")
        lines.append("fi")
        lines.append("")

    lines.append("echo ''")
    lines.append('echo -e "${GREEN}✅ AIMAS generated install complete${NC}"')
    lines.append("")
    return "\n".join(lines)


def generate_ansible(tools: List[Dict], platform: str) -> str:
    lines = [
        "---",
        "- hosts: all",
        "  become: yes",
        "  tasks:",
    ]
    for tool in tools:
        name = tool["name"]
        method = pick_install_method(tool, platform)
        if not method:
            continue
        cmd = method.get("command", "")
        # Simplified: assume apt for ansible output
        if platform == "apt" and "apt install" in cmd:
            pkg = cmd.replace("sudo apt install", "").replace("-y", "").strip().split()[0]
            lines.append(f"    - name: Install {name}")
            lines.append("      apt:")
            lines.append(f"        name: {pkg}")
            lines.append("        state: present")
            lines.append("      ignore_errors: yes")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="AIMAS Install Script Generator")
    parser.add_argument("--platform", default="apt", help="Target platform (apt, brew, etc.)")
    parser.add_argument("--categories", default="video,ai,dev", help="Comma-separated categories")
    parser.add_argument("--format", default="bash", choices=["bash", "ansible"], help="Output format")
    parser.add_argument("--output", default=None, help="Output file path")
    args = parser.parse_args()

    categories = [c.strip() for c in args.categories.split(",")]
    all_tools = []
    for cat in categories:
        tools = load_category(cat)
        all_tools.extend(tools)

    if not all_tools:
        die("No tools found for the specified categories.")

    if args.format == "bash":
        script = generate_bash(all_tools, args.platform)
        ext = "sh"
    else:
        script = generate_ansible(all_tools, args.platform)
        ext = "yml"

    if args.output:
        out_path = Path(args.output)
    else:
        SCRIPTS_DIR.mkdir(parents=True, exist_ok=True)
        out_path = SCRIPTS_DIR / f"install_generated.{ext}"

    out_path.write_text(script)
    print(f"Generated: {out_path}")
    print(f"Tools included: {len(all_tools)}")
    print(f"Platform: {args.platform}")
    print(f"Format: {args.format}")


if __name__ == "__main__":
    main()
