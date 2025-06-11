#!/bin/bash
# Run docker-slim to slim an image and print before/after sizes
# Usage: ./docker_slim_profile.sh <image>
set -euo pipefail
IMAGE="$1"
echo "Original image size:"
docker images "$IMAGE" --format '{{.Repository}}:{{.Tag}} {{.Size}}'
slim build --tag "$IMAGE.slim" "$IMAGE"
echo "Slimmed image size:"
docker images "$IMAGE.slim" --format '{{.Repository}}:{{.Tag}} {{.Size}}'
