# Architecture decisions

One decision per file, with a declarative name: **`ls` on this folder is the executive summary of the architecture** — you can tell what each decision is without opening a single file. Numbering keeps chronological order and gives a short reference in PRs ("that violates 007").

Internal format (known in the community as an *ADR — Architecture Decision Record*): Status · Context · Decision · Rationale · Consequences · (Revisit when). A new decision is a new file following the pattern; a reversed decision is never deleted — it gets the status "superseded by NNN".

## At a glance

| # | Decision |
|---|---|
| [001](001-license-is-mit.md) | License is MIT |
| [002](002-git-via-system-binary.md) | Git through the system binary first, libgit2 later |
| [003](003-editor-is-source-plus-preview.md) | The editor is source + preview; no WYSIWYG |
| [004](004-business-model-is-open-core.md) | The business model is open-core |
| [005](005-errors-use-result-with-sealed-classes.md) | Errors use Result with sealed classes; no `dartz` |
| [006](006-no-navigation-package.md) | No navigation package |
| [007](007-external-dependencies-behind-contracts.md) | Minimal coupling to external dependencies |
| [008](008-monorepo-with-pure-dart-core.md) | Monorepo with a build boundary between core and app |
| [009](009-space-session-is-single-source-of-truth.md) | The space session is the single source of truth in presentation |
| [010](010-watcher-and-git-cooperate-by-protocol.md) | The watcher and git operations cooperate by an explicit protocol |
| [011](011-telemetry-is-opt-in.md) | Observability behind a contract, telemetry opt-in |
| [012](012-shell-is-extensible-via-compile-time-modules.md) | The shell is extensible through compile-time modules |
| [013](013-stack-is-flutter-and-dart.md) | The stack is Flutter and Dart |
| [014](014-each-layer-is-its-own-package.md) | Each layer is its own package |
| [015](015-ddd-is-applied-selectively.md) | DDD is applied selectively |
| [016](016-freezed-is-mandatory-for-immutable-data.md) | Freezed is mandatory for immutable data classes |
| [017](017-tom-is-the-entry-point-and-make-is-a-face.md) | `tom` is the development entry point; `make` is a face over it |
| [018](018-source-mode-uses-re-editor.md) | Source mode is built on `re_editor` (the verdict of Spike A) |

---

*See also: [technical/](../README.md)*
