---
name: doc-standard
description: Documentation contract for agent workflows. Use when creating or updating any file under docs/ - requirements, architecture, plans, inventory, ADRs, reports or STATE.md.
---

# Documentation Standard

All project documentation is written in **English**, regardless of the
language used in conversation.

## Layout

    docs/
    ├── STATE.md              # single source of truth for progress
    ├── 00-inventory/         # migrations only, one file per module
    ├── 01-requirements.md
    ├── 02-architecture.md
    ├── 03-plan.md
    ├── adr/                  # NNNN-short-title.md
    └── reports/              # YYYY-MM-DD-<agent>-<subject>.md

## Rules

1. Never invent sections. Use the templates in `templates/`.
2. One decision = one ADR. Decisions never live only in chat.
3. Every agent updates `STATE.md` as its final step.
4. Plans are written as discrete tasks with acceptance criteria.
   A task that cannot be verified is not a task.
5. Facts only. No filler, no restating the obvious, no praise.
6. Reference files by path. Never paste large code blocks into docs.
7. If a fact is unknown, write `UNKNOWN` explicitly. Never guess.

## Writing style

- Short declarative sentences.
- Tables over prose when comparing options.
- Absolute paths from the repo root, e.g. `legacy/api/src/user.ts`.
- Dates as `YYYY-MM-DD`.

## Templates

| File | Written by | When |
|---|---|---|
| `templates/state.md` | all agents | always |
| `templates/requirements.md` | spec | new app, migration |
| `templates/architecture.md` | spec | new app, migration |
| `templates/plan.md` | spec | always |
| `templates/inventory-module.md` | scan | migrations only |
| `templates/adr.md` | spec | on every architectural decision |
| `templates/report.md` | test, refine | after each run |
| `templates/project-claude.md` | onboard | project init or drift |