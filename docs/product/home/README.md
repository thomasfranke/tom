# Home

The first screen anyone sees: open a space, or start one from a remote URL.

**Status:** Planned · Milestone M0 (clone by URL: M3) · Mobile: not designed yet

| | |
|---|---|
| [`opening-a-space/`](opening-a-space/doc.md) | The three ways in, and the one way it fails |
| [`recent-spaces/`](recent-spaces/doc.md) | What a row names, and forgetting one |
| [`cloning/`](cloning/doc.md) | Pasting a URL, and what it says while it works |
| [`the-brand-block/`](the-brand-block/doc.md) | The wordmark over the commit trunk |

## Mocks

- **empty state** — no space open: the wordmark over the trunk, opening a folder, and what was open before. [light](../../design/screens/desktop/home/empty-state-light.svg) · [dark](../../design/screens/desktop/home/empty-state-dark.svg).
- **not a Git repository** — the one way opening a folder fails. [light](../../design/screens/desktop/home/not-a-repository-light.svg) · [dark](../../design/screens/desktop/home/not-a-repository-dark.svg).

Home has no theme toggle drawn — the control lives with the
[column toggles](../workspace/columns/doc.md) in the workspace bar, which Home
does not have, and whether it gains one is open.

## Mobile

Not designed yet.
[`documents`](../navigation/file-tree/documents-on-mobile/doc.md) assumes a space
is already open; how one is chosen or connected on a phone in the first place has
not been drawn, and Phase 3 decides whether Home has a mobile counterpart at all.

---

*See also: [product/](../README.md) · [about.md](../../about.md) · [Decision 9](../../technical/decisions/009-space-session-is-single-source-of-truth.md)*
