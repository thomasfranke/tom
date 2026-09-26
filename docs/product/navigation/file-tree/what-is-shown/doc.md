# What is shown

The tree describes the folder the user has, not a filtered version of it.

**Status:** Planned · Milestone M0

## Rules

- The tree shows every `.md` file in the space, including dotfolders such as `.ai/` and `.github/`.
- **Only `.git/` is hidden.** Nothing else is filtered out by default.
- A file the editor cannot open is still shown, and clicking it does nothing — that is every file that is not markdown, and every symbolic link.
- **The tree never follows a link** to find out where it goes: it may point outside the space, or at nothing.
- The document that is open is marked, so the tree also answers *where am I*.

---

*See also: [file-tree/](../README.md) · [order-and-shape/](../order-and-shape/doc.md)*
