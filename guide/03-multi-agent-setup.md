# Chapter 3: Multi-Agent Setup

> Support every major AI coding agent from a single repository by using
> multiple entry points that all route to one source of truth.

---

## The Problem

There is no single AI coding agent that every developer uses. Teams work with
Claude Code, OpenAI Codex, Cursor, GitHub Copilot, Windsurf, Aider, and others.
Each agent reads different configuration files:

- **Claude Code** reads `CLAUDE.md` (and `AGENTS.md`)
- **OpenAI Codex** reads `CODEX.md` (and often `AGENTS.md`)
- **Cursor** reads `.cursorrules` (or `.cursor/rules`)
- **GitHub Copilot** reads `.github/copilot-instructions.md`
- **Windsurf** reads `.windsurfrules`
- **Generic agents** may look for `AGENTS.md` as a universal convention

A repository that only supports one agent forces developers using other tools
to work without guidance. A repository that tries to support all agents by
duplicating content across multiple files creates a maintenance nightmare where
files inevitably drift out of sync.

Here is how drift happens in practice:

1. The team writes detailed instructions in `CLAUDE.md`.
2. A Cursor user copies the content into `.cursorrules`.
3. A month later, someone updates the coding standards in `CLAUDE.md`.
4. Nobody remembers to update `.cursorrules`.
5. Claude Code agents follow the new standards. Cursor agents follow the old
   ones. The codebase becomes inconsistent.
6. A third developer adds a `copilot-instructions.md` by copying from the
   now-stale `.cursorrules`.
7. Three files, three different versions of the truth.

This is not a people problem. It is a structural problem. Any system that
requires humans to manually synchronize multiple files will eventually drift.
The solution is to make synchronization unnecessary by eliminating duplication.

---

## The Principle

**Multiple entry points, single source of truth.**

Every agent gets its own entry file at the location it expects. But every entry
file is a thin routing layer that points to `docs/`. No entry file contains
substantive content. The authoritative rules, standards, and procedures live in
`docs/` and only in `docs/`.

When a rule changes, you update it in one place (`docs/`). Every agent picks up
the change automatically because every agent is routed to the same documents.

The architecture looks like this:

```
AGENTS.md ─────────────────────────────┐
CLAUDE.md ─────────────────────────────┤
CODEX.md ──────────────────────────────┤
.cursorrules / .cursor/rules/global.mdc ┼──── all route to ────> docs/
.github/copilot-instructions.md ───────┘                    (single source
                                                            of truth)
Optional extras (same pattern): .windsurfrules, custom tool entry files
```

The entry files differ only in:
- Format (some agents expect Markdown, others expect plain text)
- Agent-specific features (e.g., Claude Code skills, Cursor-specific syntax)
- Phrasing adapted to each agent's conventions

They are identical in:
- The routing destinations (all point to the same `docs/` files)
- The constraints they communicate (all convey the same rules)
- The project overview (same description, possibly rephrased)

---

## The Five-Entry-Point Pattern

Research_Map uses five entry points as a baseline. You can add more for
additional agents or remove ones you do not need.

### 1. AGENTS.md -- Universal Entry Point

This is the catch-all. Any agent that does not have a dedicated entry file
should read `AGENTS.md`. It is also the canonical reference for the routing
table that all other entry files mirror.

**Location:** Repository root (`AGENTS.md`)

**Format:** Markdown with routing table

**Contents:**
- Project identity (2-3 sentences)
- Repository layout (directory tree, 5-6 lines)
- Routing table (task -> file path)
- Key rules (3-5 non-negotiable constraints)
- How to start (3-4 numbered steps)

**Example structure:**

```markdown
# AGENTS.md -- Universal Agent Entry Point

## Quick Orientation
This is [ProjectName] -- [one-line description].

## Routing Table
| I need to...                  | Go to                              |
|-------------------------------|------------------------------------|
| Understand the architecture   | docs/architecture/OVERVIEW.md      |
| Follow coding standards       | docs/golden-rules/CODING_STANDARDS.md |
| Check session state           | docs/session/SESSION_HANDOFF.md    |
| Find all docs                 | docs/_INDEX.md                     |

## Key Rules
1. docs/ is the system of record. Never duplicate content here.
2. guide/ is read-only. Never modify it.
3. Update freshness dates on any modified doc.

## How to Start
1. Read docs/agent-guide/ONBOARDING.md
2. Check docs/session/SESSION_HANDOFF.md
3. Consult the routing table above for your task
```

