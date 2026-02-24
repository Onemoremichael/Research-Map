# Dependency Rules

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Keep information flow predictable and avoid policy drift.

## Rule 1: Entry Files Route, They Do Not Define Policy

`AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.cursorrules`, and
`.github/copilot-instructions.md` must point to docs. They should stay concise.

## Rule 2: docs/ Is Authoritative

All operational truth lives in `docs/`. If workflow changes, update docs first.

## Rule 3: plans/ Is Temporal

Plans contain active work context and can expire. Durable guidance moves to docs.

## Rule 4: guide/ Is Read-Only for Agents

`guide/` explains framework concepts. Agents should not modify it during routine work.

## Rule 5: Research Claims Depend on Evidence

Any claim in docs/plans/papers must map to reproducible evidence. If evidence is
missing or uncertain, label it explicitly.

## Rule 6: Citation Claims Require Verification

Citations must be verified before being treated as facts. Use the policy in
`docs/workflows/PAPER_WRITING.md` and `docs/golden-rules/CODING_STANDARDS.md`.

## Allowed References

- Entry files -> `docs/*`, `plans/*`
- `docs/*` -> `docs/*`, `plans/*`, local scripts
- `plans/*` -> `docs/*`, experiment/code paths
- `guide/*` -> may reference docs, but is not operational authority

## Prohibited References

- Policy defined only in entry files
- Plans used as long-term policy store
- Paper claims without traceable evidence/citation status
