# Typed paths

The two halves of the space/repository split, as types.

| Type | Spoken by |
|---|---|
| `SpaceRelativePathValueObject` | The file tree, the editor, the watcher, the search index |
| `RepoRelativePathValueObject` | Git — what it reports and what it accepts |

- Both refuse `..`, an empty segment, a backslash and a drive letter — **one rule, in one place** — so joining either onto its root cannot leave it.
- **`SpaceEntity` is the only converter**: `toRepoRelative` prefixes, `toSpaceRelative` strips.
- `toSpaceRelative` answers **null** for a path the space does not contain, and null is an ordinary answer rather than a failure — git reports the whole repository, so a status on a space opened at `docs/` routinely names source files the tree does not show.

Both are single-field value objects, which is the one place an `extension type`
fits better than Freezed ([naming](../conventions/naming.md)).

---

*See also: [domain/](README.md) · [spaces.md](spaces.md)*
