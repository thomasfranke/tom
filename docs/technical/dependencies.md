# Dependency stack

Filter for every dependency: a **permissive license (MIT/BSD/Apache)** — the project ships under MIT ([Decision 1](decisions/001-license-is-mit.md)) —, maturity, and desktop suitability. The license check is a PR checklist item.

## State and models

| Package | License | Role |
|---|---|---|
| `flutter_riverpod` (app) + `riverpod` (presentation) | MIT | State; providers per space/document/panel. Two packages, one split: `tom_presentation` is pure Dart and takes the plain `riverpod`, the app takes the Flutter one. **Pinned exactly at 3.2.1**, because `riverpod_annotation` pins the runtime it generates against and the pair moves together. Note that Riverpod 3 does not export `Override` from its main barrel — it is in `misc.dart`, and `select` is in the runtime package rather than in `riverpod_annotation` |
| `freezed` + `freezed_annotation` | MIT | Mandatory for immutable entities, multi-field value objects, view-state and sealed hierarchies ([Decision 16](decisions/016-freezed-is-mandatory-for-immutable-data.md)) — `GitStatusValueObject`, `CommitEntity`, `DiffBlock`… as they get built; already in use for the `AppFailure` hierarchies (`GitFailure`, `DocumentFailure`, `SearchFailure`, `FilesystemFailure`) in `tom_core`/`tom_domain`/`tom_infra` |
| `riverpod_annotation` + `riverpod_generator`, `build_runner` | MIT | Every provider is generated from an annotation — a `@riverpod` function for a seam, a `@riverpod class` for a notifier, which is what names `homeProvider` after `Home`. Both pinned exactly, like `freezed`: a generator that moves on its own writes a diff nobody asked for |

## Markdown and diff (the heart)

| Package | License | Role |
|---|---|---|
| `markdown` | BSD-3 | The official Dart parser — **chosen**, `^7.3.0` ([Decision 19](decisions/019-blocks-come-from-the-markdown-package.md)). The AST has no source positions; they are recovered by extending each block syntax. It belongs to `tom_infra`, behind the `MarkdownParser` capability: text in, spans out, and no package type above it |
| `flutter_markdown_plus` | BSD-3 | Renders the inline content **inside** a block — **in use**, `^1.0.12`. One `MarkdownBody` per block, never one for the document: block-level layout and the container around each block are ours, which is what the rendered diff needs ([flows](flows.md#the-preview-is-assembled-block-by-block)) |
| `diffutil_dart` | Apache-2.0 | Myers over lists — **chosen**, `^5.0.0` ([Decision 27](decisions/027-blocks-are-aligned-by-myers-and-paired-by-words.md)). It belongs to `tom_infra`, behind the `TextDiffer` capability: sequences of text in, positions out. Its `equalityChecker` is what lets a *rewrite* be recognised as one, since blocks carry no identity. `diff_match_patch` was the alternative and rules itself out: 0.4.1 declares SDK `<3.0.0` |
| `re_highlight` | MIT | Syntax highlighting for code blocks in the preview — **in use**, `^0.0.3`, and no longer a choice between two since `re_editor` brings the same one ([Decision 18](decisions/018-source-mode-uses-re-editor.md)). A language it does not know is drawn unstyled rather than guessed at |

> Spike B is answered and **neither fallback is taken** — no hand-written block parser, no Rust parser over `dart:ffi` ([Decision 13](decisions/013-stack-is-flutter-and-dart.md)). What the package costs instead is one subclass per block syntax to recover positions, and a footnote in an isolated block that renders as literal text.

## Editor (source mode)

| Package | License | Role |
|---|---|---|
| `re_editor` | MIT | Desktop-oriented code editor — **chosen**, `^0.10.0` ([Decision 18](decisions/018-source-mode-uses-re-editor.md)) |
| `re_highlight` | MIT | Syntax highlighting rules and themes; `re_editor` reads markdown through it |

> Spike A is answered. The fallback — a plain `TextField` — is **withdrawn**: measured side by side it misses 96% of frames while typing a 131KB document, against `re_editor`'s 0.6%. What `re_editor` does not ship is the find/replace panel and the selection toolbar; those are ours, and they have to be in TOM's visual language anyway.

## Local infrastructure

| Package | License | Role |
|---|---|---|
| `sqlite3` + `sqlite3_flutter_libs` | MIT | FTS5 for full-text search (the bundled library is built with FTS5) |
| `watcher` | BSD-3 | Filesystem watching — external edits are an expected case |
| `path` | BSD-3 | Cross-platform paths |
| `dart:io` (`Process`) | SDK | The phase-1 Git integration; zero external dependencies |

## Desktop shell

| Package | License | Role |
|---|---|---|
| `window_manager` | MIT | Window control (title, minimum size, persisted position) |
| `file_selector` | BSD-3 | Native "open folder" dialog — **in use**, `^1.1.0`. A plugin, so it lives only in `tom_desktop`; nothing below takes a folder from anywhere but its own arguments |
| `url_launcher` | BSD-3 | Open external links from the preview in the browser |
| ~~`shared_preferences`~~ | — | **Not taken.** It is a Flutter plugin, and settings belong to `tom_infra`, which is pure Dart so that six of the seven packages run under `dart test` ([Decision 14](decisions/014-each-layer-is-its-own-package.md)). Taking it would push the capability up into `tom_desktop` to store a list of folder paths |
| *(no package)* | — | App settings are one JSON file in the folder this platform keeps app data in — this table's own second option. `JsonFileSettingsImpl` writes it through the `Filesystem` capability, which already lands a file atomically; the folder comes from the platform's conventions rather than from `path_provider`, another Flutter plugin |

## Deliberately excluded

| Excluded | Reason |
|---|---|
| `dartz` | Result pattern with native sealed classes ([Decision 5](decisions/005-errors-use-result-with-sealed-classes.md); details in [layers.md](layers.md#errors-across-boundaries)) |
| `appflowy_editor` (and anything AGPL/GPL) | Contaminates the MIT license ([Decision 1](decisions/001-license-is-mit.md)) |
| AutoRoute / any routing package | A panel-based desktop app has no navigation ([Decision 6](decisions/006-no-navigation-package.md)) |
| Dio / `http` | There is no HTTP in the MVP; it arrives with layer 3 (remote APIs) when needed |
| `sqflite` | Mobile-oriented; on desktop, plain `sqlite3` |

> Every judgment on this page is scoped to the **desktop** app. iOS and Android arrive in Phase 3, post-1.0 ([roadmap](../roadmap.md#phases)), and get their own stack under `tom_infra_mobile` — `sqflite` and a touch-capable editor become live candidates there, and `re_editor` almost certainly does not travel. Nothing here is a verdict on mobile.

---

*See also: [technical/](README.md) · [setup.md](setup.md)*
