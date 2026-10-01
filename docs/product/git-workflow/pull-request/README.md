# Opening a pull request

Writing and opening the pull request for the branch that was just pushed,
without leaving the tool.

**Status:** Planned · Milestone M3

| | |
|---|---|
| [`the-control/`](the-control/doc.md) | The row at the top of the tree, what pressing it does, and where it is not drawn |
| [`writing-it/`](writing-it/doc.md) | The page that takes the editor, the title as the first heading, and what the draft starts as |
| [`the-draft/`](the-draft/doc.md) | The draft as a file on disk, one per branch, and how long it lives |
| [`the-right-column/`](the-right-column/doc.md) | The two segments, and where each number in the overview comes from |
| [`opening-it/`](opening-it/doc.md) | The token, the request to the host, and the link when there is no token |
| [`when-it-cannot-be-opened/`](when-it-cannot-be-opened/doc.md) | The status row, the default branch, and uncommitted work |

## What is deliberately not here

Reading, reviewing and merging. Comments, approvals and checks are the host's
model, none of it is markdown in the repository, and a tool that renders a
review thread has become a second product.

## Mocks

- **writing a pull request** — the page with the whole editor, the status row where the tabs were, and the branch's own column. [light](../../../design/screens/desktop/git-pull-request/writing-a-pull-request-light.svg) · [dark](../../../design/screens/desktop/git-pull-request/writing-a-pull-request-dark.svg).
- **cannot open yet** — uncommitted work, the row in `removed`, and both actions unavailable. [light](../../../design/screens/desktop/git-pull-request/cannot-open-yet-light.svg) · [dark](../../../design/screens/desktop/git-pull-request/cannot-open-yet-dark.svg).
- **branch overview** — the same column with the second segment chosen. [light](../../../design/screens/desktop/git-pull-request/branch-overview-light.svg) · [dark](../../../design/screens/desktop/git-pull-request/branch-overview-dark.svg).

**Two screens were drawn and deleted**, and why is worth keeping: a band offering
the pull request after a push, which was a second place to open one; and a band
on the default branch explaining that there is nothing to propose, which is a
control drawn as a sentence. Neither needs a screen — the first is the button
that is always there, the second is the button that is not.

---

*See also: [product/](../../README.md) · [push-pull/](../push-pull/README.md) · [about.md](../../../about.md) · [roadmap.md](../../../roadmap.md)*
