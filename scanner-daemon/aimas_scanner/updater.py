#!/usr/bin/env python3
"""Self-updater for AIMAS Scanner Daemon.

Fetches the latest tool-list JSON definitions from the upstream GitHub repo
and updates the local copies. Supports dry-run to preview changes.

Usage:
    python3 -m aimas_scanner --update
    python3 -m aimas_scanner --update --dry-run

All operations use stdlib urllib (no external dependencies).
"""

import json
import os
import urllib.request
from pathlib import Path
from typing import List, Optional, Tuple


UPSTREAM_REPO = "aimasterwes66-collab/aimas"
UPSTREAM_BRANCH = "main"
RAW_URL = f"https://raw.githubusercontent.com/{UPSTREAM_REPO}/{UPSTREAM_BRANCH}"
API_URL = f"https://api.github.com/repos/{UPSTREAM_REPO}"

TOOL_LIST_PATH = "repo/tool-list"
MANIFEST_PATH = "aimas-manifest.json"


class SelfUpdater:
    """Update local tool definitions from upstream GitHub repo."""

    def __init__(self, local_repo: Optional[str] = None, token: Optional[str] = None):
        self.local_repo = Path(local_repo).expanduser() if local_repo else self._find_local_repo()
        self.token = token or os.environ.get("GITHUB_TOKEN")
        self.headers = {}
        if self.token:
            self.headers["Authorization"] = f"token {self.token}"

    def _find_local_repo(self) -> Path:
        """Attempt to find the local aimas repo."""
        candidates = [
            Path.home() / "Desktop" / "aimas",
            Path.home() / "aimas",
            Path.home() / ".local" / "share" / "aimas",
        ]
        for c in candidates:
            if (c / "aimas-bootstrap.sh").exists():
                return c
        return candidates[0]

    def _fetch(self, url: str) -> bytes:
        """Fetch raw bytes from a URL."""
        req = urllib.request.Request(url, headers=self.headers)
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read()

    def _fetch_json(self, url: str) -> dict:
        """Fetch and parse JSON from a URL."""
        data = self._fetch(url)
        return json.loads(data.decode("utf-8"))

    def check_updates(self) -> List[Tuple[str, str, str]]:
        """Check which files have updates available.

        Returns:
            List of (filename, local_hash, remote_hash) tuples
        """
        updates = []

        # List remote tool-list files via API
        api_url = f"{API_URL}/contents/{TOOL_LIST_PATH}"
        try:
            contents = self._fetch_json(api_url)
        except Exception as e:
            print(f"[ERR] Failed to check upstream: {e}")
            return []

        for item in contents:
            if item.get("type") != "file" or not item["name"].endswith(".json"):
                continue

            filename = item["name"]
            remote_sha = item.get("sha", "")

            local_path = self.local_repo / "repo" / "tool-list" / filename
            if not local_path.exists():
                updates.append((filename, "missing", remote_sha))
                continue

            local_content = local_path.read_bytes()
            import hashlib
            local_sha = hashlib.sha1(b"blob " + str(len(local_content)).encode() + b"\0" + local_content).hexdigest()

            if local_sha != remote_sha:
                updates.append((filename, local_sha[:8], remote_sha[:8]))

        return updates

    def update(self, dry_run: bool = False) -> List[str]:
        """Download updated files from upstream.

        Returns:
            List of updated file paths
        """
        updates = self.check_updates()
        if not updates:
            print("[UPDATE] All tool definitions are up to date.")
            return []

        print(f"[UPDATE] {len(updates)} file(s) to update:")
        for filename, local_hash, remote_hash in updates:
            status = "new" if local_hash == "missing" else "changed"
            print(f"  [{status}] {filename} ({local_hash} → {remote_hash})")

        if dry_run:
            print("[UPDATE] Dry-run mode — no files were modified.")
            return []

        updated = []
        for filename, _, _ in updates:
            raw_url = f"{RAW_URL}/{TOOL_LIST_PATH}/{filename}"
            local_path = self.local_repo / "repo" / "tool-list" / filename
            try:
                data = self._fetch(raw_url)
                local_path.write_bytes(data)
                updated.append(str(local_path))
                print(f"[UPDATE] Saved: {local_path}")
            except Exception as e:
                print(f"[ERR] Failed to update {filename}: {e}")

        # Also update manifest if it changed
        manifest_url = f"{RAW_URL}/{MANIFEST_PATH}"
        manifest_local = self.local_repo / MANIFEST_PATH
        try:
            data = self._fetch(manifest_url)
            manifest_local.write_bytes(data)
            updated.append(str(manifest_local))
            print(f"[UPDATE] Saved: {manifest_local}")
        except Exception as e:
            print(f"[WARN] Could not update manifest: {e}")

        return updated
