// Which half of `tom_data` does what — Decision 25.
library;

import 'dart:io';

import '../rule.dart';

/// A repository obtains nothing itself.
///
/// By field rather than by import: naming a capability's *failure* to
/// translate it is a repository's job; holding one is reaching one.
Iterable<Offence> repositoriesReadThroughDataSources(Directory root) sync* {
  final holdsACapability = RegExp(
    r'^  final (Filesystem|GitClient|GitClientFor|Settings|MarkdownParser|'
    r'PlatformPaths|TextDiffer) ',
    multiLine: true,
  );
  final isRepository = RegExp(r'_(?:repository|reader|aligner)_impl\.dart$');

  for (final file in libraryFilesUnder(root)) {
    if (!isRepository.hasMatch(file.path)) continue;
    final match = holdsACapability.firstMatch(file.readAsStringSync());
    if (match == null) continue;
    yield (
      rule: 'a repository reads through a data source',
      where: relative(root, file),
      detail:
          'holds a ${match.group(1)} — put a data source between them '
          '(Decision 25)',
    );
  }
}

/// A data source names no domain type.
///
/// An import is the whole check, unlike the rule above: a source has no
/// reason to reach the domain at all, not even to translate.
Iterable<Offence> dataSourcesKnowNoDomain(Directory root) sync* {
  for (final file in libraryFilesUnder(root)) {
    if (!file.path.endsWith('_data_source.dart')) continue;
    if (!file.readAsStringSync().contains('package:tom_domain/')) continue;
    yield (
      rule: 'a data source names no domain type',
      where: relative(root, file),
      detail:
          'imports tom_domain — a source obtains, a repository converts '
          'and translates (Decision 25)',
    );
  }
}
