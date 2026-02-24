# AGENTS.md - Universal Agent Entry Point

> **Purpose:** Route any agent to the operational docs fast.

## Quick Orientation

This is **Research_Map**: a research execution framework for AI-agent-assisted projects.
Use docs as the single source of truth. Do not duplicate policy in entry files.

## Routing Table

| I need to... | Go to |
|---|---|
| Understand architecture | `docs/architecture/OVERVIEW.md` |
| See dependency constraints | `docs/architecture/DEPENDENCY_RULES.md` |
| Read non-negotiable principles | `docs/golden-rules/PRINCIPLES.md` |
| Follow research/coding standards | `docs/golden-rules/CODING_STANDARDS.md` |
| Run research workflow | `docs/workflows/DEVELOPMENT.md` |
| Manage research program state | `docs/workflows/RESEARCH_MANAGEMENT.md` |
| Prepare or revise a paper | `docs/workflows/PAPER_WRITING.md` |
| Review PR quality gates | `docs/workflows/PR_REVIEW.md` |
| Run validation/repro checks | `docs/workflows/TESTING.md` |
| Update docs/freshness | `docs/workflows/DOC_GARDENING.md` |
| Onboard quickly | `docs/agent-guide/ONBOARDING.md` |
| Execute common tasks | `docs/agent-guide/COMMON_TASKS.md` |
| Continue from prior session | `docs/session/SESSION_HANDOFF.md` |
| Find all docs | `docs/_INDEX.md` |
| Create/review execution plans | `plans/_INDEX.md` |

## Key Rules

1. `docs/` is the system of record.
2. `guide/` is read-only for agents.
3. Update `<!-- reviewed: YYYY-MM-DD -->` on touched docs.
4. Never fabricate citations. Use verified sources or placeholders.
5. Run validation scripts before committing.
