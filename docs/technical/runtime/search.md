# Search: the index is a disposable cache

FTS5 indexes the content of the `.md` files. Absolute rule: **the index never
holds state that does not exist on disk.** Corrupted, deleted, schema changed
→ rebuild by reading the files again.

That is what removes an entire class of synchronisation bugs, and why
`SearchIndexCorrupted` is a recoverable failure rather than data loss. It is
also the runtime form of the project's own rule that files are the truth
([`about.md`](../../about.md)).

---

*See also: [stack/platform.md](../stack/platform.md) · [git.md](git.md)*
