#!/usr/bin/env python3
"""Placeholder script illustrating control of Docker via its socket."""

import os

DOCKER_SOCK = os.environ.get("DOCKER_SOCK", "/var/run/docker.sock")
print(f"Would attempt takeover using {DOCKER_SOCK}")
