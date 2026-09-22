# Domain model (emerging)

> **Partial, and deliberately so.** Several types here can only be settled by experiment, never by a design session — `BlockValueObject` was the largest of them, and it is now settled by measurement rather than by argument ([Decision 19](decisions/019-blocks-come-from-the-markdown-package.md)). What follows is what is **settled**, what is **open with the question formulated**, and how the gaps get filled. A partial, honest model is more useful than a complete, invented one.

Which DDD patterns apply here, and which are explicitly out: [Decision 15](decisions/015-ddd-is-applied-selectively.md).

## Settled

Every type here says which of the two kinds it is, because they are not the
same thing: an **entity** has an identity that outlives its values, a **value
object** is wholly what it carries ([layers.md](layers.md#inside-a-package)).

### `SpaceEntity`

A local folder the user opened. The unit of everything: git queue, watcher, search index and session are all scoped per space ([Decision 9](decisions/009-space-session-is-single-source-of-truth.md)).

| Field | Type | Notes |
|---|---|---|
| `root` | path | Absolute path to the folder the user opened; the identity of the space |
| `repositoryRoot` | path | Absolute path to the enclosing Git repository — equal to `root` when the repository itself was opened, an ancestor when a subfolder was |
| `name` | string | Derived from the folder name unless configured otherwise |

The two paths are separate because most teams keep `docs/` inside the repository that holds the code. Git commands run against `repositoryRoot` and report paths relative to it; navigation, search and the watcher stay within `root`. Retrofitting this would touch git, the watcher, the index and wikilink resolution at once.

### `DocumentEntity`

A single `.md` file inside a space. **The file on disk is the truth** — the entity is a view over it, never a cache that can diverge.

| Field | Type | Notes |
|---|---|---|
| `path` | path | Relative to the space root; the identity of the document |
| `content` | string | The raw markdown source |

### `ParsedDocumentValueObject`

A document once it has been split: the `DocumentEntity` it came from, its `BlockValueObject`s in order, and `linkDefinitions` — every link reference definition as its own lines.

The definitions are the price of rendering a block on its own. They are declared at document scope, so a block holding `[text][ref]` and nothing else would draw the brackets; appending them to the block's source resolves it. Footnotes do not survive the same way, which is M2's problem and stated in [Decision 19](decisions/019-blocks-come-from-the-markdown-package.md).

They travel here and not on `BlockValueObject` for two reasons: the table above is the block's whole shape, and a copy on every block is the same string as many times as the document has blocks.

### `SpaceRelativePathValueObject` · `RepoRelativePathValueObject`

The two halves of the split above, as types. `SpaceRelativePathValueObject` is what the file tree, the editor, the watcher and the search index speak; `RepoRelativePathValueObject` is what git reports and accepts. Both refuse `..`, an empty segment, a backslash and a drive letter — one rule, in one place — so that joining either onto its root cannot leave it.

`SpaceEntity` is the only converter: `toRepoRelative` prefixes, `toSpaceRelative` strips and answers **null** for a path the space does not contain. Null is an ordinary answer, not a failure — git reports the whole repository, so a status on a space opened at `docs/` routinely names source files the tree does not show.

### `SpaceEntryValueObject`

One line of the file tree: a `SpaceRelativePathValueObject` and what lives at it — file, directory, or a link, reported as itself because a listing never follows one. Deliberately not a `DocumentEntity`: a listing knows where things are, not what is in them, and reading every file of a space to draw its tree is work a documentation tool cannot afford.

### `GitStatusValueObject`

Parsed from `git status --porcelain=v2`: `branch`, `ahead`/`behind` against the tracked remote, `entries` — per-path state (modified / added / deleted / renamed / untracked / conflicted) — and `isDetached`.

`isDetached` is a field, not `branch == null`. A null `branch` has two causes: `HEAD` points at a commit, or git named a branch the parser could not read. Only the first is detachment, and showing the second as one would warn about a detached `HEAD` on a repository sitting on an ordinary branch.

### `CommitEntity` · `BranchEntity`

`CommitEntity`: `sha`, `author`, `date`, `subject`, `body`, parsed from `git log` with an explicit format.
`BranchEntity`: `name`, `isCurrent`, `upstream`.

`date` is a `CommitDateValueObject` — an instant in UTC plus the offset the author's clock stood at — not a `DateTime`. A `DateTime` cannot hold an offset: it reads `2026-09-20T01:44:01-03:00` and answers the instant `04:44:01Z`, so history would show the author's Saturday night as the reader's Sunday morning. The instant is what commits sort by; the offset is what a history row displays.

### `GitRepository`

The domain's git contract, fulfilled by `GitRepositoryImpl` in `tom_data` over the `GitClient` capability. Entities in, entities out — never process output: the implementation hands the text to a parser and the `GitClientFailure` to a translation that is exhaustive by construction. Every path on it is repository-relative, in both directions.

`GitFailure` gained two variants the capability could already report and the domain could not name: `pushRejected` (its own outcome, because the product shows it as one) and `timedOut`. `GitDetachedHead` is produced by no command — git commits happily on a detached `HEAD`; it is a state `status()` reports and a use case refuses to act on.

### `DocumentRepository` · `SpaceRepository`

Two contracts, one per space, because they fail differently: a document that cannot be read sends the user to another document (`DocumentFailure`), a folder that cannot be read sends them to another space (`SpaceFailure` — `folderMissing`, `accessDenied`, `operationFailed`). Both are fulfilled in `tom_data` over the `Filesystem` capability, which works in absolute paths and knows nothing about spaces; `SpaceEntity` is what converts, in both directions, and holding one is what makes a repository belong to a space.

`SpaceRepository.entries()` carries the file tree's policy: **`.git/` is out and is never descended into**, every other dotfolder is in. Not descending is the load-bearing half — a recursive listing walks into `.git/` before anything can filter it, and a mature repository keeps more entries there than the product will ever show — so the walk goes one level at a time and decides before it descends. The result is depth-first and sorted, so a tree can be built by walking the list once.

### `BlockValueObject`

**Settled by [Spike B](decisions/019-blocks-come-from-the-markdown-package.md).** A block is *where it is, what it says, and what kind of thing it is* — not a package AST node, which could not cross into the domain anyway ([Decision 7](decisions/007-external-dependencies-behind-contracts.md)).

| Field | Type | Notes |
|---|---|---|
| `startLine` · `endLine` | int | Zero-based, inclusive, into the document's lines. Recovered from the parser, which does not report them — see the decision for how, and for why it is subclasses rather than wrappers |
| `source` | string | The document's own lines for that span. A slice, not a second copy: raw text and structure without duplicated state |
| `kind` | enum | paragraph · heading · list · table · code · quote · rule · html |

**Granularity is top level.** A list is one block and a table is one block. Measured over this repository: 848 blocks across 2277 lines, 668 of them a single line, none longer than 20. Sub-block granularity is a diff v2 question and starts from here.

**There is no identity.** A heading path is not one — 288 distinct paths for 848 blocks, 285 of them holding more than one block — so `BlockDiffer` aligns by position and similarity, and may use the heading path only as a coarse bucket. This is the constraint that shapes the differ.

**Structure is re-derived, not stored.** Parsing a block's span costs nothing measurable (0–3% over a plain parse for the whole document), so a block that needs rendering is parsed then, with the document's link reference map in scope.

**One construct does not survive isolation: footnotes.** A block carrying `[^ref]` renders it as literal text, because the definition is another block and the reference map does not carry it. Reference links do survive, because `linkReferences` can travel with the block. The parser also synthesises a footnotes `section` node that corresponds to no lines at all, so a block list must tolerate a node with no span. What to do about footnotes is M2's, not settled here.

### `DiffBlock`

The output of `BlockDiffer` and the reason the product exists: a block paired with a classification — `unchanged` · `added` · `removed` · `modified`. `modified` also carries the before and after sides, so the UI can render intra-block changes later (diff v2).

## Open — with the question formulated

### Space configuration → settled for now: nothing is written

A space is "the folder, as is". The `.tom/` name is reserved so a future shared setting has an obvious home, but nothing is written there until something genuinely has to be shared across a team — a per-machine preference never qualifies. A file TOM writes into someone's repository becomes a compatibility obligation from its first release ([versioning](versioning.md)), and this product's whole claim is that it owns no format.

### Document loading → decide in **M0**

Does `DocumentEntity` hold `content` for the whole session, or read on demand? Decide against a real 5k-line file once the editor runs. Related: what the entity looks like while dirty.

### `Wikilink` → **M3**

Not modelled yet. Open: how a link resolves (relative to the space? a filename anywhere in it? heading anchors?), and what happens when the target does not exist.

### Conflicted state → post-MVP

`GitStatusValueObject` already reports conflicted paths, but assisted resolution needs a richer model — per-block sides, the choice made. Deferred until the feature is built.

## How this gets filled in

By evidence, not by a design session: **Spike B** answered `BlockValueObject` ([Decision 19](decisions/019-blocks-come-from-the-markdown-package.md)); **M0** answers document loading and dirty state; **M2** refines `DiffBlock`; **M3** brings `Wikilink`; the conflict model waits for post-MVP.

When a milestone or spike answers a question, move it from *Open* to *Settled* in the same PR that implements it, and delete the question. The document shrinks in uncertainty as it grows in content.
