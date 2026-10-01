# Formatting shortcuts

Buttons and keyboard shortcuts that insert markdown syntax, without hiding the source underneath it.

**Status:** Shipped · Milestone M3

## Rules

- Using a shortcut or a button inserts the **literal markdown syntax into the source** — the source stays visible and remains the truth, never a hidden intermediate format.
- **There is a button for everything the preview renders**, seventeen of them, because a button for four of the cases teaches that the other cases are not supported: undo and redo · heading, bold, italic, strikethrough · list, ordered list, task list, quote · code, table, rule · link, image, footnote, alert.
- **They sit in five groups divided by a rule**, in the order somebody reaches for them. Undo is always available and formatting is not, so the first group is told apart by more than its position.
- **The row is the width of the document area and belongs to it**: formatting at the left, the view at the right. They are the document's tools, so they sit with the document and not in the window's top bar, which carries no action on a file.
- **Both ends are anchored to the pane, not to the window.** `Source · Split · Preview` and the `Diff` chip hang from the pane's right edge and travel with it when a column opens. This revokes the earlier rule that the modes are fixed to the window's centre ([columns](../../workspace/columns/doc.md)): the centre was free while the row held nothing else, and a centred control in a full row is a control the buttons run into.
- **With the bar hidden, the modes go back to the centre of the window**, where they line up with the branch control directly above. The reason they left it was the buttons, and a preference can take the buttons away — so the rule is not *right-anchored*, it is *right-anchored while something shares the row*. The `Diff` chip stays at the pane's edge either way, because it is about the space and not about the document's tools.
- A button with nothing to act on is **disabled, never absent**: a toolbar that reflows is harder to use than a dim button.
- **The bar never drops a button, and never scrolls.** With the git column open the set is 34 points too wide, so the **last group collapses into a `⋯`** that opens it as a strip under itself — ~~the bar scrolls sideways rather than hiding anything~~. Scrolling put four buttons behind a gesture nothing on screen offered; the `⋯` is a control that says they exist. The groups that stay keep the x every board draws them at, which is why the one that gives way is the last and not the widest.
- **Where the editor is not offered, the row carries what that screen is about instead.** Reading a past version puts the commit and the way back there ([file history](../../git-workflow/file-history/doc.md)). The row stays, its contents answer to the screen.
- **A preview shows the whole bar, disabled** — ~~it used to keep undo and redo and nothing else~~. In preview the editor *is* offered, one click away on `Source`; what is missing is the caret, not the editor. So the rule above it applies and the fifteen formatting buttons are dim rather than gone, with undo and redo still live because they act on the buffer and not on a selection.

## Mocks

- **merged rows** — the row as it ships: formatting left, view right, tabs under it. [light](../../../design/screens/desktop/editor/merged-rows-light.svg) · [dark](../../../design/screens/desktop/editor/merged-rows-dark.svg).
- **The `⋯` has no board yet**, and the boards that draw all seventeen with the git column open draw them over the mode control — which the rule above revokes ([not drawn yet](../../../design/screens/not-drawn-yet.md)).
- Every screen with an editable document carries the same row; `shell` is the one to read it on ([workspace](../../workspace/regions/doc.md)).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md) · [Decision 3](../../../technical/decisions/003-editor-is-source-plus-preview.md)*
