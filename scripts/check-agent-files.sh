#!/usr/bin/env bash
# check-agent-files.sh - Verifies agent entry points route to docs/ and stay in sync.
# Usage: scripts/check-agent-files.sh [--verbose]

set -euo pipefail

VERBOSE=""
if [ "${1:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
elif [ "${1:-}" != "" ]; then
  echo "Usage: scripts/check-agent-files.sh [--verbose]" >&2
  exit 1
fi

PASS=0
FAIL=0
WARN=0
ERRORS=()

AGENT_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  "CODEX.md"
  ".cursorrules"
  ".cursor/rules/global.mdc"
  ".github/copilot-instructions.md"
)

ROUTING_TABLE_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  "CODEX.md"
  ".cursor/rules/global.mdc"
  ".github/copilot-instructions.md"
)

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

check_routes_to_docs() {
  local file="$1"

  if [ ! -f "$file" ]; then
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Missing agent file: $file")
    return
  fi

  if grep -q "docs/" "$file"; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then echo "  ✓ $file routes to docs/"; fi
  else
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ $file does not reference docs/")
  fi
}

check_referenced_paths_exist() {
  local file="$1"
  local refs
  local ref
  local missing=0

  if [ ! -f "$file" ]; then
    return
  fi

  refs=$(grep -oE '`[^`]+`' "$file" | tr -d '`' | grep -E '^(docs/|plans/|\.cursor/|\.github/|AGENTS\.md$|CLAUDE\.md$|CODEX\.md$)' | sort -u || true)

  if [ -z "$refs" ]; then
    WARN=$((WARN + 1))
    ERRORS+=("  ⚠ $file contains no backticked routing targets to validate")
    return
  fi

  while IFS= read -r ref; do
    if [ -z "$ref" ]; then
      continue
    fi

    if [ ! -e "$ref" ]; then
      FAIL=$((FAIL + 1))
      missing=1
      ERRORS+=("  ✗ $file references missing path: $ref")
    elif [ "$VERBOSE" = "--verbose" ]; then
      echo "  ✓ $file target exists: $ref"
    fi
  done <<EOF
$refs
EOF

  if [ "$missing" -eq 0 ]; then
    PASS=$((PASS + 1))
  fi
}

extract_routing_table_pairs() {
  local file="$1"
  local line
  local stripped
  local col1
  local col2
  local task
  local target

  if [ ! -f "$file" ]; then
    return
  fi

  while IFS= read -r line; do
    case "$line" in
      \|*) ;;
      *) continue ;;
    esac

    stripped="${line//|/}"
    stripped="${stripped//-/}"
    stripped="${stripped//:/}"
    stripped="${stripped// /}"
    stripped="${stripped//$'\t'/}"
    if [ -z "$stripped" ]; then
      continue
    fi

    IFS='|' read -r _ col1 col2 _ <<< "$line"
    task=$(trim "$col1")
    target=$(printf '%s\n' "$col2" | sed -n 's/.*`\([^`][^`]*\)`.*/\1/p')

    if [ -n "$task" ] && [ -n "$target" ]; then
      printf '%s\t%s\n' "$task" "$target"
    fi
  done < "$file"
}

check_routing_consistency() {
  local map_file
  local had_errors=0
  local file
  local task
  local target
  local existing
  local existing_target
  local existing_file

  map_file=$(mktemp)

  for file in "${ROUTING_TABLE_FILES[@]}"; do
    if [ ! -f "$file" ]; then
      continue
    fi

    while IFS=$'\t' read -r task target; do
      if [ -z "$task" ] || [ -z "$target" ]; then
        continue
      fi

      if [ ! -e "$target" ]; then
        FAIL=$((FAIL + 1))
        had_errors=1
        ERRORS+=("  ✗ $file routing table points to missing target for \"$task\": $target")
      fi

      existing=$(awk -F'\t' -v task="$task" '$1 == task {print $2 "\t" $3; exit}' "$map_file")
      if [ -n "$existing" ]; then
        existing_target=${existing%%$'\t'*}
        existing_file=${existing#*$'\t'}

        if [ "$existing_target" != "$target" ]; then
          FAIL=$((FAIL + 1))
          had_errors=1
          ERRORS+=("  ✗ Routing mismatch for \"$task\": $existing_file -> $existing_target, $file -> $target")
        fi
      else
        printf '%s\t%s\t%s\n' "$task" "$target" "$file" >> "$map_file"
      fi
    done < <(extract_routing_table_pairs "$file")
  done

  rm -f "$map_file"

  if [ "$had_errors" -eq 0 ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  ✓ Routing table targets are consistent across entry files"
    fi
  fi
}

check_no_content_duplication() {
  local file="$1"
  local line_count

  if [ ! -f "$file" ]; then
    return
  fi

  line_count=$(wc -l < "$file" | tr -d ' ')

  if [ "$line_count" -gt 150 ]; then
    WARN=$((WARN + 1))
    ERRORS+=("  ⚠ $file is $line_count lines (max recommended: 150) - may contain duplicated content")
  fi
}

check_no_guide_modification_instructions() {
  local file="$1"
  local matches
  local match
  local line_no
  local text

  if [ ! -f "$file" ]; then
    return
  fi

  matches=$(grep -niE '(modify|edit|update)[^[:cntrl:]]*guide|guide[^[:cntrl:]]*(modify|edit|update)' "$file" || true)
  if [ -z "$matches" ]; then
    return
  fi

  while IFS= read -r match; do
    if [ -z "$match" ]; then
      continue
    fi

    line_no=${match%%:*}
    text=${match#*:}

    if printf '%s\n' "$text" | grep -Eqi "(never|do not|don't)[^[:cntrl:]]*(modify|edit|update)[^[:cntrl:]]*guide|guide[^[:cntrl:]]*(read-only|immutable)"; then
      continue
    fi

    WARN=$((WARN + 1))
    ERRORS+=("  ⚠ $file:$line_no may instruct agents to modify guide/ (should be read-only)")
  done <<EOF
$matches
EOF
}

echo "Checking agent entry points..."
echo ""

for file in "${AGENT_FILES[@]}"; do
  echo "Checking $file:"
  check_routes_to_docs "$file"
  check_referenced_paths_exist "$file"
  check_no_content_duplication "$file"
  check_no_guide_modification_instructions "$file"
done

check_routing_consistency

echo ""
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"

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
  echo ""
  echo "All agent file checks passed."
fi
