---
name: arch-frontend-mvc
description: React MVC standard - modules with components, controllers, models and hooks, orchestrating pages, routing and transversal component library. Use when creating or reviewing any React frontend feature.
---

# React MVC Standard

Screaming architecture: `src/modules` names the business. A module
owns everything about one capability; pages orchestrate them.

The layering is MVC adapted to React:

| Role | Holds |
|------|-------|
| Model | data access and remote contract |
| Controller | the operation: calls the model, shapes the result |
| Hook | React state binding between component and controller |
| Component | presentation |
| Page | orchestration of a screen |

## Naming

Files and folders are **kebab-case with a role suffix**:

    users.table.tsx        create-user.modal.tsx
    create-user.controller.ts
    user.model.ts          use-users.ts
    users.page.tsx

Exported symbols keep their idiomatic case: `UsersTable`,
`CreateUserModal`, `UserModel`, `useUsers`.

Folders are kebab-case, plural for collections (`components`,
`controllers`), singular for a concept (`model`, `layout`).

This applies to new projects. In an existing codebase the convention
already in use wins - never rename existing files as a side effect.

## Layout

    src/
    ├── components/              # transversal, used by any module
    │   ├── layout/              # sidebar, topbar, shell
    │   ├── ui/                  # select, checkbox, modal
    │   ├── table/               # data-table, pagination
    │   └── <widget>/
    ├── modules/
    │   └── <module>/
    │       ├── components/      # scoped to this module
    │       ├── controllers/
    │       ├── hooks/           # optional
    │       ├── model/
    │       ├── types.ts
    │       └── index.ts         # public API of the module
    ├── pages/
    │   └── <module>/
    │       └── <name>.page.tsx
    └── routes/
        ├── types.ts
        ├── lazy.ts
        ├── config.ts
        └── router.tsx

## Dependency rule

    page -> module (via index.ts) -> hook -> controller -> model -> api client

| Layer | May import |
|-------|-----------|
| model | api client, types |
| controller | model, types |
| hook | controller, React |
| component | hooks, components, types |
| page | module public API, transversal components |

Violations to reject on sight:

- `fetch` or `axios` anywhere outside `model/`.
- A component importing a controller directly when a hook exists.
- A page importing from a module's internal path instead of its
  `index.ts`.
- A module importing another module's internals.
- React imports inside `model/` or `controllers/`.

## Model

One class per module, `model/<module>.model.ts`, extending the shared
API client.

It is the only place that knows the remote contract: endpoints,
payload shapes, response envelopes. It exposes methods in the app's
own vocabulary and returns the module's types, never raw responses.

- No React. No hooks. No state. Testable without a DOM.
- Maps the API shape to the module's types. If the backend renames a
  field, exactly one file changes.
- HTTP errors become typed failures the controller can act on, not
  raw responses passed upward.

`fetch` is the default. Axios is acceptable when the project already
uses it. Whichever it is, it appears only in the shared api client.

## Controllers

One file per operation: `controllers/create-user.controller.ts`.

The controller is the seam between view and model. It calls the
model, applies the rules the view should not know, and returns a
result the view can render directly.

- No JSX, no React imports.
- No direct HTTP. It goes through the model.
- One controller does one operation. If it grows branches for
  unrelated operations, split it.

## Hooks

`hooks/use-<subject>.ts`, optional. Add one when a component needs
React state around a controller: loading flags, pagination state,
refetch, optimistic updates.

- A hook wraps controllers. It never contains the remote contract.
- If a hook only forwards a call with no state, delete it and let the
  component call the controller.
- Hooks own the loading and error state that the UI renders.

## Components

`modules/<module>/components/` holds components scoped to the module:
the users table, the create modal, the filter bar.

Rule of thumb: if only this module would ever render it, it belongs
here. If two modules need it, it moves to `src/components/`, and only
on the third occurrence unless it is obviously generic.

Sub-groups get a folder: `components/tabs/` for pieces shared between
the create and edit modals.

A component receives data and callbacks. It does not fetch, and it
does not decide business outcomes.

## Pages

`pages/<module>/<name>.page.tsx`.

The page is the orchestrator: it composes module components,
holds screen-level state, and decides what is shown when. It is the
only place allowed to combine several modules.

The page imports from a module's `index.ts`, never from its internals.
That barrel is the module's public API - what is not exported is not
reachable.

## Routes

| File | Holds |
|------|-------|
| `types.ts` | route definition types, permissions and roles |
| `lazy.ts` | lazy imports of every page |
| `config.ts` | route table: path, component, permissions |
| `router.tsx` | router assembly and guards |

