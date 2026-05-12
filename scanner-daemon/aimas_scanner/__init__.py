#!/usr/bin/env python3
"""AIMAS Scanner Daemon — Phase 1: Foundation

A declarative system convergence tool that reads Markdown intent documents
and converges the local machine toward the described state.

Usage:
    python3 -m aimas_scanner --converge tests/test_intent.md
    python3 -m aimas_scanner --dry-run tests/test_intent.md
    python3 -m aimas_scanner --status
"""

__version__ = "0.1.0-alpha"
__all__ = ["parser", "scanner", "actuator", "cli"]
