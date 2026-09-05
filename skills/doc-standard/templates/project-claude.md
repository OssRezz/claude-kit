# <project name>

<one sentence: what this project is>

Flow: new-app | migration | feature-work
Updated: YYYY-MM-DD

## Standards — intended

What applies to **new** code. Decided by the human, not inferred.
Use `none - follows existing conventions` when nothing was decided.

| Layer | Standard | Skill | Applies |
|-------|----------|-------|---------|
| Backend | <e.g. hexagonal> | `arch-nest-hexagonal` | fully / structure only / none |
| Frontend | <e.g. mvc> | `arch-frontend-mvc` | fully / structure only / none |
| Code | cross-stack rules | `code-standard` | fully |
| Docs | documentation contract | `doc-standard` | fully |

### Divergences

Where the repository does not follow the assigned standard. Facts,
not a to-do list. Never rewrite existing code to close one.

- <standard rule> vs <what the repo does> -> <which one wins, and where>

Local conventions that override or extend the above:
`docs/architecture/conventions.md`

User-facing message language: es | en | i18n keys

## Modules

| Module | Path | Stack | Purpose |
|--------|------|-------|---------|
| <name> | `<path>` | <tech> | <one line> |

## Commands

| Module | Install | Run | Build | Test | Lint |
|--------|---------|-----|-------|------|------|
| <name> | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` |

Mark anything unverified as UNKNOWN. Never guess a command. State the
source of these commands and whether any CI verifies them.

## Conventions in use — observed

What the code does today. This governs **existing** code and outranks
the standards above when touching it.

- File naming: <convention, per module if they differ>
- Tests: <location and naming, or none>
- Imports: <aliases, relative vs absolute>
- State: <where it lives>
- <anything a newcomer would get wrong by default: framework quirks,
  workarounds, response contracts>

Where two conventions coexist, name both and which dominates.

## Existing documentation

Pre-existing docs that remain the source of truth for their subject.
Referenced, never duplicated here.

| Path | Covers |
|------|--------|
| `<path>` | <subject> |

## Boundaries

- <what must never be modified: other repositories, generated code,
  vendor, frozen areas>
- <what must never depend on what>

## Environment

- Required services: <db, cache, queue, external APIs>
- Config: <where env vars live, which file is the example>
- Secrets are never committed and never printed.

## Working agreements

How the human wants work delivered: batch size, additive versus
rewrite, confirmation cadence.

- <agreement>

## Notes

- <anything that would surprise a developer joining today>