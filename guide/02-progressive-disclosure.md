# Chapter 2: Progressive Disclosure

> Layer information from general to specific so that an agent can find any piece
> of information in three file reads or fewer.

---

## The Problem

AI agents operate under a hard constraint that human developers do not: the
context window. Every token an agent reads is a token subtracted from its
capacity to reason, generate code, and hold the current task in working memory.
An agent that reads 50,000 tokens of documentation before writing a single line
of code has already spent a quarter of a typical context window on orientation.

The naive response is "write less documentation." This is wrong. The real
problem is not the volume of documentation -- it is the way it is organized.

Consider two approaches to the same information:

**Approach A: Everything in one file**

A 600-line README contains the project overview, architecture, coding standards,
contribution guidelines, deployment instructions, and a FAQ. An agent looking
for the coding standards must read (or at minimum scan) 600 lines to find the
50 lines it needs. The other 550 lines are noise.

**Approach B: One file leads to another**

A 60-line entry file contains a routing table. One row says "Follow coding
standards -> docs/golden-rules/CODING_STANDARDS.md". The agent reads 60 lines,
follows one pointer, and reads the 150-line standards document. Total: 210
tokens consumed to get 150 tokens of useful content. Far better than reading
600 to find 50.

The difference is not just efficiency. When an agent reads irrelevant content,
it pollutes the context window with information that competes for attention
during reasoning. An architecture overview sitting in the context window while
the agent is writing a unit test is not harmless -- it is a distraction that
can cause the agent to over-engineer or second-guess its approach.

---

## The Principle

**Progressive disclosure** is an information design pattern where details are
revealed only when they are relevant. In repository design, it means organizing
content into layers where each layer provides more specificity than the last.

The model has three layers:

```
Layer 1: Entry Files       (~50-100 lines)   "Where do I go?"
Layer 2: Index Files       (~50-80 lines)    "What exists in this area?"
Layer 3: Detailed Documents (~100-250 lines)  "What are the specific rules?"
```

An agent starts at Layer 1 and descends only as far as it needs to. Most tasks
require reading one entry file and one detailed document -- two hops. Complex
tasks that span multiple areas might require three hops. If an agent
consistently needs four or more hops to find what it needs, the information
architecture is too deep.

The guiding metric is: **any piece of information should be reachable in three
or fewer file reads from the entry point.**

---

## Layer 1: Entry Files

Entry files sit at the repository root. They are the first thing an agent reads
when it opens a session. Their job is to provide orientation and routing -- not
content.

### What Belongs at Layer 1

- **Project identity.** One or two sentences: what is this project and what does
  it do?
- **Routing table.** A table mapping tasks to file paths. "I need to..." -> "Go
  to..."
- **Key constraints.** Three to five hard rules that apply to every session (e.g.,
  "never modify guide/", "always update freshness dates").
- **Session protocol.** How to start and end a session (read handoff, update
  handoff).

### What Does NOT Belong at Layer 1

- Architecture narratives
- Coding standards
- Deployment instructions
- Feature descriptions
- Historical context

If you find yourself explaining *how* to do something in an entry file, the
content belongs in a Layer 3 document. The entry file should contain a pointer,
not the explanation.

### Size Target

Entry files should be 50-100 lines. Above 150 lines, they are doing too much.
An agent should be able to read the entire entry file in a single pass without
significant context cost.

### Example

```markdown
# AGENTS.md -- Universal Agent Entry Point

## Quick Orientation
This is ProjectX -- a REST API for inventory management.

## Routing Table
| I need to...                  | Go to                                  |
|-------------------------------|----------------------------------------|
| Understand the architecture   | docs/architecture/OVERVIEW.md          |
| Follow coding standards       | docs/golden-rules/CODING_STANDARDS.md  |
| Run tests                     | docs/workflows/TESTING.md              |
| Check session state           | docs/session/SESSION_HANDOFF.md        |

## Key Rules
1. docs/ is the system of record. Never duplicate content into this file.
2. guide/ is read-only. Never modify it.
3. Update freshness dates when you modify any doc.
```

Notice what this file does NOT contain: the actual coding standards, the full
architecture, or the testing strategy. It is a signpost, not an encyclopedia.

---

## Layer 2: Index Files

Index files provide navigation within a content area. They list every document
in their section with a one-line description and a link. Their job is to help
the agent pick the right Layer 3 document.

### What Belongs at Layer 2

