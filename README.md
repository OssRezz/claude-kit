# claude-kit

A reusable Claude Code setup: a fixed set of agents, standards and
commands that work the same way in every project.

The idea is a small software team. Each agent has one job, its own
context, and hands off through files on disk rather than through the
conversation. That keeps context small, makes work resumable after
`/clear`, and puts a human gate where the machine cannot verify
itself.

## Requirements

| Requirement | Notes |
|-------------|-------|
| Claude Code | `npm install -g @anthropic-ai/claude-code` |
| Node.js | current LTS |
| Git | required by `build`, `refine` and `/next` |

Claude Code documentation: https://docs.claude.com/en/docs/claude-code/overview

No other dependencies. Everything in this repository is markdown.

## Install

Clone anywhere, then link it into `~/.claude`.

**macOS / Linux**

    git clone <repo-url> ~/claude-kit
    cd ~/claude-kit
    ./install.sh

**Windows (PowerShell)**

    git clone <repo-url> $env:USERPROFILE\claude-kit
    cd $env:USERPROFILE\claude-kit
    powershell -ExecutionPolicy Bypass -File .\install.ps1

Both scripts create links, not copies. Edit a file here, and every
project sees the change immediately. Windows uses junctions and a
hard link, which need no administrator rights; macOS and Linux use
symlinks.

If `~/.claude/agents`, `skills` or `commands` already exist as real
folders, move their contents into this repository first. The install
scripts will not overwrite them silently.

### Verify

    ls -l ~/.claude                                   # macOS / Linux
    Get-Item "$env:USERPROFILE\.claude\agents"        # Windows

Six agents, five skills, one command.

### Other machines

    git pull && ./install.sh

Run the installer once per machine. After that, `git pull` is enough.

## Layout

    agents/      who does the work
    commands/    slash commands
    skills/      how things are done
    CLAUDE.md    global rules, applied to every project

## Agents

| Agent | Role | Model | When |
|-------|------|-------|------|
| `onboard` | Writes the project `CLAUDE.md` and `docs/` skeleton | sonnet | first, on any project without one |
| `scan` | Inventories one legacy module | sonnet | migrations only |
| `spec` | Requirements, architecture, ADRs, plan | opus | before any implementation |
| `build` | Implements one task | sonnet | after the plan is approved |
| `test` | Writes and runs tests, reports against criteria | sonnet | after build, or before it in a fix |
| `refine` | Reviews the diff, refactors, re-runs tests | opus | after test passes |

Agents do not call each other. You invoke them, and they hand off
through `docs/`.

## Skills

| Skill | Covers |
|-------|--------|
| `doc-standard` | The `docs/` contract and every document template |
| `code-standard` | Comments, duplication, naming, error handling |
| `arch-nest-hexagonal` | NestJS module anatomy: layers, ports, use cases |
| `arch-nest-monorepo` | Multi-service topology, shared packages, HTTP clients |
| `arch-frontend-mvc` | React modules, controllers, models, state, performance |

Architecture skills are referenced per project in its `CLAUDE.md`.
A project uses only the ones that apply.

## Commands

`/next` reads `docs/STATE.md`, cross-checks it against git, and
reports which agent should run next. It never runs anything.

## Flows

**New application**

    spec        requirements, architecture options, ADR, plan
    onboard     writes CLAUDE.md from the decided architecture
    build -> test -> refine     per task

**Migration**

    onboard     CLAUDE.md from the existing code
    scan        once per module
    spec        target architecture, ADR, migration plan
    build -> test               per task, parity first
    refine                      only after parity is confirmed

**Feature**

    spec        plan only
    build -> test -> refine

**Fix**

    test        reproduce the defect with a failing test
    build       fix it
    test        confirm
    refine

## Usage

Open Claude Code at the root of the workspace, not inside one module.
For a multi-module project, the root is the folder that contains them
all.

    cd ~/work/my-project
    claude

Then, in the session:

    use onboard to document this project

    use spec to plan the billing module

    use build for task 01

    use test for task 01

    use refine for task 01

    /next

Between phases, `/clear`. The context is disposable; the state lives
in `docs/`.

### Migration example

    ~/work/drceo/
    ├── CLAUDE.md
    ├── docs/
    └── legacy/
        ├── api/
        ├── front-admin/
        └── micro-ihce/

    use onboard to document this repository

    use scan on legacy/api
    use scan on legacy/front-admin
    use scan on legacy/micro-ihce

    use spec to design the target monorepo from docs/00-inventory

One module per `scan` call. Each runs in a clean context and writes
one inventory file; `spec` then reasons over the inventories instead
of the source.

## Per-project setup

`onboard` writes the project `CLAUDE.md`. It declares which standards
apply:

    ## Standards
    | Layer    | Standard   | Skill                 |
    |----------|------------|-----------------------|
    | Backend  | hexagonal  | `arch-nest-hexagonal` |
    | Frontend | mvc        | `arch-frontend-mvc`   |

    User-facing message language: es

Keep it under 150 lines. It is loaded on every agent invocation, so
it is the most expensive file in the project per token. Anything
longer belongs in `docs/`.

## Adding a standard

    skills/<name>/SKILL.md

Frontmatter needs `name` and a `description` that states when to use
it - that description is how an agent decides to load it.

Write a standard once it has proven itself on a project. A convention
invented in advance is a guess; one extracted from working code is a
standard.

## Design notes

**Files, not conversation.** Agents hand off through `docs/`. The
returned summary is lossy; the file is the contract.

**Human gates where verification is impossible.** A bad plan looks
like a good plan, so `spec` stops and asks. A failing test does not
look like a passing test, so `build -> test` can loop unattended.

**Parity before quality.** During a migration, `refine` does not run
until behaviour matches. Mixing correctness and improvement makes
failures impossible to attribute.

**One task at a time.** An agent that keeps going accumulates
unverified work and produces a diff nobody can review.