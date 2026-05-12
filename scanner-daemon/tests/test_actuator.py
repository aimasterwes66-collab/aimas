#!/usr/bin/env python3
"""Tests for the AIMAS Scanner Daemon actuator module.

Run with: python3 -m unittest tests.test_actuator
"""

import os
import sys
import unittest

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PACKAGE_ROOT = os.path.dirname(_SCRIPT_DIR)
if _PACKAGE_ROOT not in sys.path:
    sys.path.insert(0, _PACKAGE_ROOT)

from aimas_scanner.actuator import Actuator


class MockState:
    """Minimal mock system state for testing."""
    def __init__(self, installed=None):
        self.installed_bins = installed or {}


class TestActuator(unittest.TestCase):

    def test_build_plan_empty(self):
        state = {"installed_bins": {"git": "/usr/bin/git"}}
        actuator = Actuator(state, dry_run=True)
        intent = {"capabilities": [], "run_commands": []}
        plan = actuator.build_plan(intent)
        self.assertEqual(plan, [])

    def test_build_plan_skips_installed(self):
        state = {"installed_bins": {"git": "/usr/bin/git"}}
        actuator = Actuator(state, dry_run=True)
        intent = {
            "capabilities": [{
                "capability": "dev",
                "confidence": 1.0,
                "tools": [{"name": "git", "required": True}]
            }],
            "run_commands": []
        }
        plan = actuator.build_plan(intent)
        self.assertEqual(len(plan), 0)

    def test_build_plan_installs_missing(self):
        state = {"installed_bins": {}}
        actuator = Actuator(state, dry_run=True)
        intent = {
            "capabilities": [{
                "capability": "dev",
                "confidence": 1.0,
                "tools": [{"name": "git", "required": True}]
            }],
            "run_commands": []
        }
        plan = actuator.build_plan(intent)
        self.assertEqual(len(plan), 1)
        self.assertEqual(plan[0]["target"], "git")
        self.assertEqual(plan[0]["action"], "install")

    def test_fuzzy_lookup(self):
        actuator = Actuator({}, dry_run=True)
        result = actuator._fuzzy_lookup("docker")
        self.assertIsNotNone(result)
        self.assertIn("method", result)

    def test_generate_reverse_apt(self):
        actuator = Actuator({}, dry_run=True)
        reverse = actuator._generate_reverse({"method": "apt", "target": "git"})
        self.assertIn("apt remove", reverse)

    def test_generate_reverse_pipx(self):
        actuator = Actuator({}, dry_run=True)
        reverse = actuator._generate_reverse({"method": "pipx", "target": "poetry"})
        self.assertIn("pipx uninstall", reverse)


if __name__ == "__main__":
    unittest.main()
