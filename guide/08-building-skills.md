# Chapter 8: Building Claude Code Skills

> **Pattern:** Encode repeatable agent workflows as slash-command skills --
> self-contained packages of instructions and reference data that extend Claude
> Code's capabilities without modifying its core behavior.

---

## The Problem

Agents are general-purpose. They can do almost anything, but they do nothing
automatically. Every session, the agent must be told what to do, how to do it,
and where to find the information it needs. For one-off tasks, this is fine. For
repeatable workflows, it is expensive.

Consider a common scenario: auditing a repository against the Research_Map
standard. Without a skill, the process looks like this:

1. The human types a paragraph explaining what to audit.
2. The agent asks clarifying questions.
3. The human points the agent to the checklist file.
4. The agent reads the checklist and starts checking.
5. Midway through, the agent forgets a criterion and the human corrects it.
6. The agent produces a report in whatever format it invents.

With a skill, the process is:

1. The human types `/research-map audit`.
2. The agent reads the skill instructions, loads the checklist from a reference
   file, executes every check, and produces a standardized report.

The skill eliminates ambiguity, reduces token waste, and produces consistent
results. It is the difference between giving someone verbal directions every
time and handing them a map.

---

## The Principle

**Repeatable workflows should be encoded, not repeated.** If you find yourself
giving an agent the same instructions more than twice, that workflow is a
candidate for a skill.

Skills are not automation scripts. They are instruction documents that an agent
reads and follows. The agent still does the reasoning -- it still reads files,
makes judgments, and adapts to the specific situation. The skill provides the
structure: what to do, in what order, with what inputs, producing what outputs.

This is a crucial distinction. A bash script executes rigidly. A skill is
*interpreted* by an agent that can handle edge cases, ask questions when
something is unexpected, and adapt the procedure to the situation. Skills
combine the consistency of scripts with the flexibility of agents.

---

## Implementation

### What Skills Are

In Claude Code, a skill is a slash command that agents can invoke. When a user
types `/skill-name` or `/skill-name subcommand`, Claude Code loads the skill's
instruction file and follows it.

Skills live in the `.claude/skills/` directory:

```
.claude/skills/
  research-map/
    SKILL.md                    # The instruction file
    references/
      directory-spec.md         # Supporting data
      checklist.md              # Audit criteria
      remediation.md            # Fix instructions
  session-handoff/
    SKILL.md                    # The instruction file
```

Each skill is a directory containing a `SKILL.md` file and an optional
`references/` directory with supporting data.

### Skill Anatomy

A skill has two parts: instructions and references.

**SKILL.md (instructions):**

This is the file Claude Code reads when the skill is invoked. It contains:

1. **Description:** What the skill does, in plain language.
2. **Subcommands:** If the skill has multiple modes (like `scaffold` and
   `audit`), each is documented with its usage and behavior.
3. **Instructions for Claude:** Step-by-step procedure the agent should follow.
   These are written as imperative instructions ("Read X", "Check Y",
   "Produce Z").
4. **Output format:** What the result should look like. This ensures
   consistency across invocations.

**references/ (supporting data):**

Reference files contain the data the skill needs -- checklists, templates,
specifications, lookup tables. They are separated from the instructions so that
the data can be updated without modifying the skill's logic.

For example, the `research-map` skill has three reference files:

| File               | Contents                                          |
|--------------------|---------------------------------------------------|
| `directory-spec.md`| Complete directory tree with required/optional markers |
| `checklist.md`     | Every audit criterion with pass/fail definitions  |
| `remediation.md`   | Step-by-step fixes for common audit failures      |

The agent reads these files as part of executing the skill. The separation
means that adding a new audit criterion is a data change (edit `checklist.md`),
not a logic change (edit `SKILL.md`).

### Designing a Skill

Skill design follows a four-step process:

**Step 1: Identify the workflow.**

Look for tasks that are:
- Performed repeatedly (at least 2-3 times per month).
- Structured enough to describe as a procedure.
- Complex enough that ad-hoc instructions are error-prone.
- Beneficial to standardize (consistent output matters).

