# The end-to-end mock

What the scenarios drive the app against, committed and readable: one folder
per *situation*, each holding the working tree the app will show.

```
<name>/
  fixture.json   what git has and has not seen of the content
  content/       copied verbatim into .e2e/<name>/ by `tom e2e prepare`
```

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
| `uncommitted` | path → the tail of it git has not seen, so the file lands modified |
| `commits` | further commits on the fixture's own branch, oldest first — what gives a document a *history* |
| `branches` | branches to build from that history, each with its own `commits`; the repository is left back on `main` |
| `remote` | a bare repository beside the working tree, with `theirs` (pushed by somebody else, never fetched) and `mine` (committed here, never pushed) |
| `outsideTheProject` | staged in the system temporary directory, for the one fixture that has to be outside any repository |

A branch whose commits write the *same* files as the branch below it is
worth nothing: a switch that never touched the working tree would pass. Make
them differ.

A commit that writes a file already sitting in `content/` with that exact
text changes nothing, and git refuses an empty commit — so a document with a
history belongs in the `commits`, not in the folder.

Edit the markdown freely: it is what someone reads when a scenario fails, and
it is also the only realistic documentation the app has to render. Adding a
situation is adding a folder — nothing lists them.
