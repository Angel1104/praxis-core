# Praxis

**A spec-driven development pipeline for AI coding agents.**

Two skills that give any AI coding agent a structured build process: plan the feature first, then implement it wave by wave — with tests after every wave and a written record of every decision.

Works with **Claude Code**, **OpenCode**, and **Antigravity**. Stack agnostic.

```
/plan  I want to add Google login to my app
/build 260315-142300
```

---

## Why

AI agents write code fast and plan poorly. Praxis splits the work the way a real team does:

| Actor | Owns |
|-------|------|
| **You** | Scope, business decisions, review |
| **`/plan`** | Turning intent into a dependency-ordered implementation plan |
| **`/build`** | Executing the plan wave by wave, testing as it goes |

The result is a repeatable pipeline: every feature starts from a written plan, every implementation leaves an auditable trail in `specs/cr/`, and the human keeps ownership of what ships.

---

## Installation

Run the install script from this repo into your project:

```bash
./install.sh /path/to/your/project
```

This copies the skills into all three agent paths at once:

```
.claude/skills/     ← Claude Code
.opencode/skills/   ← OpenCode
.agent/skills/      ← Antigravity
```

Or manually, if you only use one agent:

```bash
cp -r skills/ .claude/skills/      # Claude Code
cp -r skills/ .opencode/skills/    # OpenCode
cp -r skills/ .agent/skills/       # Antigravity
```

Open your agent in the project and the `/plan` and `/build` commands are available immediately.

---

## How it works

Two commands. That's it.

**`/plan`** — understands what you want to build, asks at most 3 questions, then produces a wave-structured implementation plan saved to `specs/cr/<id>.md`. It accepts a plain description or a full architect brief (`/plan briefs/user-stats.md`).

**`/build`** — reads the plan, implements it wave by wave, runs tests after each wave, and updates the plan file with a build log when done.

### Waves

Waves are how `/build` parallelizes work within a feature. The plan groups implementation units by dependency: units with no dependencies go in Wave 1, units that depend on Wave 1 go in Wave 2, and so on.

```
Wave 1: User model, Auth middleware    ← independent, no waiting
Wave 2: Login endpoint                 ← needs Wave 1 done first
Wave 3: Frontend login form            ← needs Wave 2 done first
```

The agent builds as much as possible without blocking on things that aren't ready yet — faster delivery, clearer progress.

### What gets created

Each `/plan` run creates one file:

```
specs/cr/
  260315-142300.md    ← plan + wave structure + build log
  BACKLOG.md          ← running list of all features
```

No extra folders, no separate spec/plan/review files. One file per feature.

---

## Starter repos

Boilerplates with Praxis pre-installed, ready for a first `/plan`:

- [praxis-fastapi](https://github.com/Angel1104/praxis-fastapi) — FastAPI + SQLite backend
- [next-base](https://github.com/Angel1104/next-base) — Next.js + Tailwind frontend

---

## Repository structure

```
praxis-core/
├── install.sh
├── doctrine/
│   ├── directive-execution-principle.md
│   └── implementation-planning-rules.md
└── skills/
    ├── plan/
    │   ├── SKILL.md
    │   └── references/
    ├── build/
    │   ├── SKILL.md
    │   └── references/
    └── help/
        └── SKILL.md
```

---

## Versioning

- `3.0.0` — Current. Two skills only: `/plan` + `/build`. Wave-based execution. Supports Claude Code, OpenCode, and Antigravity.
- `2.1.0` — Full Praxis lifecycle (6 stages) + 5 specialist skills. Stack agnostic.
- `2.0.0` — Stack and architecture agnostic. Removed stack doctrine files.
- `1.0.0` — Initial release. Python/FastAPI only.

---

Built by [Angel Flores](https://whosangelflores.com) · [GitHub](https://github.com/Angel1104)
