# Decision 37 — The Terminal tab is the person's own shell in a pseudo-terminal, emulated by `xterm` and opened by `pty2`

**Status:** accepted (2026-10-10), on the maintainer's calls of 2026-10-08; the body rewritten 2026-10-11 to the layout that exists (see *History*).

## Context

The panel under the document ([Decision 36](036-every-command-is-written-down.md)) was built for a second tab. The [Terminal](../../product/workspace/terminal/doc.md) is it: the person's own shell, with their own configuration, drawn inside TOM so what the app does not do is still a `git` command away without a second window. That needs a pseudo-terminal — a shell on a pipe answers like a script, not like a prompt — and an emulator that understands what a shell draws.

Three constraints shape where the pieces go:

- **Rule 1.** Read from each package's own licence: [`xterm`](https://pub.dev/packages/xterm) 4.0.0 is **MIT**, and so are its own `zmodem` and `equatable`; its `quiver` is **Apache-2.0** and `convert` **BSD-3-Clause**. [`pty2`](https://pub.dev/packages/pty2) 0.5.6 is **MIT**, its `ffi` **BSD-3-Clause** and its `win32` **BSD-3-Clause**; it carries no native code of its own and calls `forkpty` on macOS and Linux and ConPTY on Windows through `dart:ffi`. Nothing copyleft.
- **`tom_infra` is pure Dart** ([Decision 14](014-each-layer-is-its-own-package.md)): `pty2` is pure Dart over FFI, so the pty can live there; `xterm` is a widget library, so the emulator cannot.
- **A capability is a folder with its contract and an implementation** ([Decision 24](024-a-capability-is-a-folder.md)), and external dependencies stay behind contracts ([Decision 7](007-external-dependencies-behind-contracts.md)).

## Decision

**A `pseudo_terminal` capability in `tom_infra` holds the contract, every decision about the shell and the pty itself; the emulator is the one piece that stays in the application, because it is a widget.**

```
tom_infra/lib/src/pseudo_terminal/
  pseudo_terminal.dart                  start(folder, columns, rows) → a process
  pseudo_terminal_process.dart          bytes out, bytes in, resize, kill, exit code
  pseudo_terminal_failure.dart          unavailable · startFailed
  login_shell/                          which shell, its arguments, its environment
  pty2/                                 Pty2PseudoTerminalProcessImpl: the spawn
tom_desktop/lib/screens/terminal/
  terminal_emulator_widget.dart         the one file that imports `xterm`
  terminal_look.dart                    the two themes, the platform's monospace face
  terminal_sequence_filter.dart         what `xterm` 4.0.0 cannot read, rewritten
```

- **The shell is the person's**: `$SHELL` (a login shell on macOS, as Terminal.app starts it, because an app opened from the Finder has launchd's bare `PATH`), else `/bin/zsh`; `$SHELL`, else `bash`, else `sh` on Linux; PowerShell, else `%ComSpec%`, on Windows. It gets the app's whole environment, plus `TERM=xterm-256color` and a UTF-8 `LANG` when none was set.
- **The layers above are the usual ones**: `TerminalRepository` and `TerminalSessionPort` in the domain (text both ways, decoded in `tom_data` with one decoder per stream), `StartTerminalUseCase` (the repository's root, not the space's folder), and `TerminalNotifier` in presentation — kept alive, one shell per space, started on the tab's first drawing, ended with the space.
- **The emulator is a widget's; the shell and what it drew are the notifier's.** The panel is built only while its tab is chosen, so each panel builds a new `xterm` `Terminal` and replays the notifier's transcript (the last 256 K characters) before it listens — before, so a question the shell asked long ago is not answered into it again.
- **`pty2` speaks text where the contract speaks bytes**, so what it decoded is encoded again; `kill` sends a hangup (`SIGHUP`; `SIGTERM` on Windows).
- **The terminal is ordinary**: it follows the system's appearance as the platform's own terminal does — `xterm`'s default theme on dark, the standard sixteen on white on light — offers no setting, and uses the platform's own monospace face: Menlo 12 at line height 1.0 on macOS, Consolas 14 at 1.2 on Windows, 13 on Linux. Its text keeps 14 in from the sides and 11 under the head.
- **A sequence filter stands between the shell and `xterm`** (`TerminalSequenceFilter`): `xterm` 4.0.0 reads `CSI > 4 m` as an underline, never ends bold on SGR 22 and does not understand colon sub-parameters, so each is rewritten before it is written to the emulator; a sequence cut by a chunk's end is held until the next.
- **Nothing typed reaches the `CommandLog`.** The capability takes none.

## Rationale

- Putting the shell rules and the pty in `tom_infra` keeps them under `dart test` next to the contract, and keeps `tom_desktop` free of a native plugin.
- A transcript in presentation rather than a long-lived emulator: the emulator is a Flutter type and presentation is pure Dart, and keeping one alive in the composition root would be state the session does not own.
- `pty2` over `flutter_pty`: no plugin means no Swift Package Manager warning on macOS, no native build step, and a spawn that is testable without a device; both are MIT.

## Consequences

- `tom_infra` calls `forkpty` and ConPTY through FFI. The app being unsandboxed ([Decision 20](020-the-macos-app-is-not-sandboxed.md)) is what lets `forkpty` start the person's shell at all.
- The shell dies with the app even when nothing disposes it: closing the pty's master sends it a hangup.
- `xterm` 4.0.0 was published in February 2024. A replacement stays inside the three files named above.

## History

- **2026-10-10:** accepted with `flutter_pty` 0.4.2 as the pty, handed in from the composition root because a plugin cannot live in a pure-Dart package.
- **2026-10-11:** `flutter_pty` replaced by `pty2` 0.5.6 and the terminal made ordinary (no palette of TOM's, the platform's face, the sequence filter); the body above is the result.

## Revisit when

- `xterm` or `pty2` stops building on a supported Flutter or Dart, or a desktop drops one of the two pty mechanisms.
- A second terminal per space is asked for — the notifier holds one shell by design.