Examples: auditing repo quality, scaffolding new components, generating release
notes, performing session handoffs, running migration checklists.

**Step 2: Define the interface.**

Decide:
- **Name:** Short, descriptive, lowercase with hyphens. (`research-map`, not
  `ContextMapAuditAndScaffold`).
- **Subcommands:** If the skill has multiple modes, name each one. Keep to 2-3
  subcommands maximum. If you need more, consider splitting into separate skills.
- **Parameters:** What inputs does the skill accept? Keep these minimal -- most
  skills should work with zero parameters.
- **Output:** What does the skill produce? A report? A set of files? A commit?

**Step 3: Write the instructions.**

Write `SKILL.md` as a set of clear, imperative instructions. The audience is
an AI agent, not a human developer. Key principles for instruction writing:

- **Be explicit about file paths.** "Read `references/checklist.md`" not "read
  the checklist."
- **Specify the order of operations.** Number the steps. Agents follow numbered
  steps more reliably than unordered bullet lists.
- **Define the output format.** If the skill produces a report, show exactly
  what the report should look like, including section headings, table format,
  and summary structure.
- **Handle edge cases.** What should the agent do if a file is missing? If a
  check is ambiguous? If the project does not match expected structure?
- **End with a clear completion condition.** The agent should know unambiguously
  when the skill is done.

**Step 4: Add reference files.**

Extract data from the instructions into reference files when:
- The data is longer than ~20 lines.
- The data changes independently of the instructions.
- The data is used by multiple skills or other parts of the project.
- The data represents a specification that should be versioned separately.

### Case Study: The `research-map` Skill

The `research-map` skill demonstrates these principles in practice. It supports
two subcommands: `scaffold` and `audit`.

**`/research-map scaffold`**

- **Purpose:** Create the Research_Map directory structure in a new project.
- **Instructions (summarized):**
  1. Read `references/directory-spec.md` to load the complete directory tree.
  2. Check which directories and files already exist.
  3. Create only the missing ones. Never overwrite existing content.
  4. Set freshness dates on all new docs to today.
  5. Run a quick audit to confirm completeness.
  6. Report what was created and what already existed.

The key instruction is step 3: "never overwrite existing content." This makes
the skill **non-destructive** -- it can be run safely on a partially
scaffolded project.

**`/research-map audit`**

- **Purpose:** Evaluate a project against the Research_Map standard.
- **Instructions (summarized):**
  1. Read `references/checklist.md` to load all audit criteria.
  2. Walk the project directory, checking each criterion.
  3. Record pass or fail with a brief reason for each check.
  4. Calculate an overall score (passed / total as a percentage).
  5. Look up remediations in `references/remediation.md` for failures.
  6. Present results as a three-section report: score, details, remediation.

The skill is **read-only** -- it never modifies the project. This makes it safe
to run at any time, including in CI.

**What makes this skill effective:**

- **Two clear subcommands** with distinct purposes (create vs. evaluate).
- **Reference files** separate the specification from the logic. Adding a new
  required directory means editing `directory-spec.md`, not `SKILL.md`.
- **Defined output format** ensures every audit produces the same report
  structure, making results comparable across runs.
- **Safety properties** are explicit: scaffold is non-destructive, audit is
  read-only.

### Best Practices

**Single responsibility.** Each skill should do one thing well. The
`research-map` skill is borderline -- it has two subcommands -- but both operate
on the same domain (Research_Map structure). If you find a skill growing beyond
2-3 subcommands, split it.

**Clear parameters.** Prefer skills that work with zero parameters over skills
that require configuration. The fewer decisions the user has to make when
invoking a skill, the more likely they are to use it. When parameters are
needed, document them with examples.

**Reference files for data.** Never embed large data structures in `SKILL.md`.
Checklists, templates, specifications, and lookup tables belong in `references/`.
The instruction file should be readable in under a minute.

