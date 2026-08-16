# Product

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

### The cost this accepts

Git is a barrier to anyone who does not already use it, and pretending otherwise would be the easiest mistake available. A "sync" button that is a `git pull` wearing a costume teaches nobody anything and breaks in ways nobody can reason about — the abstraction leaks on the first conflict, and the person it was built for is now stuck in a situation they have no vocabulary for.

So the answer here is not to hide Git; it is to make the real thing legible. Name the operations, show what actually changed, put the irreversible ones behind a deliberate gesture. Someone who learns to branch and propose a change in TOM has learned to branch and propose a change — not a private dialect that works in one application. That is a slower path to adoption than pretending, and it is the one this project takes on purpose.

## Personas

- **Maintainer developer** — writes and reviews technical docs; wants documentation on the same lifecycle as the code (PR, review, CI).
- **Tech lead / staff engineer** — wants visibility: who changed what, when, in which PR; wants to retire Confluence.
- **The same developer, away from their machine** *(post-MVP)* — on a borrowed laptop with no toolchain, or on a phone, with a decision to record or a review to catch up on. Writing documentation needs a repository, markdown and git; it does not need a development environment. Today the alternative is to note it somewhere else and transcribe it later, which is exactly the copy this project refuses.
- **Semi-technical collaborator** *(post-MVP)* — a PM or QA who edits a page and proposes the change without knowing what a rebase is; sometimes writing first, so that a feature described by the person who asked for it reaches the repository before the code does. Proposing a change is a branch, a commit and a push with the pull request opened on the host — mechanically the same thing the developer does, with the ceremony removed.

## Killer features (the heart of the product)

> This section is the pitch-level summary. The detailed, evolving behavior rules for each feature live in [products/](../products/), one folder per feature — that is what implementation should be checked against.

1. **Rendered markdown diff** — changes shown over the *formatted* document (removed paragraph struck through, new paragraph highlighted), not `+/-` over raw text. No tool does this well today.
2. **Branch workflow without ceremony** — switch branches and watch the docs change; branch off for one edit; commit/push in a single gesture; a clear indication of being behind the remote.
3. **History and section blame** — "who wrote this paragraph, and in which commit/PR?", surfaced readably.
4. **Assisted conflict resolution** — both sides rendered side by side, choice per block.
5. **A documentation experience** — the file tree as space navigation, full-text search, wikilinks between documents, image support.

## Where a space lives

A space is a **folder**, not a repository. Most teams keep `docs/` inside the repository that holds the code, and a tool that demands a repository dedicated to documentation is asking them to move it — or worse, to copy it. TOM points at any folder inside a Git repository and works from there: git runs against the repository, while navigation and search stay inside the folder.

The same reasoning covers a kind of documentation that is easy to overlook. `CLAUDE.md`, `AGENTS.md`, `.claude/skills/` and the rest of the context a team hands to its coding agents are markdown in Git — so they are already documents TOM manages, with no feature added: a rendered diff of a change to the team's instructions, attribution to the pull request that made it, and a readable view for someone who will never open a terminal. All it asks of the file tree is not to hide dotfolders.

## Reading is not a lesser mode

The preview is not a convenience for whoever is editing. For anyone who does not write markdown by hand — and increasingly for documents drafted with an agent's help rather than typed — the rendered view *is* the product, and the editor is the part they never open. This changes nothing about storage (plain markdown on disk, always) and nothing about the MVP scope, but it settles a priority question: rendering quality is product work, not polish.

## Non-goals (equally important)

- WYSIWYG / block-based rich-text editing (Notion/AppFlowy territory)
- Real-time collaboration (the model is asynchronous, through Git)
- Databases / kanban / tasks
- Our own cloud sync (the Git remote **is** the sync)

> **Not a non-goal: mobile.** iOS and Android are a planned direction, post-1.0 — desktop still comes first, and nothing about the MVP scope changes. See the [roadmap](roadmap.md#phases) and [Decision 8](../decisions/008-monorepo-with-pure-dart-core.md), which already reserves the shape (`tom_infra_mobile` + `apps/tom_mobile` over the same pure-Dart core).

---

*See also: [roadmap.md](roadmap.md)*
