# MVP scope

**Goal of the MVP:** publicly demonstrate (HN / Reddit / Discord) that "rendered diff + a comfortable Git workflow" solves a real pain. The minimum slice a developer can try on a real repo in five minutes.

## Spikes (before M0 — the only two real technical unknowns)

> Timebox: about one weekend each. Goal: decide, not build.

- [ ] **Spike A — Editor:** can `re_editor` carry source mode? Test with a 2000+ line md file, desktop shortcuts, selection, find/replace, typing latency. If it fails → fall back to a custom `TextField`.
- [ ] **Spike B — The `markdown` AST:** does the package AST (`Node`/`Element`) carry enough information (source positions, block granularity) for the block diff (v1)? Test: parse two sibling md files, align blocks, classify unchanged/added/removed/modified. If insufficient → evaluate our own parser or enrich the AST through post-processing. **The questions this spike must answer are listed in [architecture/08-domain-model.md](../architecture/domain/model.md) — read them before starting; the shape of `Block` is the spike's main deliverable, and whether a block can be rendered in isolation decides how the preview is assembled.**

## Milestone 0 — Foundation

> Layout for everything below: [design/](../design/) — `empty-state` and `shell` are the M0 screens.

- [ ] **Extensible shell**: `runTom(modules: [])` + panels registered through `PanelDescriptor` (including the built-in ones, via `CoreModule`) — see [patterns/extension-modules.md](../architecture/presentation/extension-modules.md)
- [ ] Open a local folder inside a Git repo (a "space") — the repository root or any subfolder of it
- [ ] `.md` file tree with navigation, dotfolders included (`.claude/`, `.github/`); only `.git/` is hidden
- [ ] Markdown rendering (read-only preview), assembled block by block: headings, lists, tables, highlighted code blocks, local images, links
- [ ] Source-mode editing with preview alongside (split view)
- [ ] Save to disk (files are the truth)

## Milestone 1 — Essential Git

- [ ] Status: modified/new/deleted files visible in the UI
- [ ] Commit with a message (simplified staging: everything, or per file)
- [ ] Pull / push / fetch with ahead/behind indication
- [ ] Switch branches; create a branch
- [ ] History of the current file (the commits that touched it)

## Milestone 2 — The differentiator

- [ ] **Rendered diff** between the working tree and HEAD (v1: block diff — added, removed and modified paragraphs/headings highlighted in the preview)
- [ ] Diff between branches / between commits for a file
- [ ] Full-text search inside the space (SQLite FTS5)

## Milestone 3 — Launch polish

- [ ] Wikilinks `[[document]]` with autocomplete and navigation
- [ ] Editor conveniences: buttons and shortcuts that insert syntax (bold, italic, list, link) — the source stays visible ([Decision 3](../decisions/003-editor-is-source-plus-preview.md))
- [ ] **Export a document as PDF or HTML** — free, always. A reader who cannot get a document out of the app is held hostage by it, which contradicts the first principle in [vision.md](vision.md). Budget for it properly: [Decision 13](../decisions/013-stack-is-flutter-and-dart.md) records that PDF falls out of a web stack for nothing and is a separate problem in Flutter
- [ ] Onboarding: clone a repo by URL from inside the app
- [ ] Packaging: Windows (msix), macOS (dmg), Linux (AppImage/deb)
- [ ] Landing page + a polished README + a GIF of the rendered diff

## Out of the MVP (backlog)

Assisted conflict resolution, section blame, multiple open spaces, an example space repo for onboarding, themes.

---

*See also: [architecture/](../architecture/) · [roadmap.md](roadmap.md)*
