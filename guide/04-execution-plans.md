# Chapter 4: Execution Plans as First-Class Artifacts

> **Pattern:** Give complex work a structured, lifecycle-managed document that
> agents can discover, follow, and update -- turning multi-step tasks from
> ephemeral chat into durable, inspectable artifacts.

---

## The Problem

Complex tasks do not survive in chat history. When a multi-step initiative spans
several sessions -- or even several turns within one session -- critical details
get buried. The agent forgets what was decided, skips a step, or re-derives
context that was already established. Humans reviewing the work later cannot
reconstruct what happened or why.

This is not an agent limitation. It is a structural one. Chat history is
append-only, unindexed, and invisible to the next session. Asking an agent to
"just remember" a ten-step plan across sessions is like asking a developer to
"just remember" the sprint backlog without a board.

Without explicit plans:

- **Steps get skipped.** The agent finishes phase one and forgets phase three
  existed.
- **Context is lost.** A new session starts with no idea why a particular
  approach was chosen.
- **Progress is invisible.** Neither the human nor the agent can tell what
  percentage of the work is done.
- **Scope creeps silently.** Without written acceptance criteria, "done" is
  whatever the agent decides in the moment.
- **Handoffs break.** The next agent has no structured way to pick up where the
  last one left off.

---

## The Principle

**Execution plans are first-class artifacts, not mental bookkeeping.** They live
in the repository as versioned Markdown files with defined lifecycle states. They
are written before work begins, updated as work progresses, and archived when
work ends.

A plan is not a to-do list. It captures the *what*, *why*, and *how* of an
initiative -- including constraints, risks, dependencies, and success criteria.
It is a contract between the human who approves the work and the agent who
executes it.

Plans are **temporal**, not evergreen. They have a beginning and an end. This
distinguishes them from documentation (which is maintained indefinitely) and from
educational content (which is immutable). Plans live in `plans/`, not `docs/`,
because they are not reference material -- they are work artifacts.

---

## Implementation

### The Plan Template

Every plan follows a standard template (see `plans/_TEMPLATE.md`). The template
has seven sections, each with a specific purpose:

```
# Execution Plan: [PLAN-XXX] [Title]

## Metadata        — ID, status, author, dates
## Objective       — What and Why in one sentence each
## Context         — Background, constraints, dependencies
## Approach        — High-level strategy (2-4 sentences)
## Phases / Steps  — Ordered work items with acceptance criteria
## Risks           — What could go wrong and how to respond
## Success Criteria — Measurable outcomes that define "done"
```

**Why these sections matter:**

- **Metadata** makes plans discoverable and sortable. The status field is the
  lifecycle state. The dates track currency.
- **Objective** forces clarity. If you cannot state the deliverable and
  motivation in one sentence each, the plan is not ready.
- **Context** prevents the next agent from re-deriving background. Constraints
  and dependencies are explicit, not implied.
- **Approach** explains *why this method* over alternatives. It is the
  architectural rationale for the plan itself.
- **Phases / Steps** are the executable instructions. Each step has an
  acceptance criterion so "done" is not subjective.
- **Risks** are the things the plan author thought about so the executor does
  not have to discover them the hard way.
- **Success Criteria** are the top-level checks. When all are satisfied, the
  plan is complete.

### Plan Lifecycle

Plans move through four states:

```
Draft  ──>  Active  ──>  Completed
                    ──>  Abandoned
```

| State         | Meaning                                     | Location           |
|---------------|---------------------------------------------|--------------------|
| **Draft**     | Being designed; not yet approved for work    | `plans/active/`    |
| **Active**    | Work is underway                             | `plans/active/`    |
| **Completed** | All success criteria met                     | `plans/completed/` |
| **Abandoned** | Cancelled with reason documented             | `plans/completed/` |

The lifecycle is enforced by location. Active work lives in `plans/active/`.
When a plan finishes (or is abandoned), it moves to `plans/completed/`. This
keeps the active directory small and scannable -- an agent listing active plans
sees only what is in flight.

**State transitions:**

1. **Draft to Active:** All sections are filled in. No placeholder text remains.
   The status field is updated and the plan is committed.
2. **Active to Completed:** Every success criterion checkbox is checked. The
   status field is updated. The file is moved to `plans/completed/`.
3. **Active to Abandoned:** The reason for abandonment is recorded in the plan.
   The file is moved to `plans/completed/` with status set to Abandoned.

### Why `plans/` and Not `docs/`

This separation is a load-bearing design decision. `docs/` contains evergreen
operational content -- standards, architecture, workflows -- that is
continuously maintained and never "finished." Plans are the opposite: they are
born, they are worked, and they end.

Mixing temporal and evergreen content creates two problems:

1. **Stale plans pollute search.** An agent scanning `docs/` for current
   standards finds old plans mixed in with active guidance.
2. **Evergreen docs inherit plan lifecycle.** Docs should not have "completed"
   or "abandoned" states. They are always current or they are stale.

