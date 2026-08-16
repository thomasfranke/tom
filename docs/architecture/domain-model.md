# Domain model (emerging)

> **Partial, and deliberately so.** Several entities can only be settled by experiment — the shape of `Block` is an *output* of Spike B, not an input to it. What follows is what is **settled**, what is **open with the question formulated**, and how the gaps get filled. A partial, honest model is more useful than a complete, invented one.

Which DDD patterns apply here, and which are explicitly out: [Decision 15](../decisions/015-ddd-is-applied-selectively.md).

## Settled

### `Space`

A local folder the user opened. The unit of everything: git queue, watcher, search index and session are all scoped per space ([Decision 9](../decisions/009-space-session-is-single-source-of-truth.md)).

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

### `GitStatus`

Parsed from `git status --porcelain=v2`: `branch`, `ahead`/`behind` against the tracked remote, and `entries` — per-path state (modified / added / deleted / renamed / untracked / conflicted).

### `Commit` · `Branch`

`Commit`: `sha`, `author`, `date`, `subject`, `body`, parsed from `git log` with an explicit format.
`Branch`: `name`, `isCurrent`, `upstream`.

### `DiffBlock`

The output of `BlockDiffer` and the reason the product exists: a block paired with a classification — `unchanged` · `added` · `removed` · `modified`. `modified` also carries the before and after sides, so the UI can render intra-block changes later (diff v2).

## Open — with the question formulated

### `Block` — the central unknown → **Spike B**

Our own entity, translated from the `markdown` package AST by a parser in `tom_data` ([Decision 7](../decisions/007-external-dependencies-behind-contracts.md): the domain never sees a package type). What it contains determines what `BlockDiffer` can do. In order of consequence:

1. **Granularity.** Is a nested list item its own block, or part of the parent list? A table row, or the whole table? Fine granularity gives precise diffs but noisy alignment; coarse gives clean alignment but "the whole list changed".
2. **Source positions.** Does the AST expose offsets reliably? Without them, mapping a rendered block back to the source is guesswork.
3. **Raw text vs. structure.** Similarity comparison needs text; rendering needs structure; keeping both duplicates state.
4. **Identity.** Is there anything stable to identify a block across revisions (a heading path, a content hash), or is alignment purely positional + similarity?
5. **Isolated rendering.** Can one block be rendered given only its source? Reference links and footnotes are document-scoped, so a block alone loses them unless the reference map travels with it. This decides whether the preview can be assembled block by block ([flows](flows.md)).

**If the package cannot carry it**, two fallbacks in order: our own block-level parser (line-based rules for paragraph, heading, list, code fence and table, with inline delegated to the package, where CommonMark's real complexity lives); then, only if that fails, a Rust parser over `dart:ffi` ([Decision 13](../decisions/013-stack-is-flutter-and-dart.md)), where `pulldown-cmark`, `comrak` and `markdown-rs` all expose source positions. A complete hand-written CommonMark parser is not on the list.

Until answered, `Block` stays a placeholder. **Do not design `BlockDiffer` before the spike reports.**

### Space configuration → settled for now: nothing is written

A space is "the folder, as is". The `.tom/` name is reserved so a future shared setting has an obvious home, but nothing is written there until something genuinely has to be shared across a team — a per-machine preference never qualifies. A file TOM writes into someone's repository becomes a compatibility obligation from its first release ([versioning](../process/versioning.md)), and this product's whole claim is that it owns no format.

### Document loading → decide in **M0**

Does `Document` hold `content` for the whole session, or read on demand? Decide against a real 5k-line file once the editor runs. Related: what the entity looks like while dirty.

### `Wikilink` → **M3**

Not modelled yet. Open: how a link resolves (relative to the space? a filename anywhere in it? heading anchors?), and what happens when the target does not exist.

### Conflicted state → post-MVP

`GitStatus` already reports conflicted paths, but assisted resolution needs a richer model — per-block sides, the choice made. Deferred until the feature is built.

## How this gets filled in

By evidence, not by a design session: **Spike B** answers `Block`; **M0** answers document loading and dirty state; **M2** refines `DiffBlock`; **M3** brings `Wikilink`; the conflict model waits for post-MVP.

When a milestone or spike answers a question, move it from *Open* to *Settled* in the same PR that implements it, and delete the question. The document shrinks in uncertainty as it grows in content.
