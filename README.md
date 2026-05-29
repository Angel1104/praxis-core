# Claude Engineering Skill Pack

A Claude Code plugin that implements the **Spec-Driven Development (SDM)** lifecycle as official Claude Code skills.

Every engineering change follows one lifecycle — Intake → Spec → Plan → Build → Review → Close — with specialist skills available at every stage. Stack and architecture agnostic: works with any language, framework, and project structure.

---

## Installation

The plugin is distributed as a ZIP file through the course platform. No GitHub account required.

### Prerequisites — Install Claude Code CLI

The `/plugin` commands require the Claude Code CLI. If you only have the VSCode extension, install the CLI first.

```bash
npm install -g @anthropic-ai/claude-code
```

Works on macOS, Linux, and Windows. Requires Node.js 18+. After installing, restart your terminal so the `claude` command is on your PATH.

> You need a Claude account (claude.ai) and an active subscription or API key. The CLI uses the same account as the VSCode extension.

---

### Step 1 — Download and extract

Download `sdm-skill-pack.zip` from the course materials and extract it anywhere on your machine:

```
~/Downloads/sdm-skill-pack/
```

### Step 2 — Add the marketplace (once per machine)

Open a terminal, start the Claude Code CLI, and register the marketplace. This persists across all your projects:

```bash
claude    # opens the Claude Code CLI
```

Then inside the CLI:

```
/plugin marketplace add ~/Downloads/sdm-skill-pack
```

Adjust the path to wherever you extracted the ZIP. You should see: *"Successfully added marketplace: comocom"*.

### Step 3 — Install the plugin (once per machine)

Open your project in VSCode with the Claude Code extension, then type:

```
/plugin install sdm@comocom
```

When prompted, choose **Install for you (user scope)** — this makes all skills available in every project on your machine, without having to reinstall per project.

### Step 4 — Start working

No setup required. Start your first CR:

```
/intake  describe your change or incident here
/cr      CR-0001
```

The plugin reads your project's `CLAUDE.md` (if it exists) for conventions and architecture context, and infers the technology stack from the codebase automatically.

---

### Updating to a newer version

When a new version is released:

1. Download the new ZIP and extract it to the same location, replacing the old files.
2. Open Claude Code and run:

```
/plugin install sdm@comocom
```

> **Note:** Updates are detected by version number. Each new release has a higher version in `plugin.json`, so `/plugin install` will pick up the change automatically.

---

### For instructors — building the ZIP

From the repo root:

```bash
zip -r sdm-skill-pack.zip .claude-plugin/ sdm-skill-pack/ --exclude "*.git*"
```

Upload `sdm-skill-pack.zip` to your course platform. Students download and follow the steps above.

---

## The Lifecycle

```
Intake → Spec → Plan → Build → Review → Close
```

Every change request (CR) passes through all six stages. Run them individually or use `/cr` to run the full pipeline automatically.

| Stage | Skill | Role |
|---|---|---|
| 1 — Intake | `/intake` | Technical Triage Lead |
| 2 — Spec | `/spec` | Domain Analyst + Architect + Security |
| 3 — Plan | `/plan` | Technical Architect |
| 4 — Build | `/build` | Senior Engineer |
| 5 — Review | `/review` | Architect + Security + QA (parallel) |
| 6 — Close | `/close` | Tech Lead |
| — | `/cr` | Automated pipeline: resolves business decisions upfront, then runs 2–6 uninterrupted |

### CR State Machine

```
OPEN → SPEC_DRAFT → SPEC_REVIEWED → SPEC_APPROVED → PLAN_READY → IMPLEMENTING → REVIEWING → CLOSED
```

Each skill gate-checks the CR state before proceeding. Running out of sequence produces a clear error with the correct next step.

### Track Model

| Track | Trigger | Depth |
|---|---|---|
| Standard | Normal severity | Full depth at every stage |
| Fast | High severity | Compressed spec (lean sections only) |
| Incident | Critical severity | Spec and Plan embedded in adjacent stages; containment before code |

