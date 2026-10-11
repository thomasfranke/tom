# Documents

## `DocumentEntity`

A single `.md` file inside a space. **The file on disk is the truth** — the
entity is a view over it, never a cache that can diverge.

| Field | Type | Notes |
|---|---|---|
| `path` | path | Relative to the space root; the identity of the document |
| `content` | string | The raw markdown source, held whole and exactly as it was read — never normalized, since a line ending changed on the way through is a diff the user did not make |

- **The entity is never dirty.** What is being typed is the editor's buffer in `tom_presentation` (`EditorReady.source`), beside the entity it was read as (`saved`); dirty is the two differing, compared rather than flagged, so a character typed and taken back leaves the document clean.

## `ParsedDocumentValueObject`

A document once it has been split: the `DocumentEntity` it came from, its
[`BlockValueObject`](blocks.md)s in order, and `linkDefinitions` — every link
reference definition as its own lines.

The definitions are the price of rendering a block on its own. They are
declared at document scope, so a block holding `[text][ref]` and nothing else
would draw the brackets; appending them to the block's source resolves it.
Footnotes do not survive the same way, which is M2's problem and stated in
[Decision 19](../decisions/019-blocks-come-from-the-markdown-package.md).

They travel here and not on `BlockValueObject` for two reasons: the block's
own table is its whole shape, and a copy on every block is the same string as
many times as the document has blocks.

## `DocumentRepository`

Fulfilled in `tom_data` over the `Filesystem` capability. Its failures are
`DocumentFailure`, separate from `SpaceFailure` because the two fail
differently: a document that cannot be read sends the user to another
document, a folder that cannot be read sends them to another space
([`spaces.md`](spaces.md)).

---

*See also: [blocks.md](blocks.md) · [runtime/preview.md](../runtime/preview.md)*
