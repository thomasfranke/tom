# File history

See the commits that touched the document currently open, without leaving it.

**Status:** Planned · Milestone M1

## Rules

- The history panel lists only the commits that changed the current file, most recent first.
- Each entry shows who committed it, when, and the commit message.
- Opening a history entry shows that version of the document rendered, not raw diff text. While one is open the editor is not offered at all — a past version is read, never typed into — and there is always a way back to the working copy.
- With no document open the panel says so, rather than showing the repository's log instead.

## Mocks

- [file-history](mocks/file-history.excalidraw) — the commits that touched this document. Visual design: [light](mocks/file-history-light.svg) · [dark](mocks/file-history-dark.svg).

An opened history entry is built and **not drawn yet**: the bar above the document naming the commit, and the way back.

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
