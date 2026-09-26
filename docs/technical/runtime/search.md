# Search: the index is a disposable cache

FTS5 indexes the content of the `.md` files. Absolute rule: **the index never
holds state that does not exist on disk.** Corrupted, deleted, schema changed
→ rebuild by reading the files again.

That is what removes an entire class of synchronisation bugs, and why
`SearchIndexCorrupted` is a recoverable failure rather than data loss. It is
also the runtime form of the project's own rule that files are the truth
([`about.md`](../../about.md)).

It is taken literally: the table lives **in memory**, one per open space, and
is filled when the space opens. A copy on disk would be written and never
read, since the rebuild happens anyway — and a database that does not outlive
the session cannot go stale, cannot be half-written and has no schema to
migrate. What it costs is the reading of every document once per session,
which is the same walk the file tree already does.

Between rebuilds only one thing keeps it current: a document saved in TOM is
filed again under its own path. Nothing watches the folder ([Decision
10](../decisions/010-watcher-and-git-cooperate-by-protocol.md) is where that
would go), so a file changed by something else is found again when the space
is reopened.

---

*See also: [stack/platform.md](../stack/platform.md) · [git.md](git.md)*
