# Home

The first screen anyone sees: open a space, or start one from a remote URL.

**Status:** Planned · Milestone M0 (clone by URL: M3) · Mobile: not designed yet

| | |
|---|---|
| [`opening-a-space/`](opening-a-space/doc.md) | The three ways in, and what a folder without a repository does instead |
| [`recent-spaces/`](recent-spaces/doc.md) | What a row names, and forgetting one |
| [`cloning/`](cloning/doc.md) | Pasting a URL, and what it says while it works |
| [`the-brand-block/`](the-brand-block/doc.md) | The wordmark over the commit trunk |

## Mocks

- **empty state** — no space open: the wordmark over the trunk, opening a folder, and what was open before. [light](../../design/screens/desktop/home/empty-state-light.svg) · [dark](../../design/screens/desktop/home/empty-state-dark.svg).
Home refuses nothing, so it has no failure screen. A folder git knows nothing
about opens like any other, and the right column is what says so
([without a repository](../workspace/without-a-repository/doc.md)).

Home's bar is otherwise empty and still carries the
[preferences](../preferences/the-popover/doc.md) button — the language the app
speaks is chosen before a space is open, and the theme is inside the same
popover. ~~Home has no theme toggle and whether it gains one is open~~: it does
not, because that control no longer exists anywhere.

## Mobile

Not designed yet.
[`documents`](../navigation/file-tree/documents-on-mobile/doc.md) assumes a space
is already open; how one is chosen or connected on a phone in the first place has
not been drawn, and Phase 3 decides whether Home has a mobile counterpart at all.

---

*See also: [product/](../README.md) · [about.md](../../about.md) · [Decision 9](../../technical/decisions/009-space-session-is-single-source-of-truth.md)*
