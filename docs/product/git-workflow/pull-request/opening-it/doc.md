# Opening it

Creating the pull request through `gh`, knowing when one is already open, and the link when there is no `gh`.

**Status:** Shipped · Milestone M3

## Rules

- **TOM keeps no token and asks for none** ([Decision 35](../../../../technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
- **Creating it is `gh pr create`, run from the repository, as the account chosen for it** ([the account](../../../workspace/the-account/doc.md)) — its token only in that one call's environment, never an argument, a log line or a file; the draft's title is the title and the rest of the draft is the body.
- **Creating is GitHub's only.** On GitLab and Bitbucket the one action is the host's compare page.
- **While the request is out the action reads `Creating…`**, and neither action can be pressed.
- **Creating it never deletes the draft.** The draft stays what the pull request was opened with ([the draft](../the-draft/doc.md)).
- **Opening the page asks `gh` whether the branch already has one open, and so does creating.** When it has, the page shows it instead of offering another: the status row says `Pull request #123 is open on GitHub — this draft is what it was opened with.` in `accent`, and the one action is `View #123 on GitHub`, which opens it in the browser.
- **With `gh` and an account, the foot carries two actions**: `Create pull request`, filled, over `Open on GitHub instead`, outlined — handing the work to the browser is a choice somebody makes, not a footnote.
- **Without `gh`, or without an account whose tool holds a token, nothing changes**: the one action is `Open on GitHub`, the host's compare page with the branch, the title and the body already filled. A `gh` that does not answer is the same as none — the page never waits on it to offer the link.
- **A create that fails says so in the status row**, in `removed` — the host could not be reached, refused the account's token, or did not open it — and the row carries `Show the command`, which opens the [commands panel](../../../workspace/commands/doc.md) on the `gh pr create` that failed.
- **It says the host's name, because the app knows it.** The address is read from `git remote get-url`, so the controls read `Open on GitHub instead` and never `the host`; a remote nothing recognises draws no action at all.
- **The action survives the column closing.** It sits at the foot of the right column, where `Commit` already is, and the status row takes the first one over when that column is shut — `View #123`, `Create pull request` or `Open on GitHub`. No screen may keep its only action somewhere the window can hide.
- **Opening never pushes.** A branch that is not on the remote yet is published from the status row, which says so and carries `Push`; opening waits for it ([when it cannot be opened](../when-it-cannot-be-opened/doc.md)).

## Mocks

- **pull request — the status row** — ready, no account · ready, an account can create it · creating · already open · could not create · the action in the row, with the column shut. [light](../../../../design/screens/desktop/git-pull-request/pull-request-the-status-row-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/pull-request-the-status-row-states-dark.svg).
- **pull request — the action** — the foot of the right column in the same five states. [light](../../../../design/screens/desktop/git-pull-request/pull-request-the-action-states-light.svg) · [dark](../../../../design/screens/desktop/git-pull-request/pull-request-the-action-states-dark.svg).

---

*See also: [pull-request/](../README.md) · [when it cannot be opened](../when-it-cannot-be-opened/doc.md) · [the right column](../the-right-column/doc.md)*
