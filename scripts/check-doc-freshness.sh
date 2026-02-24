#!/usr/bin/env bash
# check-doc-freshness.sh — Checks that all docs have review dates and flags stale ones
# Usage: scripts/check-doc-freshness.sh [--max-age-days 30]

set -euo pipefail

MAX_AGE_DAYS=30
FAIL_ON_STALE=0

usage() {
  cat <<EOF
Usage: scripts/check-doc-freshness.sh [--max-age-days N]

Options:
  --max-age-days N   Maximum allowed age (in days) for reviewed docs.
  --fail-on-stale    Exit with status 1 when stale docs are found.
  -h, --help         Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-age-days)
      if [[ $# -lt 2 ]]; then
        echo "Error: --max-age-days requires a numeric value." >&2
        usage
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-age-days must be a non-negative integer (got: $2)." >&2
        usage
        exit 1
      fi
      MAX_AGE_DAYS="$2"
      shift 2
      ;;
    --fail-on-stale)
      FAIL_ON_STALE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

PASS=0
FAIL=0
STALE=0
ERRORS=()

TODAY=$(date +%s)

check_freshness() {
  local file="$1"

  # Extract reviewed date from <!-- reviewed: YYYY-MM-DD --> comment
  local review_date
  review_date=$(sed -n 's/.*<!-- reviewed: \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\) -->.*/\1/p' "$file" 2>/dev/null | head -1)

  if [ -z "$review_date" ]; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ No freshness date: $file")
    return
  fi

  # Calculate age in days
  local review_ts
  review_ts=$(date -j -f "%Y-%m-%d" "$review_date" +%s 2>/dev/null || date -d "$review_date" +%s 2>/dev/null || echo "0")

  if [ "$review_ts" = "0" ]; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Invalid date format in: $file (found: $review_date)")
    return
  fi

  local age_days=$(( (TODAY - review_ts) / 86400 ))

  if [ "$age_days" -gt "$MAX_AGE_DAYS" ]; then
    STALE=$((STALE + 1))
    ERRORS+=("  ⚠ Stale ($age_days days old): $file (reviewed: $review_date)")
  else
    PASS=$((PASS + 1))
  fi
}

echo "Checking documentation freshness (max age: ${MAX_AGE_DAYS} days)..."
echo ""

# Find all markdown files in docs/
while IFS= read -r -d '' file; do
  check_freshness "$file"
done < <(find docs -name "*.md" -type f -print0)

echo "Results: $PASS fresh, $STALE stale, $FAIL missing date"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Issues:"
  for err in "${ERRORS[@]}"; do
    echo "$err"
  done
fi

if [ "$FAIL" -gt 0 ]; then
  exit 1
elif [ "$STALE" -gt 0 ]; then
  echo ""
  if [ "$FAIL_ON_STALE" -eq 1 ]; then
    echo "Error: $STALE stale documents found (fail-on-stale enabled)."
    exit 1
  fi
  echo "Warning: $STALE stale documents found. Run doc gardening workflow."
  exit 0
else
  echo "All documents are fresh."
fi
