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

## `BranchRefValueObject` and the base of a branch

A local branch, or a remote's copy of one: the branch's own `name` and the
`remote` it belongs to, apart, because git resolves the two together (`spec`,
`origin/develop`) while a pull request is proposed onto the name alone.
`DiffBaseValueObject` pairs it with its `forkPoint` — `GitRepository.forkPoint`,
the `merge-base` a pull request onto that branch reads — and the rendered diff
is read at that commit, never at the branch's tip, so what the base did since
is not this branch's change
([the product rule](../../product/diff/branch-diff/doc.md)).

`BranchBaseService` holds the rule that picks it, pure, over what git answers:
`BranchStandingValueObject` — every branch's `ahead`/`behind` against `HEAD`,
read in one `for-each-ref %(ahead-behind:HEAD)` — and the base TOM recorded
in `branch.<name>.tomBase` when it started the branch. Nobody chooses the base, so no type models a
chosen revision.

## `MergeStateValueObject` · `ConflictRegionValueObject`

`MergeStateValueObject`: `inProgress` — whether `MERGE_HEAD` is there — and the
`message` git drafted. It carries no list of conflicted paths, because the
status already answers that and one fact with two sources can disagree with
itself.

`ConflictRegionValueObject`: one stretch of a document where git left both
sides — `start` and `end` as offsets over the whole span, marker lines
included, the `current` and `incoming` text without their markers, and the two
labels git wrote. `ConflictScannerService` finds them (`scan`), rewrites one
(`resolve`) and answers whether any is left (`holdsMarker`).

- **A choice is an edit to the buffer, never a value the model carries** — there is no `Resolution` type, and staging is how a resolution is declared ([the conflicted document](../../product/editor/conflicted-document/doc.md)).
- Only a merge is modelled: nothing here reads a rebase, a cherry-pick or a revert in progress.

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
