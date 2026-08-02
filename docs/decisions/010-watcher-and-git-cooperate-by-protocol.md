# Decision 10 — The watcher and git operations cooperate by an explicit protocol

**Status:** accepted

## Context
The filesystem watcher exists to reflect external edits (VS Code open alongside is an expected use case). But three kinds of interference produce nasty bugs unless handled by design:
1. **Echo of our own save** — the app writes a file and the watcher notifies the app about its own write.
2. **Storm during git operations** — a `checkout`/`pull` changes dozens of files in milliseconds; reacting file by file is both a race and a waste.
3. **Event bursts** — external editors save through multiple events (write + temporary rename).

## Decision
The filesystem contract and the git client contract cooperate through an explicit protocol:

1. **Silence during git operations:** the `GitClientInterface` implementation **pauses the watcher before** running any mutating command and, at the end, **emits a single `SpaceChanged` event** (granularity: the space, not the file). The session (Decision 9) reloads state in one go.
2. **Echo suppression:** every save by the app registers its path in an in-flight write list; watcher events for registered paths are discarded (with a short expiry window).
3. **Debounce:** external events are grouped (~100–300ms) before propagating; what reaches the session is "these paths changed", already consolidated.
4. **One queue per space:** git operations are already serialized (queue-based executor); the watcher's pause/resume enters the same queue, guaranteeing ordering.

## Rationale
Concurrency between subsystems is never solved by chance — it is solved by a documented protocol (a lesson learned the hard way: lifecycle + concurrency require serialization and single points of coordination).

## Consequences
- The watcher ↔ git client coupling is **deliberate and documented** — both are infrastructure and cooperation happens through contracts (`FileSystemInterface.pauseWatching()/resumeWatching()`), without leaking to upper layers.
- Presentation never sees a raw file event: it sees the session change.
- Testable in integration: temporary repo + git operation + assertion that exactly one consolidated event was emitted.
