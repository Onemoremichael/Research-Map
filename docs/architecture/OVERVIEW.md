# Architecture Overview

<!-- reviewed: 2026-02-24 -->

Research_Map is an agent-first architecture for research teams.
It separates operational truth, temporal execution, and educational guidance.

## Progressive Disclosure Model

```
Entry files -> docs/_INDEX.md -> specific workflow docs -> code/artifacts
```

This keeps session startup fast and preserves context window for actual work.

## Three Content Zones

1. `docs/` (operational and mutable): workflows, standards, quality rules.
2. `plans/` (temporal): scoped initiatives with lifecycle status.
3. `guide/` (educational and read-only): framework rationale.

## Research Lifecycle Coverage

The architecture explicitly supports:
- Problem framing and plan creation
- Experiment design and execution
- Reproducibility and validation
- Paper drafting and submission prep
- Session handoffs for continuity

## Why This Matters

Research work fails when evidence, docs, and claims drift.
Research_Map keeps those synchronized through routing discipline, freshness checks,
and explicit plan/state management.
