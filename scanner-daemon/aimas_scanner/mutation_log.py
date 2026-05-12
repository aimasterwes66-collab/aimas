#!/usr/bin/env python3
"""Mutation logging and rollback for AIMAS Scanner Daemon.

Every install/config/removal operation is recorded as an immutable mutation
with a reversible operation. Supports rollback of the last N mutations.

Log format: JSON Lines (~/.local/share/aimas/logs/mutations.jsonl)
"""

import json
import os
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional


LOG_DIR = Path.home() / ".local" / "share" / "aimas" / "logs"
MUTATION_LOG = LOG_DIR / "mutations.jsonl"


class MutationLog:
    """Records system mutations with rollback support."""

    def __init__(self, log_path: Optional[Path] = None):
        self.log_path = log_path or MUTATION_LOG
        self.log_path.parent.mkdir(parents=True, exist_ok=True)

    def _load_mutations(self) -> List[Dict[str, Any]]:
        """Read all mutations from the log file."""
        if not self.log_path.exists():
            return []
        mutations = []
        with open(self.log_path, "r") as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        mutations.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue
        return mutations

    def record(
        self,
        operation: str,
        target: str,
        command: str,
        reverse: str,
        state_before: Optional[Dict] = None,
        state_after: Optional[Dict] = None,
    ) -> str:
        """Record a single mutation. Returns mutation_id."""
        mutation = {
            "mutation_id": str(uuid.uuid4()),
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "operation": operation,
            "target": target,
            "command": command,
            "reverse": reverse,
            "state_before": state_before or {},
            "state_after": state_after or {},
        }
        with open(self.log_path, "a") as f:
            f.write(json.dumps(mutation) + "\n")
        return mutation["mutation_id"]

    def list_mutations(self, limit: int = 50) -> List[Dict[str, Any]]:
        """Return the most recent mutations (newest first)."""
        all_muts = self._load_mutations()
        return list(reversed(all_muts[-limit:]))

    def rollback_last(self, count: int = 1, dry_run: bool = False) -> List[str]:
        """Rollback the last N mutations. Returns list of rolled-back mutation_ids."""
        import subprocess

        all_muts = self._load_mutations()
        if not all_muts:
            print("[ROLLBACK] No mutations to rollback.")
            return []

        to_rollback = all_muts[-count:]
        rolled = []

        for mut in reversed(to_rollback):
            mid = mut["mutation_id"]
            reverse_cmd = mut.get("reverse", "")
            target = mut.get("target", "unknown")

            if not reverse_cmd:
                print(f"[ROLLBACK] Skip {target}: no reverse operation recorded.")
                continue

            print(f"[ROLLBACK] {mut['operation']} {target}")
            print(f"  → {reverse_cmd}")

            if dry_run:
                rolled.append(mid)
                continue

            try:
                result = subprocess.run(
                    reverse_cmd,
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=120,
                )
                if result.returncode == 0:
                    print(f"  ✓ Rolled back successfully")
                    rolled.append(mid)
                else:
                    print(f"  ✗ Rollback failed (exit {result.returncode})")
                    if result.stderr:
                        print(f"    {result.stderr.strip()[:200]}")
            except Exception as e:
                print(f"  ✗ Rollback error: {e}")

        return rolled

    def generate_report(self) -> Dict[str, Any]:
        """Generate a summary report of all mutations."""
        all_muts = self._load_mutations()
        ops = {}
        targets = set()
        for m in all_muts:
            op = m.get("operation", "unknown")
            ops[op] = ops.get(op, 0) + 1
            targets.add(m.get("target", "unknown"))

        return {
            "total_mutations": len(all_muts),
            "operations": ops,
            "unique_targets": len(targets),
            "log_file": str(self.log_path),
            "last_mutation": all_muts[-1]["timestamp"] if all_muts else None,
        }
