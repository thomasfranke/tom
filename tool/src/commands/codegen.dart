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
/// [hard] deletes the generated files first and regenerates all of them, which
/// is what answers "is what is committed what the annotations produce". The
/// delete is done here because `find` does not exist on Windows, and scoped
/// to [targets] so one package's run does not leave the tree half generated.
Future<int> runCodegen({
  required bool hard,
  List<String> targets = allTargets,
}) async {
  if (hard) {
    var deleted = 0;
    for (final target in targets) {
      final directory = directoryFor(target);
      deleted += _deleteGenerated(directory);
      // The cache goes with them: build_runner's asset graph still records
      // every output as written, and without this the package rebuilds
      // nothing and reports success.
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
