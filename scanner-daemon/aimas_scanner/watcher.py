#!/usr/bin/env python3
"""File system watcher for AIMAS Scanner Daemon (Phase 2).

Uses inotify (via inotify_simple package) or falls back to polling.
Watches intent directories and triggers convergence when Markdown files change.

Phase 1 fallback: simple polling loop (no external deps).
Phase 2: inotify integration for production use.
"""

import hashlib
import os
import time
from pathlib import Path
from typing import Callable, List, Set


class IntentWatcher:
    """Watch intent directories and invoke callback on changes."""

    def __init__(
        self,
        watch_paths: List[str],
        callback: Callable[[str], None],
        poll_interval: float = 5.0,
        ignore_patterns: tuple = (".tmp", ".draft.md", "~"),
    ):
        self.watch_paths = [os.path.expanduser(p) for p in watch_paths]
        self.callback = callback
        self.poll_interval = poll_interval
        self.ignore_patterns = ignore_patterns
        self._state: dict[str, str] = {}  # path → hash
        self._running = False

    def _hash_file(self, path: str) -> str:
        """Compute SHA-256 hash of file contents."""
        try:
            with open(path, "rb") as f:
                return hashlib.sha256(f.read()).hexdigest()
        except Exception:
            return ""

    def _collect_md_files(self) -> Set[str]:
        """Recursively find all .md files in watch paths."""
        files = set()
        for wp in self.watch_paths:
            p = Path(wp)
            if not p.exists():
                continue
            for f in p.rglob("*.md"):
                path_str = str(f)
                if any(pat in path_str for pat in self.ignore_patterns):
                    continue
                files.add(path_str)
        return files

    def _scan(self) -> List[str]:
        """Return list of changed files since last scan."""
        changed = []
        current_files = self._collect_md_files()

        # Check for new or modified files
        for path in current_files:
            h = self._hash_file(path)
            if self._state.get(path) != h:
                self._state[path] = h
                changed.append(path)

        # Check for deleted files
        for path in list(self._state.keys()):
            if path not in current_files:
                del self._state[path]

        return changed

    def start(self) -> None:
        """Start the polling watch loop (blocks)."""
        self._running = True
        print(f"[WATCH] Watching {len(self.watch_paths)} path(s)")
        for wp in self.watch_paths:
            print(f"  - {wp}")
        print(f"[WATCH] Poll interval: {self.poll_interval}s")
        print("[WATCH] Press Ctrl+C to stop")

        # Initial scan to establish baseline
        self._scan()

        try:
            while self._running:
                time.sleep(self.poll_interval)
                changed = self._scan()
                for path in changed:
                    print(f"[WATCH] Change detected: {path}")
                    try:
                        self.callback(path)
                    except Exception as e:
                        print(f"[WATCH] Callback error for {path}: {e}")
        except KeyboardInterrupt:
            print("\n[WATCH] Stopping...")
            self._running = False

    def stop(self) -> None:
        """Signal the watcher to stop."""
        self._running = False


def _test_callback(path: str) -> None:
    """Example callback that runs dry-run convergence."""
    print(f"[CALLBACK] Would converge: {path}")


if __name__ == "__main__":
    import sys
    watch_dir = sys.argv[1] if len(sys.argv) > 1 else "~/Documents/aimas-intent"
    watcher = IntentWatcher([watch_dir], _test_callback, poll_interval=3.0)
    watcher.start()
