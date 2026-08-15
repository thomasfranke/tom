# TOM — Team-Oriented Markdown

> **A Git client specialized in documentation.** Your markdown files, your Git repository, and a UI that makes that workflow pleasant for an entire team — no mandatory cloud, no lock-in, no subscription.

## Documentation map

Four folders, one question each, plus the decision log that cuts across them.

| Folder | Answers | Contents |
|---|---|---|
| [product/](product/) | what is being built, and why | [vision](product/vision.md) · [product](product/product.md) · [mvp](product/mvp.md) · [roadmap](product/roadmap.md) |
| [architecture/](architecture/) | how it is built | one folder per package, mirroring `src/packages/`, plus [dependencies](architecture/dependencies.md) |
| [design/](design/) | what it looks like | [wireframes](design/README.md) per screen · [visual language](design/visual-language.md) |
| [process/](process/) | how the work is done | [setup](process/setup.md) · [versioning](process/versioning.md) · [repository settings](process/repository-settings.md) |
| [decisions/](decisions/) | what was settled, and why | ADRs, one per file, declaratively named |

`decisions/` sits outside the four on purpose: 001 is about licensing, 004 about the business model, 013 about the stack. They belong to no single folder, and keeping the log flat is the ADR convention.

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
| [008](decisions/008-monorepo-with-pure-dart-core.md) | Monorepo with a pure Dart core *(partly superseded by 014)* |
| [009](decisions/009-space-session-is-single-source-of-truth.md) | The space session is the single source of truth |
| [010](decisions/010-watcher-and-git-cooperate-by-protocol.md) | The watcher and git cooperate by an explicit protocol |
| [011](decisions/011-telemetry-is-opt-in.md) | Telemetry is opt-in, no-op by default |
| [012](decisions/012-shell-is-extensible-via-compile-time-modules.md) | The shell is extensible through compile-time modules |
| [013](decisions/013-stack-is-flutter-and-dart.md) | The stack is Flutter and Dart |
| [014](decisions/014-each-layer-is-its-own-package.md) | Each layer is its own package |
| [015](decisions/015-ddd-is-applied-selectively.md) | DDD is applied selectively |

## Where the code is

The Dart workspace lives in [`src/`](../src/), so this folder and the licence lead the repository root rather than build files. Seven packages, one per layer; `make help` from the root lists every command.

---

*This documentation lives in `docs/` inside the repo itself, as markdown — the app should, as soon as possible, be used to edit its own docs.*
