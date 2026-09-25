// What a rule is, and the file walking every rule shares.
library;

import 'dart:io';

/// One broken rule, in the file that broke it.
typedef Offence = ({String rule, String where, String detail});

/// What every rule is: the tree in, what it found out. A rule answers how
/// things are named and shaped; who may depend on whom is
/// `src/test/integrity/architecture_test.dart`.
typedef Rule = Iterable<Offence> Function(Directory root);

/// One file of rules, as the menu and the subcommand both see it, so `tom
/// rules <name>` runs exactly what the row named after the file runs.
typedef RuleFile = ({
  String name,
  String label,
  String file,
  String description,
  List<Rule> checks,
});

/// Every hand-written Dart file of the workspace, tests included.
///
/// By package rather than by walking `src/`, which also holds `.fvm/` — the
/// pinned Flutter SDK, forty thousand files that are nobody's to rename.
Iterable<File> sourcesUnder(Directory root) sync* {
  for (final group in const <String>['packages', 'apps']) {
    final directory = Directory('${root.path}/src/$group');
    if (!directory.existsSync()) continue;
    for (final package in directory.listSync().whereType<Directory>()) {
      yield* dartFilesUnder(Directory('${package.path}/lib'));
      yield* dartFilesUnder(Directory('${package.path}/test'));
      yield* dartFilesUnder(Directory('${package.path}/integration_test'));
    }
  }
  yield* dartFilesUnder(Directory('${root.path}/src/test'));
}

/// The published half of [sourcesUnder] — what other packages can see. A test
/// double implements a contract as a matter of course and is not an
/// implementation in Decision 24's sense.
Iterable<File> libraryFilesUnder(Directory root) =>
    sourcesUnder(root).where((file) => slashed(file.path).contains('/lib/'));

/// Every `.dart` file under [directory], generated output excluded.
Iterable<File> dartFilesUnder(Directory directory) => directory.existsSync()
    ? directory.listSync(recursive: true).whereType<File>().where((file) {
        final path = slashed(file.path);
        return path.endsWith('.dart') &&
            !path.endsWith('.freezed.dart') &&
            !path.endsWith('.g.dart') &&
            !path.contains('/.dart_tool/') &&
            !path.contains('/coverage/');
      })
    : const <File>[];

/// [file] as the repository spells it.
String relative(Directory root, File file) =>
    slashed(file.path).replaceFirst('${slashed(root.path)}/', '');

/// The last segment of [entity]'s path — its own name.
String nameOf(FileSystemEntity entity) => slashed(entity.path).split('/').last;

/// [path] with `/` separators, whatever the platform listed: `dart:io` spells
/// them with `\` on Windows, and a rule looking for `/lib/` there would
/// report a clean tree.
String slashed(String path) => path.replaceAll(r'\', '/');
