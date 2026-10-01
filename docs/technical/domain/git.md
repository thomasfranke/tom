# Git types

## `GitStatusValueObject`

Parsed from `git status --porcelain=v2`: `branch`, `ahead`/`behind` against the
tracked remote, `entries` — per-path state (modified / added / deleted /
renamed / untracked / conflicted) — and `isDetached`.

`isDetached` is a field, not `branch == null`. A null `branch` has two causes:
`HEAD` points at a commit, or git named a branch the parser could not read.
Only the first is detachment, and showing the second as one would warn about a
detached `HEAD` on a repository sitting on an ordinary branch.

## `CommitEntity` · `BranchEntity`

`CommitEntity`: `sha`, `author`, `date`, `subject`, `body`, parsed from
`git log` with an explicit format.
`BranchEntity`: `name`, `isCurrent`, `upstream`.

`date` is a `CommitDateValueObject` — an instant in UTC plus the offset the
author's clock stood at — not a `DateTime`. A `DateTime` cannot hold an
offset: it reads `2026-09-20T01:44:01-03:00` and answers the instant
`04:44:01Z`, so history would show the author's Saturday night as the reader's
Sunday morning. The instant is what commits sort by; the offset is what a
history row displays.

## `RevisionValueObject`

A branch or a commit, as something to compare a document against — sealed,
with `spec` answering what git resolves it by: the branch's name, or the
commit's full sha.

It carries the whole `BranchEntity` or `CommitEntity` rather than that string,
because the control that says what is being compared names a commit's author
and age; a sha alone would need a second lookup, and a second answer is one
that can disagree with the list it came from.

## `GitRepository`

The domain's git contract, fulfilled by `GitRepositoryImpl` in `tom_data` over
the `GitClient` capability. Entities in, entities out — never process output:
the implementation hands the text to a parser and the `GitClientFailure` to a
translation that is exhaustive by construction
([`conventions/errors.md`](../conventions/errors.md)). Every path on it is
repository-relative, in both directions.

`GitFailure` gained two variants the capability could already report and the
domain could not name: `pushRejected` (its own outcome, because the product
shows it as one) and `timedOut`. `GitDetachedHead` is produced by no command —
git commits happily on a detached `HEAD`; it is a state `status()` reports and
a use case refuses to act on.

---

*See also: [runtime/git.md](../runtime/git.md) · [spaces.md](spaces.md)*
