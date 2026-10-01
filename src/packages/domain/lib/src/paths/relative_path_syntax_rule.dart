/// The syntax rules both relative-path types share.
library;

/// Whether [value] is a well-formed relative path with `/` separators.
///
/// Shared by `RepoRelativePathValueObject` and `SpaceRelativePathValueObject`,
/// which differ in what they are relative *to*, never in what a path may look
/// like. The rules are the invariant, not a sanity check: not empty, no `\`
/// (git prints `/` on every platform), no drive letter, no empty segment,
/// and no `.` or `..` segment, since `..` is how a path joined onto a root
/// leaves it.
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
