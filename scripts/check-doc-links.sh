#!/usr/bin/env bash
# check-doc-links.sh — Validates that local Markdown links resolve.
# Usage: scripts/check-doc-links.sh [--verbose]

set -euo pipefail

VERBOSE=""
if [ "${1:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
elif [ "${1:-}" != "" ]; then
  echo "Usage: scripts/check-doc-links.sh [--verbose]" >&2
  exit 1
fi

PASS=0
FAIL=0
ERRORS=()

is_external_link() {
  local target="$1"
  [[ "$target" == http://* ]] || \
    [[ "$target" == https://* ]] || \
    [[ "$target" == mailto:* ]] || \
    [[ "$target" == tel:* ]] || \
    [[ "$target" == \#* ]]
}

is_placeholder_link() {
  local file="$1"
  local target="$2"

  file=${file#./}

  if [ "$file" != "plans/_TEMPLATE.md" ]; then
    return 1
  fi

  case "$target" in
    "../docs/path/to/DOC.md"|"../docs/architecture/ADR/NNN-title.md"|"./active/PLAN-YYY-title.md")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_file_links() {
  local file="$1"
  local line
  local trimmed
  local line_no
  local in_code_block=0
  local full_match
  local target
  local target_path
  local resolved

  line_no=0

  while IFS= read -r line || [ -n "$line" ]; do
    line_no=$((line_no + 1))
    trimmed="${line#"${line%%[![:space:]]*}"}"

    case "$trimmed" in
      '```'*)
      if [ "$in_code_block" -eq 0 ]; then
        in_code_block=1
      else
        in_code_block=0
      fi
      continue
      ;;
    esac

    if [ "$in_code_block" -eq 1 ]; then
      continue
    fi

    while IFS= read -r full_match; do
      [ -z "$full_match" ] && continue
      target=$(printf '%s\n' "$full_match" | sed -n 's/.*](\([^)]*\)).*/\1/p')

      [ -z "$target" ] && continue

      # Markdown allows links like [text](<path with spaces.md>)
      target=${target#<}
      target=${target%>}

      if is_external_link "$target"; then
        continue
      fi

      target_path=${target%%#*}
      [ -z "$target_path" ] && continue

      if is_placeholder_link "$file" "$target_path"; then
        continue
      fi

      if [[ "$target_path" == /* ]]; then
        resolved=".${target_path}"
      else
        resolved="$(dirname "$file")/$target_path"
      fi

      if [ ! -e "$resolved" ]; then
        FAIL=$((FAIL + 1))
        ERRORS+=("  ✗ $file:$line_no -> $target_path")
      else
        PASS=$((PASS + 1))
        if [ "$VERBOSE" = "--verbose" ]; then
          echo "  ✓ $file:$line_no -> $target_path"
        fi
      fi
    done < <(printf '%s\n' "$line" | grep -oE '\[[^]]+\]\([^)]+\)' || true)
  done < "$file"
}

echo "Checking local Markdown links..."
echo ""

while IFS= read -r file; do
  validate_file_links "$file"
done < <(find . -type f \( -name "*.md" -o -name "*.mdc" \) \
  -not -path "./.git/*" \
  -not -path "./AI-Research-SKILLs-main/*" \
  -not -path "./node_modules/*" \
  -print | sort)

echo "Results: $PASS valid, $FAIL broken"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Broken links:"
  for err in "${ERRORS[@]}"; do
    echo "$err"
  done
fi

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "All local Markdown links are valid."
fi
