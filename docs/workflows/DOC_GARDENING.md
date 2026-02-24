# Documentation Gardening

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Keep operational docs accurate and trusted.

## Freshness Rule

Every doc in `docs/` must include:

```html
<!-- reviewed: YYYY-MM-DD -->
```

Default threshold: 30 days.

## Gardening Workflow

1. Run freshness check.
2. Review stale docs against current repo reality.
3. Update content and freshness tags.
4. Re-run validation scripts.

```bash
scripts/check-doc-freshness.sh
scripts/check-structure.sh
scripts/check-agent-files.sh
scripts/check-doc-links.sh
scripts/check-doc-index-coverage.sh
```

## Triggers for Immediate Review

- Workflow/process changes
- New/removed files referenced by docs
- Review feedback showing confusion or drift
- Major plan transitions
