# Where it is stored

One file, in a format the user can read, and a button that opens it.

**Status:** Shipped · Milestone M3 — ~~except the button that opens the file, which is drawn and dim~~: it opens the file in a tab (2026-10-08)

## Rules

- **Preferences are one JSON object**, in the folder the operating system gives the app for its own settings — not in the space, and not in any repository.
- **It is the store the app already writes**, so a new preference is a new key, never a new file and never a database ([files are the truth](../../../about.md)).
- **A missing file, a missing key or an unreadable value is the default**, silently. Losing the file loses a choice, never the app.
- **The popover has a button that opens the file**, because a settings format a user can read is a settings format a user will want to see.
- **It opens in TOM's own editor**, as a document like any other — source only, since it is not markdown to render.
- **Opening it puts a file from outside the tree on screen**, and that is allowed: the tree is the space, and this file is not in the space. It is a tab, so the way out is the way out of any tab.
- **Editing it by hand is supported, not protected**: ~~the app reads it on the next start~~ **saving it applies it** (revised 2026-10-08) — theme, language and the bar change on save, as they do from the popover — and a value it cannot use falls back to the default rather than refusing to open.
- **It is written to be read**: each key holds plain JSON — an object, a list — never JSON escaped inside a string, so what the tab shows is what a person would write.
- **The tab is source only**: `Split` and `Preview` are unavailable, the formatting buttons are dim, and there is no `Diff`, because the file is in no repository.
- **Opening it writes what is in force first**, unless its tab is already open — a machine that never chose anything still finds its three preferences in the file.
- **A choice in the popover reaches an open tab** — with no unsaved edit the tab reads the file again; with one, the choice applies on screen and a band over the tab says the file changed on disk, offering `Keep mine` and `Reload`.
- **On Home the button is dim** — there is no tab strip to open it into until a space is open.
- **Saving text that is not JSON writes it anyway** — it is the person's file; the preferences fall back to their defaults until it reads again.
- **A file that is not a JSON object is never written over** — a choice made meanwhile applies on screen and is not remembered between runs, rather than deleting what was typed.

## Mocks

- **preferences** — the popover with the button at its foot. [light](../../../design/screens/desktop/preferences/preferences-light.svg) · [dark](../../../design/screens/desktop/preferences/preferences-dark.svg).
- **preferences file open** — the file in a tab of its own, source only, no row of the tree open. [light](../../../design/screens/desktop/preferences/preferences-file-open-light.svg) · [dark](../../../design/screens/desktop/preferences/preferences-file-open-dark.svg).

---

*See also: [preferences/](../README.md) · [what it holds](../what-it-holds/doc.md) · [source mode](../../editor/source-mode/doc.md)*
