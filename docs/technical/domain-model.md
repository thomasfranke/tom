# Domain model (emerging)

> **Partial, and deliberately so.** Several entities can only be settled by experiment — the shape of `Block` is an *output* of Spike B, not an input to it. What follows is what is **settled**, what is **open with the question formulated**, and how the gaps get filled. A partial, honest model is more useful than a complete, invented one.

Which DDD patterns apply here, and which are explicitly out: [Decision 15](decisions/015-ddd-is-applied-selectively.md).

## Settled

### `Space`

A local folder the user opened. The unit of everything: git queue, watcher, search index and session are all scoped per space ([Decision 9](decisions/009-space-session-is-single-source-of-truth.md)).

| Field | Type | Notes |
|---|---|---|
| `root` | path | Absolute path to the folder the user opened; the identity of the space |
| `repositoryRoot` | path | Absolute path to the enclosing Git repository — equal to `root` when the repository itself was opened, an ancestor when a subfolder was |
| `name` | string | Derived from the folder name unless configured otherwise |

The two paths are separate because most teams keep `docs/` inside the repository that holds the code. Git commands run against `repositoryRoot` and report paths relative to it; navigation, search and the watcher stay within `root`. Retrofitting this would touch git, the watcher, the index and wikilink resolution at once.

### `Document`

A single `.md` file inside a space. **The file on disk is the truth** — the entity is a view over it, never a cache that can diverge.

| Field | Type | Notes |
|---|---|---|
| `path` | path | Relative to the space root; the identity of the document |
| `content` | string | The raw markdown source |

### `SpaceRelativePath` · `RepoRelativePath`

The two halves of the split above, as types. `SpaceRelativePath` is what the file tree, the editor, the watcher and the search index speak; `RepoRelativePath` is what git reports and accepts. Both refuse `..`, an empty segment, a backslash and a drive letter — one rule, in one place — so that joining either onto its root cannot leave it.

`Space` is the only converter: `toRepoRelative` prefixes, `toSpaceRelative` strips and answers **null** for a path the space does not contain. Null is an ordinary answer, not a failure — git reports the whole repository, so a status on a space opened at `docs/` routinely names source files the tree does not show.

### `SpaceEntry`

One line of the file tree: a `SpaceRelativePath` and what lives at it — file, directory, or a link, reported as itself because a listing never follows one. Deliberately not a `Document`: a listing knows where things are, not what is in them, and reading every file of a space to draw its tree is work a documentation tool cannot afford.

### `GitStatus`

Parsed from `git status --porcelain=v2`: `branch`, `ahead`/`behind` against the tracked remote, `entries` — per-path state (modified / added / deleted / renamed / untracked / conflicted) — and `isDetached`.

`isDetached` is a field, not `branch == null`. A null `branch` has two causes: `HEAD` points at a commit, or git named a branch the parser could not read. Only the first is detachment, and showing the second as one would warn about a detached `HEAD` on a repository sitting on an ordinary branch.

### `Commit` · `Branch`

`Commit`: `sha`, `author`, `date`, `subject`, `body`, parsed from `git log` with an explicit format.
`Branch`: `name`, `isCurrent`, `upstream`.

`date` is a `CommitDate` — an instant in UTC plus the offset the author's clock stood at — not a `DateTime`. A `DateTime` cannot hold an offset: it reads `2026-09-20T01:44:01-03:00` and answers the instant `04:44:01Z`, so history would show the author's Saturday night as the reader's Sunday morning. The instant is what commits sort by; the offset is what a history row displays.

### `GitRepository`

The domain's git contract, fulfilled by `GitRepositoryImpl` in `tom_data` over the `GitClient` capability. Entities in, entities out — never process output: the implementation hands the text to a parser and the `GitClientFailure` to a translation that is exhaustive by construction. Every path on it is repository-relative, in both directions.

`GitFailure` gained two variants the capability could already report and the domain could not name: `pushRejected` (its own outcome, because the product shows it as one) and `timedOut`. `GitDetachedHead` is produced by no command — git commits happily on a detached `HEAD`; it is a state `status()` reports and a use case refuses to act on.

