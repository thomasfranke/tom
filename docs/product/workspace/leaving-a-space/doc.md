# Leaving a space

Closing the space, or switching to another one, without going through Home.

**Status:** Shipped · Milestone M0

## Rules

- **The space can always be left.** A **home button** before the breadcrumb at the left of the top bar is the way out: one press, and the window is back on the opening screen — leaving is the one thing somebody does without choosing among spaces first, so it is not at the end of a list of them.
- The breadcrumb still names the space and still opens the menu of recent spaces; switching to another one from there skips the trip through Home — going Home only to pick a folder is a step with nothing in it.
- **Closing with an unsaved buffer asks first**, naming the document, and offers stay beside save and discard. It is the same question a [branch switch](../../git-workflow/branch-switch/doc.md) asks, because the thing at risk is the same: an edit that never reached the disk.
- **More than one unsaved document changes the words, not the flow.** The question counts them instead of naming one and the actions say `all`; it is the same screen, so there is no second one to draw.
- **The question lives in the breadcrumb's popover**, in place of the list of recent spaces, whether the home button or a recent space raised it — the question belongs to leaving, and leaving is that menu's. One document is named and its answers say `Save and close`, `Discard and close`; several are counted (`3 documents have unsaved changes.`) and the answers say `Save all and close`, `Discard all and close` — `… and open` when going to another space — with `Stay in this space` either way.
- **Escape and a click outside are *stay*.** Closing the popover closes the question with it, so it is never left standing behind something nobody can see.
- **A save that fails keeps the space.** `Save and close` leaves only once every document reached the disk; one that could not be written stays on screen, unsaved — leaving then would lose exactly what the question was asked to protect.
- **A recent space that does not open says so and changes nothing**: `handbook could not be opened — has it moved?` under the menu's rows, the space on screen staying where it is. The menu is not Home and has no screen to refuse on.
- **A document that changed on disk keeps the space too.** Its save writes nothing ([source mode](../../editor/source-mode/doc.md)), so the tab stays, unsaved, and its band asks when the tab is on screen.
- **Closing the window asks the same question**, about every tab with edits ([tabs](../../editor/tabs/doc.md)) — quitting is leaving too. It is asked whether the window's own close or the system's quit raised it, and with nothing unsaved the window just closes.
- **Asked by the window, the sentence under the question says what closing costs**: `Closing the window leaves TOM, and the edit that has not reached the disk goes with it.` The three answers are the same, and the window closes only once the question was answered with a save that worked or a discard.

## Mocks

- **closing the space** — the home button before the breadcrumb, and the breadcrumb's menu of recent spaces. [light](../../../design/screens/desktop/workspace-shell/the-space-menu-states-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/the-space-menu-states-dark.svg).
- **leaving with unsaved work — the question** — in the breadcrumb's popover, where the list of recent spaces was; its notes carry the sentence the window's close puts under it. [light](../../../design/screens/desktop/workspace-shell/leaving-with-unsaved-work-the-question-states-light.svg) · [dark](../../../design/screens/desktop/workspace-shell/leaving-with-unsaved-work-the-question-states-dark.svg).

---

*See also: [workspace/](../README.md) · [recent spaces](../../home/recent-spaces/doc.md)*
