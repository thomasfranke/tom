# Presentation: Riverpod patterns

- **Space session as the single source of truth** ([Decision 9](../decisions/009-space-session-is-single-source-of-truth.md)): `spaceSessionProvider` is the root holding the shared state of the open space (root path, current branch, `GitStatus`, ahead/behind). Git operations write to the session; panels **derive** from it via `ref.watch` (+ `select`) — they never fetch space state on their own, and there is no scattered `ref.invalidate`. The `SpaceChanged` event from Decision 10 has a single recipient: the session reloads, and derived providers react.
- **One notifier per panel** (`GitPanelNotifier`, `EditorNotifier`, `ExplorerNotifier`), each with its own `*_state.dart` (Freezed) — explicit states: `initial / loading / data / error(AppFailure)`. Panel-local state (scroll, selection, commit message draft) stays in the notifier; shared state stays in the session.
- **`ref.watch` in build, `ref.read` in callbacks** — discipline already hardened by the author's experience with provider lifecycles.
- **No business logic in notifiers:** a notifier calls a use case and translates `Result` into state. That's it.
