# Opening a change

What pressing a row of the changes list opens, whatever the file is.

**Status:** Draft · Milestone M3

## Rules

- **Every row opens, with the diff on** (2026-10-09) — pressing a change is asking to see it, and a row that cannot be pressed is a row nobody understands. It holds in both sections, `STAGED` and `CHANGES`.
- **A markdown document opens as a document, inside the space or not**: in its tab, the preview rendered, the diff drawn over the blocks ([rendered diff](../../../diff/README.md)). The list is the repository's, and a space opened on a subfolder would otherwise list changes it can never show.
- **Anything else opens in a text tab**: a file that is not markdown, wherever it is. Source only — `Split` and `Preview` unavailable, the formatting buttons dim, no `Diff` chip to turn off — as the [preferences file](../../../preferences/README.md) already opens.
- **The diff is by line**, because there is no rendered page to mark: the gutter carries `A` on an added line and `M` on a changed one, with the band behind them, and a removed run is a **seam** of `removed` between the lines it used to sit between — the source pane's own marks.
- **The base is the documents' base**: the branch this one came from, read at the fork point, and `HEAD` on the default branch ([branch diff](../../../diff/README.md)). One rule for every file in the app.
- **A file still on disk is editable**: typing marks the tab unsaved and saving writes it, as in any tab. The marks follow the buffer.
- **A deleted file opens its last committed version, read-only**: every line under the `removed` band, and the tab says it is gone.
- **The tab says it is gone with its name struck through, then `(deleted)`** (2026-10-09), in `removed` — VS Code's reading, with no band above the document.
- **The status bar says `Read-only`** in place of `Saved`; undo, redo and the formatting buttons are unavailable.
- **A deleted markdown document opens rendered** (2026-10-09): the last committed version in `Preview`, every block marked removed. `Source` and `Split` stay available and show its text the same way, every line under the `removed` band. No `Diff` chip: turning the marks off would leave an empty page. It is not a version being read — there is no `Back to now`, because there is no now to go back to.
- **A binary file opens a tab that says so** — `A binary file — not shown as text.` — with `Reveal in Finder`, rather than a page of noise. A file is binary when its first 8 KB hold a zero byte, git's own test, or when it does not read as UTF-8.
- The tree draws no open row for a file it does not list, and the status bar names the file's kind from its extension (`YAML`, `JSON`, `Plain text`).

## Mocks

Drawn on `11 · Screens: Git - Commit`, both themes, **not yet exported**:

- **a change that is not a document** — a text tab with the line marks.
- **a deleted file** — the last version, read-only, all of it removed.
- **a deleted document** — the last version rendered, every block removed.
- **a binary file** — the tab with its one sentence.

---

*See also: [commit/](../README.md) · [the changes list](../the-changes-list/doc.md) · [source mode](../../../editor/README.md)*
