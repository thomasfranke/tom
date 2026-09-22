/// What a path inside a space turned out to be.
library;

/// The kind of thing the space holds at a path.
enum SpaceEntryTypeEnum {
  /// A regular file.
  file,

  /// A folder.
  directory,

  /// A symbolic link, reported as itself because listings never follow one.
  ///
  /// Kept rather than collapsed into [file]: a link into another checkout is
  /// a real way to assemble documentation, and the tree has to be able to
  /// say that is what it is instead of opening something that may not be
  /// there.
  link,
}
