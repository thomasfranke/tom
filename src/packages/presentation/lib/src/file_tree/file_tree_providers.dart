/// What the file tree is wired from, declared where the file tree lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'file_tree_providers.g.dart';

/// Reads everything a space holds.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see what satisfies it, because it
/// does not depend on `tom_data` or `tom_infra`.
///
/// Throwing rather than defaulting is deliberate — a default here would be a
/// second place where the app decides what fulfils a contract.
@riverpod
ListSpaceEntries listSpaceEntries(Ref ref) => throw StateError(
  'listSpaceEntriesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);
