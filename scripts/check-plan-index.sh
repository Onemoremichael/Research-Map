#!/usr/bin/env bash
# check-plan-index.sh — Validates plan metadata and plans/_INDEX.md coverage.
# Usage: scripts/check-plan-index.sh [--verbose]

set -euo pipefail

VERBOSE=""
if [ "${1:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
elif [ "${1:-}" != "" ]; then
  echo "Usage: scripts/check-plan-index.sh [--verbose]" >&2
  exit 1
fi

INDEX_FILE="plans/_INDEX.md"
PASS=0
FAIL=0
ERRORS=()

if [ ! -f "$INDEX_FILE" ]; then
  echo "Missing $INDEX_FILE" >&2
  exit 1
fi

is_valid_status() {
  case "$1" in
    Draft|Active|Completed|Abandoned)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

extract_status() {
  local file="$1"
  local status

  status=$(sed -nE 's/^Status:[[:space:]]*([A-Za-z]+).*/\1/p' "$file" | head -1)
  if [ -n "$status" ]; then
    printf '%s' "$status"
    return
  fi

  status=$(sed -nE 's/^\|[[:space:]]*Status[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/p' "$file" | head -1 | xargs)
  printf '%s' "$status"
}

extract_plan_id() {
  local file="$1"
  local plan_id

  plan_id=$(sed -nE 's/^Plan ID:[[:space:]]*(PLAN-[0-9]+).*/\1/p' "$file" | head -1)
  if [ -n "$plan_id" ]; then
    printf '%s' "$plan_id"
    return
  fi

  plan_id=$(sed -nE 's/^\|[[:space:]]*Plan ID[[:space:]]*\|[[:space:]]*(PLAN-[0-9]+)[[:space:]]*\|.*/\1/p' "$file" | head -1)
  if [ -n "$plan_id" ]; then
    printf '%s' "$plan_id"
    return
  fi

  plan_id=$(basename "$file" | sed -nE 's/^(PLAN-[0-9]+).*/\1/p')
  printf '%s' "$plan_id"
}

check_plan_file() {
  local file="$1"
  local status
  local plan_id
  local location

  location=$(dirname "$file")

  if ! grep -Eq '<!-- reviewed: [0-9]{4}-[0-9]{2}-[0-9]{2} -->' "$file"; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Missing freshness tag: $file")
  fi

  status=$(extract_status "$file")
  if [ -z "$status" ]; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Missing plan status: $file")
  elif ! is_valid_status "$status"; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Invalid plan status '$status' in $file")
  else
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  ✓ $file status: $status"
    fi
  fi

  if [ "$location" = "plans/active" ] && { [ "$status" = "Completed" ] || [ "$status" = "Abandoned" ]; }; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Active plan has terminal status ($status): $file")
  fi

  if [ "$location" = "plans/completed" ] && { [ "$status" = "Draft" ] || [ "$status" = "Active" ]; }; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Completed plan has non-terminal status ($status): $file")
  fi

  plan_id=$(extract_plan_id "$file")
  if [ -z "$plan_id" ]; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Missing plan ID: $file")
  elif ! grep -Fq "$plan_id" "$INDEX_FILE"; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Plan ID not listed in plans/_INDEX.md: $plan_id ($file)")
  else
    PASS=$((PASS + 1))
  fi
}

PLAN_FILES=$(find plans/active plans/completed -type f -name "*.md" | sort)

if [ -z "$PLAN_FILES" ]; then
  echo "Checking plan index integrity..."
  echo "Results: 0 plan files found, 0 issues"
  echo "No plan files to validate."
  exit 0
fi

while IFS= read -r file; do
  [ -z "$file" ] && continue
  check_plan_file "$file"
done <<EOF_FILES
$PLAN_FILES
EOF_FILES

echo "Checking plan index integrity..."
echo "Results: $PASS checks passed, $FAIL issues"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Issues:"
  for err in "${ERRORS[@]}"; do
    echo "$err"
  done
fi

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "Plan index integrity checks passed."
fi
