---
name: review
description: >
  Post-build review gate. Validates the completed implementation before closure.
  Use after implementation-build has completed. Accepts a CR-ID. Runs proportional
  review perspectives (structural integrity, security exposure, operational impact —
  number scales with change scope), consolidates findings, and produces a PASS or BLOCKED verdict.
  Resolves BLOCKER findings autonomously where possible. A BLOCKED verdict prevents
  closure until all blockers are resolved.
  Also use when: "review the implementation", "run the code review", "check the build".
  Do NOT use for: spec review, planning review, or ad-hoc code audits unrelated to a CR.
argument-hint: CR-ID
---

# Engineering Review

**Role: Software Architect + Security Engineer + Implementation Specialist (in parallel)**
**Stage: Review — fifth gate of the CR lifecycle**

You run the formal post-build review. This is not embedded in Build — it is a distinct stage with its own gate and verdict. Your job is to validate the completed implementation against the plan, spec, and project doctrine before the CR can close.

Review is never skipped, but the number of perspectives scales with the scope of the change. See `references/proportionality-rules.md`.

Before doing anything, read your bundled references:
- `references/directive-execution-principle.md` — behavioral rules
- `references/lifecycle-stage-rules.md` — gate checks, review perspective rules, state machine
- `references/artifact-contracts.md` — review report format
- `references/review-severity-model.md` — severity levels and gate effects
- `references/finding-classification-rules.md` — how to classify and structure findings
- `references/evidence-and-citation-rules.md` — required evidence format

---

## Gate Check

1. If `$ARGUMENTS` is empty, ask:
   > "Which CR? (e.g. `CR-0042`)"
   Wait for the answer, then continue.

2. Extract the CR-ID from `$ARGUMENTS`
3. Locate `specs/cr/<cr-id>.cr.md`. If missing:
   > "No CR item found."
4. Check CR state is `IMPLEMENTING`. If not:
   - Earlier state → "Build not complete. Run `/build [cr-id]` first."
   - `REVIEWING` → "Review already in progress or complete. Check the CR item."
   - `CLOSED` → "This CR is already closed."
5. Locate `specs/cr/<cr-id>.spec.md` — required for review context on Standard and Fast tracks. On Incident track (Critical severity), the compressed problem scope in the CR item serves as the spec; a standalone spec file is not required.
6. Locate `specs/cr/plans/<cr-id>.plan.md` — required for review context on Standard and Fast tracks. On Incident track (Critical severity), no standalone plan file is required.

---

## Phase 1: Context Loading (silent)

1. Read the full CR item, spec, and plan
2. Identify all files changed during Build (from build summary in CR item)
3. Read the changed implementation files
4. Read the relevant test files (identified from the plan's test strategy and build summary)

---

## Phase 2: Proportional Review

Assess the scope of the change before deciding the review depth. See `references/proportionality-rules.md`.

**Available perspectives:**

**Perspective 1 — Structural Integrity** (sw-architect agent):
- Are architectural boundaries respected in the implemented code?
- Is dependency direction correct per the project's architecture?
- Are external interactions properly abstracted?
- Does the implementation conform to the approved plan structure?
- Are the project's required design patterns applied where needed?

**Perspective 2 — Security Exposure** (security-engineer agent):
- Are data access boundaries enforced where applicable?
- Are write operations authenticated?
- Is all external input validated at the boundary?
- Are there injection risks in the implemented code?
- Are secrets handled correctly?
- Are auth failure scenarios handled per the spec?

**Perspective 3 — Operational Impact** (engineer or qa-engineer agent, depending on CR type):
- Is the change deployable without manual intervention?
- Are schema migrations safe and reversible?
- Are failure modes observable (adequate logging)?
- Is rollback feasible if deployment fails?
- Do the tests cover the acceptance criteria and error scenarios?
- Is error handling proportionate and correct (domain exceptions, no stack traces exposed)?

**Depth decision:**
- Isolated fix, single function or file, no security or boundary implications → one focused perspective covering the most relevant concern
- Change touching security, auth, tenant isolation, or data access → security perspective is mandatory; add others based on what the change touches
- Cross-cutting change, new patterns, multiple layers → three perspectives in parallel

Spawn the selected perspective agents using the Agent tool.

Apply the shared severity model from `references/review-severity-model.md` to all findings.
Use `references/finding-classification-rules.md` to assign finding class.
Use `references/evidence-and-citation-rules.md` for evidence format on all BLOCKERs.

---

## Phase 3: Consolidate Findings

Merge findings from all three perspectives. Remove exact duplicates. For overlapping findings that cover the same location from different perspectives, retain the highest severity and note both perspectives in the rationale.

Group by severity: CRITICAL → HIGH → MEDIUM → LOW.

Determine verdict:
- `PASS` — no CRITICAL or HIGH findings remain
- `BLOCKED` — one or more CRITICAL or HIGH findings remain

---

## Phase 4: Resolve BLOCKERs

Resolve all BLOCKER findings (CRITICAL and HIGH) autonomously where the fix is technical and within the approved plan scope.

For any BLOCKER that requires a business or scope decision:
> "Review found a blocker I cannot resolve without input: [finding]. Options: [A / B]. Which do you prefer?"

After fixes, re-run the affected tests.

Repeat Phase 2 → Phase 4 on changed files until no BLOCKERs remain.

---

## Phase 5: Produce Review Report

Write the review report as a `## Review Report` section appended to `specs/cr/<cr-id>.cr.md`.

See `references/artifact-contracts.md` for the required review report format: verdict, blocker findings, non-blocking findings, advisories.

Update CR state: `IMPLEMENTING` → `REVIEWING`

---

## Phase 6: Handoff

**If verdict is PASS:**

> **Review passed for CR-[cr-id].**
>
> [Summary: what was reviewed, finding counts by severity, any advisories to carry forward]
>
> Next step: `/close [cr-id]`

**If verdict was BLOCKED and is now resolved:**

> **Review passed after fixes for CR-[cr-id].**
>
> Blockers resolved: [N]. Fixes applied: [brief list].
>
> Next step: `/close [cr-id]`

**If a BLOCKER required human input and is now awaiting decision:**

> **Review blocked on CR-[cr-id].**
>
> [Specific BLOCKER finding with remediation options]

---

## Escalation conditions

Stop and ask the human when:
- A BLOCKER finding cannot be resolved within the current plan scope
- A security CRITICAL finding requires a business decision (e.g. "should we defer this endpoint to a follow-up CR?")
- The implementation diverges so significantly from the plan that re-planning is warranted

---

## References

| File | Purpose |
|---|---|
| `references/directive-execution-principle.md` | Behavioral rules |
| `references/lifecycle-stage-rules.md` | Gate checks, review perspective rules, state machine |
| `references/artifact-contracts.md` | Review report format and required fields |
| `references/review-severity-model.md` | Severity levels, gate effects, finding structure |
| `references/finding-classification-rules.md` | Finding class definitions and assignment |
| `references/evidence-and-citation-rules.md` | Evidence format for every BLOCKER finding |
| `references/proportionality-rules.md` | Scope assessment and review depth calibration |
