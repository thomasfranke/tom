/// The syntax rules both relative-path types share.
library;

/// Whether [value] is a well-formed relative path with `/` separators.
///
/// Internal to `paths/`: `RepoRelativePath` and `SpaceRelativePath` differ in
/// what they are relative *to*, never in what a path may look like, and a
/// second copy of these rules would drift the day one of them is relaxed.
/// The rules are the invariant itself, not a sanity check:
///
/// - not empty, and no `\` — git prints `/` on every platform, and so does
///   every path TOM hands back to it;
/// - no drive letter, which is absolute on Windows however it is spelled;
/// - no empty segment, which is what a leading `/`, a trailing `/` and a
///   `//` in the middle all amount to;
/// - no `.` or `..` segment. This is the one that matters: joining a
///   relative path onto a root must not be able to leave it, and `..` is how
///   that guarantee is lost.
bool isRelativePathSyntax(String value) {
  if (value.isEmpty || value.contains(r'\') || _drive.hasMatch(value)) {
    return false;
  }
  for (final String segment in value.split('/')) {
    if (segment.isEmpty || segment == '.' || segment == '..') {
      return false;
    }
  }
  return true;
}

final RegExp _drive = RegExp(r'^[A-Za-z]:');
