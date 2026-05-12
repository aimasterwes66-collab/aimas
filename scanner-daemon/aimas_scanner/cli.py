#!/usr/bin/env python3
"""Command-line interface for the AIMAS Scanner Daemon."""

import argparse
import sys
import os

# Ensure package root is importable
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PACKAGE_ROOT = os.path.dirname(_SCRIPT_DIR)
if _PACKAGE_ROOT not in sys.path:
    sys.path.insert(0, _PACKAGE_ROOT)

from aimas_scanner import __version__
from aimas_scanner.parser import IntentParser
from aimas_scanner.scanner import SystemScanner
from aimas_scanner.actuator import Actuator
from aimas_scanner.interpreter import LLMInterpreter
from aimas_scanner.watcher import IntentWatcher


def main() -> int:
    ap = argparse.ArgumentParser(
        prog="aimas-scanner",
        description="AIMAS Scanner Daemon — Markdown intent → system convergence",
    )
    ap.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    ap.add_argument("--converge", metavar="PATH", help="Converge system to match intent document")
    ap.add_argument("--dry-run", metavar="PATH", help="Preview convergence plan without executing")
    ap.add_argument("--status", action="store_true", help="Print current system state graph")
    ap.add_argument("--force-converge", action="store_true", help="Skip hash check and re-converge")
    ap.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    ap.add_argument("--daemon", action="store_true", help="Run continuous file watcher daemon")
    ap.add_argument("--watch", metavar="DIR", default="~/.config/aimas/intent", help="Directory to watch (with --daemon)")
    ap.add_argument("--interpret", metavar="PATH", help="Use LLM to interpret free-form intent text")

    args = ap.parse_args()

    if args.status:
        return cmd_status(args.verbose)

    if args.dry_run:
        return cmd_dry_run(args.dry_run, args.verbose)

    if args.converge:
        return cmd_converge(args.converge, args.force_converge, args.verbose)

    if args.interpret:
        return cmd_interpret(args.interpret, args.verbose)

    if args.daemon:
        return cmd_daemon(args.watch, args.verbose)

    ap.print_help()
    return 0


def cmd_status(verbose: bool) -> int:
    """Print a JSON-ish representation of the current System State Graph."""
    scanner = SystemScanner()
    state = scanner.probe()

    print("═" * 60)
    print("  AIMAS SYSTEM STATE GRAPH (SSG)")
    print("═" * 60)
    print(f"  os_type:        {state['os_type']}")
    print(f"  os_version:     {state['os_version']}")
    print(f"  arch:           {state['arch']}")
    print(f"  gpu_available:  {state['gpu_available']}")
    print(f"  cuda_version:   {state['cuda_version']}")
    print("")
    print("  package_managers:")
    for pm in state["package_managers"]:
        print(f"    - {pm}")
    print("")
    print("  installed_bins (sample):")
    for name, path in list(state["installed_bins"].items())[:10]:
        print(f"    {name:20s} → {path}")
    if len(state["installed_bins"]) > 10:
        print(f"    ... and {len(state['installed_bins']) - 10} more")
    print("")
    print("  service_status:")
    for svc, stat in state["service_status"].items():
        print(f"    {svc:20s} → {stat}")
    print("")
    print("  python_envs:")
    for env in state["python_envs"]:
        print(f"    - {env}")
    print("═" * 60)
    return 0


