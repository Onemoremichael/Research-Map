#!/usr/bin/env bash
# check-structure.sh — Validates that all required files and directories exist
# Usage: scripts/check-structure.sh [--verbose]

set -euo pipefail

VERBOSE="${1:-}"
PASS=0
FAIL=0
ERRORS=()

check_exists() {
  local path="$1"
  local type="$2" # "file" or "dir"

  if [ "$type" = "dir" ] && [ -d "$path" ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then echo "  ✓ $path"; fi
  elif [ "$type" = "file" ] && [ -f "$path" ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then echo "  ✓ $path"; fi
  else
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ Missing $type: $path")
    if [ "$VERBOSE" = "--verbose" ]; then echo "  ✗ Missing $type: $path"; fi
  fi
}

check_adr_numbering() {
  local adr_dir="docs/architecture/ADR"
  local file
  local base
  local num
  local expected=1
  local found=0

  if [ ! -d "$adr_dir" ]; then
    return
  fi

  while IFS= read -r file; do
    FAIL=$((FAIL + 1))
    ERRORS+=("  ✗ ADR file does not follow numbering format (NNN-title.md): $file")
  done < <(find "$adr_dir" -maxdepth 1 -type f -name "*.md" \
    ! -name "000-template.md" ! -name "[0-9][0-9][0-9]-*.md" | sort)

  while IFS= read -r file; do
    found=1
    base=$(basename "$file")
    num=${base%%-*}
    num=$((10#$num))

    if [ "$num" -ne "$expected" ]; then
      FAIL=$((FAIL + 1))
      ERRORS+=("  ✗ ADR numbering gap: expected $(printf '%03d' "$expected"), found $(printf '%03d' "$num") in $base")
      expected=$((num + 1))
      continue
    fi

    expected=$((expected + 1))
  done < <(find "$adr_dir" -maxdepth 1 -type f -name "[0-9][0-9][0-9]-*.md" \
    ! -name "000-template.md" | sort)

  if [ "$found" -eq 1 ]; then
    PASS=$((PASS + 1))
    if [ "$VERBOSE" = "--verbose" ]; then echo "  ✓ ADR numbering is sequential"; fi
  fi
}

echo "Checking repository structure..."
echo ""

# Root files
echo "Root files:"
check_exists "README.md" "file"
check_exists "AGENTS.md" "file"
check_exists "CLAUDE.md" "file"
check_exists "ARCHITECTURE.md" "file"
check_exists ".gitignore" "file"
check_exists "LICENSE" "file"

# Agent entry points
echo "Agent entry points:"
check_exists "CODEX.md" "file"
check_exists ".cursorrules" "file"
check_exists ".cursor/rules/global.mdc" "file"
check_exists ".github/copilot-instructions.md" "file"
check_exists ".claude/settings.json" "file"
check_exists ".codex/setup.sh" "file"

# Docs structure
echo "Documentation:"
check_exists "docs" "dir"
check_exists "docs/_INDEX.md" "file"
check_exists "docs/architecture" "dir"
check_exists "docs/architecture/OVERVIEW.md" "file"
check_exists "docs/architecture/DEPENDENCY_RULES.md" "file"
check_exists "docs/architecture/ADR" "dir"
check_exists "docs/architecture/ADR/000-template.md" "file"
check_exists "docs/golden-rules" "dir"
check_exists "docs/golden-rules/PRINCIPLES.md" "file"
check_exists "docs/golden-rules/CODING_STANDARDS.md" "file"
check_exists "docs/quality" "dir"
check_exists "docs/quality/QUALITY_SCORECARD.md" "file"
check_exists "docs/quality/TECH_DEBT_REGISTER.md" "file"
check_exists "docs/workflows" "dir"
check_exists "docs/workflows/DEVELOPMENT.md" "file"
check_exists "docs/workflows/RESEARCH_MANAGEMENT.md" "file"
check_exists "docs/workflows/PAPER_WRITING.md" "file"
check_exists "docs/workflows/PR_REVIEW.md" "file"
check_exists "docs/workflows/TESTING.md" "file"
check_exists "docs/workflows/DOC_GARDENING.md" "file"
check_exists "docs/research-ops" "dir"
check_exists "docs/research-ops/PROJECT_INTAKE_TEMPLATE.md" "file"
check_exists "docs/research-ops/HYPOTHESIS_REGISTER_TEMPLATE.md" "file"
check_exists "docs/research-ops/EXPERIMENT_LOG_TEMPLATE.md" "file"
check_exists "docs/research-ops/LITERATURE_TRACKER_TEMPLATE.md" "file"
check_exists "docs/research-ops/RESULT_EVIDENCE_TEMPLATE.md" "file"
check_exists "docs/agent-guide" "dir"
check_exists "docs/agent-guide/ONBOARDING.md" "file"
check_exists "docs/agent-guide/COMMON_TASKS.md" "file"
check_exists "docs/session" "dir"
check_exists "docs/session/SESSION_HANDOFF.md" "file"

# Plans structure
echo "Plans:"
check_exists "plans" "dir"
check_exists "plans/_INDEX.md" "file"
check_exists "plans/_TEMPLATE.md" "file"
check_exists "plans/active" "dir"
check_exists "plans/completed" "dir"

# Guide structure
echo "Guide:"
check_exists "guide" "dir"
check_exists "guide/README.md" "file"
check_exists "guide/01-why-agent-legibility.md" "file"
check_exists "guide/02-progressive-disclosure.md" "file"
check_exists "guide/03-multi-agent-setup.md" "file"
check_exists "guide/04-execution-plans.md" "file"
check_exists "guide/05-quality-and-enforcement.md" "file"
check_exists "guide/06-doc-gardening.md" "file"
check_exists "guide/07-session-handoffs.md" "file"
check_exists "guide/08-building-skills.md" "file"

# Skills structure
echo "Skills:"
check_exists ".claude/skills/research-map" "dir"
check_exists ".claude/skills/research-map/SKILL.md" "file"
check_exists ".claude/skills/research-map/references" "dir"
check_exists ".claude/skills/research-map/references/directory-spec.md" "file"
check_exists ".claude/skills/research-map/references/checklist.md" "file"
check_exists ".claude/skills/research-map/references/remediation.md" "file"
check_exists ".claude/skills/session-handoff" "dir"
check_exists ".claude/skills/session-handoff/SKILL.md" "file"
check_exists ".claude/skills/session-handoff/references" "dir"
check_exists ".claude/skills/session-handoff/references/handoff-template.md" "file"

# Scripts
echo "Scripts:"
check_exists "scripts/check-structure.sh" "file"
check_exists "scripts/check-doc-freshness.sh" "file"
check_exists "scripts/check-agent-files.sh" "file"
check_exists "scripts/check-doc-links.sh" "file"
check_exists "scripts/check-doc-index-coverage.sh" "file"
check_exists "scripts/check-plan-index.sh" "file"

# ADR numbering
echo "ADR numbering:"
check_adr_numbering

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Failures:"
  for err in "${ERRORS[@]}"; do
    echo "$err"
  done
  exit 1
else
  echo "All structure checks passed."
fi
