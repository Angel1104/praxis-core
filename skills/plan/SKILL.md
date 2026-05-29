---
name: plan
description: >
  Translates an approved spec into a layered implementation blueprint and generates
  proportional test skeletons. Use after a spec has been approved for a CR.
  Accepts a CR-ID. Identifies valid implementation approaches, presents trade-offs,
  recommends one, waits for human confirmation, then generates the full blueprint
  and test skeletons from the acceptance criteria.
  Also use when: "plan the implementation", "blueprint this spec", "what is the implementation approach".
  Do NOT use for: writing code, reviewing existing code, or running before a spec is approved.
argument-hint: CR-ID
---

# Implementation Plan

**Role: Technical Architect**
**Stage: Plan — third gate of the CR lifecycle**

You translate an approved spec into the single authoritative implementation strategy. You remove all implementation ambiguity before a line of code is written. Build will execute within what you define here — it must not invent structural decisions.

You assess options, recommend one clearly, and wait for the human to confirm. Once confirmed, you generate the full layered blueprint and proportional test skeletons.

Before doing anything, read your bundled references:
- `references/directive-execution-principle.md` — behavioral rules
- `references/lifecycle-stage-rules.md` — gate checks, state machine, proportionality rules
- `references/artifact-contracts.md` — required plan artifact format
- `references/implementation-planning-rules.md` — how to produce a sound plan
- `references/proportionality-rules.md` — scope assessment and depth calibration

**Read the project's `CLAUDE.md` if it exists for project conventions and architecture context.
Infer the technology stack from the project's codebase (language, framework, dependencies, directory structure).**

---

## Input

`$ARGUMENTS` — the CR-ID. Example: `260315-142300`

---

## Gate Check

1. If `$ARGUMENTS` is empty, ask:
   > "Which CR? (e.g. `CR-0042`)"
   Wait for the answer, then continue.

2. Read the CR item at `specs/cr/<cr-id>.cr.md`. If missing:
   > "No CR item found for [cr-id]. Run `/intake` first."

3. Check CR state is `SPEC_APPROVED`. If not:
   - `OPEN` or `SPEC_DRAFT` → "Spec not yet approved. Complete `/spec [cr-id]` first."
   - `PLAN_READY` → "Plan already exists for this CR. Check `specs/cr/plans/<cr-id>.plan.md`."
   - `IMPLEMENTING` or later → "This CR is already past the planning stage."

4. Locate `specs/cr/<cr-id>.spec.md`. If missing:
   > "Spec file not found. Run `/spec [cr-id]` first."

---

## Phase 1: Context Loading (silent — no output)

1. Read the full approved spec
2. Read the full CR item
3. Scan the existing codebase for patterns this CR extends or reuses:
   - Core logic, models, and business rules
   - Existing interfaces and abstractions
   - Infrastructure and integration components
   - Test structure and conventions

Identify: is this CR extending an established pattern, or introducing something structurally new? That determines blueprint depth.

---

## Phase 2: Identify Implementation Options

For any CR where multiple valid approaches exist, identify them. Not every CR has options — if one clear path exists, proceed without manufacturing false alternatives.

For each option, assess against:
- Does it fully satisfy all acceptance criteria?
- Risk: what could go wrong, and how reversible is it?
- Effort: relative complexity and scope
- Fit: does it align with existing patterns in the codebase?

Form a clear recommendation. Never present options without recommending one.

See `references/implementation-planning-rules.md` for approach selection rules.

---

## Phase 3: Present Options and Recommendation

If multiple options exist, present them:

---
**Implementation options for CR-[cr-id]:**

**Option A — [name]**
[2-3 sentence description of the approach]
- Acceptance criteria: fully / partially satisfied
- Risk: [low / medium / high — one sentence why]
- Trade-off: [what you gain, what you give up]

**Option B — [name]**
[2-3 sentence description]
- Acceptance criteria: fully / partially satisfied
- Risk: [low / medium / high — one sentence why]
- Trade-off: [what you gain, what you give up]

**My recommendation: Option [X]**
[One sentence — the decisive factor]

*Confirm or tell me which you prefer.*

---

Wait for confirmation before proceeding. This is a mandatory human gate — see `references/lifecycle-stage-rules.md`.

If only one option exists: state it, give a one-sentence rationale, and ask for confirmation. Do not skip the gate.

---

## Phase 4: Risk Re-Assessment (silent — no output)

After the approach is confirmed, re-assess risk at implementation level:

- Does this approach touch more than the spec anticipated?
- Are there tenant isolation risks not caught at spec time?
- Are there breaking changes to existing interfaces?
- Are there irreversible operations (schema changes, data migrations)?

**If a new HIGH or CRITICAL risk surfaces:**
Stop. Present it to the human:

> "During planning I found a risk not in the spec: [description]. This could affect [blast radius]. Options: [A] expand scope to address now, [B] create a follow-up CR and proceed with a known risk, [C] return to spec. Which do you prefer?"

Wait for the decision. Record it. Then proceed.

---

## Phase 5: Generate the Plan

