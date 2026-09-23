// Which half of `tom_data` does what — Decision 25.
//
// A repository orchestrates, converts and translates; a data source obtains.
// The two rules here are the same boundary read from either side.
library;

import 'dart:io';

import '../rule.dart';

/// A repository obtains nothing itself.
///
/// By field rather than by import: naming a capability's *failure* in order
/// to translate it is a repository's job, and holding a capability is what
/// reaching one actually looks like.
Iterable<Offence> repositoriesReadThroughDataSources(Directory root) sync* {
  final holdsACapability = RegExp(
    r'^  final (Filesystem|GitClient|GitClientFor|Settings|MarkdownParser|'
    r'PlatformPaths) ',
    multiLine: true,
  );
  final isRepository = RegExp(r'_(?:repository|reader)_impl\.dart$');

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
/// The half that says *how* the data is obtained, so what it hands up is
/// what the capability produced or a DTO of its own. An import is the whole
/// check here, unlike the rule above: there is no legitimate reason for a
/// source to reach the domain at all, not even to translate.
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
