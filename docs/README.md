# TOM — Team-Oriented Markdown

> **A Git client specialized in documentation.** Your markdown files, your Git repository, and a UI that makes that workflow pleasant for an entire team — no mandatory cloud, no lock-in, no subscription.

## Documentation map

| Folder / file | Contents |
|---|---|
| [vision.md](vision.md) | Vision, market, the bet and the principles |
| [product.md](product.md) | Personas, killer features and non-goals |
| [mvp.md](mvp.md) | Spikes and MVP milestones |
| [design/](design/) | Wireframes: one screen per state, low fidelity |
| [architecture/](architecture/) | System design: layers, monorepo, Result, infrastructure, presentation, testing (numbered files in reading order) |
| [decisions/](decisions/) | Architecture decisions, one per file, declaratively named (ADR format) |
| [patterns/](patterns/) | Canonical code patterns (how it is written here) |
| [dependencies.md](dependencies.md) | Dependency stack with licenses and deliberate exclusions |
| [roadmap.md](roadmap.md) | Phases, risks and open questions |
| [versioning.md](versioning.md) | What counts as a breaking change, when 1.0 is cut, deprecation policy |
| [setup.md](setup.md) | Development setup and conventions |
| [repository-settings.md](repository-settings.md) | GitHub configuration: permissions, branch and tag protection, Actions settings |

## Decisions at a glance

| # | Decision |
|---|---|
| [001](decisions/001-license-is-mit.md) | License is MIT |
| [002](decisions/002-git-via-system-binary.md) | Git through the system binary (libgit2 later) |
| [003](decisions/003-editor-is-source-plus-preview.md) | The editor is source + preview; no WYSIWYG |
| [004](decisions/004-business-model-is-open-core.md) | The business model is open-core |
| [005](decisions/005-errors-use-result-with-sealed-classes.md) | Errors use Result with sealed classes; no dartz |
| [006](decisions/006-no-navigation-package.md) | No navigation package |
| [007](decisions/007-external-dependencies-behind-contracts.md) | External dependencies isolated behind contracts |
| [008](decisions/008-monorepo-with-pure-dart-core.md) | Monorepo with a pure Dart core |
| [009](decisions/009-space-session-is-single-source-of-truth.md) | The space session is the single source of truth |
| [010](decisions/010-watcher-and-git-cooperate-by-protocol.md) | The watcher and git cooperate by an explicit protocol |
| [011](decisions/011-telemetry-is-opt-in.md) | Telemetry is opt-in, no-op by default |
| [012](decisions/012-shell-is-extensible-via-compile-time-modules.md) | The shell is extensible through compile-time modules |
| [013](decisions/013-stack-is-flutter-and-dart.md) | The stack is Flutter and Dart |

---

*This documentation lives in `docs/` inside the repo itself, as markdown — the app should, as soon as possible, be used to edit its own docs.*