def cmd_dry_run(path: str, verbose: bool) -> int:
    """Parse intent, resolve capabilities, print plan. No execution."""
    if not os.path.isfile(path):
        print(f"[ERR] Intent file not found: {path}", file=sys.stderr)
        return 1

    parser = IntentParser()
    intent = parser.parse_file(path)

    print("═" * 60)
    print("  DRY RUN — INTENT ANALYSIS")
    print("═" * 60)
    print(f"  source:       {intent['source']}")
    print(f"  intent_id:    {intent['intent_id'][:16]}...")
    print(f"  frontmatter:  {intent['frontmatter']}")
    print("")
    print("  extracted_capabilities:")
    for cap in intent["capabilities"]:
        print(f"    - {cap['capability']:25s} (confidence: {cap['confidence']:.2f})")
        for tool in cap.get("tools", []):
            req = "required" if tool.get("required") else "optional"
            print(f"        {tool['name']:20s} [{req}]")
    print("")

    scanner = SystemScanner()
    state = scanner.probe()
    actuator = Actuator(state, dry_run=True)
    plan = actuator.build_plan(intent)

    print("  convergence_plan:")
    if not plan:
        print("    (nothing to do — system already converged)")
    for step in plan:
        print(f"    [{step['action']:12s}] {step['target']:30s} via {step['method']}")
        if step.get("command"):
            print(f"      → {step['command'][:80]}{'...' if len(step['command']) > 80 else ''}")
    print("═" * 60)
    return 0


def cmd_converge(path: str, force: bool, verbose: bool) -> int:
    """Parse intent, resolve capabilities, execute plan."""
    if not os.path.isfile(path):
        print(f"[ERR] Intent file not found: {path}", file=sys.stderr)
        return 1

    parser = IntentParser()
    intent = parser.parse_file(path)

    # Simple hash-based change detection (Phase 1: no persistence yet)
    hash_path = f"{path}.hash"
    current_hash = intent["intent_id"]
    if not force and os.path.isfile(hash_path):
        with open(hash_path) as f:
            last_hash = f.read().strip()
        if last_hash == current_hash:
            print("[INFO] Intent unchanged since last convergence. Use --force-converge to override.")
            return 0

    scanner = SystemScanner()
    state = scanner.probe()
    actuator = Actuator(state, dry_run=False)
    plan = actuator.build_plan(intent)

    if not plan:
        print("[OK] System already converged. Nothing to do.")
        return 0

    print("═" * 60)
    print("  CONVERGENCE EXECUTION")
    print("═" * 60)
    success = actuator.execute(plan, verbose=verbose)
    print("═" * 60)

    if success:
        with open(hash_path, "w") as f:
            f.write(current_hash)
        print("[OK] Convergence complete.")
        return 0
    else:
        print("[WARN] Convergence completed with errors.")
        return 1


def cmd_interpret(path: str, verbose: bool) -> int:
    """Use LLM to interpret free-form intent and print structured capabilities."""
    if not os.path.isfile(path):
        print(f"[ERR] File not found: {path}", file=sys.stderr)
        return 1

    with open(path, "r", encoding="utf-8") as f:
        text = f.read()

    interpreter = LLMInterpreter()
    print("═" * 60)
    print("  LLM SEMANTIC INTERPRETATION")
    print("═" * 60)
    print(f"  LLM available: {interpreter.available}")
    print(f"  Model: {interpreter.model}")
    print("")

    capabilities = interpreter.interpret(text)
    print(f"  Extracted {len(capabilities)} capability groups:")
    for cap in capabilities:
        print(f"\n    {cap['capability']} (confidence: {cap['confidence']:.2f})")
        for tool in cap.get("tools", []):
            req = "required" if tool.get("required") else "optional"
            ver = tool.get("version", "")
            ver_str = f" ({ver})" if ver else ""
            print(f"      - {tool['name']}{ver_str} [{req}]")
    print("═" * 60)
    return 0


def cmd_daemon(watch_dir: str, verbose: bool) -> int:
    """Run continuous file watcher that converges on intent changes."""
    watch_dir = os.path.expanduser(watch_dir)
    os.makedirs(watch_dir, exist_ok=True)

    def on_change(path: str) -> None:
        print(f"\n[DAEMON] Converging: {path}")
        cmd_converge(path, force=False, verbose=verbose)
        print("[DAEMON] Waiting for next change...\n")

    watcher = IntentWatcher([watch_dir], on_change, poll_interval=5.0)
    watcher.start()
    return 0


if __name__ == "__main__":
    sys.exit(main())
