/// What a path on disk turned out to be.
library;

/// The kind of thing a directory listing found at a path.
enum FilesystemEntryTypeEnum {
  /// A regular file.
  file,

  /// A directory.
  directory,

  /// A symbolic link, reported as itself because listings never follow one.
  link,
}
