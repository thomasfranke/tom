# Terminal

**The person's own shell, at the repository's root, in the panel under the document — the second tab beside [Commands](../commands/doc.md).**

**Status:** Shipped · Milestone M3

## The shell

- It is **the shell the person uses in their own terminal**, with their own configuration: `$SHELL` on macOS and Linux (a login shell on macOS, as Terminal.app starts one), PowerShell on Windows, else `cmd`.
- It opens **at the root of the space's repository**, not at the folder the space is — `git` answers for the whole repository from there. A space with no repository opens it at its own folder ([without a repository](../without-a-repository/doc.md)).
- It starts **the first time the Terminal tab is shown** in a space, never before; a space nobody opens the tab in runs no shell.
- **One terminal per space.** Opening another space, or closing this one, ends its shell; so does quitting the app.
- Switching to `Commands`, or closing the panel, leaves the shell running and what it drew in place — the tab comes back to it.
- A shell that ends — `exit`, Ctrl+D — says so in the terminal, dimmed, and the next key starts another in the same place.
- **What is typed there is never written into Commands**: that list is what TOM ran, not what the person runs.

## The head

- The tabs read `Commands · Terminal`; the chosen one is `text_primary` with the 2-point `accent` underline.
- After the tabs, while the terminal shows: the shell's name and the folder it opened in — `zsh · ~/work/docs`, 11.5 in `text_muted`, the home folder spelled `~` — in place of the commands count.
- The folder is where the shell started; a `cd` inside it does not move it.

## The body

- An ordinary terminal: the platform's own monospace (Menlo 12 on macOS, Consolas 14 on Windows, 13 on Linux), in the standard terminal colours, with a block caret — nothing about it follows TOM's palette. It follows the system's appearance as the platform's own terminal does: dark `#1E1E1E` with `#CCCCCC` text on a dark system, white with black text on a light one.
- The text keeps **14 in from the sides, 11 under the head and a few at the foot**, inside the body's colour, so it never touches the panel's edge.
- The prompt and the colours are the shell's own, its ANSI palette the standard one.
- A shell that cannot start leaves the body saying `The shell would not start.`

## The keyboard

- A click on the terminal gives it the keyboard.
- It receives every key a shell reads: Ctrl+C, Ctrl+D, Tab, the arrows, Escape.
- On macOS every `⌘` key stays the window's — `⌘J`, `⌘K`, `⌘S`, `⌘W` work with the terminal focused — except `⌘C`, `⌘V` and `⌘A`, which copy, paste and select inside it.
- Off macOS every Ctrl key is the shell's — Ctrl+K, Ctrl+W and Ctrl+H edit the line there — except **Ctrl+J, which closes the panel**: the keyboard's one way out. Copy is Ctrl+Shift+C and paste Ctrl+V.

## Mocks

- **the bottom panel — its states** — the Terminal tab chosen, a prompt and `git status` under it · the shell ended · the shell would not start. [light](../../../design/screens/desktop/commands-terminal/the-bottom-panel-states-light.svg) · [dark](../../../design/screens/desktop/commands-terminal/the-bottom-panel-states-dark.svg).

---

*See also: [workspace/](../README.md) · [commands/](../commands/doc.md) · [Decision 37](../../../technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)*
