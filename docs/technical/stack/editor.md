# Editor (source mode)

| Package | License | Role |
|---|---|---|
| `re_editor` | MIT | Desktop-oriented code editor — **chosen**, `^0.10.0` ([Decision 18](../decisions/018-source-mode-uses-re-editor.md)) |
| `re_highlight` | MIT | Syntax highlighting rules and themes; `re_editor` reads markdown through it |

> Spike A is answered. The fallback — a plain `TextField` — is **withdrawn**:
> measured side by side it misses 96% of frames while typing a 131KB document,
> against `re_editor`'s 0.6%. What `re_editor` does not ship is the
> find/replace panel and the selection toolbar; those are ours, and they have
> to be in TOM's visual language anyway.

The editor is a **tier 2** dependency: it is reached through our own wrapper
widget in the app, so swapping the package stays in one file
([`conventions/external-dependencies.md`](../conventions/external-dependencies.md)).
No WYSIWYG — the editor is source + preview
([Decision 3](../decisions/003-editor-is-source-plus-preview.md)).

---

*See also: [markdown-and-diff.md](markdown-and-diff.md) · [stack/](README.md)*
