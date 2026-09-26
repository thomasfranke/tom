# File history

See the commits that touched the document currently open, without leaving it.

**Status:** Planned · Milestone M1

## Rules

- The history panel lists only the commits that changed the current file, most recent first.
- Each entry shows who committed it, when, and the commit message.
- Opening a history entry shows that version of the document rendered, not raw diff text. While one is open the editor is not offered at all — a past version is read, never typed into — and there is always a way back to the working copy.
- **A version being read says so in a band above the document**, naming the commit and carrying the way back. It sits where every other piece of news from git sits, so there is one place to look for what the app is doing.
- A past version can be read beside the working copy in split view, both panes showing the whole document. Neither side is an excerpt: a version half-shown is a version somebody has to scroll to trust.
- With no document open the panel says so, rather than showing the repository's log instead.
- The panel is one of the two the right column switches between, and the commits it lists are what [branch-diff](../../diff/branch-diff/doc.md) offers as a base. One reading of the log, two surfaces.

## Mocks

- **file history** — the commits that touched this document, under the `Changes · History` switch. [light](../../../design/screens/desktop/git-history/file-history-light.svg) · [dark](../../../design/screens/desktop/git-history/file-history-dark.svg).
- **reading a version** — a past version rendered, the band naming it, no editor offered. [light](../../../design/screens/desktop/git-history/reading-a-version-light.svg) · [dark](../../../design/screens/desktop/git-history/reading-a-version-dark.svg).
- **reading a version, side by side** — the past and the working copy in full, both panes complete. [light](../../../design/screens/desktop/git-history/reading-a-version-side-by-side-light.svg) · [dark](../../../design/screens/desktop/git-history/reading-a-version-side-by-side-dark.svg).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
