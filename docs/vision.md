# Vision

Engineering teams keep their documentation as markdown inside Git repositories, yet today's tools force a bad trade-off:

| Current option | Problem |
|---|---|
| Confluence / Notion | Paid, cloud-bound, disconnected from the code, weak versioning |
| Obsidian + Git plugin | Git is a poorly integrated add-on; personal-notes focus; closed-source app |
| VS Code + extensions | Hostile to non-developers; no documentation experience (search, navigation, spaces) |
| MkDocs / Docusaurus | Read-only (generated site); editing still happens in a code editor |

**The bet:** the differentiator is not the editor — it is the **Git workflow as a first-class citizen**, designed for documentation. The quadrant "team docs + desktop + Git-native + open source" is empty.

## Principles

1. **Files are the truth.** The app reads and writes `.md` on disk. Any other tool (VS Code, vim, GitHub web) edits the same files without breaking anything. No proprietary database, no proprietary format.
2. **Git is the backbone, not a plugin.** Branch, diff, commit, PR and history are the main UI, not a hidden menu.
3. **Local-first and offline-first.** No essential feature depends on the network. Sync is `git push/pull`.
4. **A deliberately simple editor.** Source mode + preview. WYSIWYG is not a goal (not even later, barring overwhelming demand). GitHub built collaboration without a rich editor.
5. **Open source (MIT) with a paid edition for convenience.** Individuals never pay; organizations pay for governance and comfort.

---

*See also: [product.md](product.md) · [roadmap.md](roadmap.md)*
