# Decision 35 — GitHub is reached through the `gh` CLI; TOM stores no token

**Status:** draft, on the maintainer's calls of 2026-10-08.

## Context

The [account popover](../../product/workspace/the-account/doc.md) says who the person is on GitHub and what they may do in the repository. That needs a login and, for permissions, an authenticated call to GitHub's API. An app that signs people in owns an OAuth app, a token store and the security of both — and a person who already pushes from this computer has already proved who they are to its tools.

## Decision

**TOM reads the logins the computer already holds and asks GitHub through `gh`. It signs nobody in, keeps no token, and makes no HTTP request of its own.**

- **Three sources, asked never prompting**, each a plain process behind the `credentials` capability ([Decision 24](024-a-capability-is-a-folder.md)):

| Source | Asked with | Gives |
|---|---|---|
| `gh` | `gh auth status --json hosts`, then `gh auth token --user <login>` | every login, and a token per login |
| git's credential helper | `git credential fill` for `https://github.com`, in the repository | a login and a token |
| an SSH key | `ssh -T git@github.com`, batch mode | a login — GitHub's greeting — and no token |

- **GitHub's API is `gh api`**, behind the `github_api` capability; there is no HTTP client in the app. A login's permissions are `gh api repos/{owner}/{repo}`.
- **A token travels only in `GH_TOKEN`**, the environment of the one `gh api` call it is for — never an argument, a log line or a type above `tom_data`. The variable is per call, so the account `gh` has active is never switched.
- **Nothing asks a question**: `GIT_TERMINAL_PROMPT=0`, no askpass, `GH_PROMPT_DISABLED`, `ssh -o BatchMode=yes`, no terminal attached. A tool that would ask holds nothing.
- **The account used is chosen per repository and kept in its config**, `tom.githubAccount` — the files stay the truth ([rule 8](../../../AGENTS.md)).
- **Without `gh`, permissions are unknown**, drawn as such: git's and SSH's logins still say who the person is.
- **No picture.** An avatar is an image fetched over HTTP, the one request the app would make of its own; the button wears initials instead.

## Rationale

`gh` is already the person's: its login, its keyring, its enterprise hosts and its proxy settings come along, and so does the trust they placed in it. Every call is a process the app can list for the person, which a request made from Dart would not be. No package is added ([Decision 1](001-license-is-mit.md)).

## Consequences

- A person without `gh` sees who they are but not what they may do; `gh auth login` is the remedy and the person's own.
- `gh auth status` validates its tokens over the network, so reading the account takes as long as GitHub does; it is read when a space opens, on the git menu's `Reload` and after a choice, never per keystroke.
- A future host (GitLab, an enterprise GitHub) is a host argument on the same calls, not a second mechanism.

## Revisit when

**Revised (2026-10-08):** the first write arrived and the decision held. Opening a pull request is `gh pr create` and finding one already open is `gh pr list`, the same mechanism as reading — the chosen account's token in `GH_TOKEN` only, `--repo` named, every call in the commands panel. Without `gh` the browser's compare page stays the one action ([opening it](../../product/git-workflow/pull-request/opening-it/doc.md)).

~~TOM writes to GitHub on the person's behalf — opening a pull request without the browser is the first case~~ (happened, see above), or `gh` stops being the common way to hold a GitHub login.
