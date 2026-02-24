# Research Map

Scaffold and audit a Research_Map-style repository for AI research work.

## Subcommands

### `/research-map scaffold`

Create missing framework structure in the current repo without overwriting existing files.

Creates/ensures:
- Root entry files (`AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.cursorrules`, copilot instructions)
- `docs/` structure with workflows, quality docs, architecture docs, handoff docs
- Research management templates under `docs/research-ops/`
- `plans/` structure with template and index
- Validation scripts in `scripts/`
- Claude skill config under `.claude/skills/`

### `/research-map audit`

Read-only compliance audit against the Research_Map standard.

Checks include:
- Structural completeness
- Agent routing consistency
- Documentation freshness
- docs index coverage and plan index integrity
- Plan hygiene
- Citation-integrity policy presence
- Paper workflow presence

## Instructions for Claude

1. Read `references/directory-spec.md` for required layout.
2. For scaffold: create only missing files/dirs, keep existing content intact.
3. For audit: evaluate each checklist item in `references/checklist.md`.
4. Report score, failures, and remediation from `references/remediation.md`.
