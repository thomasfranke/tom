// Where the repository is, from wherever a script was started.
library;

import 'dart:io';

/// The repository root, found by walking up from the running script until a
/// directory looks like it — a marker rather than a counted depth, which
/// silently goes wrong when a file moves into a subfolder.
Directory repoRoot() {
  var directory = File(Platform.script.toFilePath()).parent;

  // Bounded, so a script started from outside the repository fails loudly
  // instead of climbing to `/`.
  for (var level = 0; level < 8; level++) {
    if (_looksLikeRoot(directory)) return directory;
    final parent = directory.parent;
    if (parent.path == directory.path) break;
    directory = parent;
  }

  throw StateError(
    'Could not find the repository root above ${Platform.script.toFilePath()}',
  );
}

/// Both markers, not either: `src/` alone matches half the Dart projects in
/// existence, and a `Makefile` alone matches the other half.
bool _looksLikeRoot(Directory directory) =>
    File('${directory.path}/Makefile').existsSync() &&
    File('${directory.path}/src/pubspec.yaml').existsSync();
