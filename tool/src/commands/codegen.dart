// `tom codegen` — build_runner, in two strengths, over one package or all.
library;

import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';

/// The dashboard that does the actual generating.
const _runner = 'tool/src/commands/run_codegen.dart';

/// The suffixes of every file build_runner owns.
const _generatedSuffixes = ['.freezed.dart', '.g.dart'];

/// Runs build_runner over [targets].
///
/// [hard] deletes the generated files first, then regenerates all of them
/// rather than only what this branch changed. It is the mode that answers "is
/// what is committed actually what the annotations produce", which is why the
/// gate sits behind it.
///
/// The delete happens here rather than by shelling out to
/// `find -name ... -delete`, because `find` does not exist on Windows. It is
/// also scoped to [targets]: regenerating one package should not wipe the
/// other seven's output and leave the tree half generated.
Future<int> runCodegen({
  required bool hard,
  List<String> targets = allTargets,
}) async {
  if (hard) {
    var deleted = 0;
    for (final target in targets) {
      final directory = directoryFor(target);
      deleted += _deleteGenerated(directory);
      // The cache goes with them, and this is the half that was missing:
      // `--force` only skips the diff of which packages changed, while
      // build_runner's own asset graph still records every output as
      // written. Deleting the files without it leaves a package that
      // rebuilds nothing and reports success — the tree half generated, the
      // analyzer full of undefined types, and the gate the only thing that
      // notices.
      _deleteBuildCache(directory);
    }
    stdout.writeln(
      '${palette.prompt}• Deleted $deleted generated file'
      '${deleted == 1 ? '' : 's'}${Ansi.reset}',
    );
  }

  return dart(['run', _runner, if (hard) '--force', ...targets]);
}

/// Removes build_runner's asset graph for [directory], which is what
/// `build_runner clean` does and the only way to make it build again.
void _deleteBuildCache(Directory directory) {
  final cache = Directory('${directory.path}/.dart_tool/build');
  if (cache.existsSync()) cache.deleteSync(recursive: true);
}

/// Deletes every generated file under [directory], returning how many.
///
/// Symlinks are not followed: a link into a package outside the workspace is
/// not ours to delete through.
int _deleteGenerated(Directory directory) {
  if (!directory.existsSync()) return 0;

  var deleted = 0;
  for (final entity in directory.listSync(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;
    if (!_generatedSuffixes.any(entity.path.endsWith)) continue;
    entity.deleteSync();
    deleted++;
  }
  return deleted;
}
