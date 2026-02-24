# ADR-001: Five Agent Entry Points

<!-- reviewed: 2026-02-11 -->

| Field     | Value                          |
|-----------|--------------------------------|
| **ADR**   | 001                            |
| **Title** | Five agent entry points        |
| **Date**  | 2026-02-11                     |
| **Status**| Accepted                       |

---

## Context

AI agents arrive at a repository through different tools: Claude Code reads
`CLAUDE.md`, Cursor reads `.cursorrules`, GitHub Copilot reads
`.github/copilot-instructions.md`, and OpenAI Codex reads `CODEX.md`. Each tool
has its own discovery mechanism and cannot be redirected to a single file.

At the same time, the operational rules governing the project must not be
duplicated across these entry points. If coding standards are stated in
`CLAUDE.md` and also in `.cursorrules`, one will inevitably drift out of date.

We needed a design that supports multiple agent arrival paths without
duplicating the content they route to.

---

## Decision

Provide five entry files — one universal (`AGENTS.md`) and four
platform-specific (`CLAUDE.md`, `CODEX.md`, `.cursorrules`,
`.github/copilot-instructions.md`). All five are **routing tables**: they
summarize the project in ≤150 lines and point to `docs/` for every rule,
standard, and process. None of them define policy inline.

---

## Options Considered

### Option A: Single universal file

One `AGENTS.md` for all platforms.

- **Pros**: Zero duplication risk. One file to maintain.
- **Cons**: Platform-specific tools (Cursor, Copilot) won't discover it. Agents
  that auto-read their platform file would get nothing.

### Option B: Full instructions in each entry file

Each platform file contains the complete set of rules.

- **Pros**: Each agent gets everything it needs in one read.
- **Cons**: Five copies of every rule. Guaranteed drift. Massive maintenance
  burden. Violates single source of truth.

### Option C: Routing tables (chosen)

Each platform file is a thin router that points to `docs/`. Platform-specific
hints (e.g., Codex sandbox setup) are allowed, but operational rules live only
in `docs/`.

- **Pros**: Each tool discovers its own file. Rules exist in exactly one place.
  Entry files stay small (cheap in context windows).
- **Cons**: Agents must follow one hop to reach the actual rules. Slightly more
  complex than a single file.

---

## Consequences

### Positive

- Rules are defined once in `docs/` and inherited by all agents
- Adding a new agent platform means creating one small routing file, not copying
  the entire ruleset
- Entry files stay under 150 lines, preserving agent context window budget

### Negative

- Five files must be kept in sync structurally (though not in content)
- `scripts/check-agent-files.sh` is needed to validate that all entry points
  still route to `docs/` and haven't grown too large

### Follow-Up

- [ ] If a sixth agent platform emerges, add its entry file and update
  `check-agent-files.sh`
