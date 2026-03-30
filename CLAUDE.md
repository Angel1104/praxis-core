# Praxis Core — Source Repository

This is the Praxis methodology source repo. It is NOT a consumer project.

## What this repo is

Praxis is a lifecycle methodology for AI-driven work. This repo contains the skill definitions and doctrine that get installed into other projects.

## Structure

```
skills/       — skill definitions (SKILL.md + references/ per skill)
doctrine/     — canonical doctrine files (single source of truth)
install.sh    — copies skills/ into a target project's .claude/skills/
README.md     — usage documentation
```

## How to work on this repo

- To add or modify a skill: edit `skills/<name>/SKILL.md`
- To change a doctrine rule: edit `doctrine/<rule>.md`, then sync the change to all `skills/*/references/<rule>.md` copies
- To add a new skill: create `skills/<name>/SKILL.md` + copy relevant doctrine files into `skills/<name>/references/`
- Never run `/setup` or `/init` here — those are for consumer projects

## Testing changes

Install into a separate test project and run the skills there:

```bash
./install.sh /path/to/test-project
```

## Praxis Configuration

Praxis Domain: general
Praxis Gates: spec=on, plan=on, review=on, lessons=on
