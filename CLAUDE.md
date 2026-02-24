# CLAUDE.md - Claude Code Entry Point

> **Purpose:** Claude routing for Research_Map.

## Project Overview

Research_Map is an agent-first research framework.
The docs define process for experiments, evidence quality, and paper writing.

## Routing Table

| I need to... | Go to |
|---|---|
| Architecture overview | `docs/architecture/OVERVIEW.md` |
| Principles and guardrails | `docs/golden-rules/PRINCIPLES.md` |
| Research and coding standards | `docs/golden-rules/CODING_STANDARDS.md` |
| End-to-end research workflow | `docs/workflows/DEVELOPMENT.md` |
| Manage research program state | `docs/workflows/RESEARCH_MANAGEMENT.md` |
| Paper-writing workflow | `docs/workflows/PAPER_WRITING.md` |
| Testing and reproducibility | `docs/workflows/TESTING.md` |
| Session continuity | `docs/session/SESSION_HANDOFF.md` |
| Plan lifecycle | `plans/_INDEX.md` |

## Skills

- `/research-map scaffold` - scaffold the framework in a project
- `/research-map audit` - audit project compliance
- `/session-handoff` - update session continuity document

## Session Protocol

1. Start with `docs/session/SESSION_HANDOFF.md`.
2. Execute work from `plans/active/` and `docs/workflows/DEVELOPMENT.md`.
3. Validate via scripts before finalizing.
4. Update `docs/session/SESSION_HANDOFF.md`.