Every page is lazy-loaded. Permissions are declared in the route
table, never checked ad hoc inside a page. Adding a screen means
adding a lazy import and a config entry, nothing else.

## Transversal components

`src/components/` holds what any module may use.

- `layout/` - shell of the application.
- `ui/` - primitives: select, checkbox, modal.
- `table/` - data table and pagination.
- one folder per larger widget.

These components know nothing about any module. A transversal
component that imports from `modules/` is misplaced.

### Contract of a reusable component

Follow the shape of the existing `DataTable`:

- Generic over its data type. Never typed to one entity.
- Fully controlled from outside: data, loading, pagination and every
  handler arrive as props. It holds only its own interaction state.
- Server-side by default for sorting, filtering and pagination -
  the component reports intent through callbacks and never fetches.
- A `skeleton` loading state and an explicit empty state, both
  configurable.
- Column behaviour declared as data (`sortable`, `filterable`,
  `align`, `draggable`), not as conditionals inside the component.
- User layout preferences persisted per table id, merged with the
  current column set so that a new column still appears for a user
  who has a saved order.
- Theming through CSS variables (`var(--text-01)`,
  `var(--border-01)`). No hardcoded colours.

Do not type column metadata as `any`. Declare the meta interface once
and use it in every table.

When a second variant is needed (grouped rows, tree rows), extract
the shared behaviour - column order, sorting, filtering, skeleton -
before copying the file. Two near-identical table implementations
diverge within a month.

## State

Zustand is the state container. React Context is not used for shared
state - only for genuinely static injection such as a theme provider
required by a library.

    src/store/<name>.store.ts              # app-wide
    modules/<module>/store/<module>.store.ts   # module-wide

**App-wide** is for state that outlives any single screen: session,
permissions, theme, layout. Nothing else qualifies.

**Module-wide** is for state that must survive navigation between
pages of the same module. If it dies with the screen, it is page
state and belongs in the page or a hook.

### Rules

- A store never calls `fetch`. It calls controllers, like a hook does.
  The data path stays `store -> controller -> model`.
- A store is not a cache for server data. Fetch, render, discard. Only
  promote to a store when two unrelated screens need the same live
  value.
- Components subscribe with selectors, never to the whole store:
  `useUserStore((s) => s.currentUser)`. Subscribing to the object
  re-renders on every unrelated change.
- Derive with selectors instead of storing computed values. Two
  fields that can disagree will disagree.
- Actions live in the store beside their state. A component never
  mutates state it does not own.
- Reset on logout is explicit. A stale store across sessions leaks
  one user's data into another's screen.

## Performance

The user downloads and computes only what the current screen needs.

### Code splitting

- Every page is lazy-loaded through `routes/lazy.ts`.
- Heavy module components are lazy too: editors, charts, file
  dropzones, anything pulling a large dependency. A modal that is
  rarely opened should not be in the initial bundle.
- Each lazy boundary has a `Suspense` fallback that matches the
  layout it replaces - a skeleton of the same shape, not a spinner.
  A fallback of a different size causes layout shift.
- Never lazy-load what is visible on first paint.

### Requests

- Debounce every input that triggers a request. 400ms is the
  project default, matching the data table.
- Debounced requests must be cancellable. Every in-flight request
  carries an `AbortSignal` and is aborted when superseded or when the
  component unmounts. Without this, debounce only reduces the number
  of requests, not the race between their responses.
- Never derive UI state from whichever response arrived last. Discard
  responses that no longer match the current query.
- No request inside a render path. Effects and event handlers only.

### Rendering

- Lists use stable domain keys. Never the array index for anything
  sortable, filterable or reorderable.
- `memo`, `useMemo` and `useCallback` are applied to a measured
  problem, not by default. Each one adds a dependency array that can
  go stale, which is a real bug traded for an imagined gain.
- Long lists are virtualised past a few hundred rows. Below that,
  pagination is simpler and already server-side.
- Import icons and utilities individually. A barrel import of an icon
  package pulls the whole set into the bundle.

## Module public API

`index.ts` exports what other parts of the app may use: components,
hooks, types. It does not export the model or the controllers.

If a page needs a controller directly, that is a missing hook or a
missing component, not a reason to widen the barrel.

## Review checklist

- [ ] No `fetch` or `axios` outside the api client and model.
- [ ] No React imports in `model/` or `controllers/`.
- [ ] Page imports modules through `index.ts` only.
- [ ] One controller per operation.
- [ ] Transversal components import nothing from `modules/`.
- [ ] Every page lazy-loaded and declared in the route config.
- [ ] Permissions declared in the route table, not inside pages.
- [ ] Reusable components generic and fully controlled.
- [ ] Loading and empty states handled explicitly.