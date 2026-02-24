# Research_Map

**An agent-first repository framework for AI research execution and paper production.**

> The repo is the operating system for research: question -> experiments -> evidence -> paper.

## What Is This?

Research_Map adapts the Context_Map structure for research teams using AI agents.
It keeps planning, experimentation, writing, and handoffs legible across sessions.

Core goals:
- Progressive disclosure for agents (route quickly to the right doc)
- Reproducible experiment workflow (plans, artifacts, validation)
- Citation integrity (no fabricated references)
- Paper-writing workflow for top ML venues
- Multi-agent compatibility (Claude, Codex, Cursor, Copilot, universal)

## Quick Start

### Agent Entry Points

| Agent | Entry Point |
|-------|-------------|
| Any / Universal | [`AGENTS.md`](AGENTS.md) |
| Claude Code | [`CLAUDE.md`](CLAUDE.md) |
| OpenAI Codex | [`CODEX.md`](CODEX.md) |
| Cursor | [`.cursorrules`](.cursorrules) -> [`.cursor/rules/global.mdc`](.cursor/rules/global.mdc) |
| GitHub Copilot | [`.github/copilot-instructions.md`](.github/copilot-instructions.md) |

### Validate the Framework

```bash
scripts/check-structure.sh
scripts/check-doc-freshness.sh
scripts/check-agent-files.sh
scripts/check-doc-links.sh
scripts/check-doc-index-coverage.sh
scripts/check-plan-index.sh
```

### Repository Target

```bash
git clone https://github.com/MJ-Ref/Research-Map.git
cd Research-Map
```

## Repository Structure

```
Research_Map/
├── AGENTS.md
├── CLAUDE.md
├── CODEX.md
├── ARCHITECTURE.md
├── docs/
│   ├── _INDEX.md
│   ├── architecture/
│   ├── golden-rules/
│   ├── quality/
│   ├── workflows/
│   ├── agent-guide/
│   └── session/
├── plans/
│   ├── _INDEX.md
│   ├── _TEMPLATE.md
│   ├── active/
│   └── completed/
├── guide/
├── scripts/
├── .claude/
├── .codex/
├── .cursor/
└── .github/
```

## Research-Specific Additions

- Research program workflow: [`docs/workflows/RESEARCH_MANAGEMENT.md`](docs/workflows/RESEARCH_MANAGEMENT.md)
- Paper workflow: [`docs/workflows/PAPER_WRITING.md`](docs/workflows/PAPER_WRITING.md)
- Citation policy: enforced in [`docs/golden-rules/CODING_STANDARDS.md`](docs/golden-rules/CODING_STANDARDS.md)
- Review criteria aligned with research quality: [`docs/workflows/PR_REVIEW.md`](docs/workflows/PR_REVIEW.md)
- Research-ops templates: `docs/research-ops/*.md`
- Included inspiration repo: `AI-Research-SKILLs-main/`, especially `20-ml-paper-writing/`

## License

MIT - see [LICENSE](LICENSE)
