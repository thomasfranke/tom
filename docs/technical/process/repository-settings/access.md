# Access

Who can do what, and the repository-wide switches.

| Action | Who |
|---|---|
| Fork, open a PR against `main` | Anyone |
| Run PR validation | Automatic — a first PR from a new outside contributor needs maintainer approval |
| Merge into `main` | Maintainer only |
| Create a `v*` tag | Maintainer only |
| Trigger the official build | Maintainer only — it does not run in this repository |

- **Nobody outside the maintainers has write access**, the default for a public repository: contribution happens through forks, never through branches here.

## Repository-wide

- Issues and Discussions enabled; blank issues disabled, templates in `.github/ISSUE_TEMPLATE/`.
- Private vulnerability reporting enabled ([SECURITY.md](../../../../SECURITY.md)).
- **Wiki disabled** — documentation lives in `docs/`, versioned with the code, which is the entire thesis of this project.
- Default branch `main`, the only long-lived line of development.
- The orphan branch `cla-signatures` is also permanent. It holds the CLA signature file and no code, and the bot commits to it directly, which is why it cannot live on `main` ([cla-bot.md](cla-bot.md)).

---

*See also: [repository-settings/](README.md) · [protection.md](protection.md)*
