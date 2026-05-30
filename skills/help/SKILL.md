---
name: help
description: >
  Explains how Praxis works, what skills are available, and how to use them.
  Usage: /help
  Also use when: "how does this work", "what commands do I have", "what is Praxis",
  "how do I start", "what is a wave", "what is a CR".
argument-hint: (optional: topic or question)
---

# Praxis Help

Show the guide below. If `$ARGUMENTS` contains a specific question or topic, answer it
directly and concisely instead of showing the full guide.

---

## What is Praxis?

Praxis is a two-command system that helps you build features faster and with less chaos.
Instead of jumping straight into code, you plan first — then build wave by wave.

Works with **Claude Code**, **OpenCode**, and **Antigravity**.

---

## The two commands

### `/plan  describe what you want to build`

Tell Praxis what you want. It scans your codebase, asks at most 3 questions, then
produces a wave-structured implementation plan saved to a file.

```
/plan  I want to add Google login
/plan  Fix the bug where users can see each other's data
/plan  briefs/google-login.md
```

You can pass a plain description, a path to a brief `.md` file, or a path to an `.html`
file exported from a design tool like Stitch.

```
/plan  I want to add Google login
/plan  briefs/google-login.md
/plan  convert stitch/chat-screen.html to a Next.js component
```

For Stitch screens: export the HTML from Stitch, save it in `stitch/`, then pass the path
with a description of what you want. `/plan` will read the HTML, understand the UI, and
produce a wave plan to convert it into a proper TSX component wired to your project.

What it creates: `specs/cr/<id>.md` — your plan file with waves, units, and scope.

---

### `/build  <cr-id>`

Takes the plan file and implements it wave by wave. Runs tests after each wave.
Updates the plan file when done.

```
/build 260315-142300
```

The CR-ID comes from the `/plan` output — it's the timestamp ID printed at the end.

---

## What are waves?

A wave is a group of implementation units that can be built independently — no unit in
a wave depends on another unit in the same wave.

```
Wave 1: User model, Auth middleware    ← built independently, no waiting
Wave 2: Login endpoint                 ← needs Wave 1 first
Wave 3: Frontend form                  ← needs Wave 2 first
```

`/build` works through waves in order. Within each wave it implements all units before
moving to the next. If a unit fails, it skips units that depend on it and continues
with the rest.

---

## What gets created

```
specs/cr/
  260315-142300.md    ← one file per feature (plan + build log)
  BACKLOG.md          ← running list of all features and their status
```

---

## Typical flow

```
/plan  I want to add file uploads, max 5MB, images only
       → asks 1-2 questions if needed
       → creates specs/cr/260315-142300.md
       → prints: "Run: /build 260315-142300"

/build 260315-142300
       → Wave 1: storage service, validator
       → Wave 2: upload endpoint
       → Wave 3: frontend component
       → updates the plan file with build results
```

---

## Tips

- If `/plan` produces a plan that's off, edit `specs/cr/<id>.md` directly before running `/build`.
- If `/build` hits something unexpected mid-wave, it asks you what to do — pick A, B, or C and it continues.
- Check `specs/cr/BACKLOG.md` to see all features and their status at a glance.
- Praxis reads your codebase automatically — no setup or config needed.
- Works the same regardless of which AI agent you use: Claude Code, OpenCode, or Antigravity.
