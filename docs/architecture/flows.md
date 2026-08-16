# Flows

How the layers behave at runtime. The static picture is in [layers.md](layers.md).

## Git, in three conceptual layers

1. **Open a folder.** The user opens a local folder that already is a Git repository. No server, no account, no import. A folder with no repository → offer `git init`, or run degraded (editing and preview only).
2. **Drive the `git` binary** — the real integration ([Decision 2](../decisions/002-git-via-system-binary.md)). `Process.run` over `status --porcelain=v2`, `log`, `diff`, `add/commit/push/pull`, `switch`, and parse the output. Credentials, SSH and config come for free: it is the user's own git running. Zero authentication implemented.
3. **Remote APIs** (post-MVP). Pull requests, reviews, OAuth clone through GitHub/GitLab REST. Only after the core is validated.

## One serialized queue per space

Every git operation goes through the `GitClient` implementation, which **serializes execution in a queue**:

- prevents races — a commit during a checkout, two simultaneous fetches;
- gives timeout, logging and `exit code + stderr → GitClientFailure` a single home;
- one runner per space, so different spaces still run in parallel.

## The watcher and git cooperate by protocol

External editing — VS Code open alongside — is an expected use case, not an error. The watcher and git interfere with each other, so the cooperation is explicit ([Decision 10](../decisions/010-watcher-and-git-cooperate-by-protocol.md)):

- **Silence during git operations.** The client pauses the watcher before mutating commands and emits a single `SpaceChanged` at the end. A checkout touches dozens of files; reacting file by file is a race.
- **Echo suppression.** The app registers the paths of its own saves and discards watcher events for them.
- **Debounce** (~100–300 ms) consolidates the bursts external editors produce.
- **Same queue.** Pause and resume enter the serialized queue above, which is what guarantees ordering.
- Document changed on disk with no local edits → reloads silently. With local edits → `ExternalChangeConflict`, and the UI offers the choice.

## The rendered diff, layer by layer

```
tom_desktop      the panel asks the notifier for the diff of the open document
tom_presentation the notifier calls the use case, turns Result into state
tom_application  ComputeRenderedDiff orchestrates repository + BlockDiffer
tom_data         DocumentRepositoryImpl reads HEAD and the working tree
tom_infra        GitClient runs `git show`, FileSystem reads the file
tom_domain       BlockDiffer classifies blocks: added, removed, modified
tom_core         every step returns Result<T>; failures are typed
```

Each layer talks only to the one below it, and the direction never inverts. `tom_domain` sits at the bottom of the call and knows nothing about how the bytes arrived.

It ships in three steps:

1. **v0 — line diff over the preview.** Myers over the text, hunks mapped onto the rendered blocks that contain them. Fast, and already better than what the alternatives show.
2. **v1 — block diff.** Parse both sides into blocks, align by similarity, classify as unchanged/added/removed/modified. This is `BlockDiffer`, the one real domain service.
3. **v2 — intra-block diff.** Word-level insert/delete inside modified blocks.

A parsing and tree-comparison problem, testable with golden files and no UI involved.

## Search: the index is a disposable cache

FTS5 indexes the content of the `.md` files. Absolute rule: **the index never holds state that does not exist on disk.** Corrupted, deleted, schema changed → rebuild by reading the files again. That is what removes an entire class of synchronisation bugs, and why `IndexCorrupted` is a recoverable failure rather than data loss.

## The space session is the single source of truth

- One session per open space holds what the whole app shares: root, current branch, `GitStatus`, ahead/behind ([Decision 9](../decisions/009-space-session-is-single-source-of-truth.md)). Git operations write to it; panels **derive** from it. No scattered `ref.invalidate`.
- `SpaceChanged` has a single recipient: the session reloads, and everything derived reacts.
- **One notifier per panel**, with explicit states — `initial / loading / data / error(AppFailure)`. Panel-local state (scroll, selection, a commit message being typed) stays in the notifier; shared state stays in the session.
- **No business logic in a notifier**: it calls a use case and turns `Result` into state. That is all.
- `ref.watch` in build, `ref.read` in callbacks.

## The preview is assembled block by block

Presentation receives an ordered list of blocks, not a document. Each is rendered on its own and wrapped in a container the app owns — and that container is what carries the diff decoration, the navigation anchor and, later, per-block selection.

Rendering the document as one opaque widget tree would make the rendered diff impossible to express and would have to be undone at M2. Inline markdown *inside* a block is delegated to the markdown package, where CommonMark's real complexity lives; the app owns block-level layout only.

Known hazard, and a question for Spike B: reference links and footnotes are defined at document scope, so a block rendered in isolation loses them unless the document's reference map travels with it ([domain model](domain-model.md)).

## Panels are registered, never hardcoded

The shell is extensible through compile-time modules from M0, even with no module existing yet ([Decision 12](../decisions/012-shell-is-extensible-via-compile-time-modules.md)). A `TomModule` contributes panels (`PanelDescriptor`: id, title, builder, placement) and provider overrides; `runTom(modules: [...])` collects them, builds the `ProviderScope` and starts the shell. The built-in panels go through exactly the same path — that is what keeps the extension point real.

Modules **add**; they never change or degrade what the app already does, and none of them may need the network to start.

## Wiring: three lifetimes

The composition root only instantiates and wires — zero logic, and `ref.watch` rather than `ref.read` while wiring.

| Lifetime | What | Mechanism |
|---|---|---|
| **App** | parsers, `BlockDiffer`, `Observability`, config | `keepAlive` |
| **Space** | `GitClient` (the queue is per space), watcher, FTS5 index, the session | a `family` keyed by the space root; disposal tears down watcher and connections when the space closes |
| **Transient** | use cases | default; lightweight objects created on demand |

Per-space scoping is the point: a git queue or a sqlite connection that floats free instead of belonging to a space is an entire class of "closed resource" bugs, solved here by construction.
