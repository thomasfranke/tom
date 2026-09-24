/// Which way commits are being moved.
library;

/// Fetch, pull or push — the three, and there is no fourth.
///
/// **No "sync".** Each is a single, explicit action and none of them runs by
/// itself (`docs/product/git-workflow/push-pull/doc.md`); a combined button
/// would be one name for three different risks.
enum RemoteActionEnum {
  /// Ask the remote what it has, and change no file on disk.
  fetch,

  /// Bring the remote's commits into this branch — the one that writes.
  pull,

  /// Publish this branch's commits.
  push,
}
