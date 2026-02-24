# Research Management Review (2026-02-24)

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Capture review findings, rationale, and implemented improvements for AI-copilot research management.

## Review Scope

- Operational workflows
- Copilot routing and constraints
- Reproducibility and citation governance
- Artifact/index hygiene automation
- Plan lifecycle enforcement

## Findings

### High Priority

1. Missing automation for docs index coverage.
- Risk: orphan docs and stale navigation for copilots.
- Resolution: added `scripts/check-doc-index-coverage.sh` and CI integration.

2. Missing automation for plan index and plan-state hygiene.
- Risk: plan drift and incorrect lifecycle status across sessions.
- Resolution: added `scripts/check-plan-index.sh` and CI integration.

3. No explicit program-level management workflow.
- Risk: copilots execute tasks without shared operating model.
- Resolution: added `docs/workflows/RESEARCH_MANAGEMENT.md`.

### Medium Priority

4. Missing standardized templates for intake/hypothesis/experiments/evidence.
- Risk: inconsistent artifact quality and low traceability.
- Resolution: added templates in `docs/research-ops/`.

5. Partial enforcement references in docs.
- Risk: contributors run inconsistent check suites.
- Resolution: updated README/workflow/onboarding/review docs to include new checks.

### Low Priority

6. Citation verification remains policy-driven, not yet API-enforced.
- Risk: human error may leave unresolved placeholders.
- Status: tracked debt item (`RD-001`).

## Improvement Principles Applied

- Enforce critical rules automatically.
- Make copilot task contracts explicit.
- Keep claims linked to evidence artifacts.
- Preserve progressive disclosure and single-source-of-truth docs.

## Validation Evidence

All checks pass:

- `scripts/check-structure.sh`
- `scripts/check-doc-freshness.sh --fail-on-stale`
- `scripts/check-agent-files.sh`
- `scripts/check-doc-links.sh`
- `scripts/check-doc-index-coverage.sh`
- `scripts/check-plan-index.sh`
