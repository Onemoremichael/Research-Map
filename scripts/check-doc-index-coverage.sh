#!/usr/bin/env bash
# check-doc-index-coverage.sh — Ensures docs/_INDEX.md covers all docs/*.md files.
# Usage: scripts/check-doc-index-coverage.sh [--verbose]

set -euo pipefail

VERBOSE=""
if [ "${1:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
elif [ "${1:-}" != "" ]; then
  echo "Usage: scripts/check-doc-index-coverage.sh [--verbose]" >&2
  exit 1
fi

INDEX_FILE="docs/_INDEX.md"
PASS=0
FAIL=0
ERRORS=()

if [ ! -f "$INDEX_FILE" ]; then
  echo "Missing $INDEX_FILE" >&2
  exit 1
fi

INDEX_LINKS=$(grep -oE '\[[^]]+\]\([^)]+\)' "$INDEX_FILE" | sed -E 's/.*\]\(([^)]+)\).*/\1/' || true)
INDEX_DOCS=()

while IFS= read -r target; do
  [ -z "$target" ] && continue

  target=${target#<}
  target=${target%>}
  target=${target%%#*}

  case "$target" in
    ""|http://*|https://*|mailto:*|tel:*|\#*)
      continue
      ;;
  esac

  case "$target" in
    *.md)
      ;;
    *)
      continue
      ;;
  esac

  resolved="docs/$target"
  INDEX_DOCS+=("$resolved")

  if [ ! -f "$resolved" ]; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ _INDEX entry points to missing doc: $resolved")
  elif [ "$VERBOSE" = "--verbose" ]; then
    echo "  ✓ indexed target exists: $resolved"
  fi
done <<EOF_LINKS
$INDEX_LINKS
EOF_LINKS

DOC_FILES=$(find docs -type f -name "*.md" ! -path "docs/_INDEX.md" | sort)

while IFS= read -r doc; do
  [ -z "$doc" ] && continue

  if printf '%s\n' "${INDEX_DOCS[@]}" | grep -Fxq "$doc"; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  ✓ indexed: $doc"
    fi
  else
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Missing from docs/_INDEX.md: $doc")
  fi
done <<EOF_DOCS
$DOC_FILES
EOF_DOCS

echo "Checking docs index coverage..."
echo "Results: $PASS indexed, $FAIL issues"

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
  echo "docs/_INDEX.md coverage is complete."
fi
