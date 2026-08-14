# Presentation: Riverpod patterns

- **Space session as the single source of truth** ([Decision 9](../decisions/009-space-session-is-single-source-of-truth.md)): `spaceSessionProvider` is the root holding the shared state of the open space (root path, current branch, `GitStatus`, ahead/behind). Git operations write to the session; panels **derive** from it via `ref.watch` (+ `select`) — they never fetch space state on their own, and there is no scattered `ref.invalidate`. The `SpaceChanged` event from Decision 10 has a single recipient: the session reloads, and derived providers react. When multiple spaces or windows arrive, it becomes one session per space (a provider family) — the shape does not change.
- **One notifier per panel** (`GitPanelNotifier`, `EditorNotifier`, `ExplorerNotifier`), each with its own `*_state.dart` (Freezed) — explicit states: `initial / loading / data / error(AppFailure)`. Panel-local state (scroll, selection, commit message draft) stays in the notifier; shared state stays in the session.
- **`ref.watch` in build, `ref.read` in callbacks** — discipline already hardened by the author's experience with provider lifecycles.
- **No business logic in notifiers:** a notifier calls a use case and translates `Result` into state. That's it.

## The preview is assembled block by block

> How the panels sit on screen: [../design/](../design/).

Presentation receives an ordered list of blocks, not a document. Each block is rendered individually and wrapped in a container the app owns, and that container is what carries the diff decoration (added, removed, modified), the anchor for navigation and, later, per-block selection.

Rendering the document as one opaque widget tree would make the rendered diff — the reason the product exists — impossible to express, and would have to be undone at M2. Inline markdown *inside* a block is delegated to the markdown package, which is where CommonMark's real complexity lives; the app owns block-level layout only.

The seam has one known hazard, and it is a question for Spike B: reference links and footnotes are defined at document scope (`[foo]` in one place, `[foo]: url` at the bottom), so a block rendered in isolation loses them unless the document's reference map travels with it. See [08-domain-model.md](08-domain-model.md).
