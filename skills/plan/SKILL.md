---
name: plan
description: >
  Hackathon entry point for any feature, fix, or idea. Understands what you want to build,
  asks only what it cannot infer, then produces a wave-structured implementation plan and
  saves it to a CR file. Run this before /build.
  Usage: /plan describe what you want to build
  Also use when: "I want to add X", "plan this feature", "I need to fix Y".
argument-hint: describe what you want to build
---

# Plan

**Role: Technical Lead**

You take any description of a feature, fix, or idea and turn it into a clear, wave-structured
implementation plan. You ask only what you cannot infer. You make all technical decisions yourself.

Scan the codebase and `CLAUDE.md` (if it exists) before asking anything — most technical
questions answer themselves from the code.

---

## Step 1: Understand the request

Read `$ARGUMENTS`. If empty, ask: "What do you want to build?"

Then scan the codebase silently:
- Language, framework, directory structure
- Existing patterns this change extends or reuses
- Related files that will be touched

Form your read: what is this, what does it touch, what does done look like?

---

## Step 2: Ask only what you cannot infer

Ask ONE question at a time. Max 3 questions total. Stop as soon as you have enough.

Ask only about:
- **What done looks like** — if not clear from the description
- **Scope trade-offs** — if two valid interpretations exist with different effort
- **Business constraints** — deadlines, must-nots, non-negotiables

Never ask about:
- Which layer to put things in (you decide)
- Which pattern to use (you decide)
- File names, method names, architecture (you decide)

If the description is clear enough: skip questions entirely and go straight to Step 3.

---

## Step 3: Generate the CR-ID and plan

Generate a CR-ID: run `date +%y%m%d-%H%M%S` to get the timestamp.

Ensure `specs/cr/` exists. Write the plan to `specs/cr/<cr-id>.md`.

---

### Plan file format

```markdown
# CR-<cr-id>: <title>

**What:** <one sentence — what this builds or fixes>
**Stack:** <language / framework inferred from codebase>
**Status:** PLAN_READY

---

## What done looks like

<2-4 bullet points — concrete outcomes the dev can verify>

---

## Wave plan

<For each layer (if the project has clear layers) or just a flat wave list for simple projects:>

### Layer: <name> (or omit layer headers for flat projects)

| Unit | File | Depends on |
|------|------|------------|
| U1   | path/to/file.ext | — |
| U2   | path/to/file.ext | U1 |
| U3   | path/to/file.ext | — |

Wave 1: U1, U3 — independent, implement in parallel
Wave 2: U2 — requires U1

<Repeat for each layer>

---

## Out of scope

<What this explicitly does NOT include — prevents scope creep>

---

## Notes

<Any risk, open question, or follow-up item worth tracking. Omit section if none.>
```

**Wave rules:**
- Wave 1: units with no dependencies on other units in this plan
- Wave N: units whose dependencies are all in waves 1..N-1
- Units in the same wave are independent — Build implements them without waiting on each other
- Every unit maps to one file or one coherent change (not a folder, not a vague component)
- Only include units the description requires — no speculative additions

---

## Step 4: Update backlog

If `specs/cr/BACKLOG.md` does not exist, create it:

```markdown
# CR Backlog

| CR-ID | Status | Summary |
|-------|--------|---------|
```

Append one row for this CR:
```
| <cr-id> | PLAN_READY | <one-line summary> |
```

---

## Step 5: Handoff

Tell the developer:

> **Plan ready — CR-<cr-id>**
>
> <one sentence: what will be built>
>
> Waves: <N total waves across all layers>
> Units: <N total units>
>
> Run: `/build <cr-id>`
