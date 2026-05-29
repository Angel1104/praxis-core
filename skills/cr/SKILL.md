---
name: cr
description: >
  Fully automated CR pipeline — runs all remaining stages uninterrupted after resolving any
  business decisions upfront. Use after /intake has produced a CR item. Accepts a CR-ID.
  Clarifies all open business questions before starting, then runs spec → plan → build → review → close
  without stopping. Informs on technical decisions; never asks about them. Resumes mid-pipeline CRs
  from the correct stage. Also use when: "run the full pipeline", "automate this CR", "let Claude handle it".
argument-hint: <cr-id>
user-invocable: true
---

# CR — Automated Pipeline

**Role: Technical Lead**

You are responsible for running the full CR pipeline automatically. You own all technical decisions — you never ask the human to make a technical choice. You inform the human of technical decisions taken and why. You stop only when a genuine business decision is needed — one that requires context only the human can have.

---

## Gate Check

1. If `$ARGUMENTS` is empty:
   > "Which CR should I run? Provide a CR-ID (e.g. `CR-0001`)."
   Wait for the answer, then continue.

2. Locate `specs/cr/<cr-id>.cr.md`. If missing:
   > "No CR item found for <cr-id>. Run `/intake` first."
   Stop.

3. Read the CR item fully — intent, type, severity, acceptance criteria, assessment, changelog.

4. Determine resume stage from CR state:

| CR State | Resume at |
|---|---|
| `OPEN` | spec |
| `SPEC_DRAFT` or `SPEC_REVIEWED` | spec (continue from current sub-state) |
| `SPEC_APPROVED` | plan (Standard/Fast track) or build (Incident track) |
| `PLAN_READY` | build |
| `IMPLEMENTING` | review |
| `REVIEWING` | close |
| `CLOSED` | nothing — report CR is already closed |

5. Report:
   > "CR-<cr-id> loaded. Resuming at: <stage>. Running pipeline to close."

---

## Phase 1: Business Clarification

Before starting the pipeline, identify every open business question across all remaining stages.

A business question is one where the answer requires context only the human can have:
- Business rules not inferable from the codebase or CR description
- Regulatory or compliance constraints
- Stakeholder priorities or deadlines
- Scope trade-offs with business impact (e.g. "defer X to keep the deadline?")

Technical questions are NOT business questions. If the answer can be determined from the codebase, the spec, the stack doctrine, or sound engineering judgement — Claude answers it.

**Clarification loop:**

1. Scan the CR item and the remaining stages for open business questions.
2. If none → skip to Phase 2 immediately.
3. If any → ask them all in one message. Be specific. For each question state why it blocks the pipeline.
4. Read the human's answers.
5. If any answer is incomplete or introduces new ambiguity → ask the follow-up questions only. Repeat until all business questions are resolved.
6. Confirm resolution:
   > "All business decisions are clear. Starting the pipeline now."

---

## Phase 2: Pipeline Execution

Execute each remaining stage in sequence by reading and following the stage skill's instructions exactly as if it had been invoked directly.

**Stage instructions are located at:**
- Spec: `sdm-skill-pack/skills/spec/SKILL.md`
- Plan: `sdm-skill-pack/skills/plan/SKILL.md`
- Build: `sdm-skill-pack/skills/build/SKILL.md`
- Review: `sdm-skill-pack/skills/review/SKILL.md`
- Close: `sdm-skill-pack/skills/close/SKILL.md`

For each stage:
1. Read the stage SKILL.md.
2. Execute its instructions in full for CR-<cr-id>.
3. When the stage completes, report:
   > "Stage <name> complete. Continuing to <next stage>."
4. Proceed to the next stage without stopping.

**Close stage override:** When executing the close stage, skip the human confirmation gate at Phase 4. The human authorized full automation by invoking `/cr`. Present the closure summary as an informational report, then proceed directly to Phase 5 without waiting for a reply. The only exception: if one or more acceptance criteria are unmet, stop and surface the gap — do not auto-close with failing ACs.

**Technical decisions encountered during execution:**
- Make the decision using codebase knowledge, stack doctrine, and engineering judgement.
- State the decision and reasoning inline:
  > "Two approaches considered: [A] and [B]. Taking [B] because [reason]. Proceeding."
- Never stop to ask.

**The only stop condition during pipeline execution:**
A question arises that was not resolved in Phase 1 and genuinely requires business context the human must provide. State the question and wait. On answer, continue immediately.

---

## Pipeline Complete

When all stages are done:

> **CR-<cr-id> is closed.**
> [One sentence: what was delivered]
> [Acceptance criteria: N/N met]
> [Technical decisions made: key choices with reasoning]
> [Follow-up CRs if created: list with CR-IDs]
