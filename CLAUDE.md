# Praxis Core — Source Repository

This is the Praxis skill pack source repo. It is NOT a consumer project.

## What this repo is

Praxis is a lightweight methodology for AI-assisted development.
This repo contains the skill definitions and doctrine distributed as the Praxis hackathon pack.

## Structure

```
skills/           — skill definitions (SKILL.md + references/ per skill)
doctrine/         — canonical doctrine files (single source of truth)
.claude-plugin/   — plugin manifest (marketplace.json)
install.sh        — copies skills/ into a target project's .claude/skills/
README.md         — end-user documentation
```

## How to work on this repo

- To add or modify a skill: edit `skills/<name>/SKILL.md`
- To change a doctrine rule: edit `doctrine/<rule>.md`, then sync the change to all `skills/*/references/<rule>.md` copies via `sync-doctrine.sh`
- To add a new skill: create `skills/<name>/SKILL.md` + copy relevant doctrine files into `skills/<name>/references/`

## Skills

| Skill | What it does |
|---|---|
| `/plan` | Understands the request, asks ≤3 questions, produces a wave-structured plan |
| `/build` | Reads the plan, implements wave by wave, updates the file when done |

## Testing changes

Install into a separate test project:

```bash
./install.sh /path/to/test-project
```
