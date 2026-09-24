// The shape of `tom_infra` — Decision 24, checked against the folder.
//
// A capability is a folder holding its contract, its failures and one
// subfolder per way of doing it, and the barrel is that folder's whole
// contents. Both rules exist so a question about the package is answered by
// listing it rather than by reading it.
library;

import 'dart:io';

import '../rule.dart';

/// A capability is a folder, and nothing sits loose beside one.
Iterable<Offence> capabilitiesAreFolders(Directory root) sync* {
  final source = Directory('${root.path}/src/packages/infra/lib/src');
  if (!source.existsSync()) return;

  for (final loose in source.listSync().whereType<File>()) {
    yield (
      rule: 'nothing sits loose beside the capabilities',
      where: relative(root, loose),
      detail:
          'a file in tom_infra without a contract is a capability nobody '
          'declared — give it a folder, or move it out (Decision 24)',
    );
  }

  for (final capability in source.listSync().whereType<Directory>()) {
    final name = nameOf(capability);
    final held = capability.listSync();
    final files = held.whereType<File>().map(nameOf);
    for (final required in <String>['$name.dart', '${name}_failure.dart']) {
      if (!files.contains(required)) {
        yield (
          rule: 'a capability holds its contract and its failures',
          where: 'src/packages/infra/lib/src/$name/',
          detail: 'no $required (Decision 24)',
        );
      }
    }
    if (held.whereType<Directory>().isEmpty) {
      yield (
        rule: 'a capability holds one folder per way of doing it',
        where: 'src/packages/infra/lib/src/$name/',
        detail: 'no implementation folder (Decision 24)',
      );
    }
  }
}

/// The infrastructure barrel is the whole of its `lib/src`.
///
/// A capability that exported less than it declares would be a contract
/// nobody can fulfil from outside.
Iterable<Offence> barrelIsWholeOfSrc(Directory root) sync* {
  final lib = Directory('${root.path}/src/packages/infra/lib');
  final barrel = File('${lib.path}/tom_infra.dart');
  if (!barrel.existsSync()) return;

  final exported = barrel.readAsStringSync();
  for (final file in dartFilesUnder(Directory('${lib.path}/src'))) {
    final path = slashed(file.path).replaceFirst('${slashed(lib.path)}/', '');
    if (exported.contains("export '$path';")) continue;
    yield (
      rule: 'the infrastructure barrel is the whole of its lib/src',
      where: relative(root, file),
      detail: "not exported — add export '$path'; (Decision 24)",
    );
  }
}
