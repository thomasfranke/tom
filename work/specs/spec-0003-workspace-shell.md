---
id: spec-0003
task_ref: task-0002
status: draft
created: 2026-09-19T21:41:35Z
---

# spec-0003 — Register the workspace panels behind the window shell

**References:** [task-0002](../tasks/task-0002-m0-foundation.md)

- **Goal:** Put the explorer, the document area and the status bar on screen at once, each one registered through `TomModule`/`PanelDescriptor` — the built-ins included, with nothing hardcoded in the shell.

## Scope

In: `TomModule` and `PanelDescriptor`; `runTom(modules: [])` as the entry point; slot resolution; the explorer's fixed width; window sizing and restore through `window_manager` behind an infra contract.

Out: what each panel renders — the tree, the preview and the status content have their own specs. The search panel is M2. Theming is M3.

## Steps

1. Define `TomModule` and `PanelDescriptor` in presentation, each descriptor naming the slot it claims.
2. Compose the shell in `apps/desktop` from registered descriptors only — the built-in panels register exactly as a third-party module would.
3. Wire `runTom(modules: [])` as the composition root's entry point.
4. Put window sizing and restore behind an infra contract implemented over `window_manager`.
5. Add an architecture test asserting the shell constructs no panel directly.

## Acceptance criteria (EARS)

- When the app starts with an empty module list, the system shall render the shell with no panels and no crash.
- When a module registers a panel descriptor, the system shall place that panel in the slot the descriptor names.
- When two descriptors claim one slot, the system shall fail at composition with a named error rather than silently rendering one of them.
- When the window is resized, the explorer shall keep the width `product/workspace/doc.md` fixes.

## Edge cases

- Zero modules, and a module registering two panels.
- A descriptor naming a slot the shell does not offer.
- A window restored smaller than the shell's minimum.
- A module whose construction throws — the shell must name it, not die anonymously.

## Tests required

Widget tests for slot placement and for the duplicate-slot failure. A pure-Dart test over the descriptor registry. An architecture test in `src/test/architecture_test.dart` asserting no panel is constructed outside registration.

## Definition of Done

- [ ] The three built-in panels reach the screen only through registration.
- [ ] The architecture test fails if a panel is hardcoded back into the shell.
- [ ] `runTom(modules: [])` starts and renders an empty shell.

## Proposed product changes

- `product/workspace/doc.md` — move the status off Planned and state the layout as shipped.

## Proposed technical changes

- `technical/flows.md#panels-are-registered-never-hardcoded` — record the registry as built, including how a slot collision fails.
- `technical/layers.md#what-enforces-it` — add the architecture test that keeps panels out of the shell.

## Outcome

_(fill after execution)_