- **Section overview.** One or two sentences describing what this area covers.
- **Document listing.** A table of every document in the section with its purpose
  and last-reviewed date.
- **Freshness policy.** A reminder of the review cadence for this section.

### What Does NOT Belong at Layer 2

- Detailed content from any of the listed documents
- Instructions or procedures
- Decision rationale

### Size Target

Index files should be 40-80 lines. They are lookup tables, not reading material.

### Example

```markdown
# docs/ -- Master Index

## Architecture
| Document           | Purpose                            | Last Reviewed |
|--------------------|------------------------------------|---------------|
| OVERVIEW.md        | System architecture narrative      | 2026-02-01    |
| DEPENDENCY_RULES.md| Module and layer dependency rules  | 2026-02-01    |

## Golden Rules
| Document              | Purpose                        | Last Reviewed |
|-----------------------|--------------------------------|---------------|
| CODING_STANDARDS.md   | Naming, formatting, patterns   | 2026-01-28    |
| PRINCIPLES.md         | Non-negotiable design beliefs  | 2026-02-01    |
```

An agent scanning this index can immediately identify which document to read
without opening any of them. The one-line descriptions do the filtering.

---

## Layer 3: Detailed Documents

Detailed documents contain the actual content: rules, standards, procedures,
architecture descriptions, and decision records. They are the authoritative
source of truth for their topic.

### What Belongs at Layer 3

- **Complete coverage of one topic.** Each document owns exactly one area.
- **Machine-readable metadata.** Freshness date, status, ownership.
- **Cross-references.** Links to related documents (never circular).
- **Examples.** Concrete illustrations of abstract rules.

### What Does NOT Belong at Layer 3

