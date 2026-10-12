# The status bar

The strip at the foot of the window: where the repository stands at the left, what is open at the right.

**Status:** Shipped · Milestone M3

## Rules

- **The bar is always on screen**, and it only reports: nothing in it is pressed, bar the update notice.
- **A segment is absent while there is nothing to read it from** — it is never drawn empty, dim or as a dash.
- **The left half is git's**, in this order:

| Segment | Says | Drawn |
|---|---|---|
| Branch | The branch's name after its glyph; `Not on a branch` when the repository is on none | Always, with a repository |
| Drift | `↑ 2 ↓ 3` — commits to publish, commits to bring back | Always, with a repository — zeros included |
| Changes | A dot in `modified`, then `3 changes` | Only with something changed |

- **The right half is the open document's**, in this order:

| Segment | Says | Drawn |
|---|---|---|
| Caret | `Ln 5, Col 12` | While the document has a caret |
| Encoding | `UTF-8` | For any text file |
| Kind | `Markdown`, `JSON`, `YAML`… read off the extension; `Plain text` for one it has no name for, `Binary` for a file that is not text | With a file open |
| Saved | `Saved` after a check · `Unsaved` in `modified` · `Saving…` while the write runs · `Read-only` for a file nothing typed can reach | With a file open |

- **The drift is glyphs and numbers here and words at the foot of the git column** — one fact, one wording per surface ([the controls](../../git-workflow/push-pull/the-controls/doc.md)).
- **`Unsaved` wears no check**, because a check beside it would say the opposite of the word; it is one of the three places an unwritten edit is said ([source mode](../../editor/source-mode/doc.md)).
- **A binary file has no caret and no encoding** — only `Binary` and `Read-only` ([opening a change](../../git-workflow/commit/opening-a-change/doc.md)).
- **A folder with no repository keeps the right half and has no left one** ([without a repository](../without-a-repository/doc.md)).
- **With no space open the bar says `no space open`** and nothing else.
- **An update found when the app opened is said here**, `Update available: <version>` in the accent, and pressing it opens the About dialog ([about](../../about/doc.md)).
- The document's name is not here: the tab and the tree's open row say it.

## Mocks

- **shell** — the bar under a space with changes and a document open. [light](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/shell-reading-and-editing-dark.svg).
- **saving — what the window says** — [light](../../../design/screens/desktop/editor/saving-what-the-window-says-states-light.svg) · [dark](../../../design/screens/desktop/editor/saving-what-the-window-says-states-dark.svg).
- **not on a branch — how it is named** — [light](../../../design/screens/desktop/git-branches/not-on-a-branch-how-it-is-named-states-light.svg) · [dark](../../../design/screens/desktop/git-branches/not-on-a-branch-how-it-is-named-states-dark.svg).
- **no repository** — the right half alone. [light](../../../design/screens/desktop/git-not-git/no-repository-light.svg) · [dark](../../../design/screens/desktop/git-not-git/no-repository-dark.svg).
- **an update is waiting** — [light](../../../design/screens/desktop/about-updates/an-update-is-waiting-light.svg) · [dark](../../../design/screens/desktop/about-updates/an-update-is-waiting-dark.svg).

---

*See also: [workspace/](../README.md) · [regions/](../regions/doc.md) · [feedback/](../feedback/doc.md)*
