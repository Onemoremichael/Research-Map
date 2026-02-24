# Research Map Directory Specification

Required high-level layout:

- Root entry files: `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `ARCHITECTURE.md`, `.cursorrules`
- `docs/`: architecture, golden-rules, quality, workflows, agent-guide, session
- `plans/`: `_INDEX.md`, `_TEMPLATE.md`, `active/`, `completed/`
- `scripts/`: structure/freshness/agent-files/doc-links checks
- `.claude/skills/research-map/`: scaffold/audit skill files

Required workflow docs:
- `docs/workflows/DEVELOPMENT.md`
- `docs/workflows/RESEARCH_MANAGEMENT.md`
- `docs/workflows/PAPER_WRITING.md`
- `docs/workflows/PR_REVIEW.md`
- `docs/workflows/TESTING.md`
- `docs/workflows/DOC_GARDENING.md`

Required research-ops templates:
- `docs/research-ops/PROJECT_INTAKE_TEMPLATE.md`
- `docs/research-ops/HYPOTHESIS_REGISTER_TEMPLATE.md`
- `docs/research-ops/EXPERIMENT_LOG_TEMPLATE.md`
- `docs/research-ops/LITERATURE_TRACKER_TEMPLATE.md`
- `docs/research-ops/RESULT_EVIDENCE_TEMPLATE.md`

Policy constraints:
- Entry files are routing tables, not full policy docs
- `docs/` is system of record
- `guide/` is read-only for agents
- Citation integrity policy is mandatory
