# The rendered diff, layer by layer

```
tom_desktop      the panel asks the notifier for the diff of the open document
tom_presentation the notifier calls the use case, turns Result into state
tom_application  ComputeRenderedDiff orchestrates repository + BlockDiffer
tom_data         DocumentRepositoryImpl reads HEAD and the working tree
tom_infra        GitClient runs `git show`, FileSystem reads the file
tom_domain       BlockDiffer classifies blocks: added, removed, modified
tom_core         every step returns Result<T>; failures are typed
```

- Each layer talks only to the one below it, and the direction never inverts.
- `tom_domain` sits at the bottom of the call and knows nothing about how the bytes arrived.
- The decoration itself is the preview's container, not a second screen ([preview.md](preview.md)).

## It ships in three steps

| | |
|---|---|
| **v0** — line diff over the preview | Myers over the text, hunks mapped onto the rendered blocks that contain them. Already better than what the alternatives show |
| **v1** — block diff | Parse both sides into blocks, align by similarity, classify as unchanged/added/removed/modified. This is `BlockDiffer`, the one real domain service |
| **v2** — intra-block diff | Word-level insert/delete inside modified blocks |

A parsing and tree-comparison problem, testable with golden files and no UI
involved.

---

*See also: [runtime/](README.md) · [preview.md](preview.md) · [domain/blocks.md](../domain/blocks.md) · [Decision 27](../decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)*
