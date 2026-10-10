# Commands

**Every command TOM runs, as it ran it — read-only, in a panel under the document.**

**Status:** Draft · built on `fix/match-the-boards`, boards on `22 · Screens: Commands & Terminal` not yet exported

## What it lists

- **Every process the app starts**: git, `gh`, `ssh`, and the programs that open a folder, a terminal or a browser — one row per command, newest at the bottom.
- A row is the time it started (`HH:MM:SS`), a check or a cross, the command line, and how long it took (`38 ms`, `1.2 s`).
- A failure is tinted `removed_soft` and says how it ended before its duration: `exit 1 · 1.8 s`, `did not finish` for one killed for its time, `did not run` for one that could not start.
- **Only what the app treated as an error is red.** An exit the app expected as an answer — `git config --get` of a key nobody set, `rev-parse --verify --quiet MERGE_HEAD` with no merge — is **neutral**: no check, no cross, no tint, `exit 1 · 23 ms` in `text_muted`. The capability that runs a command declares which exits are answers; the panel never guesses from the command text.
- The list keeps the last 500 commands of the session; the count after the tabs — `N this session` — counts every one.
- **Nothing is written to disk.** The list is the session's and goes with the window.

## No secret, ever

- The environment a command ran with is never shown — it is where a token travels.
- What `git credential fill` and `gh auth token` print is replaced by `••••`, whatever it looks like.
- Any printed line holding `password=`, `oauth`, an `Authorization:` header or a GitHub token is replaced whole by `••••`.
- An address's password in an argument shows as `••••`; arguments are otherwise shown as given — TOM never passes a token as one.

## What it does

- A press on a row opens it onto what the command printed, in a box under it; another press closes it.
- Under the pointer a row offers a copy glyph that puts its command line on the clipboard, quoted so a terminal runs the same command.
- **Read-only**: nothing in it runs a command again, and it takes no input.
- The list stays at its newest row as commands arrive.

## Opening it

- **It never opens by itself.** The toggle between the two column toggles in the top bar opens and closes it, and so does `⌘J` (`Ctrl+J` off macOS); the `×` at the right of its head closes it.
- Whether it is open is window state, like the columns.
- When a git action fails, its band carries a second action, **`Show the command`**, which opens the panel on the last command that failed, already open onto what git said.

## Where it sits

- **Under the document column only**, ~~260 tall~~ opening at 260 and **dragged from the gutter above it**, as the columns are dragged from theirs (revised 2026-10-09): never lower than 120, never so high that the document keeps less than 200. The explorer and the git column keep their full height. The height is the window's, like the columns' widths, and does not outlive it.
- Its head is a tab strip — `Commands`, then [`Terminal`](../terminal/doc.md) — the chosen tab underlined in `accent`; what is typed in the terminal is never listed here.

## Mocks

Drawn on `22 · Screens: Commands & Terminal`, approved, and **not yet exported**:

- **command-log** — the panel open under the document. `docs/design/screens/desktop/commands-and-terminal/command-log-{light,dark}.svg`.
- **command-log-output** — a row opened onto what it printed. `…/command-log-output-{light,dark}.svg`.
- **command-log-a-failure** — a failed fetch, tinted, open, reached from its band. `…/command-log-a-failure-{light,dark}.svg`.

---

*See also: [workspace/](../README.md) · [columns/](../columns/doc.md) · [feedback/](../feedback/doc.md) · [Decision 36](../../../technical/decisions/036-every-command-is-written-down.md)*
