#!/usr/bin/env python3
"""GitHub intent puller for AIMAS Scanner Daemon.

Downloads intent documents (.md files) from GitHub repos, gists, or directories
and converges the local system toward them.

Usage:
    python3 -m aimas_scanner --pull-repo owner/repo
    python3 -m aimas_scanner --pull-repo owner/repo --path docs/intent.md
    python3 -m aimas_scanner --pull-gist gist_id

All operations use stdlib urllib (no external dependencies).
"""

import json
import os
import urllib.request
from pathlib import Path
from typing import List, Optional


DEFAULT_BRANCH = "main"
RAW_GITHUB_URL = "https://raw.githubusercontent.com"
API_GITHUB_URL = "https://api.github.com"


class GitHubPuller:
    """Pull intent documents from GitHub repositories and gists."""

    def __init__(self, token: Optional[str] = None):
        self.token = token or os.environ.get("GITHUB_TOKEN")
        self.headers = {}
        if self.token:
            self.headers["Authorization"] = f"token {self.token}"

    def _fetch(self, url: str) -> bytes:
        """Fetch raw bytes from a URL."""
        req = urllib.request.Request(url, headers=self.headers)
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read()

    def _fetch_json(self, url: str) -> dict:
        """Fetch and parse JSON from a URL."""
        data = self._fetch(url)
        return json.loads(data.decode("utf-8"))

    def pull_repo(
        self,
        repo: str,
        path: str = ".aimas",
        branch: str = DEFAULT_BRANCH,
        output_dir: str = "~/.config/aimas/intent/github",
    ) -> List[str]:
        """Pull all .md files from a GitHub repo directory.

        Args:
            repo: "owner/repo" string
            path: Directory or file path within the repo
            branch: Git branch to pull from
            output_dir: Local directory to save files

        Returns:
            List of downloaded file paths
        """
        output_dir = Path(output_dir).expanduser()
        output_dir.mkdir(parents=True, exist_ok=True)

        downloaded = []

        # Try API first to list directory contents
        api_url = f"{API_GITHUB_URL}/repos/{repo}/contents/{path}?ref={branch}"
        try:
            contents = self._fetch_json(api_url)
            if not isinstance(contents, list):
                contents = [contents]
        except urllib.error.HTTPError as e:
            if e.code == 404:
                # Try as single file
                raw_url = f"{RAW_GITHUB_URL}/{repo}/{branch}/{path}"
                try:
                    data = self._fetch(raw_url)
                    local_path = output_dir / Path(path).name
                    local_path.write_bytes(data)
                    downloaded.append(str(local_path))
                    print(f"[PULL] Downloaded: {local_path}")
                    return downloaded
                except Exception as ex:
                    print(f"[ERR] Failed to pull {repo}/{path}: {ex}")
                    return []
            else:
                raise

        for item in contents:
            if item.get("type") == "file" and item["name"].endswith(".md"):
                raw_url = item["download_url"]
                local_path = output_dir / item["name"]
                try:
                    data = self._fetch(raw_url)
                    local_path.write_bytes(data)
                    downloaded.append(str(local_path))
                    print(f"[PULL] Downloaded: {local_path}")
                except Exception as e:
                    print(f"[WARN] Failed to download {item['name']}: {e}")
            elif item.get("type") == "dir":
                # Recurse into subdirectories
                sub_downloaded = self.pull_repo(
                    repo, f"{path}/{item['name']}", branch, str(output_dir)
                )
                downloaded.extend(sub_downloaded)

        return downloaded

    def pull_gist(self, gist_id: str, output_dir: str = "~/.config/aimas/intent/gists") -> List[str]:
        """Pull all files from a GitHub gist.

        Args:
            gist_id: The gist ID (e.g., "abc123...")
            output_dir: Local directory to save files

        Returns:
            List of downloaded file paths
        """
        output_dir = Path(output_dir).expanduser()
        output_dir.mkdir(parents=True, exist_ok=True)

        api_url = f"{API_GITHUB_URL}/gists/{gist_id}"
        try:
            gist_data = self._fetch_json(api_url)
        except Exception as e:
            print(f"[ERR] Failed to fetch gist {gist_id}: {e}")
            return []

        downloaded = []
        files = gist_data.get("files", {})
        for filename, file_info in files.items():
            if not filename.endswith(".md"):
                continue
            raw_url = file_info.get("raw_url")
            if not raw_url:
                continue
            local_path = output_dir / filename
            try:
                data = self._fetch(raw_url)
                local_path.write_bytes(data)
                downloaded.append(str(local_path))
                print(f"[PULL] Downloaded gist file: {local_path}")
            except Exception as e:
                print(f"[WARN] Failed to download gist file {filename}: {e}")

        return downloaded
