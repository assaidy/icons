#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib.sh"

PKG="@material-design-icons/svg"
PARENT_DIR="$ROOT_DIR/materialicons"
VERSION_FILE="$PARENT_DIR/.version"
CURRENT=$(read_version "$VERSION_FILE")

LATEST=$(get_latest_npm_version "$PKG")
if [[ -z "$LATEST" ]]; then
  err "could not determine latest version"
  exit 1
fi

if [[ "$CURRENT" == "$LATEST" ]]; then
  echo "material-icons: no changes (${CURRENT})"
  exit 0
fi

TMP=$(download_npm_package "$PKG" "$LATEST" ".")

STYLES=("outlined" "round" "sharp")
echo "material-icons: $CURRENT → $LATEST"

for style in "${STYLES[@]}"; do
  STYLE_DIR="$PARENT_DIR/$style"
  OLD_COUNT=$(find "$STYLE_DIR" -maxdepth 1 -name "*.svg" -type f | wc -l 2>/dev/null || echo 0)

  mkdir -p "$STYLE_DIR"
  rm -rf "$STYLE_DIR"/*.svg "$STYLE_DIR/LICENSE" 2>/dev/null || true
  cp "$TMP/svgs/$style/"*.svg "$STYLE_DIR/"
  NEW_COUNT=$(ls "$STYLE_DIR"/*.svg 2>/dev/null | wc -l)

  echo "  $style: ${OLD_COUNT} → ${NEW_COUNT} icons"
done

# copy LICENSE to each style dir
for style in "${STYLES[@]}"; do
  [[ -f "$TMP/svgs/LICENSE" ]] && cp "$TMP/svgs/LICENSE" "$PARENT_DIR/$style/LICENSE"
done

write_version "$VERSION_FILE" "$LATEST"
rm -rf "$TMP"