- Content that duplicates another Layer 3 document
- Navigation to unrelated areas (that is the index's job)
- Temporary information (that belongs in plans/ or session/)

### Size Target

Detailed documents should be 100-250 lines. Above 300 lines, consider splitting
into two documents. Below 50 lines, consider whether the content belongs in
another document rather than standing alone.

### Example

A coding standards document might have:

```markdown
# Coding Standards
<!-- reviewed: 2026-02-01 -->

## Naming Conventions
- Functions: camelCase
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE

## Error Handling
- Always use explicit error types, never bare catch
- Log at the boundary, not at every layer

## Testing
- Every public function has at least one test
- Test files live next to source files: foo.ts -> foo.test.ts
```

Notice the format: headings, bullet points, consistent structure. No prose
paragraphs explaining *why* camelCase was chosen (that goes in an ADR if it
matters). The standards document is a reference, not a narrative.

---

## The Routing Table Pattern

The routing table is the workhorse of progressive disclosure. It appears in
entry files and index files, and it is the primary mechanism by which agents
navigate the repository.

### Why Tables Beat Prose

Compare:

```
Prose:
"If you need to understand the architecture, check out the OVERVIEW.md file
in the docs/architecture directory. For coding standards, there's a file
called CODING_STANDARDS.md in the golden-rules folder under docs."

Table:
| I need to...                | Go to                                 |
|-----------------------------|---------------------------------------|
| Understand the architecture | docs/architecture/OVERVIEW.md         |
| Follow coding standards     | docs/golden-rules/CODING_STANDARDS.md |
```

The table is:
- **Scannable.** An agent can parse the left column to find its need and jump to
  the right column for the path.
- **Unambiguous.** The path is exact. No interpretation needed.
- **Compact.** Two rows convey what the prose version takes four lines to say.
- **Machine-parseable.** A script can extract all routing targets and verify they
  exist.

### Routing Table Format

Use this consistent format across all entry and index files:

```markdown
| I need to...              | Go to                         |
|---------------------------|-------------------------------|
| [Task description]        | [Exact file path]             |
```

The left column describes the agent's intent (what it is trying to accomplish).
The right column provides the exact file path (no ambiguity, no "see also").

### Anti-pattern: Nested Routing

Do not create chains of routing tables that point to other routing tables that
point to more routing tables. Two layers of routing (entry file -> index ->
document) is the maximum. If an agent follows a routing table entry and lands
on another routing table, the structure is too indirect.

---

## Anti-Patterns

### Front-Loading Everything

```
BAD: A 500-line CLAUDE.md that contains the full architecture, all coding
standards, and deployment instructions.

WHY: The agent reads all 500 lines at session start. Most of the content is
irrelevant to the current task. Context window wasted.

FIX: Keep the entry file under 100 lines. Move content to dedicated docs.
Use a routing table to connect them.
```

### Deep Nesting

```
BAD: docs/standards/code/style/naming/functions/camelCase.md

WHY: Five levels of directory nesting. The agent must traverse five directories
to find one rule. Each directory listing is a context-window cost.

FIX: Flatten the hierarchy. docs/golden-rules/CODING_STANDARDS.md covers
all naming, style, and formatting in one document.
```

### Scattered Information

```
BAD: Coding standards are split across README.md (line 234), CONTRIBUTING.md
(line 89), .eslintrc (comments), and a Notion page.

WHY: The agent finds one fragment and assumes it is complete. It misses the
other fragments. Behavior is inconsistent.

FIX: Single source of truth. One file owns coding standards. Everything else
points to it.
```

### Missing Indexes

```
BAD: docs/ contains 15 files with no _INDEX.md. The agent must list the
directory and guess which file to read based on file names alone.

WHY: File names are not always self-explanatory. "WORKFLOW.md" vs
"DEVELOPMENT.md" vs "PROCESS.md" -- which one describes the PR review flow?

FIX: Add an _INDEX.md that describes each file's purpose in one line.
The agent reads the index, not the directory listing.
```

### Stale Layer 1

```
BAD: The entry file's routing table points to docs/CODING_STANDARDS.md but the
file was moved to docs/golden-rules/CODING_STANDARDS.md three months ago.

WHY: The agent follows the pointer, gets a file-not-found, and either gives up
or searches the tree -- wasting tokens either way.

FIX: Validation scripts check that every routing-table target exists. Run them
in CI. Broken pointers fail the build.
```

---

## Measuring Success

Progressive disclosure succeeds when the following are true:

### The Three-Hop Test

Pick any piece of information in the repository (a coding standard, an
architecture constraint, a workflow step). Starting from the entry file, count
how many files you must read to find it. If the answer is more than three, the
structure needs flattening or better routing.

### The Context Budget Test

Simulate an agent session. Track the total tokens read before the agent starts
productive work. If orientation consumes more than 5-10% of the context window,
the entry layer is too heavy or the routing is too indirect.

### The Freshness Test

Run the validation scripts. If more than 10% of routing-table targets are
broken or more than 20% of documents lack fresh review dates, the disclosure
layers have drifted and need maintenance.

### The New-Agent Test

Give the repository to a fresh agent instance with no prior context. Ask it to
perform a specific task (e.g., "add a new API endpoint following the coding
standards"). Observe whether it finds the right documents, follows the right
rules, and produces correct output. If it struggles, the progressive disclosure
structure is not working.

---

## Implementation Steps

To add progressive disclosure to an existing repository:

1. **Create entry files.** Write AGENTS.md (and agent-specific variants) with a
   routing table. Keep it under 100 lines.

2. **Create the master index.** Write docs/_INDEX.md listing every document in
   docs/ with a one-line description.

3. **Consolidate scattered content.** Find information that exists in multiple
   places. Pick one canonical location. Replace the others with pointers.

4. **Flatten deep hierarchies.** If any information requires more than three
   hops to reach, either move the document closer to the entry point or add a
   direct pointer in the routing table.

5. **Add validation.** Write a script that checks every routing-table entry
   resolves to an existing file. Run it in CI.

6. **Add freshness dates.** Tag every document with `<!-- reviewed: YYYY-MM-DD -->`.
   Write a script to flag stale documents.

---

## Adaptation

### Small repositories (under 20 files)

A single entry file with a routing table and a flat docs/ directory may be
sufficient. Skip the index layer -- the entry file can point directly to
individual documents (two-hop maximum).

### Large repositories (100+ files)

Add section-level indexes (docs/architecture/_INDEX.md, docs/workflows/_INDEX.md)
in addition to the master index. The extra routing layer is justified because
the alternative -- a 200-line master index -- defeats the purpose.

### Monorepos

Each package or service gets its own entry file and docs/ tree. A root-level
entry file provides a routing table that maps to package-level entry files.
This adds one hop but keeps each package's documentation self-contained.

### Non-code repositories (documentation-only, design systems)

The same pattern applies. Replace "code" with whatever the deliverable is.
The layers are: entry file -> content index -> individual content documents.
The principle is universal: start general, get specific, minimize hops.

---

*Previous: [Chapter 1 -- Why Agent Legibility Matters](01-why-agent-legibility.md)*
*Next: [Chapter 3 -- Multi-Agent Setup](03-multi-agent-setup.md)*
