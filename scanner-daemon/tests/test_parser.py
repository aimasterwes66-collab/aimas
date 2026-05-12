#!/usr/bin/env python3
"""Tests for the AIMAS Scanner Daemon parser module.

Run with: python3 -m unittest tests.test_parser
"""

import os
import sys
import tempfile
import unittest

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PACKAGE_ROOT = os.path.dirname(_SCRIPT_DIR)
if _PACKAGE_ROOT not in sys.path:
    sys.path.insert(0, _PACKAGE_ROOT)

from aimas_scanner.parser import IntentParser


class TestIntentParser(unittest.TestCase):

    def setUp(self):
        self.parser = IntentParser()

    def test_frontmatter_extraction(self):
        text = """---
aimas_version: "0.1.0"
platform: linux
auto_execute: true
---

# Test Intent

Requires:
- git
- neovim
"""
        intent = self.parser.parse(text)
        self.assertEqual(intent["frontmatter"]["aimas_version"], "0.1.0")
        self.assertEqual(intent["frontmatter"]["platform"], "linux")
        self.assertTrue(intent["frontmatter"]["auto_execute"])

    def test_header_list_parsing(self):
        text = """# Test

## Requires
- git
- neovim
- python >= 3.10
"""
        intent = self.parser.parse(text)
        caps = intent["capabilities"]
        self.assertTrue(len(caps) >= 3)
        names = [c["tools"][0]["name"] for c in caps]
        self.assertIn("git", names)
        self.assertIn("neovim", names)

    def test_aimas_capability_block(self):
        text = """# Test

## Capabilities
```aimas-capability
{
  "category": "dev",
  "confidence": 0.95,
  "tools": [
    {"name": "docker", "required": true}
  ]
}
```
"""
        intent = self.parser.parse(text)
        caps = intent["capabilities"]
        self.assertTrue(any(c["capability"] == "dev" for c in caps))

    def test_aimas_run_block(self):
        text = """# Test

## Direct Commands
```aimas-run
echo hello world
```
"""
        intent = self.parser.parse(text)
        self.assertEqual(len(intent["run_commands"]), 1)
        self.assertIn("echo hello world", intent["run_commands"][0])

    def test_file_parsing(self):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".md", delete=False) as f:
            f.write("# Test\n\n## Requires\n- git\n")
            path = f.name
        try:
            intent = self.parser.parse_file(path)
            self.assertEqual(intent["source"], path)
            self.assertTrue(len(intent["capabilities"]) >= 1)
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()
