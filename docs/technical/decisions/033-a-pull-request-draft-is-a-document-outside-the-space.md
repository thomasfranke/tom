# Decision 33 — A pull request draft is a document outside the space

**Status:** accepted (2026-10-08). It is what [opening a pull request](../../product/git-workflow/pull-request/README.md) needs before any of it can be built, and the one part of it that is architecture rather than screen.

## Context

The product asks for two things that pull against each other:

- **The draft is written in TOM, with the whole editor** — the same source pane, preview and formatting bar every document has ([writing it](../../product/git-workflow/pull-request/writing-it/doc.md)).
- **The draft lives in `.git/tom/pull-request/<branch>.md`** — inside `.git/` so that it never appears in `git status`, never lands in the changes list and can never be committed into the diff it describes ([the draft](../../product/git-workflow/pull-request/the-draft/doc.md)).

Everything the editor knows how to open is **inside the space**. The session's `openDocument` is a `SpaceRelativePathValueObject`, the tabs hold those, `DocumentRepository` resolves them against `SpaceEntity.root`, and `SpaceEntity.relativize` refuses anything outside. A space may also be a folder *below* the repository's root ([rule 12](../../../AGENTS.md)), so `.git/` is not even reachable as `../.git` from every space.

Three ways out:

| | What changes | What it costs |
|---|---|---|
| **A. A wider identity** | `openDocument` becomes a sealed type — a space document or a draft — and every reader of it switches on the two | The tabs, the tree, the preview, search, the diff and the history all learn a case that means nothing to them; most of the app changes to serve one screen |
| **B. A page with its own buffer** | The pull request screen keeps a buffer of its own beside the editor's | Two buffers, so the source pane, the preview and the formatting bar need a second wiring or a second copy — exactly the "same editor" the product rules out |
| **C. The same document, from another root** | The draft is a `DocumentEntity` at `<branch>.md`, read through `DocumentRepository` over a second root: `<repositoryRoot>/.git/tom/pull-request` | The session says which root the open buffer belongs to, and the editor asks the matching repository |

## Decision

**C. A draft is a document, and the only thing that differs is the folder it is read from.**

```
SpaceSessionState.pullRequest   BranchNameValueObject?   (presentation)
  set   → the document area is the draft's; the tab strip gives way to the status row
  null  → the document area is openDocument's, as today

PullRequestDraftsFor(space)  → DocumentRepository over <repositoryRoot>/.git/tom/pull-request
DocumentRepositoryFor(space) → DocumentRepository over space.root            (unchanged)
```

- **One contract, two roots.** `DocumentRepositoryImpl` resolves every path through the `SpaceEntity` it is built for; it is changed to resolve against a root folder instead, which is `space.root` for documents and the drafts folder for drafts. A `SpaceEntity` faked over `.git/` would have done it without the change and would have lied about what a space is. No new capability, no new repository contract.
- **A branch name is the path.** `feat/x` is `feat/x.md` under the drafts folder; its slashes are folders, and git already refuses `feat` and `feat/x` at once, so two drafts can never claim one file.
- **The session carries the page, not a second document.** `pullRequest` beside `openDocument`, the way `readingVersion` sits beside it: one more reading position, and the editor's `build` watches it with the two it already watches. The tabs keep what they hold while the page is up and come back as they were.
- **The editor's buffer is the draft's while the page is up.** Same `EditorReady`, same save, same undo; `saved.path` is the draft's own name. What does not apply is switched off at the page, not taught to the editor: no rendered diff (the draft has no `HEAD` version), no search index (it is not in the space), no tree row.
- **The first read seeds it.** A draft that is not on disk yet is written from git — the branch's first commit subject as the `#` heading, the subjects between base and head as the body — by the use case that reads it, so opening the control twice never seeds twice.

What this decision does **not** settle, on purpose:

- **The token.** Creating the pull request through the host's API needs a credential in the operating system's keychain behind a capability ([opening it](../../product/git-workflow/pull-request/opening-it/doc.md)). That capability — and whether it is `security` on macOS, the Credential Manager on Windows and `secret-tool` on Linux through `Process`, or a package — is its own decision, with a license check under [Decision 1](001-license-is-mit.md). **Until then the page opens the host's compare page in the browser**, which the product already names as the fallback, so nothing on the page is a dead control.
- **Recognising the host.** `git remote get-url` gives the address; which hosts are named (GitHub, GitLab, Bitbucket) is a domain rule with a table, not an architecture choice.

**Revised (2026-10-08):** the token is settled by [Decision 35](035-github-is-reached-through-the-gh-cli.md), and not as this decision expected — there is no keychain capability and TOM keeps no token. On GitHub the page creates the pull request with `gh pr create` and asks `gh pr list` whether one is already open, through the `github_api` capability, as the account chosen for the repository; `PullRequestHostRepository` is the domain's contract for both ([opening it](../../product/git-workflow/pull-request/opening-it/doc.md)). The compare page stays the action without `gh`, and on every other host. The consequence below that deletes a draft when its pull request is opened is revoked: the draft stays what it was opened with.

## Rationale

- **"The draft is a document, and it is a file"** is the product's own sentence. Option C is the only one where the code says the same thing: every guarantee a document has — saved atomically, read back as the bytes written, unsaved-marked, guarded on leaving — the draft gets for free.
- **The cost lands where the screen is.** A and B spread the pull request across the editor, the tabs and the preview; C confines it to the session's one field, a second repository instance, and the page that reads them.
- **It keeps [Decision 9](009-space-session-is-single-source-of-truth.md).** What the window is looking at stays one answer on the session.

## Consequences

- `SpaceSessionState` gains `pullRequest`; the editor and the preview read it. The shell draws the status row where the tabs were while it is set.
- `DocumentRepositoryImpl` takes a root folder rather than a `SpaceEntity`, and a second `DocumentRepository` provider builds one for the drafts in the composition root, from the same filesystem.
- `GitClient` gains what the page reads: the commits between base and head, `diff --name-status` and `diff --stat` between them, the remote's address, and the remote's default branch.
- `DesktopShell` gains `openUrl`, for the compare page.
- Deleting a draft when its branch goes, and when its pull request is opened, is the use cases' job: nothing watches `.git/`.

## Revisit when

The editor holds more than one kind of thing besides documents. A second page that brings a buffer of its own — a commit message written in the editor, say — would make the session's field a list of pages, and option A's wider identity worth its cost.
