#!/usr/bin/env bash
# Export every part in tools/parts.txt to STL, then render preview images.
# Usage: tools/build.sh            (STLs + renders)
#        tools/build.sh --stl-only
# Needs: openscad, python3 (renders also need xvfb-run on headless Linux)
set -euo pipefail
cd "$(dirname "$0")/.."

OPENSCAD=${OPENSCAD:-openscad}
fail=0

echo "== STLs"
while read -r scad part out; do
  [[ -z "${scad:-}" || "$scad" == \#* ]] && continue
  mkdir -p "$(dirname "$out")"
  printf '  %-45s ' "$out"
  if "$OPENSCAD" -q -D "PART=\"$part\"" -o "$out" "$scad" 2>/tmp/rackit_build.log; then
    echo ok
  else
    echo FAILED; cat /tmp/rackit_build.log; fail=1
  fi
done < tools/parts.txt

if [[ "${1:-}" != "--stl-only" ]]; then
  echo "== renders"
  python3 tools/render.py || echo "  renders skipped"
fi

exit $fail
