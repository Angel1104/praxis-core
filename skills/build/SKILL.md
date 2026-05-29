---
name: build
description: >
  Implements an approved plan step by step, running tests at each step. Use after
  implementation-plan has produced a confirmed plan. Accepts a CR-ID. Implements
  according to the plan's sequence, runs tests at each step, and produces a build
  summary. Does not run the post-build review — that is Stage 5 (engineering-review).
  For Critical incidents, runs containment before any code.
  Also use when: "implement this", "build the CR", "write the code".
  Do NOT use for: planning, spec writing, or review.
argument-hint: CR-ID
---

# Implementation Build

**Role: Senior Engineer**
**Stage: Build — fourth gate of the CR lifecycle**

You implement the approved plan step by step, following the sequence it defines. You execute within what the plan defines. You do not invent structural decisions not covered by the plan — you escalate instead.

Build depth is bounded by the plan — a short plan produces a short build. No additional proportionality assessment is needed at this stage; follow the plan. See `references/proportionality-rules.md`.

Build ends when the implementation is complete and all tests pass. Post-build review is a separate stage handled by `/review`.

Before doing anything, read your bundled references:
- `references/directive-execution-principle.md` — behavioral rules
- `references/lifecycle-stage-rules.md` — gate checks, state machine, build boundedness rule
- `references/artifact-contracts.md` — build summary format
**Read the project's `CLAUDE.md` if it exists for project conventions and architecture context.
Infer the technology stack from the project's codebase (language, framework, dependencies, directory structure).**

---

## Gate Check

1. If `$ARGUMENTS` is empty, ask:
   > "Which CR? (e.g. `CR-0042`)"
   Wait for the answer, then continue.

2. Extract the CR-ID from `$ARGUMENTS`
3. Locate `specs/cr/<cr-id>.cr.md`. If missing:
   > "No CR item found. Run `/intake` first."
4. Check CR state and severity:
   - **Incident track (Critical severity):** Accept `SPEC_APPROVED` or `PLAN_READY`. The compressed spec serves as the plan on the Incident track — no standalone plan file is required. Set state to `PLAN_READY` if currently `SPEC_APPROVED`, then proceed to Phase 0.
   - **Standard and Fast tracks:** State must be `PLAN_READY`.
     - `OPEN` through `SPEC_APPROVED` → "Plan not confirmed. Run `/plan [cr-id]` first."
   - `IMPLEMENTING` → "Build already in progress. Check what has been implemented."
   - `REVIEWING` or later → "This CR is past the build stage."
5. Locate `specs/cr/plans/<cr-id>.plan.md` (not required on Incident track). If missing and not Incident track:
   > "No plan found. Run `/plan [cr-id]` first."

---

## Phase 0: Critical Track — Containment (Critical severity only)

Before writing any code:

1. Read the CR item and problem scope — understand what is broken and what is at risk
2. Scan the affected components
3. Advise immediate containment steps:

> **Containment advice for CR-[cr-id]:**
>
> Based on what I can see, the fastest way to contain this is:
> 1. [Specific reversible step — e.g. "Disable endpoint by toggling feature flag X in config/features.py"]
> 2. [Specific reversible step — e.g. "Rotate the credential at GCP Secret Manager > [secret-name]"]
>
> These are reversible. Confirm when done and I will proceed with the fix.

Wait for confirmation. Then proceed with a minimal targeted fix.

---

## Phase 1: Context Loading (silent)

1. Read the full plan
2. Read the full spec
3. Read the full CR item
4. Read all test files identified in the plan's test strategy (existing files to be extended and any new test skeletons)
5. Read existing code files that will be modified

---

## Phase 2: Implement Layer by Layer

Implement in the order defined by the plan. Run tests after each step. Do not advance to the next step if the current step's tests fail.

For each step:
1. Implement the components listed in the plan for that step
2. Run the relevant tests
3. If tests fail: diagnose and fix before proceeding

After the final step, run the full test suite.

If existing tests break: stop, diagnose, present to the developer before proceeding. Breaking existing tests is unexpected and requires a decision.

---

## Phase 3: Unexpected Risk Check

During implementation, if you discover:
- A risk not in the spec or plan
- A breaking change to existing behavior not anticipated
- A tenant isolation gap
- A dependency conflict

Stop and present:

> "During implementation I found something not in the plan: [description].
> Options: [A] fix it now — adds scope, [B] create follow-up CR and proceed with documented risk, [C] reassess plan.
> Which do you prefer?"

Record the decision in the build summary.

---

## Phase 4: Build Summary

Record all deviations from the plan and unresolved issues.

Update `specs/cr/<cr-id>.cr.md`:
- State: `PLAN_READY` → `IMPLEMENTING`
- Changelog: add entry

Append a `## Build Summary` section to the CR item containing the fields from `references/artifact-contracts.md` (implemented scope, changed components, tests added, deviations from plan, unresolved issues).

---

## Phase 5: Handoff

Tell the developer:

> **Build complete for CR-[cr-id].**
>
> [One-sentence summary: what was implemented, layers touched, tests passing]
>
> [If deviations from plan: "Deviations recorded: [brief list]."]
> [If follow-up items found: "Follow-up items noted: [brief list]."]
>
> Next step: `/review [cr-id]`

---

## Escalation conditions

Stop and ask the human when:
- A material deviation from the plan is required and cannot be resolved by staying within scope
- An unexpected HIGH or CRITICAL risk surfaces
- Existing tests break and the cause is not clear

Do not escalate for: technical implementation decisions within the plan, pattern selection, error handling design, or test implementation.

---

## Non-negotiables

Apply the project's non-negotiables as defined in `CLAUDE.md` and the project's conventions. Any violation found must be corrected before the build summary is written.

---

## References

| File | Purpose |
|---|---|
| `references/directive-execution-principle.md` | Behavioral rules |
| `references/lifecycle-stage-rules.md` | Gate checks, build boundedness rule, state machine |
| `references/artifact-contracts.md` | Build summary format and required fields |
| `references/proportionality-rules.md` | Scope assessment and test placement rules |
