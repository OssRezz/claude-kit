# Inventory - <module name>

Path: `<path to the legacy module>`
Scanned: YYYY-MM-DD

## Summary

<3-5 sentences: what this module does and how it is built>

## Stack

| Item | Value |
|------|-------|
| Language / runtime | <> |
| Framework | <> |
| Package manager | <> |
| Database | <> |
| Build tool | <> |
| Test framework | <> or NONE |

## Entry points

| Type | Path | Notes |
|------|------|-------|
| <http route / cli / cron / queue consumer> | `<path>` | <> |

## External dependencies

| Dependency | Purpose | Risk on migration |
|------------|---------|-------------------|
| <package or service> | <> | low / medium / high |

## Integrations with other modules

| Direction | Module | Mechanism |
|-----------|--------|-----------|
| calls / called by | <module> | <http, queue, shared db, import> |

## Configuration

| Variable | Purpose | Required |
|----------|---------|----------|
| <ENV_VAR> | <> | yes / no |

## Dead or suspicious code

- `<path>` - <why it looks unused>

## Migration risks

| Risk | Impact | Notes |
|------|--------|-------|
| <> | low / medium / high | <> |

## Parity checklist

Behaviour that must be identical after migration.

- [ ] <endpoint, job, or side effect>
