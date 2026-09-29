# Leaving a space

Closing the space, or switching to another one, without going through Home.

**Status:** Shipped · Milestone M0

## Rules

- **The space can always be left.** The breadcrumb at the left of the top bar is the control: it already names the space, so the way out needs nothing else in the bar. It opens a menu of recent spaces with **Close space** at the foot.
- Closing a space returns to the opening screen.
- Switching to another space from the same menu skips that trip — going Home only to pick a folder is a step with nothing in it.
- **Closing with an unsaved buffer asks first**, naming the document, and offers stay beside save and discard. It is the same question a [branch switch](../../git-workflow/branch-switch/doc.md) asks, because the thing at risk is the same: an edit that never reached the disk.
- **More than one unsaved document changes the words, not the flow.** The question counts them instead of naming one and the actions say `all`; it is the same screen, so there is no second one to draw.
- **The question is a `Dialog`, centred over a scrim** — not a popover hanging off the breadcrumb that opened it. A question that blocks the window is not a menu, and [closing a tab](../../editor/tabs/doc.md) asks the same one about a single document.

## Mocks

- **closing the space** — the breadcrumb's menu, recent spaces above and **Close space** at the foot. [light](../../../design/screens/desktop/workspace/closing-the-space-light.svg) · [dark](../../../design/screens/desktop/workspace/closing-the-space-dark.svg).
- **closing with unsaved work** — the question that names the document and offers stay. [light](../../../design/screens/desktop/workspace/closing-the-space-unsaved-work-light.svg) · [dark](../../../design/screens/desktop/workspace/closing-the-space-unsaved-work-dark.svg).

---

*See also: [workspace/](../README.md) · [recent spaces](../../home/recent-spaces/doc.md)*
