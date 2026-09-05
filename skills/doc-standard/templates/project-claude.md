# <project name>

<one sentence: what this project is>

Flow: new-app | migration | feature-work
Updated: YYYY-MM-DD

## Standards

| Layer | Standard | Skill |
|-------|----------|-------|
| Backend | <e.g. hexagonal> | `arch-nest-hexagonal` |
| Frontend | <e.g. mvc> | `arch-frontend-mvc` |
| Code | cross-stack rules | `code-standard` |
| Docs | documentation contract | `doc-standard` |

Local conventions that override or extend the above:
`docs/architecture/conventions.md`

## Modules

| Module | Path | Stack | Purpose |
|--------|------|-------|---------|
| <name> | `<path>` | <tech> | <one line> |

## Commands

| Module | Install | Run | Build | Test | Lint |
|--------|---------|-----|-------|------|------|
| <name> | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` |

Mark anything unverified as UNKNOWN. Never guess a command.

## Conventions in use

Observed in the existing code, not aspirational.

- File naming: <convention, per module if they differ>
- Tests: <location and naming>
- Imports: <aliases, relative vs absolute>
- <anything else an agent would get wrong by default>

## Boundaries

- <what must never be modified: generated code, vendor, legacy frozen areas>
- <what must never depend on what>

## Environment

- Required services: <db, cache, queue>
- Config: <where env vars live, which file is the example>
- Secrets are never committed and never printed.

## Notes

- <anything that would surprise a developer joining today>