**Size target:** 40-80 lines.

### 2. CLAUDE.md -- Claude Code Entry Point

Claude Code reads `CLAUDE.md` at session start. This file can include
Claude-specific features like skill references and session protocols.

**Location:** Repository root (`CLAUDE.md`)

**Format:** Markdown with routing table

**Additional content beyond AGENTS.md:**
- Skills available (Claude Code slash commands)
- Session protocol (Claude-specific start/end steps)
- Commit conventions (if Claude Code handles commits)
- Claude-specific constraints (tool usage, file permissions)

**Example additions:**

```markdown
## Skills Available
- /research-map scaffold -- Scaffold structure in a new project
- /research-map audit -- Audit project against the standard
- /session-handoff -- Generate a session handoff document

## Session Protocol
1. Start: Read docs/session/SESSION_HANDOFF.md
2. Work: Follow docs/workflows/DEVELOPMENT.md
3. Quality: Check against docs/quality/QUALITY_SCORECARD.md
4. End: Update docs/session/SESSION_HANDOFF.md
```

**Size target:** 40-80 lines.

### 3. CODEX.md -- OpenAI Codex Entry Point

OpenAI Codex sessions use `CODEX.md` as a first-class entry point. Keep it as a
routing table that mirrors `AGENTS.md`, with Codex-specific session conventions
if needed.

**Location:** Repository root (`CODEX.md`)

**Format:** Markdown with routing table

**Additional content beyond AGENTS.md:**
- Codex-specific workflow preferences
- Session protocol tuned for Codex behavior
- Commit and validation expectations

**Size target:** 40-80 lines.

### 4. .cursorrules -- Cursor Entry Point

Cursor reads `.cursorrules` from the repository root. The format is typically
plain text or Markdown. Cursor does not support all Markdown features, so keep
formatting simple.

**Location:** Repository root (`.cursorrules`)

**Format:** Plain text or simple Markdown

**Key differences from AGENTS.md:**
- May need simpler formatting (no complex tables in some Cursor versions)
- Should reference docs/ paths that Cursor can open
- Can include Cursor-specific instructions (e.g., how to use Cursor's
  context features)

**Example:**

```
# Project: [ProjectName]
# Description: [one-line description]

# IMPORTANT: All detailed rules live in docs/. This file is a routing table.
# Never duplicate content from docs/ into this file.

## Where to find things:
- Architecture: docs/architecture/OVERVIEW.md
- Coding standards: docs/golden-rules/CODING_STANDARDS.md
- Testing guidelines: docs/workflows/TESTING.md
- Session state: docs/session/SESSION_HANDOFF.md
- All docs: docs/_INDEX.md

## Key rules:
- docs/ is the system of record
- guide/ is read-only -- never modify
- Update <!-- reviewed: YYYY-MM-DD --> tags when modifying docs
- Run scripts/check-structure.sh before committing
```

**Size target:** 30-60 lines.

### 5. .github/copilot-instructions.md -- GitHub Copilot Entry Point

GitHub Copilot reads instructions from `.github/copilot-instructions.md`. This
file configures Copilot's behavior for the repository.

**Location:** `.github/copilot-instructions.md`

**Format:** Markdown

**Key differences from AGENTS.md:**
- Copilot operates primarily as a code completion and chat assistant, not a
  full session agent. Instructions should focus on code-level guidance.
- Routing to docs/ is still the pattern, but emphasize the coding standards
  and architectural constraints that directly affect code generation.

**Example:**

```markdown
# Copilot Instructions for [ProjectName]

## Project Overview
[ProjectName] is [one-line description].

## Code Generation Rules
Follow the coding standards in docs/golden-rules/CODING_STANDARDS.md.
Follow the dependency rules in docs/architecture/DEPENDENCY_RULES.md.

## Architecture
See docs/architecture/OVERVIEW.md for the system architecture.
Do not introduce dependencies that violate the layering rules.

## Testing
Follow the testing strategy in docs/workflows/TESTING.md.
Every public function must have at least one test.

## Documentation
When modifying docs, update the <!-- reviewed: YYYY-MM-DD --> tag.
Never modify files in the guide/ directory.
```

**Size target:** 30-50 lines.

---

## The Critical Rule: Route, Never Duplicate

This is the most important rule in multi-agent setup and it bears repeating:

