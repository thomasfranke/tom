# Tabs

The documents that are open, and which of them is on screen.

**Status:** Planned · Milestone M3

## Rules

- **Tabs are a row of their own, directly above the document**, under the formatting bar. Nothing shares the row: a tab strip that also held a control would make the control look like it belonged to one tab.
- **The row covers the document area only.** The explorer keeps its place, because a tab names a document and not a folder.
- **The active tab meets the document with no line between them.** That join is what says a tab *is* the open document rather than a button that happens to be selected.
- **It carries no divider on its right either.** The dividers separate tabs that look alike; the active one is already told apart by its fill and its marker, and a rule beside it only draws a box around what is not a box.
- **An unsaved tab is marked, and its close is not drawn.** The dot takes the place of the ✕, so nothing in the strip discards work with one stray click — the same reading as a [folder without a repository](../../workspace/without-a-repository/doc.md).
- **~~It cannot be closed~~ — the keyboard still closes it, and then the question guards it.** The shortcut is not going away, so a tab with edits that never reached the disk asks before it goes: save and close, discard and close, or keep the tab open. It is the question [leaving a space](../../workspace/leaving-a-space/doc.md) asks, about one tab instead of all of them.
- The dot is one of the three places unsaved is said, beside the explorer's dot and the status bar's words ([source mode](../source-mode/doc.md)).
- **Opening a file does not keep it open.** A click from the tree opens it in *preview*: the tab's name is italic, and there is never more than one of them — opening the next file replaces it rather than adding a tab. Somebody reading through a folder ends with one tab, not thirty.
- **Editing, saving or a double click makes it permanent**, and the italic goes. The act says the intent: a file somebody typed into is a file they meant to keep.
- **A tab never shrinks.** With more open than fit, the strip scrolls sideways and every tab keeps its width — a name cut to make room is a name nobody can read, and the point of a tab is to be recognised at a glance.
- **The set of open tabs is a session, not a repository.** The changes list answers what differs from the last commit and empties when somebody commits; the tabs answer what somebody has been in, and do not.
- Switching a tab changes what the modes and the formatting buttons act on. Neither row is redrawn — they are about the document area, and the document area is what changed.

The `Diff` chip is **not** per document: the base lives on the space and
outlives whatever is open ([branch diff](../../diff/branch-diff/doc.md)), which
is why it stays in the mode bar rather than following the tabs.

## Mocks

- **merged rows** — three open, the active one unsaved, under the row it shares the editor with. [light](../../../design/screens/desktop/editor/merged-rows-light.svg) · [dark](../../../design/screens/desktop/editor/merged-rows-dark.svg).
- **tab in preview** — the same strip with the active tab italic, opened by a click and not yet kept. [light](../../../design/screens/desktop/editor/tab-in-preview-light.svg) · [dark](../../../design/screens/desktop/editor/tab-in-preview-dark.svg).
- **closing a tab · unsaved** — the question the shortcut raises, centred over a scrim. [light](../../../design/screens/desktop/workspace/closing-a-tab-unsaved-light.svg) · [dark](../../../design/screens/desktop/workspace/closing-a-tab-unsaved-dark.svg).

---

*See also: [source-mode](../source-mode/doc.md) · [formatting-shortcuts](../formatting-shortcuts/doc.md) · [markdown-preview](../markdown-preview/doc.md)*
