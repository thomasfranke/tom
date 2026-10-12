# Formatting shortcuts

Buttons and keyboard shortcuts that insert markdown syntax, without hiding the source underneath it.

**Status:** Shipped · Milestone M3

## Rules

- Using a shortcut or a button inserts the **literal markdown syntax into the source** — the source stays visible and remains the truth, never a hidden intermediate format.
- **There is a button for everything the preview renders**, seventeen of them, because a button for four of the cases teaches that the other cases are not supported: undo and redo · heading, bold, italic, strikethrough · list, ordered list, task list, quote · code, table, rule · link, image, footnote, alert.
- **They sit in five groups divided by a rule**, in the order somebody reaches for them. Undo is always available and formatting is not, so the first group is told apart by more than its position.
- **The row is the width of the document area and belongs to it**: formatting at the left, the `Diff` chip at the right, and between them `Not saved` when a save was refused ([source mode](../source-mode/doc.md)). They are the document's tools, so they sit with the document and not in the window's top bar, which carries no action on a file.
- **Both ends are anchored to the pane, not to the window.** The tools hang from the pane's left edge and the `Diff` chip from its right, and both travel with it when a column opens.
- **With the bar hidden, nothing moves but the buttons.** The `Diff` chip stays at the pane's edge either way, because it is about the space and not about the document's tools.
- A button with nothing to act on is **disabled, never absent**: a toolbar that reflows is harder to use than a dim button. It is drawn fainter than a live one, so the two are told apart at a glance.
- **The bar never drops a button, and never scrolls.** With the git column open the set is 34 points too wide, so the **last group collapses into a `⋯`** that opens it as a strip under itself. Scrolling would put four buttons behind a gesture nothing on screen offers; the `⋯` is a control that says they exist. The groups that stay keep the x every board draws them at, which is why the one that gives way is the last and not the widest.
- **While a version is read, the row carries what that screen is about instead of the tools.** Reading a past version puts the commit and the way back there ([file history](../../git-workflow/file-history/doc.md)). The row stays, its contents answer to the screen.
- **A preview shows the whole bar, disabled.** In preview the editor *is* offered, one click away on `Source`; what is missing is the caret, not the editor. So the fifteen formatting buttons are dim rather than gone, with undo and redo still live because they act on the buffer and not on a selection — from the buttons and from ⌘Z / ⌘⇧Z alike, one history either way.

## What each one writes

- **A wrap and a line prefix toggle**: pressed again over the same selection, the marks come off — the only way a button can be pressed twice without lying.
- **A line prefix goes on every line the selection touches**, and comes off only when every one of them already has it.
- **The keys are GitHub's**, so nobody learns a second set — `Ctrl` in place of `⌘` off macOS. `⌘K` is the search's ([the surface](../../search/full-text-search/the-surface/doc.md)), so a link is `⌘⇧K`.
- A button GitHub gives no key has none.

| Button | Writes | Key |
|---|---|---|
| Undo · Redo | nothing — one step back or forward in the buffer's history | `⌘Z` · `⌘⇧Z` |
| Heading | `# ` before the line | — |
| Bold | `**` on both sides of the selection | `⌘B` |
| Italic | `*` on both sides | `⌘I` |
| Strikethrough | `~~` on both sides | `⌘⇧X` |
| List | `- ` before the line | `⌘⇧8` |
| Ordered list | `1. `, `2. `… before each line, counted | `⌘⇧7` |
| Task list | `- [ ] ` before the line | `⌘⇧L` |
| Quote | `> ` before the line | `⌘⇧.` |
| Code | a backtick on both sides; a selection that spans lines goes between two fences of its own | `⌘E` |
| Table | a two-column skeleton on lines of its own, under the caret's line | — |
| Rule | `---` on a line of its own | — |
| Link | `[` and `]` around the selection, then `(url)` | `⌘⇧K` |
| Image | `![` and `]` around the selection, then `(url)` | — |
| Footnote | `[^1]` at the caret, and its definition at the foot of the document | — |
| Alert | `> [!NOTE]` on one line and `> ` on the next, the caret there — the marker shares no line with the text, or it reads as a quote | — |

## Mocks

- **merged rows** — the row above the document, under the tabs: the tools at its left, the `Diff` chip at its right. [light](../../../design/screens/desktop/editor-formatting/merged-rows-light.svg) · [dark](../../../design/screens/desktop/editor-formatting/merged-rows-dark.svg).
- **formatting overflow** — the git column open, the last group folded into the `⋯`, lit, with the strip under it. [light](../../../design/screens/desktop/editor-formatting/formatting-overflow-light.svg) · [dark](../../../design/screens/desktop/editor-formatting/formatting-overflow-dark.svg).
- Every screen with an editable document carries the same row; `shell` is the one to read it on ([workspace](../../workspace/regions/doc.md)).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md) · [Decision 3](../../../technical/decisions/003-editor-is-source-plus-preview.md)*
