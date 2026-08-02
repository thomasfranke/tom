# MVP scope

**Goal of the MVP:** publicly demonstrate (HN / Reddit / Discord) that "rendered diff + a comfortable Git workflow" solves a real pain. The minimum slice a developer can try on a real repo in five minutes.

## Spikes (before M0 — the only two real technical unknowns)

> Timebox: about one weekend each. Goal: decide, not build.

- [ ] **Spike A — Editor:** can `re_editor` carry source mode? Test with a 2000+ line md file, desktop shortcuts, selection, find/replace, typing latency. If it fails → fall back to a custom `TextField`.
- [ ] **Spike B — The `markdown` AST:** does the package AST (`Node`/`Element`) carry enough information (source positions, block granularity) for the block diff (v1)? Test: parse two sibling md files, align blocks, classify unchanged/added/removed/modified. If insufficient → evaluate our own parser or enrich the AST through post-processing. **The four questions this spike must answer are listed in [architecture/08-domain-model.md](architecture/08-domain-model.md) — read them before starting; the shape of `Block` is the spike's main deliverable.**

## Milestone 0 — Foundation

- [ ] **Extensible shell**: `runTom(modules: [])` + panels registered through `PanelDescriptor` (including the built-in ones, via `CoreModule`) — see [patterns/extension-modules.md](patterns/extension-modules.md)
- [ ] Open a local folder that is a Git repo (a "space")
- [ ] `.md` file tree with navigation
- [ ] Markdown rendering (read-only preview): headings, lists, tables, highlighted code blocks, local images, links
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
- [ ] Onboarding: clone a repo by URL from inside the app
- [ ] Packaging: Windows (msix), macOS (dmg), Linux (AppImage/deb)
- [ ] Landing page + a polished README + a GIF of the rendered diff

## Out of the MVP (post-validation backlog)

Assisted conflict resolution, section blame, PR integration (GitHub/GitLab API), multiple spaces with unified search, read-only mode over an embedded web server, an example space repo for onboarding, themes.

---

*See also: [architecture/](architecture/) · [roadmap.md](roadmap.md)*
