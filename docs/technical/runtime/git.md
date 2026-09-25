# Git at runtime

## Three conceptual layers

1. **Open a folder.** The user opens a local folder that already is a Git
   repository. No server, no account, no import. A folder with no repository →
   offer `git init`, or run degraded (editing and preview only).
2. **Drive the `git` binary** — the real integration
   ([Decision 2](../decisions/002-git-via-system-binary.md)). `Process.run`
   over `status --porcelain=v2`, `log`, `diff`, `add/commit/push/pull`,
   `switch`, and parse the output. Credentials, SSH and config come for free:
   it is the user's own git running. Zero authentication implemented.
3. **Remote APIs** (post-MVP). Pull requests, reviews, OAuth clone through
   GitHub/GitLab REST. Only after the core is validated.

## One serialized queue per space

Every git operation goes through the `GitClient` implementation, which
**serializes execution in a queue**:

- prevents races — a commit during a checkout, two simultaneous fetches;
- gives timeout, logging and `exit code + stderr → GitClientFailure` a single
  home;
- one runner per space, so different spaces still run in parallel.

## The watcher and git cooperate by protocol

External editing — VS Code open alongside — is an expected use case, not an
error. The watcher and git interfere with each other, so the cooperation is
explicit
([Decision 10](../decisions/010-watcher-and-git-cooperate-by-protocol.md)):

- **Silence during git operations.** The client pauses the watcher before
  mutating commands and emits a single `SpaceChanged` at the end. A checkout
  touches dozens of files; reacting file by file is a race.
- **Echo suppression.** The app registers the paths of its own saves and
  discards watcher events for them.
- **Debounce** (~100–300 ms) consolidates the bursts external editors produce.
- **Same queue.** Pause and resume enter the serialized queue above, which is
  what guarantees ordering.
- Document changed on disk with no local edits → reloads silently. With local
  edits → `DocumentExternalChangeConflict`, and the UI offers the choice.

---

*See also: [state.md](state.md) · [domain/git.md](../domain/git.md)*
