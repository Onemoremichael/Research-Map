# Chapter 6: Documentation Gardening

> **Pattern:** Treat documentation as a living system that requires active
> maintenance -- not an artifact written once and forgotten. Detect staleness
> automatically, assign gardening to every session, and use a master index as
> the navigation layer.

---

## The Problem

Documentation rots faster than code. Code that drifts from its docs still
compiles, still passes tests, and still ships to production. The docs, meanwhile,
quietly become wrong. And wrong docs are worse than no docs.

When an agent reads accurate documentation, it produces correct work. When an
agent reads stale documentation, it produces confidently incorrect work -- at
scale, automatically, with no hesitation. There is no "hmm, this feels off"
instinct. The agent trusts what it reads.

In traditional development, doc rot is a chronic nuisance. In agent-led
development, it is a critical failure mode.

Common symptoms of doc rot:

- **Phantom references.** A doc describes a function, flag, or endpoint that was
  renamed or removed months ago.
- **Contradictory guidance.** Two docs describe the same process differently
  because one was updated and the other was not.
- **Missing coverage.** A new feature shipped without a corresponding doc
  update. The docs describe the system as it was, not as it is.
- **Zombie docs.** Documents that nobody reads or updates but nobody deletes
  either. They accumulate and make search results noisy.
- **Invisible staleness.** There is no way to tell whether a doc is current
  without reading the code and comparing.

---

## The Principle

**Documentation is the system of record, not an afterthought.** In a
Research_Map project, `docs/` is the authoritative source for how the project
works. Code is the implementation of what docs describe. When they diverge,
both the doc and the code are suspects -- neither is automatically right.

This principle has a corollary: **if docs are the system of record, then
maintaining them is as important as maintaining the code.** A feature is not
done when the code works. A feature is done when the code works *and the docs
are updated.*

Documentation gardening is the practice of continuously maintaining docs --
detecting staleness, updating content, verifying accuracy, and pruning what is
no longer needed. The metaphor is deliberate: a garden that is not tended
becomes overgrown. Docs that are not gardened become a liability.

---

## Implementation

### The Freshness Model

Every document in `docs/` carries a machine-readable freshness tag:

```html
<!-- reviewed: 2026-02-11 -->
```

This tag records the last date the document was reviewed and confirmed to be
accurate. It is not the last-modified date from the filesystem (which changes
when formatting is adjusted) and it is not the git commit date (which changes
when unrelated lines are touched). It is an explicit assertion: "on this date,
a human or agent verified that this document accurately describes the current
state of the project."

**Staleness detection:**

The freshness script (`scripts/check-doc-freshness.sh`) scans `docs/` for
these tags and reports:

1. **Missing tags.** A document without a freshness tag is assumed stale. This
   is the most common defect in newly created docs -- the author forgets the
   tag.
2. **Expired tags.** A document whose review date exceeds the staleness
   threshold (default: 30 days) is flagged. The threshold is configurable per
   project.
3. **Summary report.** The script outputs a list of all docs with their
   freshness status: current, approaching staleness, stale, or missing date.

**Staleness thresholds:**

| Age            | Status              | Action                            |
|----------------|---------------------|-----------------------------------|
| 0-30 days      | Current             | No action needed                  |
| 31-45 days     | Approaching stale   | Review during next gardening pass |
| 46-60 days     | Stale               | Must be reviewed this session     |
| 60+ days       | Critical            | Block other work until resolved   |

These thresholds are guidelines. High-churn areas of the project (like API
docs or configuration references) may need tighter thresholds. Stable areas
(like design principles) may tolerate longer intervals.

### The Gardening Workflow

Documentation gardening follows a four-step process: triage, update, verify,
commit.

**Step 1: Triage stale docs.**

Run the freshness check to identify which docs need attention:

```bash
scripts/check-doc-freshness.sh
```

Review the output. Prioritize:
1. Docs referenced in routing tables (highest traffic).
2. Docs related to code changed recently (highest drift risk).
3. Docs approaching the critical threshold (most urgent).

**Step 2: Update.**

For each stale doc:
- Read the document.
- Compare its claims against the current codebase.
- Update any content that has drifted.
- Remove content that is no longer relevant.
- Add content for features or changes that are not yet documented.

**Step 3: Verify.**

After updating, confirm the doc is accurate:
- Follow any procedures it describes and verify they work.
- Check that internal links resolve to existing files.
- Check that code examples compile or run correctly.
- Confirm that the doc is consistent with other docs that cover related topics.

**Step 4: Commit.**

Update the freshness tag to today's date and commit:

```bash
git commit -m "docs: garden [FILENAME] -- update for current state"
```

Include the freshness date update in the same commit as the content changes.
Do not update the date without reviewing the content -- the date is a
certification of accuracy, not a timestamp of modification.

### What Triggers a Doc Review

Three events should trigger a documentation review:

**1. Code changes.**

When code changes, the docs that describe that code may need updating. This is
the most common trigger and the easiest to miss. The rule is simple: if you
change code that is described in a doc, review that doc in the same session.