The `plans/` directory is a work queue. The `docs/` directory is a library. They
serve different purposes and deserve different homes.

### Plan Indexing

The plan index (`plans/_INDEX.md`) is the directory of all plans. It contains
two tables: Active Plans and Completed Plans.

```markdown
## Active Plans

| ID       | Title                    | Status | Owner  | Last Updated |
|----------|--------------------------|--------|--------|--------------|
| PLAN-003 | Add authentication layer | Active | agent  | 2026-02-10   |

## Completed Plans

| ID       | Title                 | Final Status | Owner  | Completed  |
|----------|-----------------------|--------------|--------|------------|
| PLAN-001 | Set up CI pipeline    | Completed    | agent  | 2026-01-28 |
| PLAN-002 | Refactor config layer | Abandoned    | agent  | 2026-02-01 |
```

The index is the first thing an agent checks when starting a session. If there
are active plans, the agent knows what work is in flight before reading anything
else.

**Index maintenance rules:**

- When creating a plan, add a row to the Active Plans table.
- When completing or abandoning a plan, move the row to the Completed Plans
  table.
- The index and the plan file must agree on status. If they disagree, the plan
  file is authoritative.

### How Agents Use Plans

Plans integrate into the session protocol at three points:

**Session start:**
1. Read `docs/session/SESSION_HANDOFF.md` for prior context.
2. Check `plans/_INDEX.md` for active plans.
3. If an active plan exists for the current task, open it and read the current
   phase.

**During work:**
1. Follow the steps in the current phase.
2. Check off completed steps as you go (update the checkboxes in the plan file).
3. If you discover a new risk or constraint, add it to the plan.
4. Commit plan updates alongside code changes.

**Session end:**
1. Update the plan's "Last Updated" date.
2. If the plan is complete, move it to `plans/completed/` and update the index.
3. Record plan progress in the session handoff.

### Example: A Real Plan in Action

Here is a condensed example showing how a plan guides work:

```markdown
# Execution Plan: [PLAN-004] Add Input Validation

## Metadata
| Field       | Value          |
|-------------|----------------|
| **Plan ID** | PLAN-004       |
| **Status**  | Active         |
| **Created** | 2026-02-11     |

## Objective
**What:** Add server-side input validation to all API endpoints.
**Why:** Unvalidated input is the top item on the tech debt register (TD-007).

## Phases / Steps

### Phase 1: Audit existing endpoints
- [x] Step 1.1: List all endpoints and their input parameters
- [x] Step 1.2: Categorize by validation complexity (simple/medium/complex)

### Phase 2: Implement validation
- [x] Step 2.1: Add validation middleware for simple endpoints
- [ ] Step 2.2: Add validation for medium-complexity endpoints
- [ ] Step 2.3: Add validation for complex endpoints

### Phase 3: Verify
- [ ] Step 3.1: Write integration tests for every endpoint
- [ ] Step 3.2: Run full test suite and confirm no regressions

## Success Criteria
- [ ] Every API endpoint validates its input before processing
- [ ] Integration tests cover all validation paths
- [ ] TD-007 is marked resolved in the tech debt register
```

An agent picking up this plan in a new session immediately knows: Phase 1 is
done, Phase 2 is partially complete (Step 2.1 finished, 2.2 and 2.3 remain),
and Phase 3 has not started. No chat history required.

---

## Adaptation

### Scaling plan complexity

Not every task needs a plan. Use this heuristic:

- **No plan needed:** Task fits in a single session and has clear scope (e.g.,
  fix a specific bug, update a single doc).
- **Lightweight plan:** Task spans 2-3 sessions or involves coordination (e.g.,
  refactor a module, add a feature with tests). Use the full template but keep
  phases to 2-3.
- **Full plan:** Task is multi-week, has dependencies, or involves risk (e.g.,
  migration, new subsystem, breaking change). Use every section of the template.

### Adapting the template

The template is a starting point. Projects with different needs can adjust:

- **Add a "Stakeholders" section** if plans require sign-off from specific
  people.
- **Add a "Rollback Plan" section** for plans that change production systems.
- **Remove the "Risks" table** if the project is low-stakes and the overhead is
  not justified. (But think carefully before removing it.)

The key invariant is that plans must be structured, discoverable, and
lifecycle-managed. The specific sections can vary.

### When plans become docs

Sometimes a plan produces knowledge that outlives the plan itself. For example,
a plan to set up CI might produce a set of conventions for pipeline
configuration. When this happens:

1. Extract the lasting knowledge into a document in `docs/`.
2. Add a reference link in the completed plan pointing to the new doc.
3. Do not leave the knowledge only in the plan -- completed plans are archived,
   not actively maintained.

This is the temporal-to-evergreen transition. Plans are born, they do their
work, and the valuable parts graduate into documentation.

---

*Execution plans turn vague intentions into inspectable, resumable work. They
are the connective tissue between what a human wants and what an agent does.*
