# Research Map Audit Checklist

## Structure

- [ ] `docs/` exists
- [ ] `docs/_INDEX.md` exists
- [ ] `docs/workflows/RESEARCH_MANAGEMENT.md` exists
- [ ] `docs/workflows/PAPER_WRITING.md` exists
- [ ] `docs/research-ops/` template docs exist
- [ ] `docs/golden-rules/CODING_STANDARDS.md` exists
- [ ] `docs/session/SESSION_HANDOFF.md` exists
- [ ] `plans/_INDEX.md` and `plans/_TEMPLATE.md` exist
- [ ] All required validation scripts exist

## Agent Entry Points

- [ ] `AGENTS.md` routes to `docs/`
- [ ] `CLAUDE.md` routes to `docs/`
- [ ] `CODEX.md` routes to `docs/`
- [ ] `.cursorrules` routes to `docs/`
- [ ] `.github/copilot-instructions.md` routes to `docs/`

## Documentation

- [ ] Every `docs/*.md` file includes freshness tag
- [ ] No stale docs (older than 30 days)
- [ ] `docs/_INDEX.md` includes paper-writing workflow
- [ ] `docs/_INDEX.md` includes research-management workflow and templates

## Research Integrity

- [ ] Citation non-hallucination policy exists
- [ ] Paper-writing workflow includes citation verification checklist
- [ ] PR review workflow checks evidence-vs-claim alignment
- [ ] Index and plan integrity checks are integrated in CI/docs
