---
description: Read project state and recommend the next agent to run
---

Determine what should happen next in this project.

## Gather

Read `docs/STATE.md`. If it does not exist, say so and stop - the
project has not been initialised by `spec` yet.

Then read, only as needed to verify:

- `docs/03-plan.md` for the task list
- `docs/reports/` for the most recent test and refine outputs
- `git log --oneline -15` and `git status --short`

## Verify state against reality

`STATE.md` is maintained by agents and can drift. Cross-check it:

| Claim in STATE.md  | Check against                           |
| ------------------ | --------------------------------------- |
| task marked built  | a commit referencing `[task NN]` exists |
| task marked tested | a report exists in `docs/reports/`      |
| working tree clean | `git status`                            |

Report every discrepancy explicitly. A stale `STATE.md` is more
dangerous than a missing one, because the next agent will trust it.

## Decide

Apply in order, first match wins:

1. Open decision blocking progress -> ask the human, name the
   decision.
2. `STATE.md` disagrees with git -> report the discrepancy, propose
   how to reconcile, do not proceed.
3. Uncommitted changes not owned by a running task -> report, stop.
4. Task built but not tested -> `test task NN`.
5. Test failures outstanding -> `build task NN` to fix them.
6. Task tested and passing, not refined -> `refine task NN`,
   unless the flow is `migration` and parity is not yet confirmed,
   in which case skip refine and move to the next task.
7. Task fully closed, more tasks remain -> `build task NN+1`.
8. All tasks closed -> report completion and list anything parked in
   Notes.
9. No plan exists -> `spec`.

## Output

Be brief. No preamble.

    Project: <name>  |  Flow: <flow>  |  Phase: <phase>
    Progress: <n of m tasks closed>

    State check: consistent | <discrepancy>

    Next: <agent> <task NN> - <title>
    Why: <one sentence>

    Parked: <count> notes, <count> open decisions

Do not run the recommended agent. Only report.
