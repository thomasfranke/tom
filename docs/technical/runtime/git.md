# Git at runtime

## Three conceptual layers

1. **Open a folder.** The user opens a local folder. No server, no account, no
   import. A folder with no repository above it opens as a space with none:
   `SpaceEntity.hasRepository` is the gate every git reader returns early on,
   and TOM never runs `git init`
   ([without a repository](../../product/workspace/without-a-repository/doc.md)).
2. **Drive the `git` binary** — the real integration
   ([Decision 2](../decisions/002-git-via-system-binary.md)). `Process.run`
   over `status --porcelain=v2`, `log`, `diff`, `add/commit/push/pull`,
   `switch`, and parse the output. Credentials, SSH and config come for free:
   it is the user's own git running. Zero authentication implemented.
3. **The host, through `gh`.** GitHub is asked by the `gh` CLI behind the
   `github_api` capability, with the logins the computer already holds — no
   HTTP client, no token kept
   ([Decision 35](../decisions/035-github-is-reached-through-the-gh-cli.md)).
   Reviews and OAuth clone are post-MVP, only after the core is validated.

- **git 2.41 or newer.** `GitClient.branchStandings` asks `for-each-ref` for `%(ahead-behind:HEAD)` — what the diff's base is deduced from — and an older git fails that command. Opening a space therefore asks `git --version` first (`GitClient.version`, `GitVersionValueObject.minimum`) and refuses an older one with `GitFailure.tooOld` before any other read; a line it cannot read is no refusal.
- **A file's history follows a rename** — `log` is run with `--follow` whenever a path is given, so a renamed document keeps the commits it had under its old name.
- **A push refused for a protected branch is its own failure** — `GitClientBranchProtected`, matched on `protected branch`, `GH006` or `GH013` before the race pattern, becomes `GitBranchProtected` above the repository; it is never retried as a lost race.

## A serialized queue in the client

Every git operation goes through the `GitClient` implementation, which
**serializes execution in a queue**:

- prevents races on one client — a commit during a checkout, two simultaneous fetches;
- gives the timeout, the `CommandLog`, the `CommandGate` and `exit code + stderr → GitClientFailure` a single home;
- **the queue is the instance's, and the composition root keeps one client per folder** (`gitClientFor`) for as long as the app runs, so every use case's commands on one repository share one queue — two writes started together never meet on `index.lock`;
- **a read waits behind a remote action in flight on the same repository** — a fetch, pull or push holds the queue until it answers or its timeout does;
- the client is kept by the folder it was asked for, not by the repository above it: everything that writes asks with the repository root, which is what makes that one queue.

## A read an action makes first

- **`deleteUncommitted` asks `HEAD` before it deletes** — `ls-tree --full-tree --name-only -z HEAD -- <files>`, a key of its own in `GitCommandKeyEnum`. Any of the paths committed deletes nothing and answers `GitClientPathCommitted` (`GitPathCommitted` above the repository); an unborn `HEAD` is read as nothing committed.
- **A path `HEAD` does not hold is asked about only when the status cannot tell** — untracked, added and renamed paths are never read at `HEAD` (`GitStatusValueObject.hasNothingAtHead`, used by `BaseContentCache.baseOf` and the overview); where the question must still be asked, the client records git's *no such path* refusal as an answered command, matched on stderr, never as a failure.
- **A probe of a program the machine does not have** (`gh`, `ssh`) is recorded as exit 127, declared an answer, with `ran: false` — the row reads *did not run* and is not red; a timeout, a start error that is not *not found* and a malformed answer stay failures. A missing `gh` where a pull request is opened is a failure: that action needs it.
- **`DiscardAllChangesUseCase` asks the merge state and `HEAD` before `reset`**: mid-merge it answers `GitMergeConflict`, before the first commit `GitNoCommitsYet`, and neither runs a command that writes.
- **`StageChangesUseCase` asks the status before `add`** and reads only the paths git calls conflicted — one inside the space through the space, one beside it through `SpaceEntity.repositorySpace`; any still holding a marker line answers `GitConflictMarkersPresent` and nothing is staged.
- `ChangesNotifier` reads git again on those three refusals before it publishes them — each means the list on screen was stale.

## Nothing watches the folder

External editing — VS Code open alongside — is an expected use case, not an
error, and there is no watcher in the MVP
([Decision 10](../decisions/010-watcher-and-git-cooperate-by-protocol.md),
revised):

- **`Reload` is how an outside change arrives** — the tree's re-reads the folder and git, the git menu's re-reads git.
- **Everything TOM itself writes ends in a re-read**: a save, a commit, a stage, a branch switch and the three remote actions all finish in `GitReadingNotifier.refresh()` ([state.md](state.md)).
- **A save asks the disk first.** `SaveDocumentUseCase.save` is handed `replacing`, the text the buffer was read as, and reads the file before it writes: other text, or bytes that stopped being UTF-8, is `DocumentExternalChangeConflict` and nothing is written; a file that is gone is written again.
- `EditorNotifier` passes `replacing` for every document and for the preferences file, never for a pull request's draft; the conflict becomes `EditorReady.changedOnDisk` — the band — and `Keep mine` sets `overwritesDisk`, which lets one save through without the read.
- **A write replaces the text and nothing else** (`Filesystem.writeBytes`): a symbolic link is resolved and its target written, the temporary starts as a copy of the file it replaces so the mode is kept, and a file nobody may write to answers `FilesystemAccessDenied`, naming the document.

---

*See also: [state.md](state.md) · [domain/git.md](../domain/git.md)*
