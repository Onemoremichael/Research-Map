# Research Map Remediation Guide

## Missing Paper Workflow

Create `docs/workflows/PAPER_WRITING.md` with:
- contribution narrative steps
- citation verification checklist
- submission readiness checklist

## Missing Research Management Workflow

Create `docs/workflows/RESEARCH_MANAGEMENT.md` and include:
- intake/hypothesis/experiment/literature/evidence lifecycle
- copilot task contract
- milestone completion criteria

## Citation Policy Missing

Add explicit non-hallucination rules in `docs/golden-rules/CODING_STANDARDS.md`.

## Routing Drift

Ensure all entry files route to docs and stay concise.

## Stale Docs

Review affected docs and update `<!-- reviewed: YYYY-MM-DD -->`.

## Plan Hygiene Issues

Ensure plan files include valid status and index coverage.

## Index Coverage Issues

- Add missing docs to `docs/_INDEX.md`
- Add missing plan IDs to `plans/_INDEX.md`
- Run `scripts/check-doc-index-coverage.sh` and `scripts/check-plan-index.sh`
