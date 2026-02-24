# Development Workflow

<!-- reviewed: 2026-02-24 -->

> **Purpose:** End-to-end workflow for research implementation and evidence production.

For program-level coordination across multiple experiments and copilots, use
`docs/workflows/RESEARCH_MANAGEMENT.md` alongside this workflow.

## Lifecycle

1. Plan
2. Implement / Run
3. Validate
4. Document
5. Review

## 1) Plan

- Check `plans/active/` for an existing plan.
- Create/update a plan for non-trivial work.
- Define: objective, hypothesis, metrics, datasets, risks.

## 2) Implement / Run

- Use a feature branch.
- Keep code and experiment changes scoped to the plan.
- Record command-line entry points and configs used.

## 3) Validate

Run repository validations:

```bash
scripts/check-structure.sh
scripts/check-doc-freshness.sh
scripts/check-agent-files.sh
scripts/check-doc-links.sh
scripts/check-doc-index-coverage.sh
scripts/check-plan-index.sh
```

Then run project-specific checks (tests, evaluations, repro reruns).

## 4) Document

- Update impacted docs and freshness dates.
- Record results provenance (configs, seeds, artifact paths).
- For paper-related work, follow `docs/workflows/PAPER_WRITING.md`.

## 5) Review

- Open PR and follow `docs/workflows/PR_REVIEW.md`.
- Ensure claims are supported by evidence.
- Ensure citations are verified or explicitly marked placeholders.

## Pre-Commit Checklist

- [ ] Plan status is current
- [ ] Validation scripts pass
- [ ] Index and plan integrity checks pass
- [ ] Docs and freshness tags updated
- [ ] Evidence paths/commands are recorded
- [ ] Citation integrity checks completed for writing changes
- [ ] Session handoff updated for major work
