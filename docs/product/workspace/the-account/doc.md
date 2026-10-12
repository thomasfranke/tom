# The account

**Who the person is, here and on GitHub — read from what the computer already holds, never signed into.**

**Status:** Shipped · Milestone M3

## The button

- The account button is the **last control at the right of the top bar**, after the preferences gear — on Home too.
- It shows the initials of git's `user.name`, else the first letter of the GitHub login, else the outline of a person.
- It opens a popover hanging from its right edge; pressing it again, clicking outside or `Esc` closes it. The button wears no mark of its own while the popover is open — the popover under it says so.

## While it is read

- **Before the first answer, the popover says it is asking, never what it does not know yet.** Git's name and email, and the button's initials, show as soon as git answers; the GitHub section says `Asking git and gh who you are…` in place of "no credentials", and this repository's five columns are dashes over `Known once the answer is in.` — because `gh` checks its tokens online, and a wrong answer for seconds is still a wrong answer.
- A later reading — `Reload`, a choice — keeps the last answer on screen until the new one lands.

## Commits as

- The popover shows the name and the email git commits with here, as git resolves them — **shown, never changed**.
- Without either, it says `Not set` and that git asks for a name and an email first.

## GitHub

- **TOM never signs anyone in and keeps no copy of a login.** An account is one the computer's own tools hold: `gh`, git's credential helper over HTTPS, or an SSH key GitHub greets by name.
- The account says where it came from — `via gh`, `via git`, `via SSH` — and the caption under it says the login is the computer's, not TOM's.
- With several accounts, the select lists them; **the one chosen is remembered per repository**, in the repository's own git config. A repository nobody chose for uses the first account that may push there, else the first.
- The menu is the accounts and nothing else: setting a login up is the person's own business with those tools.
- With none, the popover says there are no GitHub credentials on this computer, and how git and `gh` come to have one.

## This repository

- Drawn only when the space's `origin` is on GitHub, and never on Home; otherwise nothing is said about permissions.
- **GitHub is the one host it knows.** An `origin` on GitLab or Bitbucket draws no section here, and its pull request is the host's own page ([opening it](../../git-workflow/pull-request/opening-it/doc.md)).
- The repository's name opens its page in the browser.
- Five columns say what the account may do there — `READ · PR · PUSH · MERGE · ADMIN`, a tick or a dash each. Opening a pull request and merging one follow push; the role's name is not shown.
- **Nothing known is drawn as nothing known**: without a login, or without `gh` to ask GitHub, all five are dashes and a line under them says so — SSH has its own line, because it says who somebody is and not what they may do.

## Mocks

- **account — no credentials** — the whole window: nothing on this computer, no git name, no account, five dashes. [light](../../../design/screens/desktop/account/account-no-credentials-light.svg) · [dark](../../../design/screens/desktop/account/account-no-credentials-dark.svg).
- **the account popover — its states** — [light](../../../design/screens/desktop/account/the-account-popover-states-light.svg) · [dark](../../../design/screens/desktop/account/the-account-popover-states-dark.svg):
  - *no credentials* — the popover alone.
  - *through gh* — an account from `gh`, the caption saying the login is the computer's, and the five columns.
  - *through SSH* — a login from the SSH key alone: who, never what — five dashes.
  - *reading* — the first reading out: git's name, `Asking git and gh who you are…`, five dashes pending.
  - *choosing an account* — the select open on the computer's accounts, one through `gh` and one through git.
- **the account button — its three faces** — initials, the first letter of the login, the outline of a person. [light](../../../design/screens/desktop/account/the-account-button-its-three-faces-states-light.svg) · [dark](../../../design/screens/desktop/account/the-account-button-its-three-faces-states-dark.svg).
- **the account on Home** — the popover with no repository section. [light](../../../design/screens/desktop/home/the-account-on-home-states-light.svg) · [dark](../../../design/screens/desktop/home/the-account-on-home-states-dark.svg).

---

*See also: [workspace/](../README.md) · [columns](../columns/doc.md) · [Decision 35](../../../technical/decisions/035-github-is-reached-through-the-gh-cli.md)*