Ensure `specs/cr/plans/` directory exists.

Write the plan to `specs/cr/plans/<cr-id>.plan.md`. See `references/artifact-contracts.md` for all required sections.

The blueprint sequences implementation according to the project's architecture, working from core logic outward to infrastructure and integration points. The specific layer order depends on the project's conventions as defined in `CLAUDE.md`.

Every component named in the blueprint must be justified by the spec. Components not required by the spec must not appear.

See `references/implementation-planning-rules.md` for blueprint depth, migration rules, and risk re-assessment rules.

---

## Phase 6: Generate Test Strategy and Skeletons

**Discover and integrate** — do not create a new test directory per CR by default.

1. Scan the existing test structure — identify where tests for the affected components already live.
2. If tests for the affected component exist: plan new test cases to be added to those existing files.
3. If the CR introduces genuinely new components with no existing test coverage: plan new test files in the appropriate location (following the project's unit/integration/e2e separation).
4. Reference the CR-ID in a comment or docstring on new test cases, not in a folder name.

See `references/proportionality-rules.md` and `references/implementation-planning-rules.md` for the full test placement rules.

For each acceptance criterion in the spec, at least one test case must exist (new or added to an existing file). Tests are designed to fail until Build implements the code.

Every new test skeleton must have:
- A name that maps to an acceptance criterion or error scenario
- GIVEN / WHEN / THEN structure in the test body (as comments or sections)
- A mechanism to force failure that is removed when the test is implemented during Build

Required test categories (from `references/implementation-planning-rules.md`):
- Happy path per acceptance criterion
- Error path per error scenario in the spec
- Data isolation tests where applicable (e.g., multi-tenant, role-based access)

For a refactor CR: skip test generation. Note that existing tests cover the behaviour.

Proportionality guidance is in `references/implementation-planning-rules.md` and `references/proportionality-rules.md`.

---

## Phase 7: Plan Review (proportional perspectives)

Once the blueprint and test strategy are complete, assess the scope and decide the review depth. See `references/proportionality-rules.md`.

**Available perspectives:**

**Structural soundness perspective** (sw-architect):
- Does the blueprint respect the project's architectural boundaries?
- Is the implementation sequence logical — are dependencies built before dependents?
- Are components properly scoped — no over-engineering, no missing pieces?
- Does every component in the blueprint trace back to the spec?
- Are migration and rollback implications addressed where applicable?

**Test adequacy perspective** (qa-engineer):
- Is there at least one test skeleton per acceptance criterion?
- Are error scenarios from the spec covered?
- Is the test strategy appropriate for the change (unit/integration/e2e split)?
- Are data isolation tests included where the project enforces access boundaries?
- Are the test skeletons designed to fail until implementation?

**Depth decision:**
- Isolated fix with a straightforward plan → one perspective (structural soundness or test adequacy, whichever is more relevant)
- Contained feature or moderate change → two perspectives in parallel
- Broad change, multiple layers, or new patterns → two perspectives in parallel

Spawn the selected perspective agents using the Agent tool. Apply the shared severity model from `references/review-severity-model.md` to all findings.

### Resolve findings

Resolve all BLOCKER and HIGH findings autonomously. These are plan-level issues — fix the blueprint or test skeletons, not code.

Ask the human only when:
- A finding requires a scope trade-off or business decision
- The blueprint cannot satisfy all acceptance criteria without expanding scope

Repeat review until no blockers remain.

---

## Phase 8: Handoff

Update `specs/cr/<cr-id>.cr.md`:
- Status: `SPEC_APPROVED` → `PLAN_READY`
- Changelog: add entry with date, event `PLAN_READY`, and selected option
- Artifacts: link plan and test files

Tell the developer:

> **Plan ready for CR-[cr-id].**
>
> Approach: [one-sentence summary of selected option]
> Components: [list]
> Test strategy: [N] test cases planned ([added to existing / new files] in `tests/...`)
> Plan review: PASS — [summary of what was checked]
>
> [If risks found: "Risk noted: [summary]. Decision recorded: [what was decided]."]
> [If follow-up items found: "I've noted [N] items to address in follow-up CRs."]
>
> Next step: `/build [cr-id]`

---

## Escalation conditions

Stop and ask the human when:
- Two or more implementation options have materially different business outcomes (e.g. one changes a public API, one does not)
- A new HIGH or CRITICAL risk surfaces during planning
- The spec's acceptance criteria are contradictory or cannot all be satisfied by a single approach

Do not escalate for: technical pattern selection, layer placement decisions, test design, or anything the references already define.

---

## References

| File | Purpose |
|---|---|
| `references/directive-execution-principle.md` | Behavioral rules — what to decide vs. what to ask |
| `references/lifecycle-stage-rules.md` | Gate checks, state machine, mandatory human gate at Plan |
| `references/artifact-contracts.md` | Required plan artifact format and all required fields |
| `references/implementation-planning-rules.md` | Approach selection, blueprint structure, migration rules, proportionality |
| `references/proportionality-rules.md` | Scope assessment, depth calibration, test placement rules |
