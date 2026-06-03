#!/usr/bin/env bash
# Resize App Store screenshots to Apple-required dimensions (portrait 6.7" display).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/AppStoreScreenshots"

# App Store Connect accepted sizes (portrait) — 6.7" display:
WIDTH=1284
HEIGHT=2778

# Alternative 6.5" display: WIDTH=1242 HEIGHT=2688

if ! command -v sips >/dev/null 2>&1; then
  echo "sips not found (requires macOS)."
  exit 1
fi

shopt -s nullglob
files=("$OUT_DIR"/*.png)
if [ ${#files[@]} -eq 0 ]; then
  echo "No PNG files in $OUT_DIR"
  exit 1
fi

for f in "${files[@]}"; do
  base=$(basename "$f")
  [[ "$base" == *-backup.png ]] && continue
  w=$(sips -g pixelWidth "$f" 2>/dev/null | awk '/pixelWidth:/{print $2}')
  h=$(sips -g pixelHeight "$f" 2>/dev/null | awk '/pixelHeight:/{print $2}')
  if [ "$w" = "$WIDTH" ] && [ "$h" = "$HEIGHT" ]; then
    echo "✓ $base (already ${WIDTH}×${HEIGHT})"
    continue
  fi
  sips -z "$HEIGHT" "$WIDTH" "$f" --out "$f" >/dev/null
  echo "✓ $base (${w}×${h} → ${WIDTH}×${HEIGHT})"
done

echo ""
echo "Done. All screenshots are ${WIDTH}×${HEIGHT} px (portrait, 6.7\" display)."
