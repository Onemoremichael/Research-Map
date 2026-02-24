# Paper Writing Workflow

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Produce publication-ready drafts with evidence and citation integrity.

This workflow adapts guidance from:
`AI-Research-SKILLs-main/20-ml-paper-writing/`

## Non-Negotiable Rule

**Never hallucinate citations.**
If a reference cannot be verified, mark it as placeholder and flag it.

## Workflow

1. Define contribution narrative (one sentence).
2. Map each claim to evidence (tables, figures, experiments).
3. Draft sections end-to-end.
4. Verify citations programmatically or from trusted sources.
5. Run pre-submission checklist.
6. Produce an evidence packet for reviewer-facing claims.

## Narrative Check

Before drafting, confirm:
- **What:** specific contribution
- **Why:** evidence that supports it
- **So what:** why community should care

## Citation Verification Checklist

- [ ] Searched source via trusted index/API (Semantic Scholar/arXiv/CrossRef)
- [ ] Verified existence in at least one authoritative source
- [ ] Retrieved/validated BibTeX from DOI or canonical source
- [ ] Verified the cited claim appears in the paper
- [ ] Marked unresolved citations as placeholders

Placeholder example:

```latex
\cite{PLACEHOLDER_author2026_verify}  % TODO: verify before submission
```

## Drafting Checklist

- [ ] Abstract states concrete contribution/results
- [ ] Introduction includes clear contribution bullets
- [ ] Methods are reproducible
- [ ] Experiments include settings + uncertainty reporting
- [ ] Limitations section is explicit
- [ ] Related work is accurate and sufficiently broad

## Submission Readiness

- [ ] Page-limit and format requirements satisfied for target venue
- [ ] Required checklist statements included
- [ ] Anonymization and ethics/disclosure requirements handled
- [ ] Final citation sweep complete (no unresolved placeholders)

## Copilot Output Contract for Writing Tasks

Each copilot writing task should output:

- Updated section text and changed file paths
- Claim-to-evidence mapping table
- List of newly added citations with status (`verified` or `placeholder`)
- Explicit unresolved risks/questions for human review
