#!/usr/bin/env bash
set -euo pipefail

# Always resolve to project root (not pwd-dependent)
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORK_DIR="$PROJECT_ROOT/webr-build"

echo "▶ Project root: $PROJECT_ROOT"
echo "▶ Work dir:      $WORK_DIR"

mkdir -p "$WORK_DIR/library"
mkdir -p "$WORK_DIR/webr-repo"
mkdir -p "$WORK_DIR/public/webr"

echo "▶ Starting WebR build container..."

docker run --rm -it \
  --platform linux/amd64 \
  -v "$WORK_DIR:/work" \
  -w /work \
  ghcr.io/r-wasm/webr:latest \
  bash -lc "
    set -euo pipefail

    echo '▶ Installing R packages...'
    Rscript /work/install-rwasm.R

  "

echo "✔ Build complete"
echo "→ Output: $WORK_DIR/public/webr/"