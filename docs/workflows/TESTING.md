# Testing and Reproducibility Strategy

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Validate framework integrity and research reproducibility.

## Layer 1: Framework Integrity

Run every time:

```bash
scripts/check-structure.sh
scripts/check-doc-freshness.sh
scripts/check-agent-files.sh
scripts/check-doc-links.sh
scripts/check-doc-index-coverage.sh
scripts/check-plan-index.sh
```

These checks enforce not only structure/freshness, but also index coverage and
plan-state consistency for multi-session research management.

## Layer 2: Project Tests

Add domain-specific tests for your research codebase, e.g.:
- unit/integration tests
- dataset/schema validators
- metric regression checks

## Layer 3: Reproducibility Checks

For headline results, verify:
- rerun command works
- config and seed are recorded
- expected metrics are reproducible within acceptable variance
- environment requirements are documented

## Minimum Repro Artifact Bundle

- Command(s) to rerun
- Config file(s)
- Seed(s)
- Data/version references
- Hardware/runtime notes
