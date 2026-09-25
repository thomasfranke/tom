# State: the space session and the notifiers

## The space session is the single source of truth

- One session per open space holds what the whole app shares: root, current
  branch, `GitStatusValueObject`, ahead/behind
  ([Decision 9](../decisions/009-space-session-is-single-source-of-truth.md)).
  Git operations write to it; panels **derive** from it. No scattered
  `ref.invalidate`.
- `SpaceChanged` has a single recipient: the session reloads, and everything
  derived reacts.

## One notifier per panel

- Explicit states — `initial / loading / data / error(AppFailure)`.
  Panel-local state (scroll, selection, a commit message being typed) stays in
  the notifier; shared state stays in the session.
- **No business logic in a notifier**: it calls a use case and turns `Result`
  into state. That is all.
- `ref.watch` in build, `ref.read` in callbacks.

---

*See also: [composition.md](composition.md) · [git.md](git.md)*
