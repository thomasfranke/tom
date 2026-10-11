# File history

See the commits that touched the document currently open, without leaving it.

**Status:** Shipped · Milestone M1

## Rules

- The history panel lists only the commits that changed the current file, most recent first.
- Each entry shows who committed it, when, and the commit message.
- Opening a history entry shows that version of the document rendered, not raw diff text. A past version is read, never typed into — its source pane is read-only — and there is always a way back to the working copy.
- **A version being read says so in the row above the document**, where the tools were: the commit, whose it is and how old, and `Back to now` ([formatting shortcuts](../../editor/formatting-shortcuts/doc.md)).
- **The history follows the document through a rename**: a file that was moved or renamed keeps the commits made under its earlier name.
- A past version can be read in split view: that version's source beside that version's rendering, both read-only and both whole. The working copy is not on screen — it is one press away, at `Back to now`, and comes back as it was left: buffer, caret and undo history. No pane is captioned; the row above the document names the commit.
- **`Split` is that view, and the modes stay while a version is read.** The mode that opened the screen is the one that closes it — pressing it again returns to the single version; a switch that dropped `Split` would be a door that locks behind you.
- With no document open the panel says so — `Open a document to see what changed it.` — rather than showing the repository's log instead.
- The panel is one of the two the right column switches between ([columns](../../workspace/columns/doc.md)).

## Mocks

- **file history** — the commits that touched this document, under the `Git · History` switch. [light](../../../design/screens/desktop/git-history/file-history-light.svg) · [dark](../../../design/screens/desktop/git-history/file-history-dark.svg).
- **reading a version** — a past version rendered, the row above it naming the commit, no editor offered. [light](../../../design/screens/desktop/git-history/reading-a-version-light.svg) · [dark](../../../design/screens/desktop/git-history/reading-a-version-dark.svg).
- **reading a version, side by side** — a past version's source beside its rendering, both panes complete. [light](../../../design/screens/desktop/git-history/reading-a-version-side-by-side-light.svg) · [dark](../../../design/screens/desktop/git-history/reading-a-version-side-by-side-dark.svg).
- **history with no document open** — the column saying so. [light](../../../design/screens/desktop/git-history/history-with-no-document-open-states-light.svg) · [dark](../../../design/screens/desktop/git-history/history-with-no-document-open-states-dark.svg).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