---

## Specialist Skills

Callable independently or dispatched by lifecycle skills during review.

| Skill | Expertise |
|---|---|
| `/sw-architect` | Architecture review, boundary violations, structural compliance |
| `/domain-analyst` | Spec completeness, acceptance criteria quality, edge case detection |
| `/security-engineer` | Vulnerability assessment, isolation audit, auth design |
| `/engineer` | Implementation, component writing, debugging |
| `/qa-engineer` | Test generation, coverage review, adversarial thinking |

---

## How a CR Flows

**Step by step:**
```
/intake   Users need to upload profile photos. Max 5MB, JPEG/PNG only.
/spec     CR-0001
/plan     CR-0001
/build    CR-0001
/review   CR-0001
/close    CR-0001
```

**Or automated — let Claude handle it:**
```
/intake   Users need to upload profile photos. Max 5MB, JPEG/PNG only.
/cr       CR-0001
```

`/cr` resolves all open business questions upfront in a clarification loop, then runs the full pipeline uninterrupted. Technical decisions are made by Claude — it informs you of the choices taken and why, but never asks you to make them. The only stop after the clarification loop is a business question that could not have been anticipated.

---

## Stack and Architecture Support

The plugin is fully stack and architecture agnostic. It does not prescribe a specific technology, framework, or architecture pattern. Instead:

- **Stack** is inferred from the project's codebase (language, dependencies, directory structure)
- **Architecture** is read from the project's `CLAUDE.md` if documented, or inferred from code structure
- **Engineering principles** (separation of concerns, dependency direction, test strategy) are universal and applied by all skills

The plugin provides the **controlled development process**. Your project provides the **technical decisions**.

---

## Repository Structure

```
sdm-skill-pack/
├── .claude-plugin/
│   └── plugin.json           ← Plugin manifest
├── doctrine/                 ← Process doctrine — universal rules for the lifecycle
│   ├── engineering-principles.md
│   ├── directive-execution-principle.md
│   ├── artifact-contracts.md
│   ├── lifecycle-stage-rules.md
│   ├── contract-impact-rules.md
│   ├── review-severity-model.md
│   ├── finding-classification-rules.md
│   ├── evidence-and-citation-rules.md
│   ├── implementation-planning-rules.md
│   ├── spec-quality-rules.md
│   ├── testing-quality-rules.md
│   ├── lessons-learned-rules.md
│   └── backlog-persistence-rules.md
└── skills/
    ├── intake/         ← Stage 1: /intake
    ├── spec/           ← Stage 2: /spec
    ├── plan/           ← Stage 3: /plan
    ├── build/          ← Stage 4: /build
    ├── review/         ← Stage 5: /review
    ├── close/          ← Stage 6: /close
    ├── cr/             ← Automated pipeline: /cr
    ├── sw-architect/   ← Specialist: /sw-architect
    ├── domain-analyst/ ← Specialist: /domain-analyst
    ├── security-engineer/ ← Specialist: /security-engineer
    ├── engineer/       ← Specialist: /engineer
    └── qa-engineer/    ← Specialist: /qa-engineer
```

Each skill bundles its own copies of the doctrine files it needs in `references/`. Skills are self-contained.

When doctrine changes, update the source in `doctrine/` then sync to the relevant skill `references/` folders.

---

## Versioning

`2.0.0` — Stack and architecture agnostic. Removed stack doctrine files, setup skill, and architecture-specific doctrine. Added universal engineering principles. Skills infer stack from codebase and read architecture from `CLAUDE.md`.

`1.1.0` — Platform-agnostic model. Stack doctrine introduced (`stack-python-fastapi`, `stack-flutter`). Setup skill added. `backend-engineer` replaced by `engineer`. All skills renamed to short form.

`1.0.0` — Initial release. Full SDM lifecycle (6 stages) + 5 specialist skills. Python/FastAPI only.
