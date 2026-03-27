---
name: help
description: >
  Explains how the SDM lifecycle works. Use when you want to understand what a
  skill does, what order to run them, how gates work, how to configure the project,
  or how to handle a specific situation. Answers any question about the SDM system.
  Usage: /help
  Also use when: "how does this work", "what do I run next", "explain /spec",
  "what is a CR", "how do I configure gates", "what is the difference between /init and /setup".
argument-hint: (optional: topic or question)
---

# SDM Help

**Role: Guide**

You explain the SDM lifecycle clearly and concisely. Read `CLAUDE.md` first to
understand the project's current configuration (platform, domain, gates), then
answer in context.

If `$ARGUMENTS` is empty: show the full overview below.
If `$ARGUMENTS` contains a question or topic: answer it directly and specifically.

---

## Overview — What is SDM?

SDM (Spec-Driven Method) is a lightweight lifecycle for managing engineering changes —
or any kind of work — with structure, traceability, and just enough process.

Every piece of work goes through a **CR (Change Request)**. A CR has a state that
advances through gates: Intake → Spec → Plan → Build → Review → Close.

Each gate produces an artifact. Each artifact is a Markdown file in `specs/cr/`.
Nothing moves forward without the previous gate completing.

---

## The Skills

### Setup skills (run once per project)

| Skill | When to use |
|-------|-------------|
| `/init` | Brand new project — no code yet. Interviews you, recommends a stack and architecture, writes `CLAUDE.md` + `ARCHITECTURE.md` as a blueprint. |
| `/setup` | Existing project — code already exists. Scans the codebase, asks proportional questions, writes `CLAUDE.md` + `ARCHITECTURE.md` as a snapshot. |

Run one of these before anything else. You only need to re-run when the architecture changes significantly.

---

### Lifecycle skills (run per CR, in order)

```
/intake → /spec → /plan → /build → /review → /close
```

| Skill | Stage | What it does | Input | Output |
|-------|-------|-------------|-------|--------|
| `/intake` | 1 — Triage | Classifies the change, assesses risk, produces a CR item | Anything: description, error log, file, URL | `specs/cr/<cr-id>.cr.md` |
| `/spec` | 2 — Specification | Drafts a spec, reviews it through 3 perspectives, locks it | CR-ID | `specs/cr/<cr-id>.spec.md` |
| `/plan` | 3 — Planning | Translates the spec into a layered build plan with waves | CR-ID | `specs/cr/plans/<cr-id>.plan.md` |
| `/build` | 4 — Implementation | Implements layer by layer following the plan | CR-ID | Code + tests |
| `/review` | 5 — Review | Reviews the build: structure, security, correctness | CR-ID | Review report in CR item |
| `/close` | 6 — Closure | Verifies ACs, captures lessons, feed-forward, closes the CR | CR-ID | `specs/cr/<cr-id>.close.md` |

---

### Shortcut skills

| Skill | When to use |
|-------|-------------|
| `/cr` | Runs the full pipeline (spec → plan → build → review → close) automatically from a CR-ID. Resolves business questions upfront, then runs uninterrupted. Use when you trust Claude to handle the whole pipeline. |
| `/engineer` | Ad-hoc implementation, code review, refactoring, or debugging — outside of a CR. No lifecycle tracking. |

---

## Gates and rigor

Every CR has a **rigor level** set at intake:

| Rigor | What it means |
|-------|--------------|
| `fast` | Lean or no spec. Skips straight to build for fix/refactor. Lean spec for features. |
| `standard` | Default. Full spec for features/security, lean spec for fix/refactor. |
| `full` | Full spec + plan + build + review for everything, regardless of type. |

Set rigor at intake: `/intake --rigor fast fix the login bug`

---

## Configurable gates

Each gate can be turned off project-wide in `CLAUDE.md`:

```
SDM Gates: spec=on, plan=on, review=on, lessons=on
```

