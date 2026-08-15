# Dependency stack

Filter for every dependency: a **permissive license (MIT/BSD/Apache)** — the project ships under MIT ([Decision 1](../decisions/001-license-is-mit.md)) —, maturity, and desktop suitability. The license check is a PR checklist item.

## State and models

| Package | License | Role |
|---|---|---|
| `flutter_riverpod` + `riverpod_annotation` | MIT | State; providers per space/document/panel |
| `freezed` + `freezed_annotation` | MIT | Immutable entities and states (`GitStatus`, `Commit`, `DiffBlock`…) |
| `riverpod_generator`, `riverpod_lint`, `custom_lint`, `build_runner` | MIT | Dev-time (codegen and lints) |

## Markdown and diff (the heart)

| Package | License | Role |
|---|---|---|
| `markdown` | BSD-3 | The official Dart parser; exposes an AST (`Node`/`Element`) — the foundation of the preview and of diff v1 |
| `flutter_markdown_plus` | BSD | Renders the inline content **inside** a block; block-level layout and decoration are ours, which is what the rendered diff needs ([flows](flows.md#the-preview-is-assembled-block-by-block)) |
| `diff_match_patch` or `diffutil_dart` | Apache/MIT | Textual diff (Myers) for diff v0 and block alignment in v1 |
| `re_highlight` or `flutter_highlight` | MIT | Syntax highlighting for code blocks in the preview |

> If Spike B rules out the `markdown` package, the named fallbacks are our own block parser and, failing that, a Rust parser over `dart:ffi` ([Decision 13](../decisions/013-stack-is-flutter-and-dart.md)). Neither is in the stack today.

## Editor (source mode)

| Package | License | Role |
|---|---|---|
| `re_editor` | MIT | Desktop-oriented code editor — main candidate (**Spike A**, see [mvp.md](../product/mvp.md)) |
| *(fallback)* custom `TextField` | — | Plan B if the spike fails |

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
| `file_selector` | BSD-3 | Native "open folder" dialog |
| `url_launcher` | BSD-3 | Open external links from the preview in the browser |
| `shared_preferences` *(or JSON in app-support)* | BSD-3 | App settings (recent spaces, theme) |

## Deliberately excluded

| Excluded | Reason |
|---|---|
| `dartz` | Result pattern with native sealed classes ([Decision 5](../decisions/005-errors-use-result-with-sealed-classes.md); details in [layers.md](layers.md#errors-across-boundaries)) |
| `appflowy_editor` (and anything AGPL/GPL) | Contaminates the MIT license ([Decision 1](../decisions/001-license-is-mit.md)) |
| AutoRoute / any routing package | A panel-based desktop app has no navigation ([Decision 6](../decisions/006-no-navigation-package.md)) |
| Dio / `http` | There is no HTTP in the MVP; it arrives with layer 3 (remote APIs) when needed |
| `sqflite` | Mobile-oriented; on desktop, plain `sqlite3` |

> Every judgment on this page is scoped to the **desktop** app. iOS and Android arrive in Phase 3, post-1.0 ([roadmap](../product/roadmap.md#phases)), and get their own stack under `tom_infra_mobile` — `sqflite` and a touch-capable editor become live candidates there, and `re_editor` almost certainly does not travel. Nothing here is a verdict on mobile.

---

*See also: [architecture/](./) · [setup.md](../process/setup.md)*
