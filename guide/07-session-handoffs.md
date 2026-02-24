# Chapter 7: Session Handoffs for Continuity

> **Pattern:** Capture the full state of a working session in a structured
> document so the next agent -- or the same agent in a new session -- can resume
> without loss of context, momentum, or intent.

---

## The Problem

Agent sessions are ephemeral. When a session ends, the agent's working memory
disappears. The next session starts from zero -- no memory of what was done,
what was tried, what failed, or what was decided. This is not a bug in the
agent. It is a fundamental property of session-based interaction.

Without explicit handoff mechanisms, projects suffer from what might be called
"session amnesia":

- **Duplicated work.** The next agent re-investigates a problem that was already
  diagnosed. It re-reads files that were already analyzed. It re-derives
  conclusions that were already reached.
- **Lost decisions.** A design choice was made in session three, but session
  four does not know about it and makes a different choice. The codebase
  accumulates contradictory decisions.
- **Invisible blockers.** An agent hit a wall -- a failing test, a missing
  dependency, an ambiguous requirement -- and the information dies with the
  session. The next agent hits the same wall.
- **Context loading tax.** Every session spends its first 10-20 minutes
  re-orienting. In a project with many short sessions, this tax consumes a
  significant fraction of productive capacity.
- **The "what happened?" question.** A human reviewing the project has to piece
  together what occurred from git logs, file diffs, and guesswork. There is no
  narrative.

The cost of session amnesia compounds over time. Each lost handoff makes the
next session less efficient, which makes the project slower, which increases the
number of sessions needed, which creates more handoff opportunities to lose.

---

## The Principle

**Minimize coordination cost.** The next agent should never need to ask "what
happened?" The repository should tell it -- clearly, completely, and in a
predictable location.

This is Principle 10 from the Research_Map design principles. It recognizes that
the coordination cost between sessions is a first-order concern, not an
afterthought. Every minute an agent spends re-orienting is a minute it is not
doing productive work.

The mechanism is a **session handoff document** -- a structured Markdown file
that captures the state of work at the end of each session. It is not a log
(which accumulates entries). It is a snapshot (which is overwritten each time).
The previous state is preserved in git history, not in the document itself.

---

## Implementation

### What a Session Handoff Is

A session handoff is a structured document stored at
`docs/session/SESSION_HANDOFF.md`. It answers seven questions:

1. **What happened?** (Session Summary)
2. **What is finished?** (Work Completed)
3. **What is in progress?** (Work In Progress)
4. **What is stuck?** (Blocked Items)
5. **What should happen next?** (Next Steps)
6. **What choices were made?** (Key Decisions)
7. **What is unresolved?** (Open Questions)

Every field is mandatory. If a section has no content (e.g., there are no
blocked items), it should say "None" rather than being omitted. An empty section
is ambiguous -- it could mean "nothing" or it could mean "the agent forgot to
fill this in."

### The Handoff Template

```markdown
# Session Handoff

<!-- reviewed: YYYY-MM-DD -->

## Last Updated
YYYY-MM-DD

## Session Summary
[1-3 sentences describing what this session accomplished at a high level.]

## Work Completed
- [Specific deliverable 1 -- file names, feature names, bug IDs]
- [Specific deliverable 2]

## Work In Progress
- [Task 1 -- what state it is in, what remains]
- [Task 2 -- enough context to pick up without re-reading everything]

## Blocked Items
- [Blocker 1 -- what is blocked and what would unblock it]

## Next Steps
1. [Highest priority task -- be concrete, not vague]
2. [Second priority task]
3. [Third priority task]

## Key Decisions
- [Decision 1 -- what was decided and why. Link to ADR if one was created.]

## Open Questions
- [Question 1 -- what needs human input or further investigation]
```

**Field-level guidance:**

**Session Summary:** Write this last, even though it appears first. It is the
executive summary. One to three sentences that a human or agent can read in
five seconds to understand the session's contribution.

**Work Completed:** Be specific. "Updated authentication" is not useful.
"Added JWT validation middleware in `src/auth/validate.ts` and updated
`docs/architecture/OVERVIEW.md` to document the auth flow" is useful. The next
agent needs to know exactly what files were touched and what state they are in.

**Work In Progress:** This is the most critical section for continuity. For
each in-progress item, include enough context that the next agent can resume
without re-reading the entire codebase. What approach was chosen? What is
done so far? What step comes next?

**Blocked Items:** Include what would unblock each item. "Blocked on database
migration" is less useful than "Blocked on database migration -- needs DBA to
approve the schema change in `migrations/005_add_roles.sql`."

**Next Steps:** Prioritize. Number the items. Be concrete: "Implement the
`/users` endpoint following the pattern in `src/routes/posts.ts`" is
actionable. "Continue working on the API" is not.

**Key Decisions:** Every non-trivial choice made during the session. Future
agents need this to avoid re-litigating settled questions. If an ADR was
created, link to it.

**Open Questions:** Things the agent was unsure about. This is the explicit
surface for human input. A human reviewing the handoff can answer these
questions before the next session starts, turning ambiguity into direction.

### The Session Protocol

