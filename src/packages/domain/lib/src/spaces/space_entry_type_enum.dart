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
  /// Not collapsed into [file]: the tree has to say what it is rather than
  /// open something that may not be there.
  link,
}
