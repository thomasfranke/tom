# Leaving a space

Closing the space, or switching to another one, without going through Home.

**Status:** Shipped · Milestone M0 — the count of several unsaved documents since 2026-10-09; the `closing with unsaved work` board still draws the dialog

## Rules

- **The space can always be left.** A **home button** before the breadcrumb at the left of the top bar is the way out: one press, and the window is back on the opening screen. ~~The breadcrumb's menu carries **Close space** at the foot~~ — revoked on 2026-10-07: leaving is the one thing somebody does without choosing among spaces first, so it should not be at the end of a list of them.
- The breadcrumb still names the space and still opens the menu of recent spaces; switching to another one from there skips the trip through Home — going Home only to pick a folder is a step with nothing in it.
- **Closing with an unsaved buffer asks first**, naming the document, and offers stay beside save and discard. It is the same question a [branch switch](../../git-workflow/branch-switch/doc.md) asks, because the thing at risk is the same: an edit that never reached the disk.
- **More than one unsaved document changes the words, not the flow.** The question counts them instead of naming one and the actions say `all`; it is the same screen, so there is no second one to draw.
- ~~**The question is a `Dialog`, centred over a scrim** — not a popover hanging off the breadcrumb that opened it.~~ — revoked on 2026-10-09, the maintainer's call: the app's shape stays.
- **The question lives in the breadcrumb's popover**, in place of the list of recent spaces, whether the home button or a recent space raised it — the question belongs to leaving, and leaving is that menu's. One document is named and its answers say `Save and close`, `Discard and close`; several are counted (`3 documents have unsaved changes.`) and the answers say `Save all and close`, `Discard all and close` — `… and open` when going to another space — with `Stay in this space` either way.

## Mocks

- **closing the space** — the home button before the breadcrumb, and the breadcrumb's menu of recent spaces. [light](../../../design/screens/desktop/workspace-shell/closing-the-space-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/closing-the-space-dark.svg).
- **closing with unsaved work** — the question that names the document and offers stay. [light](../../../design/screens/desktop/workspace-shell/closing-the-space-unsaved-work-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/closing-the-space-unsaved-work-dark.svg).

---

*See also: [workspace/](../README.md) · [recent spaces](../../home/recent-spaces/doc.md)*
