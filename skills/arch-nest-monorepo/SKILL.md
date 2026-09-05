---
name: arch-nest-monorepo
description: Topology standard for NestJS monorepos with multiple services - workspace layout, shared packages, inter-service HTTP clients, database ownership and health aggregation. Use alongside arch-nest-hexagonal when the project hosts more than one deployable service.
---

# NestJS Monorepo Standard

Applies when one repository hosts several deployable services.
Module anatomy is defined by `arch-nest-hexagonal` and is unchanged
by this document.

If the project is a single service, this skill does not apply. Do not
introduce a workspace to prepare for services that do not exist.

## Layout

    apps/
    ├── auth/
    ├── organizations/
    └── <service>/
    packages/
    ├── nest-core/
    ├── pdf/
    ├── s3/
    └── mailer/

`apps/` holds deployable services. Each is a complete NestJS
application with its own `src/modules`, its own database and its own
lifecycle.

`packages/` holds code shared by two or more services.

Package manager: pnpm workspaces. One lockfile at the root.

## Database ownership

**Each service owns its database schema exclusively.**

- No service reads or writes another service's tables.
- No shared connection string across services.
- No foreign keys across service boundaries.
- No `JOIN` to a table you do not own.

This is the rule that makes services separable. Break it once and the
services are a distributed monolith: they deploy separately but can
never change independently.

A service holds foreign identifiers as plain values (`companyId`),
not as relations. Resolving them is a call to the owning service.

## Inter-service communication

Services talk over HTTP. The client lives in the calling service, in
`src/shared/infrastructure/<service>-client/`, and is named for the
service it calls: `organizations-client`.

### Client rules

- The client exposes the calling service's own domain-shaped types.
  A remote payload is mapped at the client boundary, exactly like a
  Prisma mapper. Remote shapes never reach a use case.
- Timeouts are mandatory and explicit. A call with no timeout turns
  a slow dependency into an outage.
- Failures map to domain errors of the calling module, not to raw
  HTTP errors. `ClientCompanyNotFoundError`, not a 404 propagated up.
- Retries only for idempotent reads. Never retry a write blindly.
- Never forward a raw incoming request to another service. Build the
  outbound call explicitly.

### What travels

Identity and correlation propagate on every call: the auth context
and a request id for tracing. Nothing else is implicit.

### When not to call

If a service needs another service's data on every request in a hot
path, that is a boundary problem, not a client problem. Report it -
either the data belongs to the caller, or the two services are one.

## Shared packages

### Promotion rule

Code becomes a package when **two or more services genuinely need
it** and it depends on no single service.

Two occurrences is a coincidence. Wait for the third, or for a clear
statement that the second is permanent. A package created early
becomes a dumping ground that every service depends on and nobody can
change.

### What belongs

- Cross-cutting framework glue: `AppError`, error interceptor,
  response envelope, auth decorators, logging factory.
- Technology adapters with no business meaning: pdf, s3, mailer.

### What never belongs

- Business rules of any bounded context.
- Domain entities. Two services with the same concept hold their own
  version of it. Sharing an entity couples their release cycles.
- Prisma schemas or generated clients.
- Anything importing from `apps/`.

### Package rules

- A package never imports from `apps/`, ever.
- A package never imports from another package unless that dependency
  is declared and acyclic.
- A package exports through a single entry point.
- A breaking change to a shared package is a change to every service
  that consumes it. Say so in the handoff.

## Service anatomy

Each service under `apps/` follows `arch-nest-hexagonal`, plus:

- `src/shared/health/` - its own health controller.
- `src/shared/infrastructure/` - database, cache, and one folder per
  remote service client.
- `src/shared/interfaces/auth/` - security wiring.
- Route prefix carries the service name: `@Controller("auth/users")`.
  This keeps routes unambiguous behind a gateway.
- Environment validated at boot with a schema. A service must fail to
  start on missing configuration, never start degraded.

## Health

Every service exposes `<service>/health`, public, reporting per-check
status for each dependency it owns.

A service reports only its own dependencies. It does not health-check
other services - that produces cascading false alarms where one
outage makes every service report unhealthy. Aggregation is the
aggregator's job.

## Working across services

- One task touches one service. If a change requires two services,
  it is two tasks with an explicit order, and the contract between
  them is written down before either starts.
- Deploy order matters: the provider of a new contract ships before
  its consumer. Additive first, removal later.
- Never change a shared package and a consumer in the same commit
  without saying so.

## Review checklist

- [ ] No cross-service database access.
- [ ] No foreign keys across service boundaries.
- [ ] Remote payloads mapped at the client boundary.
- [ ] Every outbound call has an explicit timeout.
- [ ] Remote failures surface as domain errors.
- [ ] No package imports from `apps/`.
- [ ] No business rules or domain entities in `packages/`.
- [ ] Health checks only own dependencies.
- [ ] Config validated at boot.
