---
name: arch-nest-hexagonal
description: Hexagonal module anatomy for NestJS - folder structure, layer boundaries, ports and adapters, use cases, domain errors and naming. Use when creating or reviewing any NestJS module. Covers module structure only, not deployment topology.
---

# NestJS Hexagonal Module Standard

Screaming architecture: the folder tree names the business, not the
framework. A reader sees `users`, `billing`, `sessions` before seeing
`controllers` or `services`.

This skill defines **module anatomy**. It says nothing about whether
the system is one service or twenty. For monorepo and inter-service
rules see `arch-nest-monorepo`.

## Prerequisite contract

The project must provide a core module or package exporting:

| Export                     | Purpose                                 |
| -------------------------- | --------------------------------------- |
| `AppError`                 | Base error with `code` and `httpStatus` |
| error interceptor / filter | Maps `AppError` to HTTP response        |
| `buildWinstonOptions`      | Winston configuration factory           |
| `@Public()`                | Marks a route as unauthenticated        |
| `@ResponseMessage()`       | Declares the envelope message           |

Where it lives is a project decision: a shared package in a monorepo,
or `src/core` in a standalone app. Record the choice in `CLAUDE.md`.
If it does not exist, say so before writing code - do not reimplement
it per module.

## Anatomy

    src/
    ├── modules/
    │   └── <module>/
    │       ├── application/
    │       │   ├── services/            # module-scoped, optional
    │       │   └── use-cases/
    │       │       └── <use-case>/
    │       │           ├── __tests__/
    │       │           ├── <use-case>.usecase.ts
    │       │           └── index.ts
    │       ├── domain/
    │       │   ├── entities/
    │       │   ├── errors/
    │       │   └── ports/
    │       │       ├── tokens.ts
    │       │       └── <name>.repository.port.ts
    │       ├── infrastructure/
    │       │   └── <adapter>/           # named after the technology
    │       ├── interfaces/
    │       │   ├── controllers/
    │       │   └── dto/
    │       └── <module>.module.ts
    ├── shared/
    │   ├── health/
    │   ├── infrastructure/
    │   └── interfaces/
    ├── app.module.ts
    └── main.ts

The module folder is named after the business capability, plural when
it manages a collection: `users`, `sessions`, `password-reset`.

## Dependency rule

Dependencies point inward. `domain` imports nothing from the other
three layers.

| Layer            | May import from              |
| ---------------- | ---------------------------- |
| `domain`         | nothing outside itself       |
| `application`    | `domain`                     |
| `infrastructure` | `domain`, and its technology |
| `interfaces`     | `application`, `domain`      |

Violations to reject on sight:

- A framework or ORM decorator on a domain entity.
- A Prisma type in a use case signature.
- A controller calling a repository directly, bypassing the use case.
- `infrastructure` importing from `interfaces`, or the reverse.

## Domain

### Entities

Plain TypeScript. No `@nestjs/*`, no ORM decorators, no persistence
concerns. `<name>.entity.ts`.

The entity owns invariants that hold regardless of storage. Anything
requiring a database lookup is not an invariant - it belongs to a use
case.

### Ports

Interfaces the outside world must satisfy, named for the role, not
the technology: `<name>.repository.port.ts`, `<name>.mailer.port.ts`.

Injection tokens live together in `ports/tokens.ts` as `Symbol` or
`const` tokens. Never inject by concrete class.

### Errors

`errors/<module>.errors.ts`. One class per failure case, extending
`AppError` with a stable `code` and an `httpStatus`.

```typescript
export class UserNotFoundError extends AppError {
  readonly code = "USER_NOT_FOUND";
  readonly httpStatus = HttpStatus.NOT_FOUND;
  constructor() {
    super("El usuario no existe");
  }
}
```

Rules:

- `code` is `SCREAMING_SNAKE_CASE`, stable, and part of the public API.
  Clients branch on it. Renaming one is a breaking change.
