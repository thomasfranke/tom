// What a name has to say, in the class and in the file.
//
// Every rule here has the same shape of consequence: the reader cannot tell
// what a thing is without opening it, and two things that should not collide
// do.
library;

import 'dart:io';

import '../rule.dart';

/// Decision 24 — a class fulfilling a contract says so, twice.
///
/// `DartIo` says which implementation, so the second is a sibling rather than
/// a rename; `Impl` says it fulfils a contract declared elsewhere, which the
/// position of the file cannot say. A failure hierarchy implements
/// `AppFailure` and is neither — a marker classifying data is not a seam.
Iterable<Offence> implementationsSaySo(Directory root) sync* {
  final fulfils = RegExp(
    r'^(?:final |abstract )?class (\w+)[^{]*? implements (\w+)',
    multiLine: true,
  );
  for (final file in libraryFilesUnder(root)) {
    for (final match in fulfils.allMatches(file.readAsStringSync())) {
      final name = match.group(1)!;
      if (match.group(2) == 'AppFailure' || name.startsWith('_')) continue;
      if (name.endsWith('Impl') && file.path.endsWith('_impl.dart')) continue;
      yield (
        rule: 'an implementation says so, in the class and in the file',
        where: relative(root, file),
        detail:
            '$name fulfils ${match.group(2)} — name it <How>Impl in '
            '<how>_impl.dart (Decision 24)',
      );
    }
  }
}

/// Every variant of a failure hierarchy carries the hierarchy's prefix.
///
/// `DocumentPermissionDenied`, not `PermissionDenied`: the variants are
/// top-level classes Freezed generates, so two hierarchies naming the same
/// concept would collide, and the one that reads first wins silently.
Iterable<Offence> failuresCarryTheirPrefix(Directory root) sync* {
  final hierarchy = RegExp(r'sealed class (\w+)Failure with');
  final variant = RegExp(r'\}\) = (\w+);');

  for (final file in libraryFilesUnder(root)) {
    if (!file.path.endsWith('_failure.dart')) continue;
    final source = file.readAsStringSync();
    final named = hierarchy.firstMatch(source);
    if (named == null) continue;
    final prefix = named.group(1)!;
    for (final match in variant.allMatches(source)) {
      final name = match.group(1)!;
      if (name.startsWith(prefix)) continue;
      yield (
        rule: "a failure variant carries its hierarchy's prefix",
        where: relative(root, file),
        detail:
            '$name does not start with $prefix — two hierarchies naming '
            'the same concept would collide',
      );
    }
  }
}

/// Decision 23 — a domain type says whether it is an entity or a value
/// object.
///
/// They are not the same thing and the difference decides how the code may
/// treat them: an entity has an identity that outlives its values, a value
/// object is wholly what it carries. Failures, contracts, ports, enums and
/// syntax rules say what they are already.
Iterable<Offence> domainTypesSayWhichKind(Directory root) sync* {
  final declared = RegExp(
    r'^(?:final |abstract |sealed )?class (\w+)',
    multiLine: true,
  );
  final saysAlready = RegExp(r'_(?:failure|enum|repository|port|rule)\.dart$');

  for (final file in dartFilesUnder(
    Directory('${root.path}/src/packages/domain/lib/src'),
  )) {
    if (saysAlready.hasMatch(file.path)) continue;
    for (final match in declared.allMatches(file.readAsStringSync())) {
      final name = match.group(1)!;
      if (name.startsWith('_') ||
          name.endsWith('Entity') ||
          name.endsWith('ValueObject')) {
        continue;
      }
      yield (
        rule: 'a domain type says whether it is an entity or a value object',
        where: relative(root, file),
        detail: '$name says neither (Decision 23)',
      );
    }
  }
}
