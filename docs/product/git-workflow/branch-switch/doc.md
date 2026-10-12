# Branch switch

Move between branches, or start a new one, and watch the documents update — without a terminal.

**Status:** Shipped · Milestone M1

## Rules

- The current branch name is always visible — the branch control and the status bar carry it from the moment a space is open.
- **A repository on no branch says `Not on a branch`**, in both places, rather than being left blank. The word `detached` appears nowhere in the app.
- Switching branches updates every open document to the version on the new branch, and the tree and git are read again.
- A new branch can be created starting from the current one, and the app switches to it immediately. Where it started is recorded, and is what the diff is measured against ([branch diff](../../diff/branch-diff/doc.md)).
- **Enter in the name creates the branch**, as the button does.
- **A name git would not take is refused as it is typed**, under the field, and the button stays unavailable:

| The name | The field says |
|---|---|
| Holds a space, or one of `~ ^ : ? * [ \` | `Not a name git accepts` |
| Holds `..` or `@{`, or starts with `-` — git would read that one as an option | `Not a name git accepts` |
| Has an empty part between two `/`, or a part that starts with `.`, ends with `.` or ends in `.lock` | `Not a name git accepts` |
| Is a branch that already exists | `There is already a branch called that` |

- Switching is blocked if it would silently discard unsaved changes; the user is asked to save or discard first. The question names the document, and offers the third answer too — staying where you are. Closing the surface *is* staying, so the question can never be left standing behind something nobody can see.
- The question is asked in the switcher itself, not in a dialog over the window: it belongs to the control that raised it, and nothing else is blocked while it waits.

## Mocks

The switcher, and each of the three answers it can give.

- **branch switcher** — the branches, filtered by one box. [light](../../../design/screens/desktop/git-branches/branch-switcher-light.svg) · [dark](../../../design/screens/desktop/git-branches/branch-switcher-dark.svg).
- **starting a branch** — naming a new one from the current branch. [light](../../../design/screens/desktop/git-branches/the-branch-popover-states-light.svg) · [dark](../../../design/screens/desktop/git-branches/the-branch-popover-states-dark.svg).
- **unsaved work** — the question, inside the switcher, naming the document and offering stay. [light](../../../design/screens/desktop/git-branches/branch-switcher-unsaved-work-light.svg) · [dark](../../../design/screens/desktop/git-branches/branch-switcher-unsaved-work-dark.svg).
- **git refused** — what git said, said where it was asked, with the list still on screen. [light](../../../design/screens/desktop/git-branches/the-branch-popover-states-light.svg) · [dark](../../../design/screens/desktop/git-branches/the-branch-popover-states-dark.svg).
- **not on a branch — how it is named** — the branch control and the status bar. [light](../../../design/screens/desktop/git-branches/not-on-a-branch-how-it-is-named-states-light.svg) · [dark](../../../design/screens/desktop/git-branches/not-on-a-branch-how-it-is-named-states-dark.svg).

---

*See also: [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
