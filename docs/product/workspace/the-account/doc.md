# The account

**Who the person is, here and on GitHub — read from what the computer already holds, never signed into.**

**Status:** Draft · built on `fix/match-the-boards`, boards on `21 · Screens: Account` not yet exported

## The button

- The account button is the **last control at the right of the top bar**, after the preferences gear — on Home too.
- It shows the initials of git's `user.name`, else the first letter of the GitHub login, else the outline of a person.
- It opens a popover hanging from its right edge, and wears an `accent` ring while the popover is open; pressing it again, clicking outside or `Esc` closes it.

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
- The repository's name opens its page in the browser.
- Five columns say what the account may do there — `READ · PR · PUSH · MERGE · ADMIN`, a tick or a dash each. Opening a pull request and merging one follow push; the role's name is not shown.
- **Nothing known is drawn as nothing known**: without a login, or without `gh` to ask GitHub, all five are dashes and a line under them says so — SSH has its own line, because it says who somebody is and not what they may do.

## Mocks

Not yet exported; on the Penpot page `21 · Screens: Account`, to land in [`desktop/account/`](../../../design/screens/desktop/account/):

- **account-no-credentials** — nothing on this computer: no git name, no account, five dashes.
- **account-through-gh** — an account from `gh`, the caption saying the login is the computer's, and the five columns.
- **choosing-an-account** — the select open on the computer's accounts, one of them through SSH.
- **account-through-ssh** — a login from the SSH key alone: who, never what — five dashes.
- **account-reading** — the first reading out: git's name, `Asking git and gh who you are…`, five dashes pending.

---

*See also: [workspace/](../README.md) · [columns](../columns/doc.md) · [Decision 35](../../../technical/decisions/035-github-is-reached-through-the-gh-cli.md)*
