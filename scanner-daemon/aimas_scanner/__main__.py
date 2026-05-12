#!/usr/bin/env python3
"""Entry point for running aimas_scanner as a module."""

import sys
import os

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PACKAGE_ROOT = os.path.dirname(_SCRIPT_DIR)
if _PACKAGE_ROOT not in sys.path:
    sys.path.insert(0, _PACKAGE_ROOT)

from aimas_scanner.cli import main

if __name__ == "__main__":
    sys.exit(main())
