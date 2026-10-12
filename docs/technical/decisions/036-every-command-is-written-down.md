# Decision 36 — Every command is written down, through a port in `tom_core`, and shown in a region under the document

**Status:** accepted (2026-10-10), on the maintainer's calls of 2026-10-08.

## Context

TOM is a git client that runs git, `gh`, `ssh` and the platform's own openers as processes ([Decision 2](002-git-via-system-binary.md), [Decision 35](035-github-is-reached-through-the-gh-cli.md)). When one fails, the band says what it cost in the product's words; what git actually said is lost. The [commands panel](../../product/workspace/commands/doc.md) shows every command as it ran. That needs two things the architecture did not have: a way for every capability that starts a process to report it, and a region of the shell under the document.

## Decision

1. **A port in `tom_core`: `CommandLog.record(CommandRecord)`**, with `SilentCommandLogImpl` as the default. Mechanism, not vocabulary — a program, its arguments, a time, a duration, an exit code, an output — so it sits beside `Observability` for the same reason: the capabilities are in `tom_infra`, the list is in `tom_presentation`, and neither may see the other.
2. **Every capability that starts a process takes one by constructor injection** — `git_client`, `credentials`, `github_api`, `desktop_shell` — defaulting to the silent log, and times each process through `CommandLog.started`, **declaring the exit codes it reads as answers** (`answers`). A record is `failed` only on no exit or an exit not declared; a declared one is `answered`, drawn neutral.
3. **`CommandRecord.of` is the one place a secret is taken out**: the environment is never read; the standard output of `git credential fill` and `gh auth token` is replaced by `••••`; any line holding `password=`, `oauth`, `Authorization:` or a GitHub token is replaced whole; an address's password in an argument is hidden. Output is cut to 200 lines per stream.
4. **The log is `CommandsNotifier`, kept alive, bounded to the last 500, never written to disk.** The composition root hands the notifier to every capability as the port.
5. **The shell gains a fifth region, `PanelPlacementEnum.bottom`**: under the document column only, closed by default, a tab strip at its head even with one tab, registered through `PanelDescriptor` like every other region ([Decision 12](012-shell-is-extensible-via-compile-time-modules.md)). `PanelDescriptor.summary` is what the chosen tab puts after the tabs.

## Rationale

- One port and one constructor parameter per capability is the smallest change that reaches every process; a wrapper around `Process` would have been a capability of its own that every other one depends on.
- Redacting in the record rather than in the panel means no implementation of the port can receive a secret, including one a module installs.
- A bottom region rather than a third column: the commands are read while the document stays in view, and a terminal — the next tab — wants width more than height.

## Consequences

- `tom_core` holds a second port. Like `Observability`, it is not a precedent for product vocabulary there.
- A capability that starts a process without a `CommandLog` is a review finding.
- A failure band links to the last failed command **of its verb** (`fetch`, `pull`, `push`), not to *its* record: failures do not carry a record's identity across the layers, and some errors are still read as answers above the client by their words (an unborn branch's `log`), so "the last failure" alone is not guaranteed to be the band's.
