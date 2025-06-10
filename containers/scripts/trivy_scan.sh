#!/bin/bash
# Wrapper script to scan an image with Trivy
# Usage: ./trivy_scan.sh <image>
set -euo pipefail
IMAGE="$1"
trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE"