**All entry points route to `docs/`. None of them duplicate content from `docs/`.**

When you are tempted to paste a coding standard into `.cursorrules` "just so
Cursor can see it directly," stop. Instead, write a reference:

```
BAD (duplication):
  .cursorrules: "Use camelCase for functions, PascalCase for classes"
  docs/golden-rules/CODING_STANDARDS.md: "Use camelCase for functions, PascalCase for classes"

  Problem: When the standard changes, you must update both files.

GOOD (routing):
  .cursorrules: "Follow coding standards in docs/golden-rules/CODING_STANDARDS.md"
  docs/golden-rules/CODING_STANDARDS.md: "Use camelCase for functions, PascalCase for classes"

  Benefit: Change the standard once in docs/. All agents see the update.
```

There is one narrow exception: the project overview (1-2 sentences describing
what the project does) may appear in each entry file because it is stable,
rarely changes, and helps agents orient before they follow any routing pointers.
Even this is optional -- you can route to a project overview doc instead.

---

## Keeping Entry Points in Sync

Even though entry points do not contain substantive content, they do contain
routing tables. These tables must stay synchronized -- every entry file should
route to the same set of key documents.

### The canonical routing table

Designate `AGENTS.md` as the canonical routing table. When adding a new doc to
the routing, update `AGENTS.md` first, then propagate the change to the other
entry files.

### Synchronization checklist

When you add, rename, or move a document in `docs/`:

1. Update `docs/_INDEX.md` (the master index)
2. Update the routing table in `AGENTS.md`
3. Update `CLAUDE.md` if the document is relevant to Claude sessions
4. Update `CODEX.md` if the document is relevant to Codex sessions
5. Update `.cursorrules` / `.cursor/rules/global.mdc` if relevant to Cursor users
6. Update `.github/copilot-instructions.md` if relevant to Copilot
7. Run `scripts/check-agent-files.sh` to verify all routing targets resolve

### Automation with validation scripts

The synchronization checklist above is manual. Humans and agents will forget
steps. That is why validation is essential.

`scripts/check-agent-files.sh` should verify:

- Every file path referenced in any entry file actually exists
- Key documents (CODING_STANDARDS.md, OVERVIEW.md, TESTING.md) appear in all
  routing tables that reference them
- No entry file exceeds the size threshold (suggesting content duplication)
- No entry file contains patterns that suggest inline policy (e.g., code
  blocks with rules instead of pointers to docs)

A basic implementation:

```bash
#!/bin/bash
# scripts/check-agent-files.sh
# Validates that agent entry files route correctly to docs/

ERRORS=0

# Check each entry file for broken references
for ENTRY_FILE in AGENTS.md CLAUDE.md CODEX.md .cursorrules .github/copilot-instructions.md; do
  if [ ! -f "$ENTRY_FILE" ]; then
    continue  # Not all entry files are required
  fi

  echo "Checking $ENTRY_FILE..."

  # Extract file paths (patterns like docs/something/FILE.md)
  PATHS=$(grep -oE 'docs/[a-zA-Z0-9_/-]+\.md' "$ENTRY_FILE" | sort -u)

  for PATH_REF in $PATHS; do
    if [ ! -f "$PATH_REF" ]; then
      echo "  ERROR: $ENTRY_FILE references $PATH_REF but file does not exist"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

if [ $ERRORS -gt 0 ]; then
  echo "FAILED: $ERRORS broken reference(s) found"
  exit 1
else
  echo "PASSED: All entry file references resolve"
  exit 0
fi
```

Run this in CI. A broken routing table should fail the build just like a broken
test.

---

## Writing Effective Entry Points

### General guidelines for all entry files

1. **Start with identity.** The first thing the agent reads should be the project
   name and a one-line description. This anchors the agent's understanding
   before it reads anything else.

2. **Use routing tables.** Tables are faster to parse than prose. Use the
   `| I need to... | Go to |` format consistently.

3. **State constraints explicitly.** Hard rules (e.g., "never modify guide/")
   belong in every entry file because they prevent damage before the agent
   reads any other document.

4. **Keep it under 100 lines.** If an entry file exceeds 100 lines, it is almost
   certainly duplicating content that belongs in `docs/`.

5. **End with a footer.** A one-line reminder: "This file is a routing table.
   All content lives in docs/." This reinforces the pattern for both agents and
   humans.

### Adapting tone for different agents

Each agent has different capabilities and conventions. Adapt the entry file's
phrasing accordingly:

