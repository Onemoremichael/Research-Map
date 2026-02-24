# Non-Negotiable Design Principles

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Core rules for reliable, agent-assisted research.

## 1. One Truth in docs/

Operational truth belongs in `docs/`. Entry files are routers.

## 2. Progressive Disclosure

Keep top-level guidance short. Route to detail when needed.

## 3. Evidence Before Claims

Every research claim must map to reproducible evidence.

## 4. Never Hallucinate Citations

If a citation cannot be verified programmatically or from a trusted source,
mark it as placeholder and flag it.

## 5. Temporal vs Evergreen Separation

`plans/` for active initiatives, `docs/` for stable policy, `guide/` for teaching.

## 6. Enforce What Matters

Use scripts to validate structure, routing, freshness, and links.

## 7. Reproducibility Is a Quality Gate

Results are not complete without rerun instructions, configs, and environment notes.

## 8. Session Continuity Is Mandatory

End each session by updating `docs/session/SESSION_HANDOFF.md`.
