# Decision 38 — A command waits at a gate in `tom_core`, and what the gate allows is a file keyed by the command

**Status:** draft, on the maintainer's calls of 2026-10-09.

## Context

[Approvals](../../product/git-workflow/approvals/doc.md) lets the person choose who says yes before git and `gh` run: nobody (`Automatic`, the default), a list they keep (`Semi-automatic`), or themselves every time (`Manual`, reads included). The question is put in the [Commands panel](../../product/workspace/commands/doc.md), which already hears about every process through `CommandLog` ([Decision 36](036-every-command-is-written-down.md)) — after it ran. Approving needs the same reach *before* it runs, and the layers have the same shape as then: the capabilities are in `tom_infra`, the panel is in `tom_presentation`, and neither may see the other.

## Decision

1. **A second port beside `CommandLog` in `tom_core`: `CommandGate`**, with an open gate as the default. A capability hands it what it is about to run — one command, or the several one method runs in order — and awaits a verdict for each: run, or denied. Mechanism, not vocabulary: a key, a command line, whether it reads or writes.
2. **`git_client` and `github_api` take the gate by constructor injection and ask before every `Process.run`.** `credentials` reads through git and `gh` and asks too; `desktop_shell` (Finder, the terminal, the browser) and the pty do not — the maintainer's line is *git and gh*.
3. **Every call site names its key**: the command as git receives it, flags included, with `<file>`, `<files>` and `<branch>` where a value goes — an enum per capability, so the whole set is enumerable and the file can list it. Flags are in the key because one subcommand does a safe thing and a destructive one (`restore --staged` against `restore --worktree`).
4. **The wait is not the command's time.** The capability asks before it starts the process and its timer, so a silent-timeout never counts the person reading.
5. **A denial is a failure of its own in each hierarchy** (`GitClientCommandDenied` → `GitCommandDenied`, and the like for `gh`), never an error band: presentation stops the action, reads git again, and for a denied *read* keeps the last reading and says it is stale.
6. **The gate is `CommandsNotifier`**, which is already the log: a waiting command is a record in the same list, in a state the log did not have (`waiting`, `running`, `denied`, `cancelled`). The composition root hands the one notifier to the capabilities as both ports.
7. **What an action is called is presentation's**, carried to the gate as a zone value around the use-case call — the capabilities never learn a product word, and commands asked for inside one such call are one plan.
8. **The mode is a preference; the list is a file of its own**, `git-approvals.json` beside `preferences.json`, behind a domain contract (`ApprovalsRepository`): every key the app can run, `false` unless the person allowed it. A key the file does not hold is `false`. `Manual` never reads it.

## Rationale

- At the capability and not in the use cases: a use case that forgets to ask is a command that runs unasked, and the plan would be declared by hand in forty places. Before `Process.run` nothing escapes, including a command a later change adds.
- The command as the key rather than the app's action: the person reads in the file exactly what will run, and can edit it without a glossary.
- One notifier for both ports: the panel draws one list, and a command's row is the same row before and after it runs.

## Consequences

- `tom_core` holds a third port, and it is the first one a capability *awaits*. A capability that starts git or `gh` without asking the gate is a review finding, as one without a `CommandLog` already is.
- Each sealed failure hierarchy gains a denial, and every exhaustive switch over them has to answer it.
- In `Manual` the app's own reads queue behind the person; a screen that assumed a reading arrives promptly needs a state for *not yet asked*.
- **It is a confirmation, not a security boundary**: the terminal and the file go round it, and the doc says so.
- A zone value is ambient state. It is read in one place, the notifier, and nowhere below presentation.
