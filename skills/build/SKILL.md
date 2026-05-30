---
name: build
description: >
  Implements the plan produced by /plan, wave by wave. Reads the CR file, executes
  each wave in order, runs tests after each wave, and updates the CR file when done.
  Usage: /build <cr-id>
  Also use when: "implement this", "build CR-...", "write the code for ...".
  Do NOT use for: planning, spec writing, or review.
argument-hint: CR-ID
---

# Build

**Role: Senior Engineer**

You implement what the plan says, wave by wave. You do not invent scope beyond the plan.
You make all technical decisions within what the plan defines — you only stop when something
genuinely cannot proceed without a human decision.

---

## Step 1: Load the plan

If `$ARGUMENTS` is empty, ask: "Which CR? (e.g. `260315-142300`)"

Read `specs/cr/<cr-id>.md`. If missing:
> "No plan found for <cr-id>. Run `/plan` first."

Read `CLAUDE.md` if it exists. Scan the files listed in the wave plan to understand
existing code before writing anything.

---

## Step 2: Execute wave by wave

Work through every wave in the plan in order.

**For each wave:**

1. Announce: `Wave N: <unit names>`
2. Implement all units in this wave — they are independent, implement each fully
3. Run tests if the project has a test command (check `CLAUDE.md` or infer from codebase)
4. If tests fail: diagnose and fix before moving to the next wave
5. Announce completion: `Wave N done — <N> units`

**If a unit fails and blocks other units:** skip the dependents, record why, continue
with remaining units in later waves that are not affected.

**If you discover something not in the plan** (a risk, a breaking change, a conflict):

> "Found something not in the plan: [description].
> Options: [A] fix it now, [B] skip and create a follow-up, [C] stop and reassess.
> Which do you prefer?"

Wait for the answer, then continue.

**After the final wave:** run the full test suite if available.

---

## Step 3: Update the CR file

Append a `## Build` section to `specs/cr/<cr-id>.md`:

```markdown
## Build

**Status:** DONE
**Changed files:** <list>
**Tests:** <passing / no tests / N failing — reason>
**Deviations from plan:** <list, or "none">
**Follow-up items:** <list, or "none">
```

Update `BACKLOG.md` — change the status for this CR from `PLAN_READY` to `DONE`.

---

## Step 4: Handoff

Tell the developer:

> **Build done — CR-<cr-id>**
>
> <one sentence: what was built>
>
> Waves completed: <N>/<N>
> Tests: <passing / none / N failing>
>
> [If follow-up items: "Follow-up noted: <brief list>"]
