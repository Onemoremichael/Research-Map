# Chapter 5: Quality Scoring and Enforcement

> **Pattern:** Define quality as measurable dimensions, score them with rubrics,
> track debt explicitly, and enforce standards with scripts -- because manual
> discipline is insufficient for agent-led development at scale.

---

## The Problem

Every project starts with good intentions about quality. Standards are
documented. Best practices are shared. And then, gradually, they erode. A rushed
feature skips a test. A doc update is deferred. A naming convention is
forgotten. No single violation is catastrophic, but the accumulation is.

In human-led development, this erosion is slowed by code review, team culture,
and institutional memory. In agent-led development, none of those safeguards
exist by default. An agent does not have cultural norms. It does not remember
last month's code review feedback. It does not feel the vague unease of
declining quality.

Without explicit quality infrastructure:

- **Standards exist but are not checked.** The coding standards doc says "use
  camelCase" but nothing verifies compliance.
- **Quality is binary.** Work is either "done" or "not done" -- there is no
  spectrum, no scoring, no trend.
- **Tech debt is invisible.** Known shortcuts are remembered by the humans who
  took them, and forgotten when those humans move on.
- **Enforcement is aspirational.** Rules are documented in docs nobody reads
  after the first week.
- **Regression is silent.** Quality declines steadily but nobody notices because
  nobody is measuring.

---

## The Principle

**If a rule is important enough to state, it is important enough to check
automatically.**

This is Principle 6 from the Research_Map design principles, and it is the
foundation of the quality system. Quality is not a set of hopes -- it is a set
of measurements. Measurements require dimensions, rubrics, and tooling.

The quality system has three components:

1. **Quality Scorecard** -- defines what quality means, how to measure it, and
   what scores are acceptable.
2. **Tech Debt Register** -- tracks known quality gaps so they can be
   prioritized and resolved.
3. **Enforcement Scripts** -- automate the checks that can be automated, so
   compliance is verified, not assumed.

Together, these create a feedback loop: the scorecard defines the standard, the
scripts check against it, and the debt register captures what falls short.

---

## Implementation

### The Quality Scorecard

The scorecard (see `docs/quality/QUALITY_SCORECARD.md`) measures quality across
four dimensions, each scored 1 to 5:

| Dimension       | Weight | What It Measures                               |
|-----------------|--------|------------------------------------------------|
| Documentation   | 30%    | Freshness, completeness, accuracy of docs      |
| Structure       | 25%    | Directory compliance, routing integrity         |
| Plans           | 20%    | Lifecycle compliance, template adherence        |
| Code Quality    | 25%    | Standards compliance, tests, debt tracking      |

**Why these four dimensions:**

- **Documentation** gets the highest weight because, in an agent-first repo,
  docs are the system of record. If the docs are wrong, agents will do the
  wrong thing -- at scale and with confidence.
- **Structure** is weighted heavily because progressive disclosure depends on
  structural integrity. If the directory layout is broken, the routing tables
  are broken, and agents cannot find anything.
- **Plans** ensure that multi-step work is managed, not ad-hoc. Stale or
  improperly managed plans indicate process breakdown.
- **Code Quality** covers the traditional measures -- standards, tests, and
  debt -- adapted for agent-led workflows.

**Scoring rubrics:**

Each dimension has a rubric that maps observable conditions to a score. For
example, the Documentation dimension:

| Score | Freshness                           | Completeness                      |
|-------|-------------------------------------|-----------------------------------|
| 5     | All docs reviewed within 30 days    | Every routing target exists       |
| 4     | All docs reviewed within 45 days    | All required docs exist           |
| 3     | Some within 30 days, none over 60   | Core docs exist, some stubs       |
| 2     | Most docs older than 60 days        | Multiple missing docs             |
| 1     | No dates or all older than 90 days  | Routing points to missing files   |

The rubrics are deliberately concrete. "Good documentation" is subjective.
"All docs reviewed within 30 days" is verifiable.

**Overall score formula:**

```
Overall = (Documentation * 0.30)
        + (Structure     * 0.25)
        + (Plans         * 0.20)
        + (Code Quality  * 0.25)
```

Score interpretation:

| Range       | Rating     | Action                                        |
|-------------|------------|-----------------------------------------------|
| 4.5 - 5.0  | Excellent  | Maintain current practices                    |
| 3.5 - 4.4  | Good       | Address gaps in lowest-scoring dimension       |
| 2.5 - 3.4  | Needs Work | Prioritize remediation; create a plan          |
| 1.0 - 2.4  | Critical   | Stop feature work; focus on repo health        |

**Audit cadence:**

- Full audit: at least monthly.
- Spot checks: after any major structural change.
- Automated checks: on every pull request via CI.

### The Tech Debt Register

The tech debt register (see `docs/quality/TECH_DEBT_REGISTER.md`) is a single
table tracking every known quality gap in the project.

Each entry has:

| Field       | Purpose                                               |
|-------------|-------------------------------------------------------|
| ID          | Sequential identifier (TD-001, TD-002, ...)           |
| Description | One-line summary of the debt                          |
| Impact      | H / M / L -- how much damage if left unresolved       |
| Effort      | H / M / L -- how much work to resolve                 |
| Owner       | Who is responsible (or "unassigned")                   |
| Status      | open / in-progress / resolved / wont-fix               |
| Date Added  | When the debt was first identified                    |

**Why a register instead of issues:**

Issue trackers are external to the repo. The register lives in the repo, under
version control, visible to every agent in every session. An agent does not need
GitHub access or Jira credentials to check for known debt -- it reads a
Markdown file.