- **Claude Code (CLAUDE.md):** Can handle nuanced instructions. Reference
  skills, session protocols, and commit conventions. Claude understands context
  well, so routing-table pointers are sufficient.

- **Cursor (.cursorrules):** Keep instructions concrete and direct. Cursor
  operates closer to code, so emphasize coding standards and architecture
  constraints. Simple formatting works best.

- **Copilot (.github/copilot-instructions.md):** Focus on code generation
  guidance. Copilot assists with completions and suggestions, so the most
  relevant docs are coding standards, testing patterns, and dependency rules.

---

## Anti-Patterns

### The monolithic entry file

```
BAD: CLAUDE.md is 400 lines and contains the full coding standards,
architecture overview, and testing strategy inline.

WHY: It works for Claude Code but creates massive duplication. When a standard
changes, CLAUDE.md must be updated separately from docs/. Other agents do not
benefit from the content because it is in a Claude-specific file.

FIX: Extract all substantive content to docs/. Replace inline content with
routing-table pointers.
```

### The copy-paste entry files

```
BAD: AGENTS.md, CLAUDE.md, CODEX.md, and .cursorrules contain identical 200-line
content copied between them.

WHY: Four copies of the same text. When one is updated, the others become
stale. An agent reading a stale copy follows outdated rules.

FIX: Move the shared content to docs/. Each entry file becomes a thin
routing layer with only agent-specific differences.
```

### The missing entry file

```
BAD: The team uses Claude Code and Cursor but only has CLAUDE.md. Cursor
users get no guidance.

WHY: Cursor agents work without context, making assumptions about coding
standards and architecture. Code quality varies by which agent wrote it.

FIX: Add .cursorrules with a routing table pointing to docs/. It takes 10
minutes and eliminates an entire class of inconsistency.
```

### Entry files that contradict each other

```
BAD: CLAUDE.md says "use async/await for all I/O." .cursorrules says "use
callbacks for performance."

WHY: Two agents, two conflicting instructions. Code written by different
agents follows different patterns. The codebase becomes a patchwork.

FIX: Neither entry file should contain this rule. It belongs in
docs/golden-rules/CODING_STANDARDS.md. Both entry files route there.
Contradiction becomes impossible because there is only one source.
```

---

## Implementation Steps

To set up multi-agent support in an existing repository:

1. **Identify which agents your team uses.** Survey the team. You only need
   entry files for agents that are actually in use (plus AGENTS.md as the
   universal fallback).

2. **Write AGENTS.md first.** This is the canonical routing table. Get the
   routing right here before creating agent-specific variants.

3. **Create agent-specific entry files.** For each agent in use, create the
   appropriate file (`CODEX.md`, `.cursorrules`, `copilot-instructions.md`,
   etc.). Copy the routing table from AGENTS.md and adapt the format and phrasing.

4. **Audit for duplication.** Search all entry files for substantive content
   (coding rules, architecture details, process descriptions). Move any you
   find to docs/ and replace with pointers.

5. **Add validation.** Create or update `scripts/check-agent-files.sh` to verify
   that all routing-table targets exist across all entry files.

6. **Document the pattern.** Add a note to your onboarding doc explaining why
   multiple entry files exist and how they stay in sync.

---

## Adaptation

### Single-agent teams

If your team only uses one AI agent, you still benefit from the routing pattern.
Write the entry file for your agent and AGENTS.md as the universal fallback. If
you add a second agent later, you already have the structure in place.

### Agents not listed here

New AI coding tools emerge regularly. The pattern is the same for any new agent:

1. Find out which file the agent reads for project instructions
2. Create that file at the expected location
3. Write a routing table pointing to `docs/`
4. Add the file to your validation script

The content of every entry file is the same: project identity, routing table,
key constraints. Only the format and agent-specific features differ.

### Teams with custom tooling

If your team uses a custom AI agent or wrapper, create a custom entry file for
it. The file name and location should match whatever the tool expects. The
content follows the same pattern: route to `docs/`, never duplicate.

### Keeping it lightweight

Not every entry file needs to route to every document. A Copilot instructions
file focused on code generation may only route to coding standards, testing, and
architecture. A Claude Code file for a full-session agent may route to the
complete document set. Tailor each entry file to what that specific agent needs
most frequently.

---

*Previous: [Chapter 2 -- Progressive Disclosure](02-progressive-disclosure.md)*
