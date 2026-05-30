# Praxis Hackathon Skill Pack

Two skills that give any AI coding agent a structured build process — plan your feature, implement it wave by wave.

Works with **Claude Code** and **OpenCode** (same SKILL.md format). Stack agnostic.

---

## Installation

Copy the `skills/` folder into your project:

```bash
cp -r skills/ .claude/skills/
```

That's it. Open Claude Code or OpenCode in your project and the `/plan` and `/build` commands are available immediately.

---

## How it works

Two commands. That's it.

```
/plan  I want to add Google login to my app
/build 260315-142300
```

**`/plan`** — understands what you want to build, asks at most 3 questions, then produces a wave-structured implementation plan saved to `specs/cr/<id>.md`.

**`/build`** — reads the plan, implements it wave by wave, runs tests after each wave, updates the plan file when done.

---

## What are waves?

Waves are how `/build` parallelizes work within a feature.

The plan groups implementation units by dependency. Units with no dependencies go in Wave 1 and are implemented independently. Units that depend on Wave 1 go in Wave 2, and so on.

```
Wave 1: User model, Auth middleware    ← independent, no waiting
Wave 2: Login endpoint                 ← needs Wave 1 done first
Wave 3: Frontend login form            ← needs Wave 2 done first
```

This means the AI builds as much as possible without blocking on things that aren't ready yet — faster delivery, clearer progress.

---

## What gets created

Each `/plan` run creates one file:

```
specs/cr/
  260315-142300.md    ← plan + wave structure + build log
  BACKLOG.md          ← running list of all features
```

No extra folders, no separate spec/plan/review files. One file per feature.

---

## Structure

```
praxis-hackathon/
├── doctrine/
│   ├── directive-execution-principle.md
│   └── implementation-planning-rules.md
└── skills/
    ├── plan/
    │   ├── SKILL.md
    │   └── references/
    └── build/
        ├── SKILL.md
        └── references/
```

---

## Versioning

`3.0.0` — Hackathon edition. Two skills only: `/plan` + `/build`. Wave-based execution. Minimal overhead.

`2.1.0` — Full Praxis lifecycle (6 stages) + 5 specialist skills. Stack agnostic.

`2.0.0` — Stack and architecture agnostic. Removed stack doctrine files.

`1.0.0` — Initial release. Python/FastAPI only.
