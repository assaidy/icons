#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib.sh"

REPO="lucide-icons/lucide"
PKG_DIR="$ROOT_DIR/lucide"
VERSION_FILE="$PKG_DIR/.version"
CURRENT=$(read_version "$VERSION_FILE")

LATEST=$(get_latest_gh_release "$REPO")
if [[ -z "$LATEST" ]]; then
  err "could not determine latest version"
  exit 1
fi

if [[ "$CURRENT" == "$LATEST" ]]; then
  echo "lucide: no changes (${CURRENT})"
  exit 0
fi

TMP=$(download_gh_release "$REPO" "$LATEST" "svg")

NEW_COUNT=$(find "$TMP/svgs" -maxdepth 1 -name "*.svg" -type f | wc -l)
OLD_COUNT=$(find "$PKG_DIR" -maxdepth 1 -name "*.svg" -type f | wc -l 2>/dev/null || echo 0)

if diff_svgs "$PKG_DIR" "$TMP/svgs"; then
  log "lucide: same SVGs, only version bump"
  rm -rf "$PKG_DIR"/*.svg "$PKG_DIR/LICENSE" 2>/dev/null || true
  cp "$TMP/svgs/"*.svg "$PKG_DIR/"
  [[ -f "$TMP/svgs/LICENSE" ]] && cp "$TMP/svgs/LICENSE" "$PKG_DIR/LICENSE"
  write_version "$VERSION_FILE" "$LATEST"
  echo "lucide: bumped $CURRENT → $LATEST (${NEW_COUNT} icons)"
else
  echo "lucide: $CURRENT → $LATEST"
  echo "  old: ${OLD_COUNT} icons, new: ${NEW_COUNT} icons"
  report_svg_diff "$PKG_DIR" "$TMP/svgs"

  rm -rf "$PKG_DIR"/*.svg "$PKG_DIR/LICENSE" 2>/dev/null || true
  cp "$TMP/svgs/"*.svg "$PKG_DIR/"
  [[ -f "$TMP/svgs/LICENSE" ]] && cp "$TMP/svgs/LICENSE" "$PKG_DIR/LICENSE"
  write_version "$VERSION_FILE" "$LATEST"
fi

rm -rf "$TMP"
