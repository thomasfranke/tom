# Known divergence

**What shipped is behind the boards.** The rules in
[`the-surface/`](../the-surface/doc.md) are the standard; the surface that was
built is not there yet.

**Status:** Open · the maintainer's call

## What is different

| The boards say | What shipped |
|---|---|
| Search whole in the left column | The box above the file tree, the results in the right column above git |
| A `This file · Whole space` choice, always visible | Whole space only, no scope control |
| Finding occurrences inside the open document | Not built |
| Replacing them | Not built |

## What closing it means

- Moving the results into the left column beside the box, which leaves the right column with changes and history alone.
- Replacing is drawn **per line**, each match carrying its own action, with a **Replace all** beside the count of occurrences. There is no pair of buttons under the fields.

The surface was built against an earlier `searching` board, which was replaced
by three while it was being built. The maintainer chose to review that rather
than rebuild the surface in the same session.

---

*See also: [full-text-search/](../README.md) · [the-surface/](../the-surface/doc.md)*
