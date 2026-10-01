# What is searched

The scope, the index behind it, and what a typed string means.

**Status:** Shipped · Milestone M2

## Rules

- Search covers the **text content** of every markdown file in the space, not just file and folder names.
- Results are available offline and return quickly enough to type-ahead. **Search never depends on the network.**
- **The index is a cache**: deleting it and reopening the space rebuilds it from the files on disk, with no loss of information.
- **What is typed is words**, in any order, the last of them possibly half-typed. Never a query language, and no character a keyboard has means anything but a word or a separator.
- The best match is first, and the line above the results says how many documents matched.

Keeping FTS5's own syntax — `AND`, `"`, `*` — out of reach of the keyboard is
what the word rule buys; how the index is built is
[`technical/runtime/search.md`](../../../../technical/runtime/search.md).

---

*See also: [full-text-search/](../README.md) · [the-surface/](../the-surface/doc.md)*
