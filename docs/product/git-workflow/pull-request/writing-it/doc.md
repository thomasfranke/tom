# Writing it

The page that takes the editor, and what is in the draft before anybody types.

**Status:** Planned · Milestone M3

## Rules

- **The pull request is written in TOM, because its description is markdown.** The same source pane, the same preview and the same [formatting shortcuts](../../../editor/formatting-shortcuts/doc.md) the rest of the app has. Leaving a markdown tool to write markdown in a browser textarea is the thing this tool exists to stop.
- **The page takes the whole editor, and the tab strip goes with it.** What it replaces is not a document among the open ones; the row the tabs had becomes the status row, so the chrome keeps its height and the document area keeps its width.
- **The screen carries what a plain document cannot**: the base it is proposed onto, what the branch has done, and the one action that opens it. Everything else on it is the editor, unchanged.
- **The title is the document's first heading, not a field.** A pull request written as markdown has a title the way every markdown document does — the `#` on its first line — so there is no box above the editor and nothing to keep in step with it.
- **The draft starts filled, from git.** The heading is the branch's first commit subject and the body is the subjects between base and head — nothing invented and nothing fetched, because git already knows. All of it is editable, and a draft with no heading is the one thing that stops the button.

## Mocks

- **writing a pull request** — [light](../../../../design/screens/desktop/git-pull-request/writing-a-pull-request-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/writing-a-pull-request-dark.svg).

---

*See also: [pull-request/](../README.md) · [the draft](../the-draft/doc.md) · [the right column](../the-right-column/doc.md)*