**Prioritization uses an impact-vs-effort matrix:**

```
              |  Low Effort  |  Med Effort  |  High Effort  |
--------------+--------------+--------------+---------------+
 High Impact  |  DO FIRST    |  PLAN NEXT   |  PLAN NEXT    |
 Med Impact   |  DO FIRST    |  SCHEDULE    |  BACKLOG      |
 Low Impact   |  OPPORTUNISTIC| BACKLOG     |  RECONSIDER   |
```

High-impact, low-effort items are resolved immediately. Low-impact, high-effort
items are reconsidered -- the cost may not justify the fix. Items in between are
scheduled based on capacity.

**Review cadence:**

- Every session: check for new debt encountered during work.
- Weekly: review open items, update statuses, re-assess priorities.
- Monthly: as part of the scorecard audit, verify the register is current.

**Resolving debt:**

When an entry is resolved, its status changes to `resolved` but the row is not
deleted. Resolved entries are historical records. The commit message references
the debt ID (e.g., `fix: resolve TD-003 -- add input validation`).

### Enforcement Scripts

Enforcement scripts live in `scripts/` and validate structural invariants
automatically. They are read-only -- they report violations but never modify
files.

**Core scripts:**

| Script                     | What It Checks                              |
|----------------------------|---------------------------------------------|
| `check-structure.sh`       | Required directories and files exist         |
| `check-doc-freshness.sh`   | Every doc has a review date within threshold |
| `check-agent-files.sh`     | Routing table links resolve to real files    |

**Structure validation** (`check-structure.sh`) verifies that the directory
layout matches the Research_Map specification. It checks for required
directories (`docs/`, `plans/`, `guide/`, `scripts/`), required files
(`AGENTS.md`, `CLAUDE.md`, `docs/_INDEX.md`), and the absence of structural
anti-patterns (e.g., docs in the root directory, plans mixed into `docs/`).

**Freshness checking** (`check-doc-freshness.sh`) scans every Markdown file in
`docs/` for the `<!-- reviewed: YYYY-MM-DD -->` tag. It flags files that are
missing the tag entirely (assumed stale) and files whose review date exceeds the
staleness threshold (default: 30 days).

**Routing verification** (`check-agent-files.sh`) parses the routing tables in
agent entry files and confirms that every target file exists. A broken routing
link is a critical defect -- it means an agent following the entry point will
hit a dead end.

**Script design principles:**

1. **Read-only.** Scripts report problems; they never fix them. Automated fixes
   mask structural issues that deserve human or agent judgment.
2. **Exit codes.** Scripts return 0 on success and non-zero on failure. This
   makes them composable with CI pipelines and pre-commit hooks.
3. **Clear output.** Each violation is reported with the file path, the rule
   that was violated, and a suggested fix.
4. **Idempotent.** Running a script twice produces the same output. No side
   effects.

### Building a Quality Culture with Agents

Agents do not internalize culture, but they follow instructions. The quality
system works by embedding checks into the agent workflow:

**Pre-commit gate:**
The session protocol includes running validation scripts before committing.
This is documented in `CLAUDE.md` and `AGENTS.md` so every agent sees it at
session start.

**Self-auditing:**
Agents are instructed to score their own work against the quality scorecard
dimensions after completing a task. This is not a substitute for automated
checks -- it catches the things scripts cannot check, like whether a doc
accurately describes the code.

**Debt discovery:**
Agents are instructed to add entries to the tech debt register when they
encounter quality gaps during normal work. This turns every agent session into
a passive quality audit.

**Escalation:**
When the overall quality score drops below 3.5, the scorecard recommends
creating an execution plan specifically for remediation. Quality recovery is
treated as real work, not a side activity.

---

## Adaptation

### Adjusting dimensions and weights

The four-dimension model is a starting point. Projects with different priorities
can adjust:

- **API-heavy projects** might add an "API Consistency" dimension covering
  endpoint naming, versioning, and schema compliance.
- **Data pipeline projects** might add a "Data Quality" dimension covering
  validation, lineage, and freshness of data artifacts.
- **Projects without plans** can redistribute the Plans weight to other
  dimensions.

The principle is constant: quality must be defined as measurable dimensions.
The specific dimensions vary by project.

### Adjusting thresholds

The default staleness threshold of 30 days is aggressive. Projects with slower
development cadences might use 60 or 90 days. Projects with fast-moving
codebases might tighten to 14 days. The threshold should reflect how quickly
docs can drift from reality in your project.

### Lightweight adoption

Not every project needs the full quality system on day one. A reasonable
adoption path:

1. **Start with structure validation.** Run `check-structure.sh` to ensure the
   repo layout is correct. This catches the most damaging defects.
2. **Add freshness checking.** Once docs are in place, add
   `check-doc-freshness.sh` to prevent staleness.
3. **Add the tech debt register.** When the team starts noticing shortcuts,
   formalize tracking.
4. **Add the full scorecard.** When the project is mature enough to benefit
   from multidimensional quality measurement.

Each step adds value independently. There is no need to adopt everything at
once.

### Custom enforcement scripts

The provided scripts check Research_Map structural invariants. Projects should
add their own scripts for project-specific rules:

- A web application might check that every route has a corresponding test file.
- A library might check that every public function has a doc comment.
- A monorepo might check that cross-package dependencies follow declared rules.

The pattern is always the same: state the rule in docs, then write a script
that verifies it.

---

*Quality is not a destination. It is a feedback loop: define, measure, report,
improve. The scorecard, register, and scripts are the machinery that keeps
that loop turning.*