### `DocumentRepository` · `SpaceRepository`

Two contracts, one per space, because they fail differently: a document that cannot be read sends the user to another document (`DocumentFailure`), a folder that cannot be read sends them to another space (`SpaceFailure` — `folderMissing`, `accessDenied`, `operationFailed`). Both are fulfilled in `tom_data` over the `Filesystem` capability, which works in absolute paths and knows nothing about spaces; `Space` is what converts, in both directions, and holding one is what makes a repository belong to a space.

`SpaceRepository.entries()` carries the file tree's policy: **`.git/` is out and is never descended into**, every other dotfolder is in. Not descending is the load-bearing half — a recursive listing walks into `.git/` before anything can filter it, and a mature repository keeps more entries there than the product will ever show — so the walk goes one level at a time and decides before it descends. The result is depth-first and sorted, so a tree can be built by walking the list once.

### `DiffBlock`

The output of `BlockDiffer` and the reason the product exists: a block paired with a classification — `unchanged` · `added` · `removed` · `modified`. `modified` also carries the before and after sides, so the UI can render intra-block changes later (diff v2).

## Open — with the question formulated

### `Block` — the central unknown → **Spike B**

Our own entity, translated from the `markdown` package AST by a parser in `tom_data` ([Decision 7](decisions/007-external-dependencies-behind-contracts.md): the domain never sees a package type). What it contains determines what `BlockDiffer` can do. In order of consequence:

1. **Granularity.** Is a nested list item its own block, or part of the parent list? A table row, or the whole table? Fine granularity gives precise diffs but noisy alignment; coarse gives clean alignment but "the whole list changed".
2. **Source positions.** Does the AST expose offsets reliably? Without them, mapping a rendered block back to the source is guesswork.
3. **Raw text vs. structure.** Similarity comparison needs text; rendering needs structure; keeping both duplicates state.
4. **Identity.** Is there anything stable to identify a block across revisions (a heading path, a content hash), or is alignment purely positional + similarity?
5. **Isolated rendering.** Can one block be rendered given only its source? Reference links and footnotes are document-scoped, so a block alone loses them unless the reference map travels with it. This decides whether the preview can be assembled block by block ([flows](flows.md)).

**If the package cannot carry it**, two fallbacks in order: our own block-level parser (line-based rules for paragraph, heading, list, code fence and table, with inline delegated to the package, where CommonMark's real complexity lives); then, only if that fails, a Rust parser over `dart:ffi` ([Decision 13](decisions/013-stack-is-flutter-and-dart.md)), where `pulldown-cmark`, `comrak` and `markdown-rs` all expose source positions. A complete hand-written CommonMark parser is not on the list.

Until answered, `Block` stays a placeholder. **Do not design `BlockDiffer` before the spike reports.**

### Space configuration → settled for now: nothing is written

A space is "the folder, as is". The `.tom/` name is reserved so a future shared setting has an obvious home, but nothing is written there until something genuinely has to be shared across a team — a per-machine preference never qualifies. A file TOM writes into someone's repository becomes a compatibility obligation from its first release ([versioning](versioning.md)), and this product's whole claim is that it owns no format.

### Document loading → decide in **M0**

Does `Document` hold `content` for the whole session, or read on demand? Decide against a real 5k-line file once the editor runs. Related: what the entity looks like while dirty.

### `Wikilink` → **M3**

Not modelled yet. Open: how a link resolves (relative to the space? a filename anywhere in it? heading anchors?), and what happens when the target does not exist.

### Conflicted state → post-MVP

`GitStatus` already reports conflicted paths, but assisted resolution needs a richer model — per-block sides, the choice made. Deferred until the feature is built.

## How this gets filled in

By evidence, not by a design session: **Spike B** answers `Block`; **M0** answers document loading and dirty state; **M2** refines `DiffBlock`; **M3** brings `Wikilink`; the conflict model waits for post-MVP.

When a milestone or spike answers a question, move it from *Open* to *Settled* in the same PR that implements it, and delete the question. The document shrinks in uncertainty as it grows in content.
