# Agent Onboarding Guide

<!-- reviewed: 2026-02-24 -->

Welcome to **Research_Map**.

Use this order every session:

1. Read your entry file (`AGENTS.md`, `CLAUDE.md`, `CODEX.md`, etc.)
2. Read `docs/session/SESSION_HANDOFF.md`
3. Check `plans/active/`
4. Open only the docs relevant to your task via `docs/_INDEX.md`

## Core Rules

- `docs/` is authoritative.
- `guide/` is read-only.
- Keep claims tied to evidence.
- Never fabricate citations.
- End each session with a handoff update.
- Use `docs/workflows/RESEARCH_MANAGEMENT.md` for program-level coordination.

## First Commands

```bash
scripts/check-structure.sh
scripts/check-doc-freshness.sh
scripts/check-agent-files.sh
scripts/check-doc-links.sh
scripts/check-doc-index-coverage.sh
scripts/check-plan-index.sh
```
