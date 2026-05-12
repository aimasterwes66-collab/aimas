#!/usr/bin/env python3
"""LLM Semantic Interpreter for AIMAS Scanner Daemon (Phase 2).

Uses the local Ollama API to convert vague Markdown intent into structured
capability requirements. Falls back to static keyword matching if Ollama
is unavailable.

Requires: Python 3 stdlib only (urllib, json).
"""

import json
import re
import urllib.request
from typing import Any


DEFAULT_MODEL = "qwen2.5-coder:14b"
OLLAMA_URL = "http://localhost:11434/api/generate"

SYSTEM_PROMPT = """You are the AIMAS Semantic Interpreter. Your job is to read user intent descriptions and extract structured capability requirements.

Rules:
1. NEVER hallucinate tools. Only use known capabilities from the list below.
2. Convert vague descriptions into specific package names.
3. Identify version constraints when mentioned.
4. Flag conflicting requirements.
5. Output valid JSON only.

Known capability categories:
- ai-llm: ollama, llama.cpp, gpt4all, localai, uv, pipx
- video: ffmpeg, obs-studio, kdenlive, shotcut, handbrake, blender
- audio: audacity, lmms, supercollider, hydrogen, musescore
- image: gimp, inkscape, blender, krita, darktable, comfyui, invokeai
- dev: docker, kubectl, terraform, ansible, git, neovim
- scrape: scrapy, selenium, playwright, beautifulsoup4, yt-dlp
- shell: zsh, tmux, starship, zoxide, eza, bat, fd, ripgrep
- network: nmap, wireshark, tcpdump, iperf3, socat
- security: metasploit, burp-suite, owasp-zap, sqlmap, nikto
- gaming: godot, blender, unity, love2d, steam, lutris
- homelab: jellyfin, plex, nextcloud, pihole, portainer
- productivity: obsidian, logseq, joplin, taskwarrior

Output format:
{
  "capabilities": [
    {
      "capability": "category-name",
      "confidence": 0.95,
      "tools": [
        {"name": "tool-name", "required": true, "version": ">=1.0"}
      ]
    }
  ]
}
"""


class LLMInterpreter:
    """Semantic interpreter using local Ollama LLM."""

    def __init__(self, model: str = DEFAULT_MODEL, url: str = OLLAMA_URL):
        self.model = model
        self.url = url
        self.available = self._check_ollama()

    def _check_ollama(self) -> bool:
        """Probe if Ollama is running and the model is available."""
        try:
            req = urllib.request.Request(
                self.url.replace("/api/generate", "/api/tags"),
                method="GET",
            )
            with urllib.request.urlopen(req, timeout=3) as resp:
                data = json.loads(resp.read().decode())
                models = [m["name"] for m in data.get("models", [])]
                return self.model in models or any(self.model.split(":")[0] in m for m in models)
        except Exception:
            return False

    def interpret(self, text: str) -> list[dict[str, Any]]:
        """Convert free-form Markdown text into structured capabilities."""
        if self.available:
            return self._llm_interpret(text)
        return self._fallback_interpret(text)

    def _llm_interpret(self, text: str) -> list[dict[str, Any]]:
        """Use Ollama to extract capabilities."""
        prompt = f"{SYSTEM_PROMPT}\n\nUser intent:\n{text}\n\nExtract capabilities as JSON:"
        payload = json.dumps({
            "model": self.model,
            "prompt": prompt,
            "stream": False,
            "options": {"temperature": 0.1, "num_predict": 2048},
        }).encode()

        req = urllib.request.Request(
            self.url,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                data = json.loads(resp.read().decode())
                raw = data.get("response", "")
                # Extract JSON from markdown code blocks if present
                json_match = re.search(r"```json\s*(.*?)\s*```", raw, re.DOTALL)
                if json_match:
                    raw = json_match.group(1)
                else:
                    # Try to find raw JSON object
                    json_match = re.search(r"(\{.*\})", raw, re.DOTALL)
                    if json_match:
                        raw = json_match.group(1)
                parsed = json.loads(raw)
                return parsed.get("capabilities", [])
        except Exception as e:
            print(f"[WARN] LLM interpretation failed: {e}. Falling back to keyword matching.")
            return self._fallback_interpret(text)

    def _fallback_interpret(self, text: str) -> list[dict[str, Any]]:
        """Static keyword-based capability extraction (no LLM required)."""
        text_lower = text.lower()
        capabilities = []

        keyword_map = {
            "ai-llm": ["ai", "llm", "machine learning", "ollama", "gpt", "stable diffusion", "model"],
            "video": ["video", "recording", "streaming", "edit", "ffmpeg", "obs", "kdenlive"],
            "audio": ["audio", "music", "sound", "daw", "audacity", "lmms", "synth"],
            "image": ["image", "photo", "gimp", "inkscape", "krita", "blender", "pixel"],
            "dev": ["docker", "kubernetes", "terraform", "ansible", "devops", "git", "code"],
            "scrape": ["scrape", "crawl", "download", "yt-dlp", "scrapy", "playwright"],
            "shell": ["shell", "terminal", "zsh", "tmux", "prompt", "starship", "zoxide"],
            "network": ["network", "packet", "nmap", "wireshark", "tcpdump", "bandwidth"],
            "security": ["security", "pentest", "hack", "vulnerability", "scan", "exploit"],
            "gaming": ["game", "engine", "godot", "unity", "emulator", "steam", "lutris"],
            "homelab": ["homelab", "self-host", "jellyfin", "plex", "nextcloud", "pihole"],
            "productivity": ["notes", "knowledge", "task", "todo", "obsidian", "logseq"],
        }

        tool_map = {
            "ai-llm": ["ollama", "uv", "pipx"],
            "video": ["ffmpeg", "obs-studio", "kdenlive", "blender"],
            "audio": ["audacity", "lmms", "supercollider"],
            "image": ["gimp", "inkscape", "krita", "darktable"],
            "dev": ["docker", "git", "neovim", "terraform"],
            "scrape": ["yt-dlp", "scrapy", "playwright"],
            "shell": ["zsh", "tmux", "starship", "zoxide", "eza", "bat"],
            "network": ["nmap", "wireshark", "tcpdump", "iperf3"],
            "security": ["nmap", "nikto", "sqlmap", "metasploit"],
            "gaming": ["godot", "blender", "steam", "lutris"],
            "homelab": ["docker", "jellyfin", "nextcloud", "pihole"],
            "productivity": ["taskwarrior", "tldr", "cheat"],
        }

        for category, keywords in keyword_map.items():
            matches = [k for k in keywords if k in text_lower]
            if matches:
                confidence = min(0.5 + 0.1 * len(matches), 0.95)
                tools = []
                for tool_name in tool_map.get(category, []):
                    tools.append({
                        "name": tool_name,
                        "required": True,
                        "version": "",
                    })
                capabilities.append({
                    "capability": category,
                    "confidence": confidence,
                    "tools": tools,
                })

        return capabilities
