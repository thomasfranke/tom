# What each one does

The difference between fetch and pull, and the one thing a pull is not allowed
to do.

**Status:** Planned · Milestone M1

## Rules

- **Fetch alone never changes a file on disk.** Only a pull, or an explicit merge, does — and after a pull the file tree shows what arrived, because the app knows it wrote.
- **A pull merges, and never rebases.** The app decides this rather than inheriting whatever the machine happens to be configured with.

Merge keeps every local commit exactly where it is, which is what "nothing you
committed has been lost" means. A rebase rewrites them and can stop halfway
somewhere a reader of documentation has no way out of.

---

*See also: [push-pull/](../README.md) · [file-tree](../../../navigation/file-tree/README.md)*