**Idempotent operations.** Skills should be safe to run multiple times. Scaffold
should not create duplicates. Audit should not leave artifacts. A user should
never be afraid to invoke a skill.

**Explicit output format.** Define what the result looks like. Show an example
report or output structure in the instructions. This prevents the agent from
inventing a different format each time, which makes output unreliable and
hard to compare.

**Error handling.** Document what the agent should do when things go wrong.
"If the file does not exist, report it as a failure and continue" is better
than leaving the agent to decide on its own.

### Testing Skills

Skills are tested by running them and verifying the output. There is no unit
test framework for skills -- they are instruction documents, not code. But
that does not mean they cannot be validated.

**Testing approaches:**

1. **Run on a clean project.** Scaffold a new project from scratch and verify
   all files are created correctly.
2. **Run on a partial project.** Scaffold a project that already has some files
   and verify nothing is overwritten.
3. **Run audit on a known-good project.** The score should be high. Any
   unexpected failures indicate a bug in the checklist or instructions.
4. **Run audit on a known-bad project.** The score should be low. The failures
   should match the known defects.
5. **Check edge cases.** What happens with an empty project? A project with
   unexpected files? A project with corrupted docs?

Test after any change to `SKILL.md` or reference files. Skill bugs are subtle
because the skill does not crash -- it just produces wrong output.

### Skill Distribution

Skills are part of the repository. When a project is cloned or forked, the
skills come with it. This is intentional:

- **Skills are project-specific.** A skill that scaffolds Research_Map structure
  belongs in a Research_Map repo. A skill that generates API docs belongs in the
  API project.
- **Skills travel with the repo.** There is no external skill registry to
  configure. Clone the repo, and the skills are available.
- **Skills are version-controlled.** Changes to skills are tracked, reviewed,
  and reversible. A broken skill can be reverted like any other file.

For skills that are useful across multiple projects (like `session-handoff`),
include them in the template repo so every new project inherits them.

---

## Adaptation

### Skills for different domains

The `research-map` skill is domain-specific. Other domains suggest other skills:

- **Web application:** `/generate-component` -- scaffold a new UI component
  with tests, styles, and docs.
- **API project:** `/add-endpoint` -- create a new endpoint with route,
  handler, validation, tests, and API doc entry.
- **Data pipeline:** `/add-stage` -- scaffold a new pipeline stage with
  config, tests, and monitoring hooks.
- **Documentation project:** `/review-docs` -- audit all docs for freshness,
  broken links, and style compliance.

The pattern is the same: identify the repeatable workflow, define the interface,
write the instructions, add reference data.

### Growing a skill library

Start with one skill for your most-repeated workflow. Add new skills only when
you observe a workflow being repeated manually. Resist the urge to pre-build
skills for workflows that might be needed -- skills are cheap to create later
and expensive to maintain if unused.

A healthy skill library for a mid-size project has 3-5 skills. More than that
suggests either a complex project or skills that are too narrowly scoped.

### Skills vs. scripts

Skills and scripts serve different purposes:

| Aspect      | Skill                          | Script                          |
|-------------|--------------------------------|---------------------------------|
| Executor    | AI agent                       | Shell / runtime                 |
| Flexibility | Adapts to context              | Rigid execution                 |
| Judgment    | Can handle edge cases          | Fails on unexpected input       |
| Output      | Natural language + structured  | Structured only                 |
| Best for    | Complex, judgment-required     | Simple, deterministic checks    |

Use scripts for checks that are purely mechanical (does this file exist? is
this date within range?). Use skills for workflows that require reading,
reasoning, and adapting (audit the project, scaffold with awareness of existing
state, generate a report with recommendations).

The two are complementary. A skill can invoke scripts as part of its procedure:
"Run `scripts/check-structure.sh` and include the output in the report."

---

*Skills are the bridge between ad-hoc agent instructions and reliable, repeatable
workflows. They encode your team's best practices into a format that agents can
follow consistently -- turning tribal knowledge into institutional capability.*
