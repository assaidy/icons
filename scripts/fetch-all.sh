#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

LIBRARIES=("lucide" "material-icons" "tabler-icons")
CHANGES=false
ANY_FAIL=false

echo "── Checking ${#LIBRARIES[@]} libraries ──"

for lib in "${LIBRARIES[@]}"; do
  script="$ROOT_DIR/scripts/libraries/${lib}.sh"
  if [[ ! -f "$script" ]]; then
    err "no script for $lib"
    ANY_FAIL=true
    continue
  fi

  output=$("$script" 2>&1) && rc=0 || rc=$?

  if [[ "$rc" -ne 0 ]]; then
    echo "$output"
    ANY_FAIL=true
    continue
  fi

  if ! echo "$output" | grep -q "no changes"; then
    CHANGES=true
  fi
  echo "$output" | head -1
  echo "$output" | grep . | tail -n +2 | sed 's/^/  /'

done

echo ""
if [[ "$ANY_FAIL" == "true" ]]; then
  echo "✗ Some libraries failed"
  exit 1
elif [[ "$CHANGES" == "true" ]]; then
  echo "✓ Updates applied — run 'go run gen/main.go' to regenerate Go code"
else
  echo "✓ No changes"
fi
