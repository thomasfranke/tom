# Decision 12 — The shell is extensible through compile-time modules

**Status:** accepted

## Context

Dart compiles AOT: nothing is loaded at runtime, so composition happens at build time. Whatever extension mechanism this app has, it has to be decided early — a panel wired directly into the shell widget is cheap to write and expensive to unpick, and by the time there is a reason to extend the app, the shell has usually grown a dozen of them.

Separately, an application that hardcodes its own panels has no way to accept anyone else's.

## Decision

1. **A public extension contract, from M0.** The app exposes `TomModule` (panels, provider overrides, commands) and a `runTom(modules: [...])` entrypoint. Panels are registered through descriptors, never hardcoded in the shell.
2. **The built-in panels go through the same mechanism.** Explorer, editor, diff and git are registered by an internal `CoreModule`, not by the shell. One path for everything, so the mechanism cannot rot from disuse — it is exercised on every run of the app.
3. **One direction.** A module depends on the app and the core; the app never imports a module. `main.dart` calls `runTom(modules: [])`: clone it, build it, it works.
4. **The mechanism ships in M0 even with nothing to load.** `runTom` plus descriptors from the very first shell.

## Rationale

- It is [Decision 7](007-external-dependencies-behind-contracts.md) turned on the application itself: anything that extends the app is reached through a contract and stays isolated behind it.
- A public contract is a feature rather than a side effect — a third party can add a panel without forking and without asking.
- Cost of being born extensible: hours. Cost of retrofitting a monolithic shell: weeks.

## Consequences

- Contract and panel-registration templates: [flows.md](../architecture/flows.md#panels-are-registered-never-hardcoded).
- M0 gains the "extensible shell" item.
- A feature flag guards **registration**, not rendering ([feature flags](../../CONTRIBUTING.md#feature-flags)): a disabled panel is never registered, so it is unreachable rather than merely invisible.
- Changing `TomModule` so that an existing module stops compiling is a breaking change ([versioning](../process/versioning.md)).
