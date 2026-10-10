# Platform: local infrastructure and the desktop shell

## Local infrastructure

| Package | License | Role |
|---|---|---|
| `sqlite3` + `sqlite3_flutter_libs` | MIT | FTS5 for full-text search — **in use**. The table is in memory, one per open space, so the bundled library is what provides FTS5 and nothing is written to disk ([runtime/search.md](../runtime/search.md)) |
| `watcher` | BSD-3 | Filesystem watching — external edits are an expected case |
| `path` | BSD-3 | Cross-platform paths |
| `dart:io` (`Process`) | SDK | The phase-1 Git integration; zero external dependencies |

## Desktop shell

| Package | License | Role |
|---|---|---|
| `window_manager` | MIT | Window control (title, minimum size, persisted position) |
| `file_selector` | BSD-3 | Native "open folder" dialog — **in use**, `^1.1.0`. A plugin, so it lives only in `tom_desktop`; nothing below takes a folder from anywhere but its own arguments |
| `url_launcher` | BSD-3 | Open external links from the preview in the browser |

## Terminal

Licences read on pub.dev on 2026-10-08 ([Decision 37](../decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).

| Package | License | Role |
|---|---|---|
| `flutter_pty` | MIT | The pseudo-terminal — **in use**, `^0.4.2`: `forkpty` on macOS and Linux, ConPTY on Windows. A plugin with native code, so only the spawn lives in `tom_desktop`; which shell and with what is `tom_infra`'s `pseudo_terminal/login_shell/` |
| `xterm` | MIT | The emulator and its widget — **in use**, `^4.0.0`, reached from one file (`screens/terminal/widgets/terminal_emulator_widget.dart`) |
| `zmodem`, `equatable` | MIT | `xterm`'s own |
| `quiver` | Apache-2.0 | `xterm`'s own |
| `convert`, `ffi` | BSD-3 | `xterm`'s and `flutter_pty`'s own |

## Settings: no package at all

| Rejected | Reason |
|---|---|
| ~~`shared_preferences`~~ | **Not taken.** It is a Flutter plugin, and settings belong to `tom_infra`, which is pure Dart so that six of the eight packages run under `dart test` ([Decision 14](../decisions/014-each-layer-is-its-own-package.md)). Taking it would push the capability up into `tom_desktop` to store a list of folder paths |
| ~~`path_provider`~~ | Also a Flutter plugin; the application-data folder comes from the platform's own conventions instead, behind the `PlatformPaths` capability |

App settings are one JSON file in the folder this platform keeps app data in —
this table's own second option. `JsonFileSettingsImpl` writes it through the
`Filesystem` capability, which already lands a file atomically.

- `Settings` keeps a JSON value under each key — an object stays an object, never JSON escaped inside a string — because the file opens in a tab and is edited by hand.
- A string holding a JSON object or list is the shape earlier builds wrote, and is read as what it holds; the next write rewrites the whole file in today's shape.
- A file that is not a JSON object is read as empty and never written over — what is in it is somebody's typing.
- The editor reads and saves the file as a document rooted in that folder, the same `DocumentRepositoryImpl` a space uses ([Decision 33](../decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md) for the pattern).

---

*See also: [runtime/search.md](../runtime/search.md) · [runtime/git.md](../runtime/git.md)*
