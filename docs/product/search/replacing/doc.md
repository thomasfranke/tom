# Replacing what was found

Changing the words the search found, in the document on screen.

**Status:** Planned · Milestone M3

## Rules

- **A replacement writes into the buffer and never to disk.** Saving is somebody's decision, and a tool that wrote the file because a word was replaced would have saved on their behalf.
- Replacing is offered **only for `This file`**. The whole space is read from the index and the documents behind it are not open, so there is no buffer to write into.
- The chevron that opens it is drawn in either scope, and **opening it moves the question to `This file`** — the act says which scope is meant, so nothing has to refuse afterwards.
- **Each occurrence carries its own action**, beside a way to dismiss it. There is no pair of buttons under the fields deciding for all of them.
- Those two are drawn **on the current occurrence only** — the one the pointer is on, which is also the one wearing the pill. A pair of buttons per row, times fifty rows, is a hundred controls nobody asked for.
- **`Replace all` sits beside the count**, which is what says how many it is about to change.
- **A replacement verifies before it writes.** If the text at that occurrence is no longer what the occurrence said, it does not apply and the occurrence leaves the list — a stale position that wrote anyway would corrupt the document rather than miss.
- An occurrence shows the change before it is made: **the old words struck through in the removed role, the new ones straight after them in the added role** — the pair the diff already uses, in the order the text would read.
- **The replacement box may be empty**, and an empty one deletes what matched. That is a replacement like any other and needs no second control.

- **A replacement is undone by the editor's own undo**, not by a control of its own. It is written into the buffer the way a keystroke is, so `⌘Z` walks back through it like any other edit — including `Replace all`, which is one step back rather than one per occurrence.

## Mocks

- **replacing what was found** — [light](../../../design/screens/desktop/search/searching-replace-light.svg) · [dark](../../../design/screens/desktop/search/searching-replace-dark.svg).

---

*See also: [search/](../README.md) · [finding in the document](../in-the-document/doc.md)*