- The message is user-facing. Its language is declared per project in
  `CLAUDE.md`; identifiers, comments and `code` are always English.
- Never leak internals: no SQL, no stack traces, no payloads.
- Throw domain errors from use cases. Never throw `HttpException`
  outside `interfaces`.
- Group related errors with a comment header only when the file has
  distinct sections. Never decorate individually.

## Application

### Use cases

One class per use case, one folder per use case, a single public
method `execute`.

    create-user/
    ├── __tests__/
    │   └── create-user.usecase.spec.ts
    ├── create-user.usecase.ts
    └── index.ts

The folder name is the action in kebab-case: `create-user`,
`set-user-password`, `find-users-by-role`. The class is
`CreateUserUseCase`.

A use case orchestrates: it validates business preconditions, calls
ports, and throws domain errors. It contains no HTTP, no SQL, no
framework types.

`index.ts` re-exports the use case so imports stay stable if the
internal file layout changes.

### Services

`application/services/` is for logic shared by two or more use cases
**within the same module**, when that logic is more than a helper
function - it holds a decision, not a transformation.
`ClientScopeResolver` used by create and update is the shape.

Do not create a service for a single caller. Do not create a service
that is a thin wrapper over a port. A service never becomes a
catch-all: if it grows methods unrelated to each other, split it.

## Infrastructure

One folder per technology adapter, named after it: `prisma`, `redis`,
`s3`. It implements the ports.

- `<name>.<tech>.repository.ts` implements the port.
- `<name>.<tech>.mapper.ts` converts between persistence rows and
  domain entities, in both directions, explicitly.

The mapper is what keeps the domain pure. It is not optional and it
is not generated. If a field has no domain meaning, it does not cross
into the entity.

## Interfaces

### Controllers

`<module>.controller.ts`. Thin: receive, delegate to one use case,
return. No business logic, no conditionals on domain state.

Route prefix includes the service or module name so it stays
unambiguous behind a gateway: `@Controller("auth/users")`.

Use `@Public()` only where authentication genuinely does not apply,
and `@ResponseMessage()` to declare the envelope message.

### DTOs

`dto/<action>.dto.ts`, one per operation. All input validation lives
here with `class-validator`. Inner layers trust their inputs, which
is only safe if the boundary is strict.

DTOs are not domain entities and are never passed into a use case
unchanged if the use case would then depend on their shape. Convert
at the boundary.

## Module wiring

`<module>.module.ts` binds ports to adapters:

```typescript
providers: [
  CreateUserUseCase,
  { provide: USER_REPOSITORY, useClass: UserPrismaRepository },
];
```

Export only what other modules legitimately need. A module that
exports everything has no boundary.

## Logging

Winston through `buildWinstonOptions`, configured once in
`app.module.ts` with the service name.

Log at boundaries and on failure, not on every step. Never log
credentials, tokens or full request bodies.

## Health

Every service exposes `<service>/health`, public, checking each real
dependency it owns (database, cache, queue) and returning per-check
status. A health endpoint that returns `ok` without touching its
dependencies is worse than none: it makes an outage invisible.

## Testing

Tests live in `__tests__/` beside the code under test.

| Layer         | Tested how                       |
| ------------- | -------------------------------- |
| domain entity | direct, no mocks                 |
| use case      | ports mocked, behaviour asserted |
| mapper        | round-trip, both directions      |
| controller    | thin, covered by e2e             |

Assert on domain errors by `code`, never by message. Messages are
user-facing copy and will change.

## Review checklist

- [ ] Domain has no framework or ORM imports.
- [ ] Every port has a token in `ports/tokens.ts`.
- [ ] One use case per folder, single `execute`.
- [ ] Errors extend `AppError` with a stable `code`.
- [ ] Mapper converts both directions explicitly.
- [ ] Controller delegates to exactly one use case.
- [ ] DTO validates every input field.
- [ ] Module exports only what is needed outside.
- [ ] Tests assert on `code`, not on message text.
