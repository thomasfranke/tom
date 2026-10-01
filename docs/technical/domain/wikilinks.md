# Wikilinks

`[[target#anchor]]`, and what it turns out to point at.

## `WikilinkValueObject`

What somebody wrote, before anything is looked up.

| Field | Type | Notes |
|---|---|---|
| `target` | string | What sits before the `#`, trimmed. Never empty — `tryParse` answers null instead |
| `anchor` | string? | What follows the **first** `#`; a later one belongs to the anchor |

- `tryParse` takes what is *between* the brackets: finding them is the parser's business, not this type's.
- `isPath` is a `/` in the target — the author saying they mean one exact file.
- `targetWithoutExtension` drops a trailing `.md`, so writing it is allowed and means the same thing.

## `WikilinkTargetValueObject`

The answer: `resolved` · `missing` · `ambiguous`.

**Sealed rather than a nullable path, because ambiguous is not missing.** A name
the space holds twice is a question to the author, and picking one silently
answers it wrong — the link keeps working while pointing somewhere nobody meant
([Decision 28](../decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).

- `destination` is where to navigate, and **ambiguous answers null**: the choice belongs to whoever writes the link, not to whoever clicks it.
- `missing` is ordinary rather than exceptional — a link is often written before the document it points at.

## `WikilinkResolverService`

A link and the space's listing in, a target out.

- **A domain service** because the rule belongs to no single document, and it carries **no port**: matching a name against a list is logic, not a capability. Contrast `BlockDifferService`, which has one because Myers is ([naming](../conventions/naming.md)).
- **Total.** Every link gets an answer; nothing here fails.
- Only entries that are documents are candidates, so a folder named like the target and a `.svg` beside it are both invisible to it.
- A name matches case-insensitively, a path exactly — a name is what somebody remembered, a path is what the filesystem said.

The listing is the file tree's own, which makes resolution as current as the
tree is and no more: a document created outside TOM is not linkable until the
space is reopened, the same bound [search](../runtime/search.md) carries.

---

*See also: [domain/](README.md) · [spaces.md](spaces.md) · [paths.md](paths.md) · [product rules](../../product/wikilinks/doc.md)*
