# Approvals

Who says yes before a command runs: nobody, a list the person keeps, or the person every time.

**Status:** Draft · Milestone M3 — the layers under the interface are built; nothing draws it yet

## The three modes

- **Chosen in the [preferences popover](../../preferences/the-popover/doc.md)**, under `GIT COMMANDS`: a segmented control `Automatic · Semi · Manual`, applied when pressed, with one sentence under it saying what the chosen mode does.
- **Automatic** — the default. Every command runs as soon as it is asked for; the [Commands panel](../../workspace/commands/doc.md) only keeps the record.
- **Semi-automatic** — a command waits for approval unless `git-approvals.json` allows it. **Every command starts `false`**: nothing is allowed until the person allows it.
- **Manual** — every command waits, every time, **reads included**: the commands the app runs on its own (`status`, the branches, the log) ask too, so opening a space asks before the git column has anything to show. The file is not consulted.

- **What asks is git and `gh`** — whatever touches the repository or GitHub. Opening Finder, the terminal or the browser changes nothing of the person's work and never asks.

## Approving, in the Commands panel

- **The panel opens by itself when a command waits** — the one time it does. A command waiting where nobody looks is an app that seems hung.
- **On Home too.** The clone and Home's own reads wait like any other, so the panel opens there, over the foot of Home at its usual height — Home does not move under it.
- **A folder on this machine never waits for git.** Where git asks first, picking a folder opens the workspace at once with its tree and its files; where the repository is, and everything git reads after, waits in the panel as one plan, and the git column says it is asking until the person lets it run. Denying leaves the files where they are and the column out of date, with `Reload` to ask again. The check for an older git moves with the question: it is answered in the column, not on Home. In Automatic nothing waits, and the opening is as it always was.
- **Only a clone ends on Home when denied**, with the address field back as it was; in Manual Home reads nothing by itself — the recent rows name no branch and the account reads when its popover is opened.
- **An action shows its whole plan**: a head naming the action and counting its commands (`Discard all changes · 2 commands`), then one row per command, approved top down.
- **Opening a space is one plan** — `Reading the repository · 4 commands` — not a plan per read.
- **What was read once is not asked for again**: the text a document is compared against is kept for the session, so typing re-draws the diff without a new row; and where the repository keeps its own files is kept per space, so saving a pull request's [draft](../pull-request/the-draft/doc.md) asks nothing.
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
- **It has a tab of its own**, so it and `preferences.json` can be open at once.
- **On Home the button is unavailable**, as `Open preferences.json` is — there is no document area to open a tab into ([where it is stored](../../preferences/where-it-is-stored/doc.md)).
- **The command is the key**, written as git receives it, with `<file>`, `<files>` and `<branch>` where a value goes; the value is `true` or `false`.
- **Flags are part of the key.** Unstaging and discarding are both `git restore`, so `git restore --staged -- <files>` and `git restore --worktree -- <file>` are two keys: allowing one never allows the other.
- **A read an action makes for its own safety is a key like any other**: deleting a file git never committed first asks the last commit for it — `git ls-tree --full-tree --name-only -z HEAD -- <files>` — so in Semi that is one more command to allow, and in Manual one more row before the delete's own plan.
- **Every command the app can run is listed**, so the person can edit it by hand. A key the file does not hold is `false`.

## What it is not

- **Not a security boundary.** The [terminal](../../workspace/terminal/doc.md) and the file itself go round it; it is a confirmation, and a way to see what a button does before it does it.

## What moves when it ships

These `Shipped` docs do not know this one yet, and each gains its line with the interface:

| Doc | What changes |
|---|---|
| [what it holds](../../preferences/what-it-holds/doc.md) | A fourth preference, `Git commands` |
| [while a request runs](../push-pull/while-a-request-runs/doc.md) | `Push` reads `Waiting for approval`, the bar stays down |
| [when the link is broken](../push-pull/when-the-link-is-broken/doc.md) | The foot says `Out of date: a read was denied.` |

## Mocks

- **manual — a plan waiting** — two commands, the first waiting. [light](../../../design/screens/desktop/git-approvals/manual-a-plan-waiting-light.svg) · [dark](../../../design/screens/desktop/git-approvals/manual-a-plan-waiting-dark.svg).
- **always allow, asked in manual — the question** — the dialog. [light](../../../design/screens/desktop/git-approvals/always-allow-asked-in-manual-the-question-states-light.svg) · [dark](../../../design/screens/desktop/git-approvals/always-allow-asked-in-manual-the-question-states-dark.svg).
- **semi-automatic — always allow** — a push waiting, its button saying so. [light](../../../design/screens/desktop/git-approvals/semi-automatic-always-allow-light.svg) · [dark](../../../design/screens/desktop/git-approvals/semi-automatic-always-allow-dark.svg).
- **manual — opening a space** — the reads waiting, as one plan. [light](../../../design/screens/desktop/git-approvals/manual-opening-a-space-light.svg) · [dark](../../../design/screens/desktop/git-approvals/manual-opening-a-space-dark.svg).
- **manual — a read denied** — the column keeping its last reading, its foot saying so. [light](../../../design/screens/desktop/git-approvals/manual-a-read-denied-light.svg) · [dark](../../../design/screens/desktop/git-approvals/manual-a-read-denied-dark.svg).
- **approval row — states** — waiting · while it runs · after `Run` · after `Deny`. [light](../../../design/screens/desktop/git-approvals/approval-row-states-light.svg) · [dark](../../../design/screens/desktop/git-approvals/approval-row-states-dark.svg).
- **git commands — automatic** — the popover, the default chosen. [light](../../../design/screens/desktop/git-approvals-the-setting/git-commands-automatic-light.svg) · [dark](../../../design/screens/desktop/git-approvals-the-setting/git-commands-automatic-dark.svg).
- **git commands — the three modes** — automatic · semi-automatic · manual. [light](../../../design/screens/desktop/git-approvals-the-setting/git-commands-the-three-modes-states-light.svg) · [dark](../../../design/screens/desktop/git-approvals-the-setting/git-commands-the-three-modes-states-dark.svg).
- **git-approvals.json** — the file in its tab. [light](../../../design/screens/desktop/git-approvals-the-setting/git-approvals-json-light.svg) · [dark](../../../design/screens/desktop/git-approvals-the-setting/git-approvals-json-dark.svg).
- **home — a command waiting** — the panel over the foot of Home, a clone waiting. [light](../../../design/screens/desktop/home/home-a-command-waiting-light.svg) · [dark](../../../design/screens/desktop/home/home-a-command-waiting-dark.svg).

---

*See also: [git-workflow/](../README.md) · [commands/](../../workspace/commands/doc.md) · [preferences/](../../preferences/README.md)*
