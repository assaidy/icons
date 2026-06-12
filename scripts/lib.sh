#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log()  { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*" 1>&2; }
err() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ERROR: $*" 1>&2; }

get_latest_gh_release() {
  local repo="$1"
  local tag
  tag=$(curl -sL -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$repo/releases/latest" \
    | jq -r '.tag_name // empty')
  if [[ -z "$tag" || "$tag" == "null" ]]; then
    tag=$(curl -sL -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$repo/tags" \
      | jq -r '.[0].name // empty')
  fi
  echo "$tag"
}

get_latest_npm_version() {
  local pkg="$1"
  npm view "$pkg" version 2>/dev/null || echo ""
}

read_version() {
  local file="$1"
  if [[ -f "$file" ]]; then cat "$file"; fi
}

write_version() {
  echo "$2" > "$1"
}

# download SVGs from a GitHub release archive into a temp directory
# prints the temp dir path on stdout
download_gh_release() {
  local repo="$1" tag="$2" svg_subdir="$3"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  log "Downloading $repo $tag"
  curl -sL -o "$tmp_dir/release.zip" "https://github.com/$repo/archive/refs/tags/$tag.zip"
  unzip -q -o "$tmp_dir/release.zip" -d "$tmp_dir/extracted"

  local root
  root=$(find "$tmp_dir/extracted" -mindepth 1 -maxdepth 1 -type d | head -1)

  local svg_dir="$tmp_dir/svgs"
  mkdir -p "$svg_dir"

  if [[ -d "$root/$svg_subdir" ]]; then
    cp "$root/$svg_subdir/"*.svg "$svg_dir/"
  else
    local found
    found=$(find "$root" -name "*.svg" -type f)
    if [[ -n "$found" ]]; then
      find "$root" -name "*.svg" -type f -exec cp {} "$svg_dir/" \;
    else
      err "No SVGs found in $root/$svg_subdir"
      rm -rf "$tmp_dir"
      return 1
    fi
  fi

  # copy license if found
  local license_file
  license_file=$(find "$root" -maxdepth 1 \( -name "LICENSE*" -o -name "LICENCE*" \) -type f | head -1)
  if [[ -n "$license_file" ]]; then
    cp "$license_file" "$svg_dir/LICENSE"
  fi

  echo "$tmp_dir"
}

# download SVGs from an npm package into a temp directory
# prints the temp dir path on stdout
download_npm_package() {
  local pkg="$1" version="$2" svg_subdir="$3"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  log "Downloading $pkg@$version"
  (
    cd "$tmp_dir"
    npm pack "${pkg}@${version}" --quiet
    local tarball
    tarball=$(ls *.tgz 2>/dev/null | head -1)
    tar -xzf "$tarball"
  )

  local svg_dir="$tmp_dir/svgs"
  mkdir -p "$svg_dir"

  if [[ -d "$tmp_dir/package/$svg_subdir" ]]; then
    cp "$tmp_dir/package/$svg_subdir/"*.svg "$svg_dir/"
  else
    local found
    found=$(find "$tmp_dir/package" -name "*.svg" -type f)
    if [[ -n "$found" ]]; then
      find "$tmp_dir/package" -name "*.svg" -type f -exec cp {} "$svg_dir/" \;
    else
      err "No SVGs found in package/$svg_subdir"
      rm -rf "$tmp_dir"
      return 1
    fi
  fi

  local license_file
  license_file=$(find "$tmp_dir/package" -maxdepth 1 \( -name "LICENSE*" -o -name "LICENCE*" \) -type f | head -1)
  if [[ -n "$license_file" ]]; then
    cp "$license_file" "$svg_dir/LICENSE"
  fi

  echo "$tmp_dir"
}

# diff SVGs between old_dir and new_dir, prints formatted report
# returns: 0 if identical, 1 if different
diff_svgs() {
  local old_dir="$1" new_dir="$2"

  # build sorted lists of svg filenames (excluding LICENSE)
  local old_file new_file
  old_file=$(mktemp)
  new_file=$(mktemp)

  if [[ -d "$old_dir" ]]; then
    find "$old_dir" -maxdepth 1 -name "*.svg" -type f -printf '%f\n' | sort > "$old_file" 2>/dev/null || true
  fi
  if [[ -d "$new_dir" ]]; then
    find "$new_dir" -maxdepth 1 -name "*.svg" -type f -printf '%f\n' | sort > "$new_file" 2>/dev/null || true
  fi

  local added removed
  added=$(comm -13 "$old_file" "$new_file" | wc -l)
  removed=$(comm -23 "$old_file" "$new_file" | wc -l)

  rm -f "$old_file" "$new_file"

  if [[ "$added" -eq 0 && "$removed" -eq 0 ]]; then
    return 0
  fi
  return 1
}

# report added/removed SVGs between old_dir and new_dir
report_svg_diff() {
  local old_dir="$1" new_dir="$2"

  local old_file new_file
  old_file=$(mktemp)
  new_file=$(mktemp)

  if [[ -d "$old_dir" ]]; then
    find "$old_dir" -maxdepth 1 -name "*.svg" -type f -printf '%f\n' | sort > "$old_file" 2>/dev/null || true
  fi
  if [[ -d "$new_dir" ]]; then
    find "$new_dir" -maxdepth 1 -name "*.svg" -type f -printf '%f\n' | sort > "$new_file" 2>/dev/null || true
  fi

  local added removed
  added=$(comm -13 "$old_file" "$new_file")
  removed=$(comm -23 "$old_file" "$new_file")

  if [[ -n "$removed" ]]; then
    echo "    removed ($(echo "$removed" | wc -l)):"
    echo "$removed" | sed 's/^/      - /'
  fi
  if [[ -n "$added" ]]; then
    echo "    added ($(echo "$added" | wc -l)):"
    echo "$added" | sed 's/^/      + /'
  fi

  rm -f "$old_file" "$new_file"
}
