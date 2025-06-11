#!/usr/bin/env python3
"""Check which PID namespace this process is running in."""

from pathlib import Path

ns = Path('/proc/self/ns/pid').readlink()
print(f"Current PID namespace: {ns}")
