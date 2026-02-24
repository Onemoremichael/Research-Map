# Pull Request Review Process

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Ensure correctness, reproducibility, and research integrity before merge.

## Required Checks

### Structure and Docs

- [ ] Validation scripts pass
- [ ] `check-doc-index-coverage.sh` and `check-plan-index.sh` pass
- [ ] Docs updated for behavior/process changes
- [ ] Freshness tags updated on touched docs
- [ ] No policy duplication in entry files

### Research Quality

- [ ] Claims in PR match provided evidence
- [ ] Experimental setup and metrics are clearly documented
- [ ] Repro instructions are present for key results
- [ ] Plan/hypothesis/artifact tracking is updated for the scope of change
- [ ] Known limitations are stated where relevant

### Citation Integrity (when writing/docs touched)

- [ ] No fabricated references
- [ ] Unverified references are explicitly marked
- [ ] Bibliography changes are traceable to real sources

## Block Merge If

- Any validation script fails
- Evidence is insufficient for stated claims
- Citation integrity violations are found
- Session/plan updates needed for continuity are missing
