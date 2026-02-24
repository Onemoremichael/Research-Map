# ADR-003: Plans Live at Top Level, Not Under docs/

<!-- reviewed: 2026-02-11 -->

| Field     | Value                          |
|-----------|--------------------------------|
| **ADR**   | 003                            |
| **Title** | Plans live at top level, not under docs/ |
| **Date**  | 2026-02-11                     |
| **Status**| Accepted                       |

---

## Context

Execution plans are work artifacts with lifecycle states (Draft → Active →
Completed → Abandoned). Documentation in `docs/` is evergreen operational truth
that is continuously maintained. These two types of content have fundamentally
different lifecycles.

The question is where plans should live: under `docs/` alongside operational
docs, or in their own top-level directory.

---

## Decision

Plans live at `plans/` (top level), with `active/` and `completed/`
subdirectories. They are **not** under `docs/`.

---

## Options Considered

### Option A: `docs/plans/`

Plans nested inside the documentation tree.

- **Pros**: Everything in one tree. Simpler top-level directory structure.
- **Cons**: Conflates temporal artifacts with evergreen content. An agent
  running `check-doc-freshness.sh` on `docs/` would flag completed plans as
  stale — but stale is their natural state. Plan lifecycle (active → completed)
  doesn't fit the docs maintenance model. Muddies what "docs/ is the system of
  record" means.

### Option B: `plans/` at top level (chosen)

Plans in their own directory with explicit lifecycle subdirectories.

- **Pros**: Clean separation of temporal vs. evergreen content. Freshness
  scripts can target `docs/` without false-flagging archived plans. An agent
  listing `plans/active/` gets exactly what's in flight — no filtering needed.
  The directory structure itself communicates the lifecycle model.
- **Cons**: One more top-level directory. Agents need to know that plans aren't
  in `docs/`.

### Option C: Issue tracker only

Plans live in GitHub Issues or a project management tool, not in the repo.

- **Pros**: Rich tooling (labels, assignees, milestones).
- **Cons**: Not version-controlled alongside the code. Agents can't read them
  without API access. Breaks the "repo is the system of record" principle.

---

## Consequences

### Positive

- `docs/` contains only evergreen content — no lifecycle management needed
- `plans/active/` is a clean, scannable list of current work
- Freshness enforcement on `docs/` doesn't produce false positives on archived plans
- The physical move from `active/` to `completed/` makes lifecycle state visible
  in the file system

### Negative

- Routing tables and onboarding docs must explicitly mention that plans are at
  `plans/`, not `docs/plans/` — this was a source of initial drift
- Two index files to maintain (`docs/_INDEX.md` and `plans/_INDEX.md`)

### Follow-Up

- [ ] Ensure all docs that reference plans use `plans/` not `docs/plans/`
  (validated in the drift fix commit 93bd564)