Examples:
- Renaming a function? Check if any doc references the old name.
- Adding a new API endpoint? Add it to the API reference doc.
- Changing a configuration option? Update the configuration doc.

**2. Time-based triggers.**

The freshness script catches docs that are aging regardless of whether the
underlying code changed. Some types of drift are not caused by code changes --
they are caused by ecosystem changes, deprecated dependencies, or evolving
best practices.

Run the freshness check at the start of every session. If stale docs are found,
gardening them takes priority over new feature work unless there is an urgent
task.

**3. Audit findings.**

The quality scorecard audit (Chapter 5) includes a Documentation dimension.
When an audit reveals a low documentation score, a focused gardening effort is
warranted. This might take the form of an execution plan (Chapter 4) if the
number of stale docs is large.

### Agent Role in Gardening

In a Research_Map project, documentation gardening is not a separate chore
performed by a dedicated "doc writer." It is embedded into every agent's
workflow.

**The integration principle:** Every task that changes the project state should
include a corresponding doc check. This is not optional. It is part of the
definition of "done."

How agents participate:

- **On session start:** Check the freshness report. If any critical docs are
  stale, garden them before starting other work.
- **During work:** When modifying code, check whether the associated docs need
  updating. Update them in the same commit or the immediately following one.
- **On session end:** Update the freshness date on any doc you reviewed or
  modified during the session.

This distributed approach -- where every agent gardens a little on every
session -- prevents the accumulation of doc debt. It is far more effective than
periodic "doc sprints" where someone tries to update everything at once.

### The Master Index Pattern

The master index (`docs/_INDEX.md`) is the navigation layer for all operational
documentation. It lists every document in `docs/` with its purpose and last
reviewed date.

```markdown
## Architecture

| Document                  | Purpose                      | Last Reviewed |
|---------------------------|------------------------------|---------------|
| OVERVIEW.md               | System architecture narrative| 2026-02-11    |
| DEPENDENCY_RULES.md       | Layer dependency constraints | 2026-02-11    |

## Quality

| Document                  | Purpose                      | Last Reviewed |
|---------------------------|------------------------------|---------------|
| QUALITY_SCORECARD.md      | Quality scoring rubric       | 2026-02-11    |
| TECH_DEBT_REGISTER.md     | Known tech debt tracking     | 2026-02-11    |
```

**Why the index matters:**

1. **Discovery.** An agent looking for a specific topic can scan the index
   instead of traversing the directory tree. The purpose column answers "is this
   the doc I need?" without opening each file.
2. **Freshness at a glance.** The Last Reviewed column shows the health of the
   entire documentation set in one table. Stale dates stand out visually.
3. **Completeness checking.** If a doc exists in the directory but not in the
   index, it is an orphan. If an entry exists in the index but the file is
   missing, it is a broken link. Both are defects.
4. **Routing integration.** Agent entry files (`AGENTS.md`, `CLAUDE.md`) link
   to `docs/_INDEX.md` as the master navigation. The index is the bridge
   between entry-point routing and individual docs.

**Index maintenance rules:**

- When creating a new doc, add it to the index in the appropriate section.
- When deleting a doc, remove it from the index.
- When updating a doc's freshness date, update the corresponding date in the
  index.
- The index and the individual doc freshness tags must agree. If they disagree,
  the individual doc's tag is authoritative.

---

## Adaptation

### Scaling freshness thresholds

The default 30-day threshold works for actively developed projects. Adjust
based on your project's cadence:

- **Fast-moving projects** (daily deployments, rapid iteration): consider 14
  days for high-traffic docs, 30 for others.
- **Stable projects** (monthly releases, mature codebase): 60 days may be
  sufficient for most docs, with 30 for API references.
- **Archived projects** (maintenance mode): 90 days, with checks only on the
  docs most likely to be consulted by maintenance agents.

### Handling large doc sets

Projects with dozens of docs cannot garden everything every session. Use a
rotation:

1. Divide docs into tiers based on traffic and change frequency.
2. **Tier 1** (routing targets, API refs): garden every session.
3. **Tier 2** (architecture, standards): garden weekly.
4. **Tier 3** (historical ADRs, completed plan summaries): garden monthly.

The freshness script handles this automatically -- it flags docs based on age,
so tier-1 docs with a 14-day threshold will be flagged sooner than tier-3 docs
with a 90-day threshold.

### Docs without code

Some docs describe processes, not code. For example, the onboarding guide or
the session handoff procedure. These still need gardening, but the trigger is
different: instead of "did the code change?", the trigger is "did the process
change?" Time-based checks are the primary mechanism for these.

### When to delete a doc

Gardening includes pruning. A document should be deleted (or archived) when:

- The feature it describes has been removed.
- It has been superseded by a more comprehensive doc.
- It has not been read or referenced in multiple audit cycles.
- Its content has been absorbed into another doc.

Deletion is a commit, not a silent removal. The commit message explains what
was removed and why. If the doc contained any lasting value, that value should
be extracted into a surviving doc before deletion.

---

*A well-gardened doc set is a competitive advantage. It means every agent
session starts with accurate context, every decision is informed by current
information, and every handoff is grounded in truth -- not in what was true
three months ago.*
