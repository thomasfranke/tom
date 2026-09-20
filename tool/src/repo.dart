// Where the repository is, from wherever a script was started.
library;

import 'dart:io';

/// The repository root, found by walking up from the running script until a
/// directory looks like it.
///
/// The scripts in `tool/` each counted levels instead — `.parent.parent`, with
/// a comment naming the depth — which is correct until a file moves into a
/// subfolder and silently starts resolving to the wrong place. Looking for a
/// marker costs a few `existsSync` calls and cannot be wrong.
Directory repoRoot() {
  var directory = File(Platform.script.toFilePath()).parent;

  // A bounded walk: deep enough for any layout this repository grows, and
  // finite so a script started from outside it fails loudly instead of
  // climbing to `/`.
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
