# Where it is stored

One file, in a format the user can read, and a button that opens it.

**Status:** Planned · Milestone M3

## Rules

- **Preferences are one JSON object**, in the folder the operating system gives the app for its own settings — not in the space, and not in any repository.
- **It is the store the app already writes**, so a new preference is a new key, never a new file and never a database ([files are the truth](../../../about.md)).
- **A missing file, a missing key or an unreadable value is the default**, silently. Losing the file loses a choice, never the app.
- **The popover has a button that opens the file**, because a settings format a user can read is a settings format a user will want to see.
- **It opens in TOM's own editor**, as a document like any other — source only, since it is not markdown to render.
- **Opening it puts a file from outside the tree on screen**, and that is allowed: the tree is the space, and this file is not in the space. It is a tab, so the way out is the way out of any tab.
- **Editing it by hand is supported, not protected**: the app reads it on the next start, and a value it cannot use falls back to the default rather than refusing to open.

## Mocks

- **preferences** — the popover with the button at its foot. [light](../../../design/screens/desktop/preferences/preferences-light.svg) · [dark](../../../design/screens/desktop/preferences/preferences-dark.svg).
- The file open in the editor is **not drawn yet** ([not-drawn-yet](../../../design/screens/not-drawn-yet.md)).

---

*See also: [preferences/](../README.md) · [what it holds](../what-it-holds/doc.md) · [source mode](../../editor/source-mode/doc.md)*
