# The control

The row that opens the draft, and where it is not drawn.

**Status:** Shipped · Milestone M3

## Rules

- **The control is a shortcut to that document, not a form that appears.** Pressing it opens the draft the branch already has, the same way pressing a file in the tree opens the file; nothing is created on the way in and nothing is lost on the way out.
- **It sits at the top of the file tree, between two hairlines.** It reads as a document row and highlights like one when it is the open document, because that is what it is; the rules above and below say the one thing a row cannot — that this is not a file in the space. It is not drawn where the column shows something other than the tree, which is the search results and a closed column.
- **A push that lands offers no pull request in its band** — the row is always there, and a second place to open one is one too many. The one band that does is the refusal of a protected branch, where it is the remedy ([when it fails](../../push-pull/when-it-fails/doc.md)).

## Mocks

- **writing a pull request** — the row at the top of the tree, highlighted as the open document. [light](../../../../design/screens/desktop/git-pull-request/writing-a-pull-request-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/writing-a-pull-request-dark.svg).
- **pull request row — states, in the explorer** — available · open · on the default branch · unknown host · no remote · still being read. [light](../../../../design/screens/desktop/git-pull-request-not-ready/pull-request-row-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request-not-ready/pull-request-row-states-dark.svg).

---

*See also: [pull-request/](../README.md) · [the draft](../the-draft/doc.md) · [file tree](../../../navigation/file-tree/README.md)*
