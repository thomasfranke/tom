# The end-to-end mock

What the scenarios drive the app against, committed and readable: one folder
per *situation*, each holding the working tree the app will show.

```
<name>/
  fixture.json   what git has and has not seen of the content
  content/       copied verbatim into .e2e/<name>/ by `tom e2e prepare`
```

The scenarios that read these folders live beside this one, in `../e2e/`,
one folder per menu of `tom e2e` (`e2e/<group>/<submenu>/`); `../support/`
holds the harness. A scenario names its fixture and never its own folder.

`tom e2e prepare` copies `content/`, makes the repository, and commits it —
the history is built, never committed here. A file is *modified* or
*untracked* because of the state of a repository, not because of anything a
file can contain, so `fixture.json` is what says so:

| Key | Means |
|---|---|
| `summary`, `description` | what the situation is, for `tom e2e fixtures` |
| `space` | the folder inside the repository the user opens; absent when the space *is* the repository |
| `commit` | the message of the one commit the history holds |
| `untracked` | files to leave out of that commit |
| `uncommitted` | path → the tail of it git has not seen, so the file lands modified; a path that `content/` does not hold is one a later `commit` writes, and its tail is added after that commit (how a document gets Windows line endings) |
| `commits` | further commits on the fixture's own branch, oldest first — what gives a document a *history*; a commit may also carry `rename`, a `{from: to}` map applied with `git mv`, which is how a file's history has to follow it |
| `branches` | branches to build from that history, each with its own `commits` and an optional `from` (an earlier branch in the list; `main` otherwise), started by plain git so nothing records it; a name listed again adds its commits to the branch already made, which is how a base moves on after another branch was cut from it; the repository is left back on `main` |
| `remote` | a bare repository beside the working tree, with `theirs` (pushed by somebody else, never fetched) and `mine` (committed here, never pushed); `proposing` is a branch made off `main`, pushed and left checked out, and `address` what `origin` then says it is while pushes still reach the bare; `protected: true` installs a `pre-receive` hook, last, that refuses every push with GitHub's protected-branch message (`docs-protected-branch`) |
| `outsideTheProject` | staged in the system temporary directory, for the one fixture that has to be outside any repository |

A branch whose commits write the *same* files as the branch below it is
worth nothing: a switch that never touched the working tree would pass. Make
them differ.

A commit that writes a file already sitting in `content/` with that exact
text changes nothing, and git refuses an empty commit — so a document with a
history belongs in the `commits`, not in the folder.

`"remote": {}` is a remote with no drift at all — a bare holding exactly what
was committed. `docs-to-clone` is that and nothing else: the bare is what the
clone scenario pastes as an address, and the scenario clones it into
`.e2e/clones/`, which it empties first.

Edit the markdown freely: it is what someone reads when a scenario fails, and
it is also the only realistic documentation the app has to render. Adding a
situation is adding a folder — nothing lists them.
