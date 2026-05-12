#!/usr/bin/env python3
"""Markdown intent parser — extracts structured requirements from .md files.

Supported block types:
  - YAML frontmatter (--- ... ---)
  - ## Headers as capability categories
  - ### Requires / ## Goals / ## Config as structured lists
  - ```aimas-run  blocks for direct commands
  - ```aimas-capability blocks for semantic tool specs
"""

import hashlib
import json
import os
import re
from typing import Any


class IntentParser:
    """Parse an AIMAS Markdown intent document into a structured capability graph."""

    def parse_file(self, path: str) -> dict[str, Any]:
        with open(path, "r", encoding="utf-8") as f:
            raw = f.read()
        return self.parse(raw, source=path)

    def parse(self, text: str, source: str = "<inline>") -> dict[str, Any]:
        frontmatter, body = self._extract_frontmatter(text)
        capabilities = []
        config_overrides = {}

        # Extract aimas-capability code blocks
        capabilities.extend(self._parse_capability_blocks(body))

        # Extract aimas-run code blocks
        run_commands = self._parse_run_blocks(body)

        # Extract structured lists under headers
        capabilities.extend(self._parse_header_lists(body))

        # Extract config directives
        config_overrides = self._parse_config(body)

        # Merge frontmatter config
        if "config" in frontmatter:
            config_overrides.update(frontmatter["config"])

        intent_id = hashlib.sha256(text.encode("utf-8")).hexdigest()

        return {
            "intent_id": intent_id,
            "source": source,
            "frontmatter": frontmatter,
            "capabilities": capabilities,
            "run_commands": run_commands,
            "config_overrides": config_overrides,
        }

    # ------------------------------------------------------------------
    # Frontmatter
    # ------------------------------------------------------------------
    def _extract_frontmatter(self, text: str) -> tuple[dict, str]:
        pattern = r"^---\s*\n(.*?)\n---\s*\n(.*)$"
        m = re.match(pattern, text, re.DOTALL)
        if not m:
            return {}, text

        raw_yaml, body = m.group(1), m.group(2)
        fm = {}
        for line in raw_yaml.splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                k, v = k.strip(), v.strip().strip('"').strip("'")
                if v.lower() in ("true", "false"):
                    v = v.lower() == "true"
                elif v.isdigit():
                    v = int(v)
                fm[k] = v
        return fm, body

    # ------------------------------------------------------------------
    # Code blocks
    # ------------------------------------------------------------------
    def _parse_capability_blocks(self, body: str) -> list[dict]:
        caps = []
        pattern = r"```aimas-capability\s*\n(.*?)\n```"
        for m in re.finditer(pattern, body, re.DOTALL):
            raw = m.group(1).strip()
            try:
                data = json.loads(raw)
            except json.JSONDecodeError:
                data = self._yamlish_to_dict(raw)
            caps.append(self._normalize_capability(data))
        return caps

    def _parse_run_blocks(self, body: str) -> list[str]:
        cmds = []
        pattern = r"```aimas-run\s*\n(.*?)\n```"
        for m in re.finditer(pattern, body, re.DOTALL):
            cmds.append(m.group(1).strip())
        return cmds

    # ------------------------------------------------------------------
    # Header-based structured lists
    # ------------------------------------------------------------------
    def _parse_header_lists(self, body: str) -> list[dict]:
        caps = []
        # Find sections like "## Requires", "## Capabilities", etc.
        for section in re.finditer(r"^##\s+([^\n]+)\n(.*?)(?=\n##\s+|\Z)", body, re.MULTILINE | re.DOTALL):
            title = section.group(1).strip().lower()
            content = section.group(2)
            if title in ("requires", "capabilities", "tools", "goals"):
                caps.extend(self._list_items_to_capabilities(content))
        return caps

    def _list_items_to_capabilities(self, text: str) -> list[dict]:
        caps = []
        for line in text.splitlines():
            line = line.strip()
            if line.startswith("-") or line.startswith("*"):
                item = line.lstrip("- *").strip()
                # Try to parse as "tool: version" or "tool >= version"
                tool_match = re.match(r"^([a-zA-Z0-9_\-]+)(?:\s*[:>=]\s*(.+))?", item)
                if tool_match:
                    name = tool_match.group(1)
                    version = tool_match.group(2) or ""
                    caps.append({
                        "capability": f"install-{name}",
                        "confidence": 0.85,
                        "tools": [{"name": name, "required": True, "version": version}],
                    })
        return caps

    # ------------------------------------------------------------------
    # Config parsing
    # ------------------------------------------------------------------
    def _parse_config(self, body: str) -> dict[str, Any]:
        config = {}
        for section in re.finditer(r"^##\s+Config\s*\n(.*?)(?=\n##\s+|\Z)", body, re.MULTILINE | re.DOTALL):
            for line in section.group(1).splitlines():
                line = line.strip()
                if line.startswith("-") or line.startswith("*"):
                    item = line.lstrip("- *").strip()
                    if ":" in item:
                        k, v = item.split(":", 1)
                        config[k.strip()] = v.strip().strip('"').strip("'")
        return config

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    def _yamlish_to_dict(self, text: str) -> dict[str, Any]:
        """Very lenient pseudo-YAML parser for simple key-value / list structures."""
        result: dict[str, Any] = {}
        current_key = None
        current_list: list[str] = []
        for line in text.splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            if stripped.endswith(":") and not stripped.startswith("-"):
                if current_key and current_list:
                    result[current_key] = current_list
                    current_list = []
                current_key = stripped[:-1].strip()
                result[current_key] = []
            elif stripped.startswith("-") and current_key is not None:
                current_list.append(stripped.lstrip("- ").strip())
                result[current_key] = current_list
            elif ":" in stripped and not stripped.startswith("-"):
                k, v = stripped.split(":", 1)
                result[k.strip()] = v.strip().strip('"').strip("'")
        return result

    def _normalize_capability(self, data: dict) -> dict:
        """Ensure a capability dict matches the expected schema."""
        return {
            "capability": data.get("category", data.get("capability", "unknown")),
            "confidence": data.get("confidence", 0.9),
            "tools": data.get("tools", data.get("tools", [])),
        }
