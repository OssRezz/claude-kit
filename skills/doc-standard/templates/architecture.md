# Architecture

Updated: YYYY-MM-DD
Related ADRs: docs/adr/

## Overview

<2-4 sentences describing the shape of the system>

## Standards applied

| Layer | Standard | Skill |
|-------|----------|-------|
| Backend | <e.g. hexagonal> | `arch-nest-hexagonal` |
| Frontend | <e.g. mvc> | `arch-frontend-mvc` |

If a standard is defined locally instead of by a skill, document it in
`docs/architecture/conventions.md` and reference it here.

## Components

| Component | Responsibility | Stack | Path |
|-----------|----------------|-------|------|
| <name> | <one line> | <tech> | `<path>` |

## Folder structure

    <the canonical tree every module must follow>

## Data flow

<how a request travels through the system, or a numbered list of steps>

## Cross-cutting concerns

| Concern | Approach |
|---------|----------|
| Authentication | <> |
| Authorization | <> |
| Error handling | <> |
| Logging | <> |
| Configuration | <> |
| Testing | <> |

## Boundaries

- <what must never depend on what>
