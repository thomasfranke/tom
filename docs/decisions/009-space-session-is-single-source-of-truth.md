# Decision 9 — The space session is the single source of truth in presentation

**Status:** accepted

## Context
The panels (explorer, editor, diff, git) are all views over the same open repo. If each notifier fetched its own state independently, post-operation coordination (a commit affects status, history, the file tree and the open document) would become hand-rolled cascading invalidation — a well-known and hard-to-trace class of bug.

## Decision
A **root session provider** (`spaceSessionProvider`) is the single source of truth for the open space in presentation: it holds the space (root path), current branch, `GitStatus`, ahead/behind and sync state.

- **Panel notifiers derive from the root** via `ref.watch` (with `select` for minimal rebuilds) — they never fetch space state on their own.
- **Git operations write to the root:** notifiers call use cases, but the resulting update (new status, new branch) enters through the session, and panels react by derivation — not through scattered `ref.invalidate`.
- **Panel-local state** (scroll, text selection, commit message draft) stays in the panel's notifier — the root only carries what is shared.
- Multiple windows/spaces in the future: one session per space (family).

## Rationale
- Removes coordination by cascading invalidation; Riverpod's dependency graph does the propagation.
- Since Riverpod is restricted to presentation (Decision 7, Tier 3), coordination between panels is presentation's responsibility — the session is the idiomatic mechanism.
- Mirrors the "one root feeds consumers" pattern already validated in the author's experience.

## Consequences
- The single "space changed" event from Decision 10 has a clear recipient: the session reloads status and derived providers react.
- Testing panel notifiers: providing a fake session is enough.
