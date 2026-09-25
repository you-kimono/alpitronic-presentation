#!/usr/bin/env bash
# Export the revealjs deck to PDF via reveal's own ?print-pdf mode, driven by
# headless Chrome. Not "quarto render --to pdf": that re-renders through LaTeX
# and loses custom.scss, the arrows.lua filter and all reveal layout.
#
# Pass --no-render to skip the quarto step and print the existing _output HTML.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

OUT_DIR="_output"
HTML="$OUT_DIR/index.html"
PDF="$OUT_DIR/index.pdf"

chrome=""
for c in google-chrome google-chrome-stable chromium chromium-browser; do
  if command -v "$c" >/dev/null 2>&1; then chrome="$c"; break; fi
done
if [[ -z "$chrome" ]]; then
  echo "render-pdf: no Chrome/Chromium found on PATH" >&2
  exit 1
fi

if [[ "${1:-}" != "--no-render" ]]; then
  echo "render-pdf: quarto render"
  quarto render
fi

if [[ ! -f "$HTML" ]]; then
  echo "render-pdf: $HTML not found (run without --no-render)" >&2
  exit 1
fi

echo "render-pdf: $HTML -> $PDF"
# --virtual-time-budget lets reveal finish laying out and paginating before the
# snapshot; --run-all-compositor-stages-before-draw avoids half-painted slides.
"$chrome" --headless --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=25000 \
  --run-all-compositor-stages-before-draw \
  --print-to-pdf="$PDF" \
  "file://$PWD/$HTML?print-pdf"

if command -v pdfinfo >/dev/null 2>&1; then
  echo "render-pdf: $(pdfinfo "$PDF" | awk '/^Pages:/ {print $2}') pages"
fi
