# Spaces

## `SpaceEntity`

A local folder the user opened. The unit of everything: git queue, watcher,
search index and session are all scoped per space
([Decision 9](../decisions/009-space-session-is-single-source-of-truth.md)).

| Field | Type | Notes |
|---|---|---|
| `root` | path | Absolute path to the folder the user opened; the identity of the space |
| `repositoryRoot` | path | Absolute path to the enclosing Git repository — equal to `root` when the repository itself was opened, an ancestor when a subfolder was |
| `name` | string | Derived from the folder name unless configured otherwise |

The two paths are separate because most teams keep `docs/` inside the
repository that holds the code. Git commands run against `repositoryRoot` and
report paths relative to it; navigation, search and the watcher stay within
`root`. Retrofitting this would touch git, the watcher, the index and wikilink
resolution at once.

## `SpaceRelativePathValueObject` · `RepoRelativePathValueObject`

The two halves of the split above, as types. `SpaceRelativePathValueObject` is
what the file tree, the editor, the watcher and the search index speak;
`RepoRelativePathValueObject` is what git reports and accepts. Both refuse
`..`, an empty segment, a backslash and a drive letter — one rule, in one
place — so that joining either onto its root cannot leave it.

`SpaceEntity` is the only converter: `toRepoRelative` prefixes,
`toSpaceRelative` strips and answers **null** for a path the space does not
contain. Null is an ordinary answer, not a failure — git reports the whole
repository, so a status on a space opened at `docs/` routinely names source
files the tree does not show.

## `SpaceEntryValueObject`

One line of the file tree: a `SpaceRelativePathValueObject` and what lives at
it — file, directory, or a link, reported as itself because a listing never
follows one. Deliberately not a `DocumentEntity`: a listing knows where things
are, not what is in them, and reading every file of a space to draw its tree
is work a documentation tool cannot afford.

## `SpaceRepository`

Fulfilled in `tom_data` over the `Filesystem` capability, which works in
absolute paths and knows nothing about spaces; `SpaceEntity` is what converts,
in both directions, and holding one is what makes a repository belong to a
space. Its failures are `SpaceFailure` — `folderMissing`, `accessDenied`,
`operationFailed` — separate from `DocumentFailure` because a folder that
cannot be read sends the user to another space, not to another document.

`entries()` carries the file tree's policy: **`.git/` is out and is never
descended into**, every other dotfolder is in. Not descending is the
load-bearing half — a recursive listing walks into `.git/` before anything can
filter it, and a mature repository keeps more entries there than the product
will ever show — so the walk goes one level at a time and decides before it
descends. The result is depth-first and sorted, so a tree can be built by
walking the list once.

---

*See also: [documents.md](documents.md) · [git.md](git.md)*
