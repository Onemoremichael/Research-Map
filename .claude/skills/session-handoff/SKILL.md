# Session Handoff

Generate or update the session handoff document to ensure continuity between
work sessions. This skill captures the current state of work so the next
session (human or agent) can pick up without lost context.

## Usage

```
/session-handoff
```

No arguments required. The skill reads the current project state and conversation
context to produce the handoff document.

## Output

Updates `docs/session/SESSION_HANDOFF.md` with the latest session state. If the
file does not exist, it is created using the template in
`references/handoff-template.md`.

## Instructions for Claude

1. Read `references/handoff-template.md` to load the handoff document structure.
2. If `docs/session/SESSION_HANDOFF.md` already exists, read it to understand
   prior session state.
3. Gather current session context:
   - Summarize the work performed in this session.
   - Identify items that are in progress but not yet complete.
   - Note any blockers or unresolved questions.
   - List key decisions that were made.
   - Enumerate files that were created or modified.
4. Determine prioritized next steps based on incomplete work and project goals.
5. Write the updated handoff document to `docs/session/SESSION_HANDOFF.md`:
   - Set `Last Updated` to today's date.
   - Fill every section from the template. Leave no section empty. Use "None"
     if a section genuinely has no items.
   - Preserve any relevant context from previous handoff entries that is still
     applicable.
6. Confirm the update to the user with a brief summary of what was captured.

## Notes

- This skill is non-destructive in the sense that it preserves prior context,
  but it does overwrite the handoff file with the latest state.
- Run this skill at the end of every work session for best results.
- The handoff document is intentionally concise. Link to other docs rather
  than duplicating detailed content.