The handoff document integrates into a three-phase session protocol:

**Phase 1: Start (read the handoff)**

```
1. Open docs/session/SESSION_HANDOFF.md
2. Read the Session Summary for orientation
3. Read Work In Progress for current state
4. Read Blocked Items for known obstacles
5. Read Next Steps for priorities
6. Read Open Questions for any answers provided by the human
```

This takes 1-2 minutes and replaces 10-20 minutes of re-orientation. The agent
knows what happened, what is in flight, and what to do next.

**Phase 2: Work (execute the session)**

Work proceeds according to the priorities in Next Steps, adjusted for any new
instructions from the human. During work:

- If a decision is made, note it for the handoff.
- If a blocker is encountered, note it for the handoff.
- If a question arises that cannot be resolved, note it for the handoff.
- If an in-progress item is completed, note it for the handoff.

These notes can be mental (within the session) or written in a scratch area.
The key is that nothing is lost when the session ends.

**Phase 3: End (write the handoff)**

Before closing the session, update `docs/session/SESSION_HANDOFF.md`:

1. Overwrite every field with current information.
2. Update the `Last Updated` date and the freshness tag.
3. Commit with the message: `session: update handoff [YYYY-MM-DD]`.

The handoff update is the last action of every session. It is not optional. A
session without a handoff update is a session that never happened -- its work
may be in the code, but its context is lost.

### Overwrite, Do Not Append

The handoff document is overwritten each session, not appended to. This is a
deliberate design choice:

- **Appending creates accumulation.** After ten sessions, the document is ten
  handoffs long. An agent reading it must scan through history to find the
  current state.
- **Overwriting keeps it current.** The document always reflects the latest
  session. There is no parsing required.
- **Git preserves history.** Previous handoff states are accessible via
  `git log -p docs/session/SESSION_HANDOFF.md`. The history is there when
  needed, but it does not clutter the working document.

This mirrors how a physical shift handoff works: the outgoing shift fills in
the current state on a form. The incoming shift reads the form. Previous forms
are filed, not stapled to the current one.

### Minimizing Coordination Cost

The handoff is designed to minimize the time between "session starts" and
"productive work begins." Every design choice in the template serves this goal:

- **Fixed structure** means the agent knows where to look. There is no
  variation between handoffs in format or section order.
- **Mandatory fields** mean nothing is accidentally omitted. The agent never
  encounters a handoff that is missing the section it needs.
- **Concrete language** means the agent does not have to interpret vague
  descriptions. "Implement X in file Y following pattern Z" is immediately
  actionable.
- **Prioritized next steps** mean the agent does not have to decide what to
  work on. The previous session already made that determination.

The gold standard: an agent reads the handoff and begins productive work within
its first action. No clarifying questions. No re-exploration. No wasted tokens.

### Handoff as a Skill

In Research_Map projects using Claude Code, the session handoff can be invoked
as a skill:

```
/session-handoff
```

This skill reads the current state of the project -- recent git history, open
files, active plans -- and generates a draft handoff document. The agent reviews
the draft, adjusts any details, and commits it.

The skill automates the mechanical parts of handoff creation (gathering facts)
while preserving the agent's judgment for the interpretive parts (summarizing
decisions, prioritizing next steps). See Chapter 8 for more on building skills.

---

## Adaptation

### Multi-agent coordination

When multiple agents work on the same project simultaneously (e.g., one on
frontend, one on backend), a single handoff document creates contention. Two
approaches:

**Scoped handoffs:** Create separate handoff files for each work stream:
```
docs/session/SESSION_HANDOFF_FRONTEND.md
docs/session/SESSION_HANDOFF_BACKEND.md
```

Each agent reads and writes only its scoped handoff. A periodic coordination
session (human or agent) reads all handoffs and resolves cross-stream issues.

**Shared handoff with sections:** Keep a single file but add labeled sections
for each work stream. This works when the streams are tightly coupled and
agents need to see each other's state.

### Long-running sessions

For sessions that span hours of continuous work, consider mid-session handoff
updates. This protects against session crashes or interruptions. A mid-session
handoff does not need to be committed -- it can be a local save that is
finalized and committed at session end.

### Minimal handoffs

Not every session warrants a detailed handoff. If the session was short and
accomplished a single, well-defined task (like fixing a typo), the handoff can
be brief:

```markdown
## Session Summary
Fixed typo in docs/architecture/OVERVIEW.md.

## Work Completed
- Fixed "dependancy" -> "dependency" in OVERVIEW.md, line 47

## Work In Progress
None

## Next Steps
1. Continue with items from the previous handoff's Next Steps
```

The structure is the same. Only the content is shorter. Do not skip the
structure itself -- the predictability of the format is more important than the
length of the content.

### Handoffs in non-agent projects

The handoff pattern works for human developers too. Any project where work
is done in sessions (which is all projects) benefits from explicit state
capture. The format is the same; the audience is the developer's future self
instead of a different agent.

---

*Session handoffs are the memory that agents lack. They convert ephemeral
sessions into a continuous narrative of progress, decisions, and intent. The
fifteen minutes spent writing a handoff saves hours of re-orientation across
every future session.*
