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
2. **One source, many views.** Documentation is never copied to be read by a different audience. The developer editing in VS Code, the reviewer reading a rendered diff in a pull request, and the person browsing in TOM are all looking at the same file on disk. A tool that requires a copy has already lost.
3. **Git is the backbone, not a plugin.** Branch, diff, commit, PR and history are the main UI, not a hidden menu.
4. **Local-first and offline-first.** No essential feature depends on the network. Sync is `git push/pull`.
5. **A deliberately simple editor.** Source mode + preview. WYSIWYG is not a goal (not even later, barring overwhelming demand). GitHub built collaboration without a rich editor.
6. **Open source (MIT) with a paid edition for convenience.** Individuals never pay; organizations pay for governance and comfort.

## The cost this accepts

Git is a barrier to anyone who does not already use it, and pretending otherwise would be the easiest mistake available. A "sync" button that is a `git pull` wearing a costume teaches nobody anything and breaks in ways nobody can reason about — the abstraction leaks on the first conflict, and the person it was built for is now stuck in a situation they have no vocabulary for.

So the answer here is not to hide Git; it is to make the real thing legible. Name the operations, show what actually changed, put the irreversible ones behind a deliberate gesture. Someone who learns to branch and propose a change in TOM has learned to branch and propose a change — not a private dialect that works in one application. That is a slower path to adoption than pretending, and it is the one this project takes on purpose.

---

*See also: [product.md](product.md) · [roadmap.md](roadmap.md)*
