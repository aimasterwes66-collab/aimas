#!/usr/bin/env python3
"""Tests for the AIMAS Scanner Daemon scanner module.

Run with: python3 -m unittest tests.test_scanner
"""

import os
import sys
import unittest

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PACKAGE_ROOT = os.path.dirname(_SCRIPT_DIR)
if _PACKAGE_ROOT not in sys.path:
    sys.path.insert(0, _PACKAGE_ROOT)

from aimas_scanner.scanner import SystemScanner


class TestSystemScanner(unittest.TestCase):

    def setUp(self):
        self.scanner = SystemScanner()

    def test_os_type(self):
        os_type = self.scanner._os_type()
        self.assertIsInstance(os_type, str)
        self.assertNotEqual(os_type, "unknown")

    def test_os_version(self):
        version = self.scanner._os_version()
        self.assertIsInstance(version, str)

    def test_arch(self):
        arch = self.scanner._arch()
        self.assertIn(arch, ["x86_64", "amd64", "arm64", "aarch64", "unknown"])

    def test_package_managers(self):
        pms = self.scanner._package_managers()
        self.assertIsInstance(pms, list)
        # On a bootstrapped system, at least apt should be present
        self.assertIn("apt", pms)

    def test_installed_bins(self):
        bins = self.scanner._installed_bins()
        self.assertIsInstance(bins, dict)
        # git and bash should almost always be present
        self.assertIn("git", bins)
        self.assertIn("bash", bins)

    def test_service_status(self):
        services = self.scanner._service_status()
        self.assertIsInstance(services, dict)
        for svc in ("ollama", "docker", "ssh"):
            self.assertIn(svc, services)

    def test_probe(self):
        state = self.scanner.probe()
        self.assertIn("os_type", state)
        self.assertIn("package_managers", state)
        self.assertIn("installed_bins", state)
        self.assertIn("service_status", state)
        self.assertIn("gpu_available", state)
        self.assertIn("python_envs", state)


if __name__ == "__main__":
    unittest.main()
