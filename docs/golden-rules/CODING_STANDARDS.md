# Research and Coding Standards

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Practical standards for experiments, code quality, and paper artifacts.

## Naming and Organization

- Use descriptive, stable names for experiments and scripts.
- Store run configs near code (`configs/`, `scripts/`, or equivalent).
- Keep paths and environment assumptions explicit in docs/plans.

## Reproducibility Standards

- Record seed, dataset version, model version, and hyperparameters.
- Record compute environment (hardware, runtime, dependencies).
- Keep commands required to rerun key results.
- If results are non-deterministic, report run count and variability.

## Experimental Reporting

- Separate exploratory runs from headline results.
- For each reported result, include metric definitions and evaluation setup.
- Avoid cherry-picking; note failed/negative findings when relevant.

## Citation Integrity (Critical)

- Never write BibTeX entries from memory.
- Verify references from trusted sources (DOI/CrossRef, Semantic Scholar, arXiv).
- If verification fails, use explicit placeholders and mark for human review.
- Do not present unverified citations as factual.

Suggested placeholder style:

```latex
\cite{PLACEHOLDER_verify_this_source}  % TODO: verify before submission
```

## Paper-Writing Standards

- Keep one-sentence contribution explicit.
- Keep claims aligned with evidence.
- Include limitations and reproducibility notes.
- Follow `docs/workflows/PAPER_WRITING.md` for workflow checklists.

## Documentation Standards

- All docs in `docs/` must include freshness tags.
- Keep entry files concise and routing-focused.
- Avoid duplicate policy text across files.
