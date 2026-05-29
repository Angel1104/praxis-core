# Proportionality Rules

## The principle

Every skill is an intelligent agent. Before producing output, assess the actual scope of the change — read the CR, read the codebase, judge what the work genuinely requires. Scale your output to the work, not to a template.

A one-line bug fix in an existing, well-tested function does not need the same depth as a new subsystem. Both pass through all six stages. Both respect every non-negotiable. But their depth is different — because the work is different.

---

## How to assess scope

At the start of your stage, before producing anything, answer:

1. **What is actually changing?** — count of files, functions, layers touched
2. **Is this extending an established pattern or introducing something new?** — new patterns require more scrutiny
3. **What is the blast radius?** — a change isolated to one function vs. a change that crosses architectural boundaries
4. **What existing coverage exists?** — are there already tests, specs, or documentation for the affected area?

These answers determine your depth. You do not need a field in the CR item to tell you this — you can read the codebase and judge.

---

## Depth guidance by stage

### Intake

Intake already scales conversation depth by input clarity. No change needed — continue using judgement.

### Spec

| Scope | Depth |
|---|---|
| Isolated fix in existing code, clear intent | Minimal sections (one sentence each where appropriate). Single-perspective review focused on the most relevant concern. |
| New endpoint or feature on existing patterns | Core sections populated. Two-perspective review (domain + architecture or domain + security, whichever is more relevant). |
| New subsystem, new domain concept, cross-cutting change | All sections fully populated. Three-perspective review (domain-analyst + sw-architect + security-engineer). |

The spec proportionality table in `spec-quality-rules.md` still applies — this extends it to the review process.

### Plan

| Scope | Depth |
|---|---|
| Isolated fix, single function or file | Short plan (one page or less). No new test files if existing tests cover the affected component — add test cases to existing files instead. One-perspective review if the change is straightforward. |
| Contained feature, few components | Standard plan. New test files only for genuinely new components. Two-perspective review. |
| Broad change, multiple layers or new patterns | Full blueprint with layered sequence. New test structure where needed. Two-perspective review (sw-architect + qa-engineer). |

### Build

Build depth is bounded by the plan. A short plan produces a short build. No additional proportionality assessment needed — follow the plan.

### Review

| Scope | Depth |
|---|---|
| Isolated fix, single function or file, no security or boundary implications | One focused perspective covering the most relevant concern (usually structural integrity or operational impact). |
| Change touching security, auth, tenant isolation, or data access | At minimum: security perspective is mandatory. Add structural and/or operational perspectives based on what the change touches. |
| Cross-cutting change, new patterns, multiple layers | Three perspectives in parallel (structural integrity + security exposure + operational impact). |

### Close

Close always verifies acceptance criteria and runs lessons-learned. Depth scales naturally: a trivial fix has fewer ACs to verify and is less likely to produce genuine lessons.

---

## Test placement — discover and integrate

Do not create a new test directory or file per CR by default. Instead:

1. **Scan the existing test structure** — identify where tests for the affected components already live.
2. **Add to existing files** when test coverage for the component exists — new test cases go alongside related tests.
3. **Create new test files** only when the CR introduces genuinely new components with no existing test coverage.
4. **Follow the project's test organisation** — respect the existing unit/integration/e2e separation.
5. **Reference the CR-ID** in a comment or docstring on the new test cases, not in a folder name.

A human developer would check what tests exist before creating new files. The AI should do the same.

---

## What proportionality does NOT change

These are non-negotiable regardless of scope:

- **All six stages run.** No stage is skipped.
- **Human gates remain mandatory.** Intake confirmation, plan confirmation, close confirmation.
- **Security CRITICAL findings always block.** No exception.
- **Architectural boundary violations always block.** No exception.
- **Predecessor enforcement.** Each stage verifies its prerequisite.
- **Acceptance criteria must be testable.** Every AC needs a test, even if that test is added to an existing file.
- **Data isolation tests are mandatory** where the project enforces access boundaries.

Proportionality scales depth, not rigour. A one-line fix still gets reviewed — it just doesn't need three parallel agents to do it.
