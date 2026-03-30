# Praxis Core

**Praxis** — a lightweight lifecycle for managing engineering changes with structure, traceability, and just enough process.

Works for any language, framework, or project type. No stack assumptions.

---

## What it does

Every piece of work becomes a **CR (Change Request)** that moves through gates:

```
/triage → /spec → /plan → /build → /audit → /ship
```

Each gate produces an artifact. Each artifact is a Markdown file in `specs/cr/`. Nothing moves forward without the previous gate completing. The whole pipeline can run automatically with `/flow`.

---

## Install

```bash
./install.sh /path/to/your/project
```

Then open Claude Code in your project and run:

```
/init    — new project with no code yet
/setup   — existing project (auto-detects your stack)
```

That's it. Praxis is ready.

---

## The skills

| Skill | What it does |
|-------|-------------|
| `/init` | New project — interviews you, recommends a stack, writes `CLAUDE.md` + `ARCHITECTURE.md` as a blueprint |
| `/setup` | Existing project — scans codebase, asks proportional questions, writes `CLAUDE.md` + `ARCHITECTURE.md` |
| `/triage` | Triage — classifies any change, assesses risk, creates a CR item |
| `/spec` | Specification — drafts, reviews (3 perspectives), and approves a spec |
| `/plan` | Planning — translates spec into a layered blueprint with wave execution order |
| `/build` | Implementation — builds layer by layer, runs tests at each wave |
| `/audit` | Review — 3-perspective post-build review, resolves blockers autonomously |
| `/ship` | Closure — verifies ACs, captures lessons, writes feed-forward, closes CR |
| `/flow` | Full pipeline — runs spec → plan → build → audit → ship uninterrupted |
| `/craft` | Ad-hoc — implement, review, refactor, or debug outside the CR lifecycle |
| `/help` | Explains how the system works |

---

## Configuration (`CLAUDE.md`)

`/setup` and `/init` write this automatically. You can edit it manually.

```
# Software projects (written by /setup and /init automatically):
Praxis Platform:     python-fastapi      # e.g. python-fastapi, typescript-nestjs, go-gin
Praxis Domain:       software            # software | content | research | strategy | general
Praxis Gates:        spec=on, plan=on, review=on, lessons=on
Praxis TestCommand:  pytest tests/ -v    # exact command — used verbatim by /build and /craft
Praxis TestRunner:   pytest              # runner name — used by /plan for skeleton generation
Praxis Language:     python              # language — used for idioms, grep patterns, code style
Praxis SourceRoot:   src/               # main source directory — scopes all file searches
Praxis FileExt:      *.py               # file extension — used in grep commands
Praxis IsolationKey: tenant_uid         # data isolation field, or "none"

# Non-software projects (content, research, strategy, general):
Praxis Domain:       content
Praxis Gates:        spec=on, plan=on, review=on, lessons=on
```

**Domains:** `software` gets a full technical spec. `content`, `research`, `strategy`, `general` get a Plan Brief — 8 focused questions instead of a tech spec. Non-software projects omit all stack-specific fields.

**Gates:** turn off what you don't need. A personal script can run `spec=off, plan=off, review=off`. A production service keeps everything on.

---

## CR lifecycle

```
OPEN → SPEC_DRAFT → SPEC_REVIEWED → SPEC_APPROVED
     → PLAN_READY → IMPLEMENTING → REVIEWING → CLOSED
```

Each skill checks state before running and tells you if something is out of order.

**CR-IDs** are incremental: `CR-0001`, `CR-0042`. Generated automatically by `/triage`.

---

## Rigor levels

`/triage` classifies automatically — you rarely need to set this manually.

| Flag | When to use |
|------|------------|
| `--rigor fast` | Skip spec for bugs/fixes, go straight to build |
| `--rigor standard` | Default — triage decides based on type |
| `--rigor full` | Force full spec + plan regardless of type |

---

## Feed-forward

`/ship` writes to `specs/feed-forward.md`. `/triage` reads the last 3 entries and surfaces anything relevant to the new CR. Learning from one CR flows into the next automatically.

---

## Project structure after setup

```
CLAUDE.md                  ← Praxis config
ARCHITECTURE.md            ← Project snapshot (re-run /setup when architecture changes)
specs/
  cr/
    BACKLOG.md             ← All open CRs
    CR-0001.cr.md          ← CR item
    CR-0001.spec.md        ← Specification
    plans/
      CR-0001.plan.md      ← Implementation plan
  lessons-learned.md
  feed-forward.md
.claude/
  skills/                  ← Praxis skills (installed by install.sh)
```
