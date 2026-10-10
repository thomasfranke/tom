# Decision 37 — The Terminal tab is the person's own shell in a pseudo-terminal, emulated by `xterm` and opened by `flutter_pty`

**Status:** draft, on the maintainer's calls of 2026-10-08.

## Context

The panel under the document ([Decision 36](036-every-command-is-written-down.md)) was built for a second tab. The [Terminal](../../product/workspace/terminal/doc.md) is it: the person's own shell, with their own configuration, drawn inside TOM so what the app does not do is still a `git` command away without a second window. That needs a pseudo-terminal — a shell on a pipe answers like a script, not like a prompt — and an emulator that understands what a shell draws.

Three constraints shape where the pieces go:

- **Rule 1.** Read on pub.dev today: [`xterm`](https://pub.dev/packages/xterm) 4.0.0 is **MIT**, and so are its own `zmodem` and `equatable`; its `quiver` is **Apache-2.0** and `convert` **BSD-3-Clause**. [`flutter_pty`](https://pub.dev/packages/flutter_pty) 0.4.2 is **MIT**, its `ffi` **BSD-3-Clause**, and its native code is its own (`forkpty` on macOS and Linux, ConPTY on Windows). Nothing copyleft.
- **`tom_infra` is pure Dart** ([Decision 14](014-each-layer-is-its-own-package.md)), and both packages are Flutter's — `flutter_pty` a plugin with native code, `xterm` a widget library.
- **A capability is a folder with its contract and an implementation** ([Decision 24](024-a-capability-is-a-folder.md)), and external dependencies stay behind contracts ([Decision 7](007-external-dependencies-behind-contracts.md)).

## Decision

**A `pseudo_terminal` capability in `tom_infra` holds the contract and every decision about the shell; the one thing only a Flutter plugin can do — open the pty — is handed to it from the composition root.**

```
tom_infra/lib/src/pseudo_terminal/
  pseudo_terminal.dart                  start(folder, columns, rows) → a process
  pseudo_terminal_process.dart          bytes out, bytes in, resize, kill, exit code
  pseudo_terminal_failure.dart          unavailable · startFailed
  login_shell/                          which shell, its arguments, its environment;
                                        the spawn is a constructor parameter
tom_desktop/lib/bootstrap/
  flutter_pty_pseudo_terminal_process_impl.dart   the spawn: `Pty.start`, wrapped
tom_desktop/lib/screens/terminal/widgets/
  terminal_emulator_widget.dart         the one file that imports `xterm`
```

- **The pattern is `BundledFacesPdfExporter`'s**: the logic is in `tom_infra`, tested under `dart test` against a spawn that only records; the composition root supplies the piece Flutter owns and wires it. The rule that a capability holds an implementation folder holds — `login_shell/` is the implementation, and the plugin is its parameter.
- **The shell is the person's**: `$SHELL` (a login shell on macOS, as Terminal.app starts it, because an app opened from the Finder has launchd's bare `PATH`), else `/bin/zsh`; `$SHELL`, else `bash`, else `sh` on Linux; PowerShell, else `%ComSpec%`, on Windows. It gets the app's whole environment, plus `TERM=xterm-256color` and a UTF-8 `LANG` when none was set.
- **The layers above are the usual ones**: `TerminalRepository` and `TerminalSessionPort` in the domain (text both ways, decoded in `tom_data` with one decoder per stream), `StartTerminalUseCase` (the repository's root, not the space's folder), and `TerminalNotifier` in presentation — kept alive, one shell per space, started on the tab's first drawing, ended with the space.
- **The emulator is a widget's; the shell and what it drew are the notifier's.** The panel is built only while its tab is chosen, so each panel builds a new `xterm` `Terminal` and replays the notifier's transcript (the last 256 K characters) before it listens — before, so a question the shell asked long ago is not answered into it again.
- **Nothing typed reaches the `CommandLog`.** The capability takes none.

## Rationale

- Putting the shell rules in `tom_infra` keeps them under `dart test` and next to the contract; moving the whole capability into `tom_desktop` would have made the one rule that reads the environment untestable without a device.
- A transcript in presentation rather than a long-lived emulator: the emulator is a Flutter type and presentation is pure Dart, and keeping one alive in the composition root would be state the session does not own.
- `xterm` and `flutter_pty` are one author's pair, maintained together, and the only MIT emulator-and-pty set on pub.dev that runs on all three desktops.

## Consequences

- `tom_desktop` carries a native plugin; the macOS Podfile builds it like `sqlite3_flutter_libs`. The app being unsandboxed ([Decision 20](020-the-macos-app-is-not-sandboxed.md)) is what lets `forkpty` start the person's shell at all.
- The shell dies with the app even when nothing disposes it: closing the pty's master sends it a hangup.
- `xterm` 4.0.0 was published in February 2024 and `flutter_pty` 0.4.2 in January 2025. A fork, or a replacement, stays inside the two files named above.

## Revisit when

- `xterm` or `flutter_pty` stops building on a supported Flutter, or a desktop drops one of the two pty mechanisms.
- A second terminal per space is asked for — the notifier holds one shell by design.
