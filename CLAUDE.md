# SDM Core — Source Repository

This is the SDM skill pack source repo. It is NOT a consumer project.

## What this repo is

SDM (Spec-Driven Development) is a lifecycle methodology for engineering changes.
This repo contains the skill definitions and doctrine that get packaged and distributed
as the `sdm` Claude Code plugin.

## Structure

```
skills/           — skill definitions (SKILL.md + references/ per skill)
doctrine/         — canonical doctrine files (single source of truth)
.claude-plugin/   — plugin manifest (marketplace.json)
install.sh        — copies skills/ into a target project's .claude/skills/ (legacy path)
README.md         — end-user documentation
```

## How to work on this repo

- To add or modify a skill: edit `skills/<name>/SKILL.md`
- To change a doctrine rule: edit `doctrine/<rule>.md`, then sync the change to all `skills/*/references/<rule>.md` copies via `sync-doctrine.sh`
- To add a new skill: create `skills/<name>/SKILL.md` + copy relevant doctrine files into `skills/<name>/references/`

## Lifecycle skills

| Skill | Stage |
|---|---|
| `/intake` | 1 — Intake |
| `/spec` | 2 — Spec |
| `/plan` | 3 — Plan |
| `/build` | 4 — Build |
| `/review` | 5 — Review |
| `/close` | 6 — Close |
| `/cr` | Automated pipeline (2–6) |

## Specialist skills

`/sw-architect`, `/domain-analyst`, `/security-engineer`, `/engineer`, `/qa-engineer`

## Testing changes

Install into a separate test project:

```bash
./install.sh /path/to/test-project
```
