# Infrastructure and data patterns

## Git: serialized executor

Every git operation on a space goes through the `GitClientInterface` implementation, which **serializes execution in a queue** (the same philosophy as the operation-queue pattern the author validated for SQLite in a previous app):

- Prevents races (`commit` during `checkout`, two simultaneous `fetch`es)
- A single place for timeout, logging and `exit code + stderr → GitFailure` translation
- One runner per space; different spaces run in parallel

## Filesystem: the watcher and external edits ([Decision 10](../decisions/010-watcher-and-git-cooperate-by-protocol.md))

External editing (VS Code open alongside) is an **expected use case, not an error** — but the watcher and git operations interfere with each other, so cooperation is an explicit protocol, never a coincidence:

- **Silencing during git operations:** the git client pauses the watcher before mutating commands and emits **a single `SpaceChanged` event** at the end (a `checkout` changes dozens of files; reacting file by file is a race)
- **Echo suppression:** the app registers the path of its own saves; watcher events for those paths are discarded
- **Debounce** (~100–300ms) consolidating bursts from external editors before propagating
- **One queue per space:** watcher pause/resume enters the same serialized queue as git operations, guaranteeing order
- Open document changed externally with no local edits → reloads silently; with concurrent local edits → `ExternalChangeConflict` and the UI offers a choice (standard desktop-editor behavior)

## Search: the index as a disposable cache

FTS5 (SQLite) indexes the content of the `.md` files. Absolute rule: **the index never holds state that does not exist on disk**. Corrupted, deleted, schema changed → rebuild from scratch by reading the files. This eliminates an entire class of synchronization bugs.

## The rendered diff (incremental evolution)

1. **v0 — line diff over the preview:** classic textual diff (Myers) mapped onto the rendered blocks containing each hunk. Fast to ship, already better than current tools.
2. **v1 — block diff:** parse both sides into blocks (paragraph, heading, list item, code block), align by similarity, classify as unchanged/added/removed/modified. This is the heart of `domain/services/block_differ.dart` (pure business rule — see [03-repository-structure.md](03-repository-structure.md)).
3. **v2 — intra-block diff:** word-level ins/del inside modified blocks.

A parsing and tree-comparison problem — **testable with golden files, no UI involved**: pairs of md files + expected diff as JSON, running in CI.
