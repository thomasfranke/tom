# Approvals

Who says yes before a command runs: nobody, a list the person keeps, or the person every time.

**Status:** Draft · designed, not built — boards on `28 · Screens: Git - Approvals`, approved 2026-10-09, not yet exported

## The three modes

- **Chosen in the [preferences popover](../../preferences/the-popover/doc.md)**, under `GIT COMMANDS`: a segmented control `Automatic · Semi · Manual`, applied when pressed, with one sentence under it saying what the chosen mode does.
- **Automatic** — the default. Every command runs as soon as it is asked for; the [Commands panel](../../workspace/commands/doc.md) only keeps the record.
- **Semi-automatic** — a command waits for approval unless `git-approvals.json` allows it. **Every command starts `false`**: nothing is allowed until the person allows it.
- **Manual** — every command waits, every time, **reads included**: the commands the app runs on its own (`status`, the branches, the log) ask too, so opening a space asks before the git column has anything to show. The file is not consulted.

- **What asks is git and `gh`** — whatever touches the repository or GitHub. Opening Finder, the terminal or the browser changes nothing of the person's work and never asks.

## Approving, in the Commands panel

- **The panel opens by itself when a command waits** — the one time it does. A command waiting where nobody looks is an app that seems hung.
- **An action shows its whole plan**: a head naming the action and counting its commands (`Discard all changes · 2 commands`), then one row per command, approved top down.
- **The waiting row** carries a hollow dot beside its time and three buttons at its right: **`Run`** (a check, filled `accent`), **`Always allow`** (two checks, outlined `accent`) and **`Deny`** (a cross, filled `removed`). The rows under it say `waits for the one above`.
- **`Run`** runs that one command. While it runs, a spinner sits where its check will be; then the check and the time taken, and the next row becomes the one that waits.
- **`Always allow`** runs it and writes `true` beside that command in the file. A row that later runs without asking says `allowed` before its time.
- **`Deny`** stops the plan: the row takes a red cross and `denied`, every row under it says `cancelled`, the head says `stopped · N of M ran`, and git is read again so the window shows what is true. What already ran stays ran.
- **A denied read leaves the window as it was**: the last reading stays on screen, the git column's foot says `Out of date: a read was denied.` in `modified` with `Reload` beside it, and `Reload` asks again. The app does not insist.
- **In Manual, `Always allow` asks first** — a dialog, `Switch to Semi-automatic?`, saying that this one command becomes allowed and every other stays `false`. `Stay in Manual` is the safe answer and comes first.
- **The control that was pressed waits too**: `Push` reads `Waiting for approval`, the other remote controls are unavailable, and the progress bar stays down — nothing is on the network yet.
- The panel's head says the mode and what waits — `Manual · 2 waiting` — where the session's count is otherwise.

## The file

- **`git-approvals.json`**, beside `preferences.json` and never in the repository; `Open git-approvals.json` inside the `GIT COMMANDS` section opens it in a text tab, and saving applies it.
- **The command is the key**, written as git receives it, with `<file>`, `<files>` and `<branch>` where a value goes; the value is `true` or `false`.
- **Flags are part of the key.** Unstaging and discarding are both `git restore`, so `git restore --staged -- <files>` and `git restore --worktree -- <file>` are two keys: allowing one never allows the other.
- **Every command the app can run is listed**, so the person can edit it by hand. A key the file does not hold is `false`.

## What it is not

- **Not a security boundary.** The [terminal](../../workspace/terminal/doc.md) and the file itself go round it; it is a confirmation, and a way to see what a button does before it does it.

## Mocks

Drawn on `28 · Screens: Git - Approvals`, both themes, **not yet exported**:

- **git commands — automatic / semi-automatic / manual** — the popover with each mode chosen.
- **manual — a plan waiting** — two commands, the first waiting.
- **semi-automatic — always allow** — a push waiting, its button saying so.
- **manual — opening a space** — the four reads waiting.
- **manual — always allow asks first** — the dialog.
- **manual — a read denied** — the column keeping its last reading, its foot saying so.
- **git-approvals.json** — the file in its tab.
- **approval row — states** — waiting, running, ran, denied.

---

*See also: [git-workflow/](../README.md) · [commands/](../../workspace/commands/doc.md) · [preferences/](../../preferences/README.md)*
