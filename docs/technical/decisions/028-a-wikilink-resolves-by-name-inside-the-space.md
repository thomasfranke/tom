# Decision 28 — A wikilink resolves by name inside the space, and says so when it cannot

**Status:** accepted

## Context

`[[document]]` is M3 ([wikilinks](../../product/wikilinks/doc.md)), and the domain model has carried the question unanswered since the chapter was written: *how does a link resolve — relative to the space, by a filename anywhere in it, or by heading anchor — and what happens when the target does not exist* ([open-questions.md](../domain/open-questions.md)).

Three things already constrain the answer.

**A space is a folder, not a repository** ([rule 12](../../../AGENTS.md)). Navigation and search stay inside `root` while git runs against `repositoryRoot`, so a link is not allowed to reach a file the tree does not show — even though that file is in the same repository.

**The people who write these links are not all developers.** The semi-technical collaborator and the tech lead in [about.md](../../about.md) are writing prose, not paths. A convention that requires counting `../` to reach a sibling folder is a convention they will get wrong, and the failure is silent: a link that points at nothing looks exactly like a link that points at something until it is clicked.

**The app already holds the listing.** The file tree enumerates every `.md` under the space when it opens, and the search index is filled from that same listing ([runtime/search.md](../runtime/search.md)). Resolving a name is a lookup over data the session already has, not a new traversal.

## Decision

**A wikilink target is matched by document name across the whole space. A target containing `/` is matched as a space-relative path instead.**

```
[[architecture]]                  → the document named architecture.md, anywhere
[[technical/architecture]]        → docs-relative path, exactly
[[architecture#enforcement]]      → the document, plus a heading anchor
```

- The `.md` extension is optional in the link and ignored in the match.
- Matching a name is case-insensitive; matching a path is not, because a path is what the filesystem said.
- **A target that matches more than one document is ambiguous, and ambiguous is its own outcome** — not the first match, not the nearest one.
- A heading anchor is carried but not resolved here: the link resolves to the document, and the anchor is the preview's problem.
- Resolution never leaves the space root. A target that escapes it does not resolve, the same as one that is missing.

`WikilinkValueObject` carries what was written; `WikilinkTargetValueObject` is the sealed answer — `resolved`, `missing`, `ambiguous` — so the preview can draw the three differently and the product rule that an unresolved link is *visibly distinguished* has something to read.

## Rationale

**By name, because that is what people write.** Obsidian, Roam and every wiki before them resolve by name for the same reason, and a team moving documentation into TOM arrives with that expectation. The alternative — always space-relative — is markdown's own link syntax, which already exists and which `[[ ]]` would then duplicate with worse ergonomics.

**With a path escape hatch, because names collide.** This repository has two `doc.md` files per feature folder by design; a name-only scheme would make half its documents unlinkable. A `/` in the target is an unambiguous signal that the author means a path, and it costs nothing to honour.

**Ambiguity is named rather than resolved.** Picking the first match makes the link work today and break when somebody adds a file with the same name in another folder, and the breakage is invisible — the link still resolves, just to the wrong document. A third state costs one variant in a sealed class and turns a silent wrong answer into a visible question.

**The anchor is parsed and not resolved** because heading anchors are the preview's vocabulary, not the domain's: the domain has blocks with no stable identity ([Decision 19](019-blocks-come-from-the-markdown-package.md)), so there is nothing here to resolve an anchor *against*.

## Consequences

- The resolver needs the space's document listing, which makes it a **domain service** rather than a method on an entity: the rule belongs to no single document. Unlike `BlockDifferService` it carries **no port** — that one has `BlockAlignerPort` because Myers is a capability, while matching a name against a list is pure logic. The service is handed the listing and reaches nothing ([naming](../conventions/naming.md)).
- Autocomplete on `[[` reads that same listing, so it costs no new capability.
- A rename breaks links that named the old file. That is true of markdown links today and this does not make it worse; repairing links on rename is a separate feature nobody has asked for.
- The listing is a session-lifetime snapshot, so a document created outside TOM is not linkable until the space is reopened — the same bound [search](../runtime/search.md) already carries, for the same reason.
- `Wikilink` leaves [open-questions.md](../domain/open-questions.md) and enters the model.

## Revisit when

Someone asks for links **across** spaces, or for anchors that survive an edit. The first breaks the space-root rule and needs a different answer than this one; the second needs block identity, which Decision 19 measured and did not find.
