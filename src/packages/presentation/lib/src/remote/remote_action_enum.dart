/// Which way commits are being moved.
library;

/// Fetch, pull or push — the three, and no combined "sync", which would be
/// one name for three different risks
/// (`docs/product/git-workflow/push-pull/the-controls/doc.md`).
enum RemoteActionEnum {
  /// Ask the remote what it has, and change no file on disk.
  fetch,

  /// Bring the remote's commits into this branch — the one that writes.
  pull,

  /// Publish this branch's commits.
  push,
}
