# Research Management Workflow

<!-- reviewed: 2026-02-24 -->

> **Purpose:** Define how AI copilots and humans coordinate research programs from intake to publication.

## Operating Model

Research work is managed through five linked artifacts:

1. Intake brief (`docs/research-ops/PROJECT_INTAKE_TEMPLATE.md`)
2. Hypothesis register (`docs/research-ops/HYPOTHESIS_REGISTER_TEMPLATE.md`)
3. Experiment log (`docs/research-ops/EXPERIMENT_LOG_TEMPLATE.md`)
4. Literature tracker (`docs/research-ops/LITERATURE_TRACKER_TEMPLATE.md`)
5. Evidence packet (`docs/research-ops/RESULT_EVIDENCE_TEMPLATE.md`)

These artifacts make copilot behavior auditable and reduce context loss across sessions.

## Lifecycle

### 1) Intake and Scoping

- Capture research question, constraints, deadlines, and target venue.
- Define success metrics before running experiments.
- Open or update an execution plan in `plans/active/`.

### 2) Hypothesis Management

- Maintain explicit hypothesis statements and acceptance criteria.
- Link each hypothesis to planned experiments.
- Track status (`open`, `supported`, `refuted`, `inconclusive`).

### 3) Experiment Execution

- Every run gets an experiment log entry with config, seed, and dataset version.
- Distinguish exploratory runs from decision-driving runs.
- Record failed runs and why they failed.

### 4) Literature and Citation Control

- Track candidate papers in the literature tracker.
- Mark citation status (`verified`, `placeholder`, `rejected`).
- Only verified citations may support claims in final drafts.

### 5) Evidence Synthesis and Decisions

- For each major claim, assemble a compact evidence packet.
- Record confidence and limitations.
- Document decision outcomes in plan updates and session handoff.

## Copilot Task Contract

When assigning work to a copilot, always provide:

- Task objective and hypothesis ID(s)
- Allowed datasets/models/compute constraints
- Required outputs (files, tables, charts, paper sections)
- Validation gates required for completion
- Escalation rule for ambiguity or contradictory results

## Weekly Cadence (Recommended)

- Review hypothesis statuses
- Triage blocked experiments
- Review unresolved citations/placeholders
- Refresh active plan priorities
- Update `docs/session/SESSION_HANDOFF.md`

## Completion Criteria for a Research Milestone

- Plan phase marked complete
- Evidence packet updated
- Reproducibility notes documented
- Citation status cleaned for milestone artifacts
- Handoff updated with next milestones
