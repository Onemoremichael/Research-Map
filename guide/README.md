# Research_Map Guide

> Educational companion to the Research_Map agent-first repository template.

## What This Guide Is

This guide explains the ideas, patterns, and principles behind Research_Map. It is
not operational documentation -- it does not tell you what to do in this specific
project. Instead, it teaches you *why* the template is structured the way it is
and how to apply the same thinking to your own repositories.

Think of it as a textbook that ships alongside the working example. The repo
itself demonstrates every pattern; the guide explains the reasoning.

## Who It Is For

- **Developers** adopting agent-led development for the first time
- **Teams** transitioning from human-centric repos to agent-first structures
- **AI agents** that need to understand the methodology (though agents should
  prefer `docs/` for operational questions)
- **Architects** evaluating whether Research_Map fits their workflow

## How to Read It

- **Sequential for learning.** Chapters build on each other. Start at Chapter 1
  and read through to understand the full methodology.
- **Individual chapters for reference.** Each chapter is self-contained enough to
  be useful on its own. Jump to whichever topic you need.

Every chapter follows the same structure: **Problem** (what goes wrong without
this pattern), **Principle** (the core idea), **Implementation** (how to do it),
**Adaptation** (how to tailor it to your context).

## Chapters

| Chapter | Title | Description |
|---------|-------|-------------|
| [01](01-why-agent-legibility.md) | Why Agent Legibility Matters | The case for structuring repos so AI agents can read them effectively |
| [02](02-progressive-disclosure.md) | Progressive Disclosure | Layering information so agents find what they need in three hops or fewer |
| [03](03-multi-agent-setup.md) | Multi-Agent Setup | Supporting Claude Code, Cursor, Copilot, and other agents from one repo |
| [04](04-execution-plans.md) | Execution Plans as First-Class Artifacts | Giving complex tasks structured, lifecycle-managed documents that agents can discover and follow |
| [05](05-quality-and-enforcement.md) | Quality Scoring and Enforcement | Defining quality as measurable dimensions with automated checks and debt tracking |
| [06](06-doc-gardening.md) | Documentation Gardening | Treating docs as a living system with freshness detection and continuous maintenance |
| [07](07-session-handoffs.md) | Session Handoffs for Continuity | Capturing session state so the next agent resumes without loss of context |
| [08](08-building-skills.md) | Building Claude Code Skills | Encoding repeatable workflows as slash-command skills with instructions and reference data |

## Important: This Directory Is Read-Only

The `guide/` directory is **reference material**. Agents must never modify these
files during normal operation. If a guide chapter needs updating, that is a
deliberate editorial decision -- not something that happens as a side effect of
working on the project.

Operational truth lives in `docs/`. Educational content lives here.

---

*This guide is part of the Research_Map agent-first repository template.*
