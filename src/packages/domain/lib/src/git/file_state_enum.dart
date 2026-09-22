/// How one path differs from the last commit.
library;

/// What happened to a path, in the product's own words.
///
/// The six the domain model names
/// (`docs/technical/domain-model.md`) — git's own alphabet is wider, and
/// `tom_data` collapses what it reports into these.
enum FileStateEnum {
  /// The file exists on both sides with different content.
  modified,

  /// The file is new to the repository.
  added,

  /// The file is gone.
  deleted,

  /// The file moved, keeping enough content for git to recognise it.
  renamed,

  /// The file is on disk and git was never told about it.
  untracked,

  /// A merge left both sides claiming the file.
  conflicted,
}
