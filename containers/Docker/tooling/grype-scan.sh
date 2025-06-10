#!/bin/bash
# Simple wrapper around grype to scan a directory or list of images.
# Usage: grype-scan.sh <directory|image-list-file> [results-dir]
# Requires grype to be installed and accessible in PATH.

set -euo pipefail

if ! command -v grype >/dev/null 2>&1; then
  echo "grype command not found. Please install grype." >&2
  exit 1
fi

TARGET=${1:-}
RESULTS_DIR=${2:-grype-results}

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <directory|image-list-file> [results-dir]" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"

if [[ -d "$TARGET" ]]; then
  output="$RESULTS_DIR/$(basename "$TARGET").json"
  echo "[grype] scanning directory $TARGET"
  grype dir:"$TARGET" -o json > "$output"
  echo "Results saved to $output"
elif [[ -f "$TARGET" ]]; then
  while read -r image; do
    [[ -z "$image" ]] && continue
    sanitized=$(echo "$image" | tr '/:' '_')
    output="$RESULTS_DIR/${sanitized}.json"
    echo "[grype] scanning image $image"
    grype "$image" -o json > "$output"
    echo "Results saved to $output"
  done < "$TARGET"
else
  echo "Target $TARGET not found" >&2
  exit 1
fi