Turn off gates you don't need for your project type:

| Example project | Suggested config |
|----------------|-----------------|
| Small script / personal tool | `spec=off, plan=off, review=off, lessons=on` |
| Content / writing project | `plan=off, review=off, lessons=on` |
| Full production software | all `on` (default) |
| Fast iteration / prototype | `spec=on, plan=off, review=on, lessons=off` |

When a gate is `off`, the skill detects it and skips automatically — you don't
need to remember.

---

## Domain

`SDM Domain` in `CLAUDE.md` changes how `/spec` behaves:

| Domain | What /spec produces |
|--------|-------------------|
| `software` | Technical specification with ACs, architecture, security, contract impact |
| `content` | Plan Brief — 8 questions: problem, goal, audience, appetite, ACs, constraints, assumptions, rabbit holes |
| `research` | Plan Brief |
| `strategy` | Plan Brief |
| `general` | Plan Brief |

---

## Feed-forward

Every time a CR closes, `/close` writes to `specs/feed-forward.md`:
- Problems revealed during the CR
- Scope that was deferred
- Assumptions that turned out to be wrong
- Open questions for future CRs

The next `/intake` reads the last 3 entries and surfaces anything relevant.
This keeps learning from one CR flowing into the next automatically.

---

## Files and directories

```
CLAUDE.md                        ← SDM config: platform, domain, gates
ARCHITECTURE.md                  ← Project snapshot (generated by /setup or /init)
specs/
  cr/
    BACKLOG.md                   ← All open CRs in one table
    <cr-id>.cr.md                ← CR item (state, assessment, decisions)
    <cr-id>.spec.md              ← Specification or Plan Brief
    <cr-id>.close.md             ← Closure artifact (preserved in git history)
    plans/
      <cr-id>.plan.md            ← Implementation plan with waves
  lessons-learned.md             ← Accumulated lessons across all CRs
  feed-forward.md                ← Feed-forward items from recent CRs
```

---

## CR states

```
OPEN → SPEC_DRAFT → SPEC_REVIEWED → SPEC_APPROVED
     → PLAN_READY → IMPLEMENTING → REVIEWING → CLOSED
```

Each skill checks the state before running and tells you if something is out of order.

---

## Common questions

**"Where do I start?"**
Run `/init` (new project) or `/setup` (existing project). Then `/intake <describe your first change>`.

**"What if I just want to fix a small bug quickly?"**
`/intake --rigor fast fix the bug in X` — this skips the spec and goes straight to build.

**"Can I skip planning and just build?"**
Yes: set `plan=off` in `SDM Gates`, or use `--rigor fast` on the CR. `/plan` will skip automatically.

**"I have a content/writing project, not code — does this work?"**
Yes. Set `SDM Domain: content` and `SDM Gates: plan=off, review=off`. You'll get a Plan Brief instead of a tech spec, and the lifecycle tracks your writing work the same way.

**"What is a wave?"**
In `/plan` and `/build`, work is broken into units and grouped into waves. Wave 1 = units with no dependencies (can run in parallel). Wave 2 = units that depend on Wave 1. This makes the build order explicit and prevents skipping dependencies.

**"The CR is stuck — how do I check its state?"**
Read `specs/cr/<cr-id>.cr.md` — the state is in the header table. Then run the skill for the current state.

**"How do I run the full pipeline automatically?"**
`/cr <cr-id>` — runs spec → plan → build → review → close uninterrupted. Asks only genuine business questions before starting.

---

## Quick reference card

```
New project:        /init
Existing project:   /setup
New change:         /intake [--rigor fast|standard|full] <description>
Write spec:         /spec <cr-id>
Plan build:         /plan <cr-id>
Build it:           /build <cr-id>
Review build:       /review <cr-id>
Close CR:           /close <cr-id>
Full pipeline:      /cr <cr-id>
Ad-hoc work:        /engineer <task>
This help:          /help [topic]
```
