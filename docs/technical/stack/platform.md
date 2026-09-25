# Platform: local infrastructure and the desktop shell

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

## Settings: no package at all

| Rejected | Reason |
|---|---|
| ~~`shared_preferences`~~ | **Not taken.** It is a Flutter plugin, and settings belong to `tom_infra`, which is pure Dart so that six of the eight packages run under `dart test` ([Decision 14](../decisions/014-each-layer-is-its-own-package.md)). Taking it would push the capability up into `tom_desktop` to store a list of folder paths |
| ~~`path_provider`~~ | Also a Flutter plugin; the application-data folder comes from the platform's own conventions instead, behind the `PlatformPaths` capability |

App settings are one JSON file in the folder this platform keeps app data in —
this table's own second option. `JsonFileSettingsImpl` writes it through the
`Filesystem` capability, which already lands a file atomically.

---

*See also: [runtime/search.md](../runtime/search.md) · [runtime/git.md](../runtime/git.md)*
