---
name: code-standard
description: Cross-stack code quality rules - comments, duplication and shared code extraction, naming, file size. Use when writing or reviewing any application code. Complements the stack-specific architecture skills, which define folder structure.
---

# Code Standard

Stack-agnostic. Folder structure and layer naming are defined by the
architecture skill for the stack, which outranks this document on
those points.

## Comments

The global rule is: comment why, not what. In practice:

Write a comment when a reader who knows the language would still ask
"why is this here?":

- A business rule that is not derivable from the code.
- A deliberate deviation from the project standard, with the reason.
- A workaround for an external bug, with a link or issue reference.
- A performance trade-off that makes the code look wrong.
- A non-obvious ordering or timing dependency.

Do not write a comment for:

- What the next line does.
- Function or variable names that already say it.
- Marking sections, separating blocks, or decorating.
- Recording who changed what and when.

If a comment is needed to explain *what* the code does, the fix is to
rename or extract, not to add the comment.

## Duplication

Duplication is only a problem when the copies must change together.
Two functions that look alike but serve different reasons are not
duplication, and merging them creates coupling that is harder to undo
than the copy was.

Before extracting, ask: if requirement A changes, must B change too?

- Yes -> extract.
- No -> leave both. The similarity is incidental.

### Where extracted code goes

1. **Same file** if only that file uses it. A private helper is the
   cheapest form of reuse.
2. **Same module** if only that module uses it. Follow the
   architecture skill for placement.
3. **Shared location** only when two or more modules genuinely need
   it, and it has no dependency on any single module.

Never promote to shared on the second occurrence alone. Two is a
coincidence, three is a pattern. Premature sharing produces a
dumping-ground module that everything depends on.

### What must never be shared

- Business rules belonging to one bounded context.
- Anything that would make a shared package import from a feature
  module. Dependencies point inward and downward, never sideways.

## Naming

- Names state what the thing **is**, not how it is implemented.
  `UserRepository`, not `UserSqlHelper`.
- No abbreviations except ones universal in the domain (`id`, `url`,
  `http`). No single letters outside loop counters and lambdas.
- Booleans read as assertions: `isActive`, `hasPermission`,
  `canRetry`.
- Functions start with a verb. Collections are plural.
- No type suffixes on variables. No Hungarian notation.
- Consistency with the surrounding file beats consistency with this
  document. Do not rename existing code as a side effect.

### Files and folders

- One primary export per file. The file is named after it.
- Case convention follows the stack skill and, failing that, the
  dominant convention already in the repository. Never mix two
  conventions within one module.
- Folder names are plural for collections of things (`controllers`,
  `entities`), singular for a bounded concept (`billing`, `auth`).

## Size

These are smells, not limits. Crossing one means look, not split.

- A function that needs a comment to explain its sections.
- A file exceeding roughly 300 lines.
- A function with more than 3 levels of nesting.
- A parameter list longer than 4. Pass an object.

## Error handling

- Never swallow an exception. Handle it, wrap it with context, or let
  it propagate.
- Never catch broadly to hide a specific failure.
- Validate at the boundary. Inner layers trust their inputs.
- Error messages state what failed and with what input. They never
  leak secrets, tokens or full payloads.