# The preview

Presentation receives an **ordered list of blocks, not a document**. Each is
rendered on its own and wrapped in a container the app owns.

That container carries the diff decoration, the navigation anchor and, later,
per-block selection. Rendering the document as one opaque widget tree would make
the rendered diff impossible to express, and would have to be undone at M2.

- Inline markdown *inside* a block is delegated to the `markdown` package, where CommonMark's real complexity lives. The app owns block-level layout only.
- A document that matches its base is drawn as a document. When a diff arrives, the column is the **diff's** sequence rather than the document's, because a removed block is in no file on disk and has to be drawn where it used to be.
- The preview renders the buffer, then asks what changed against its base and says so on the state it has already published — so the document is on screen while the comparison, a git process, is still being made.

## What the base is, is the session's answer

`HEAD` unless somebody chose a branch or a commit
([the product rule](../../product/diff/branch-diff/doc.md); the type is
[`RevisionValueObject`](../domain/git.md)), and nothing at all for a version
opened from the history that nobody asked to compare.

- The preview **listens** to that answer rather than watching it: another base is the same text with other marks, so nothing is parsed again and the pane is never sent back to "reading it".
- What offers the choice reads no git of its own — the branches are the switcher's reading, the commits the history panel's, which is what keeps one answer to "which revisions are there".

## Document-scope constructs, measured

The hazard of rendering blocks in isolation
([Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md)):

- **Reference links survive.** The parser's `linkReferences` map travels with the blocks and the output is identical.
- **Footnotes do not.** `[^ref]` in an isolated block renders as literal text, because its definition is a different block.

Every other construct in this repository's 848 blocks renders identically alone.
What the preview does about footnotes is M2's, and there is a failing case
waiting for it.

---

*See also: [runtime/](README.md) · [rendered-diff.md](rendered-diff.md) · [domain/blocks.md](../domain/blocks.md)*
