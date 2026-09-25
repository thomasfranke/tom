# Documents: the preview and the rendered diff

## The preview is assembled block by block

Presentation receives an ordered list of blocks, not a document. Each is
rendered on its own and wrapped in a container the app owns — and that
container is what carries the diff decoration, the navigation anchor and,
later, per-block selection.

Rendering the document as one opaque widget tree would make the rendered diff
impossible to express and would have to be undone at M2. Inline markdown
*inside* a block is delegated to the markdown package, where CommonMark's real
complexity lives; the app owns block-level layout only.

**That container is now carrying its first job.** The rendered diff is
decoration on the blocks that are already there, not a second screen: the
preview renders the buffer, then asks what it changed against its base and
says so on the state it has already published — so the document is on screen
while the comparison, which is a git process, is still being made. When a diff
arrives the column is the *diff's* sequence rather than the document's,
because a removed block is in no file on disk and has to be drawn where it
used to be. A document that matches its base is drawn as a document.

**What the base is, is the session's answer.** `HEAD` unless somebody chose a
branch or a commit ([the product rule](../../product/diff/branch-diff/doc.md),
the type is [`RevisionValueObject`](../domain/git.md)), and nothing at all for
a version opened from the history that nobody asked to compare. The
preview *listens* to that answer rather than watching it: another base is the
same text with other marks, so nothing is parsed again and the pane is never
sent back to "reading it". What offers the choice reads no git of its own —
the branches are the switcher's reading and the commits are the history
panel's, which is what keeps one answer to "which revisions are there".

That hazard is now measured
([Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md)):
reference links and footnotes are defined at document scope, and they behave
differently. **Reference links survive** — the parser's `linkReferences` map
travels with the blocks and the output is identical. **Footnotes do not**:
`[^ref]` in an isolated block renders as literal text, because its definition
is a different block. Every other construct in this repository's 848 blocks
renders identically alone. Deciding what the preview does about footnotes is
M2's, and there is a failing case waiting for it.

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

Each layer talks only to the one below it, and the direction never inverts.
`tom_domain` sits at the bottom of the call and knows nothing about how the
bytes arrived.

It ships in three steps:

1. **v0 — line diff over the preview.** Myers over the text, hunks mapped onto
   the rendered blocks that contain them. Fast, and already better than what
   the alternatives show.
2. **v1 — block diff.** Parse both sides into blocks, align by similarity,
   classify as unchanged/added/removed/modified. This is `BlockDiffer`, the
   one real domain service.
3. **v2 — intra-block diff.** Word-level insert/delete inside modified blocks.

A parsing and tree-comparison problem, testable with golden files and no UI
involved.

---

*See also: [domain/blocks.md](../domain/blocks.md) · [domain/documents.md](../domain/documents.md)*
