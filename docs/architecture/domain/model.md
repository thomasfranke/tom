# Domain model (emerging)

> **Status: partial and deliberately so.** The product's rules are still forming, and several entities can only be settled by experiment rather than by design — the shape of `Block`, in particular, is an *output* of Spike B, not an input to it.
>
> This document has three parts: what is **settled** (the architecture already depends on it), what is **open with the question formulated** (so the spike or milestone that answers it knows what it is looking for), and how the document is filled in over time. A partial, honest model is more useful than a complete, invented one.

## Settled

### `Space`

A local folder that is a Git repository, opened by the user. The unit of everything: git queue, watcher, search index and session are all scoped per space ([Decision 9](../../decisions/009-space-session-is-single-source-of-truth.md)).

| Field | Type | Notes |
|---|---|---|
| `root` | path | Absolute path to the folder the user opened; the identity of the space |
| `repositoryRoot` | path | Absolute path to the enclosing Git repository — equal to `root` when the repository itself was opened, an ancestor of it when a subfolder was |
| `name` | string | Derived from the folder name unless configured otherwise |

The two paths are separate because most teams keep `docs/` inside the repository that holds the code. Git commands run against `repositoryRoot` and report paths relative to it; navigation, search and the watcher stay within `root`. Modelling this from the start is deliberate: retrofitting it would touch git, the watcher, the index and wikilink resolution at once.

### `Document`

A single `.md` file inside a space. **The file on disk is the truth** — the entity is a view over it, never a cache that can diverge.

| Field | Type | Notes |
|---|---|---|
| `path` | path | Relative to the space root; the identity of the document |
| `content` | string | The raw markdown source |

### `GitStatus`

The state of the working tree, parsed from `git status --porcelain=v2`.

| Field | Type | Notes |
|---|---|---|
| `branch` | string | Current branch |
| `ahead` / `behind` | int | Relative to the tracked remote |
| `entries` | list | Per-path state: modified / added / deleted / renamed / untracked / conflicted |

### `Commit`

| Field | Type | Notes |
|---|---|---|
| `sha` | string | |
| `author`, `date`, `subject`, `body` | | Parsed from `git log` with an explicit format |

### `Branch`

| Field | Type | Notes |
|---|---|---|
| `name` | string | |
| `isCurrent` | bool | |
| `upstream` | string? | Tracked remote branch, if any |

### `DiffBlock`

The output of `BlockDiffer` and the reason the product exists. A block paired with a classification:

- `unchanged` · `added` · `removed` · `modified`
- `modified` additionally carries the "before" and "after" sides, so the UI can render intra-block changes later (diff v2).

## Open — with the question formulated

### `Block` — the central unknown → **Spike B**

`Block` is our own entity translated from the `markdown` package AST by `data/parsers/markdown_block_parser.dart` ([Decision 7](../../decisions/007-external-dependencies-behind-contracts.md): the domain never sees a package type). What it *contains* determines what `BlockDiffer` can do. Questions the spike must answer, in order of consequence:

1. **Granularity.** Is a nested list item its own block, or part of the parent list block? A table row, or the whole table? The trade-off: fine granularity gives precise diffs but noisy alignment; coarse granularity gives clean alignment but "the whole list changed" diffs.
2. **Source positions.** Does the AST expose offsets/line numbers reliably? Without them, mapping a rendered block back to the source for editing and for diff v0 is guesswork.
3. **Raw text vs. structure.** Does a block keep its raw markdown, its parsed children, or both? Similarity comparison (v1) needs text; rendering needs structure; keeping both duplicates state.
4. **Identity.** Is there anything stable to identify a block across revisions (a heading path, a hash of content), or is alignment purely positional + similarity?
5. **Isolated rendering.** Can one block be rendered on its own, given only its source text? Reference links and footnotes are defined at document scope (`[foo]` in one place, `[foo]: url` at the bottom), so a block rendered alone loses them unless the document's reference map travels with it. This is what decides whether the preview can be assembled block by block ([06-presentation.md](../presentation/state.md)) — which is what the rendered diff needs in order to decorate blocks individually.

**If the package cannot carry it**, two fallbacks in order. First, our own block-level parser — line-based rules for paragraph, heading, list, code fence and table, a few dozen cases — with inline delegated to the package, which is where CommonMark's real complexity lives. Second, and only if that also fails, a Rust parser reached over `dart:ffi` ([Decision 13](../../decisions/013-stack-is-flutter-and-dart.md)), where `pulldown-cmark`, `comrak` and `markdown-rs` all expose source positions. A complete hand-written CommonMark parser is not on the list: hundreds of rules and edge cases for no gain.

Until answered, `Block` stays a placeholder. **Do not design `BlockDiffer` before the spike reports.**

### Space configuration → settled for now: nothing is written

A space is "the folder, as is". The `.tom/` directory name is reserved so a future shared setting has an obvious home, but nothing is written there until one genuinely has to be shared across a team — and a per-machine preference never qualifies. The restraint has a reason, in [versioning.md](../../process/versioning.md): a file TOM writes into someone's repository becomes a compatibility obligation from its first release, and this product's whole claim is that it owns no format.

### Document loading → decide in **M0**

Does `Document` hold `content` in memory for the whole session, or read on demand? Decide with a real large file (a 5k-line markdown doc) once the editor is running. Related: what the entity looks like while dirty (unsaved edits) versus clean.

### `Wikilink` → **M3**

Not modelled yet. Open: how a link resolves (path relative to the space? filename anywhere in the space? heading anchors?), and what happens to a link whose target does not exist.

### Conflicted state → post-MVP

`GitStatus` already reports conflicted paths, but assisted conflict resolution needs a richer model (per-block sides, the choice made). Deferred until the feature is built.

## How this document gets filled in

The model is completed by evidence, not by a design session:

| Source of answers | Fills in |
|---|---|
| **Spike B** | `Block` — every question above, and how the preview is assembled |
| **M0** | `Document` loading and dirty state |
| **M2** | `DiffBlock` refinements once v1 is real |
| **M3** | `Wikilink` |
| **Post-MVP** | Conflict model |

When a milestone or spike answers a question, move it from *Open* to *Settled* in the same PR that implements it, and delete the question. The document shrinks in uncertainty as it grows in content.
