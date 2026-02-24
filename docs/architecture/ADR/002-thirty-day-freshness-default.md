# ADR-002: 30-Day Default Freshness Threshold

<!-- reviewed: 2026-02-11 -->

| Field     | Value                          |
|-----------|--------------------------------|
| **ADR**   | 002                            |
| **Title** | 30-day default freshness threshold |
| **Date**  | 2026-02-11                     |
| **Status**| Accepted                       |

---

## Context

Every document in `docs/` carries a `<!-- reviewed: YYYY-MM-DD -->` tag.
`scripts/check-doc-freshness.sh` flags documents whose tag is older than a
configurable threshold. The question is: what should the default be?

Too short and teams spend all their time rubber-stamping dates. Too long and
stale docs accumulate silently until an agent acts on outdated guidance.

Agent-led development makes this more urgent than in human-only workflows.
Agents follow docs literally — a stale doc doesn't just confuse, it causes
wrong actions taken with full confidence.

---

## Decision

Default freshness threshold is **30 days**. The script accepts a
`--max-age-days` flag so adopters can adjust for their cadence.

---

## Options Considered

### Option A: 90-day threshold

Common in traditional documentation practices.

- **Pros**: Low maintenance overhead. Aligns with quarterly review cycles.
- **Cons**: Three months is long enough for significant drift in an actively
  developed project. Agents acting on 80-day-old docs may follow obsolete
  instructions.

### Option B: 30-day threshold (chosen)

Monthly review cycle.

- **Pros**: Catches drift before it compounds. Aligns with typical sprint
  cadences. "Review" can be a quick confirmation — if nothing changed, just
  update the date.
- **Cons**: Higher review frequency. Teams with slow-moving docs may find it
  noisy.

### Option C: 7-day threshold

Weekly review.

- **Pros**: Near-realtime accuracy guarantees.
- **Cons**: Unsustainable for most teams. Review fatigue leads to rubber-stamping,
  which defeats the purpose entirely.

---

## Consequences

### Positive

- Docs stay accurate enough that agents can trust them without second-guessing
- Monthly review is achievable — most docs only need a date bump, not a rewrite
- The `--max-age-days` escape hatch means this isn't one-size-fits-all

### Negative

- Teams with stable, slow-moving docs may flag false positives
- The 30-day default requires discipline to avoid rubber-stamping

### Follow-Up

- [ ] If rubber-stamping becomes a pattern, consider adding a `--strict` mode
  that checks git diff to verify actual content review
