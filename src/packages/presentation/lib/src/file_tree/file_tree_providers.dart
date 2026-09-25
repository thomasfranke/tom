/// What the file tree is wired from, declared where the file tree lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'file_tree_providers.g.dart';

/// Reads everything a space holds.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package: it names what it needs and cannot see
/// what satisfies it.
@riverpod
ListSpaceEntriesUseCase listSpaceEntries(Ref ref) => throw StateError(
  'listSpaceEntriesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);
