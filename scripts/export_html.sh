#!/usr/bin/env bash
set -euo pipefail

# Helper script to run Godot headless export for HTML5
# Usage:
#   GODOT_BIN=/path/to/godot ./scripts/export_html.sh [output_dir] [export_preset]
# or
#   ./scripts/export_html.sh /path/to/godot [output_dir] [export_preset]

GODOT_BIN="${GODOT_BIN:-}"
if [ -z "$GODOT_BIN" ]; then
  if [ $# -ge 1 ] && [ -x "$1" ]; then
    GODOT_BIN="$1"
    shift
  fi
fi

OUT_DIR="${1:-build/html5}"
PRESET="${2:-HTML5}"

if [ -z "$GODOT_BIN" ]; then
  echo "ERROR: Godot binary not specified. Set GODOT_BIN environment variable or pass path as first argument."
  echo "Example: GODOT_BIN=/path/to/Godot_v4.2.0-stable_linux.x86_64 ./scripts/export_html.sh"
  exit 2
fi

if [ ! -x "$GODOT_BIN" ]; then
  echo "ERROR: GODOT_BIN ($GODOT_BIN) is not executable or not found"
  exit 3
fi

mkdir -p "$OUT_DIR"

# Export using Godot CLI. For HTML5 export you must have the HTML5 export template installed for this Godot version.
# The exported file path for HTML5 should be an index.html (Godot will write supporting files next to it).
OUT_HTML="$OUT_DIR/index.html"

echo "Running: $GODOT_BIN --export \"$PRESET\" $OUT_HTML"
"$GODOT_BIN" --export "$PRESET" "$OUT_HTML"

echo "Export complete. Files in: $OUT_DIR"

echo "Contents:" 
ls -la "$OUT_DIR" || true
