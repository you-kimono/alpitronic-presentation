#!/usr/bin/env bash
# Pre-render hook: build diagrams/*.dot -> diagrams/*.svg with the system
# graphviz. Quarto's bundled graphviz-wasm crashes on splines=curved
# ("memory access out of bounds"), so inline {dot} cells cannot draw arcs.
set -euo pipefail

if ! command -v dot >/dev/null 2>&1; then
  echo "render-diagrams: graphviz 'dot' not found on PATH" >&2
  exit 1
fi

shopt -s nullglob
for src in diagrams/*.dot; do
  out="${src%.dot}.svg"
  if [[ ! -f "$out" || "$src" -nt "$out" ]]; then
    echo "render-diagrams: $src -> $out"
    dot -Tsvg "$src" -o "$out"
  fi
done
