/// What the search is wired from, declared where the search lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'search_providers.g.dart';

/// Reads a space's documents into the index.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
IndexSpaceUseCase indexSpace(Ref ref) => throw StateError(
  'indexSpaceProvider has no default. The composition root overrides it — '
  'see runTom() in tom_desktop.',
);

/// Files one document again, after it was written.
@riverpod
IndexDocumentUseCase indexDocument(Ref ref) => throw StateError(
  'indexDocumentProvider has no default. The composition root overrides it — '
  'see runTom() in tom_desktop.',
);

/// Asks the index what matches what was typed.
@riverpod
SearchSpaceUseCase searchSpace(Ref ref) => throw StateError(
  'searchSpaceProvider has no default. The composition root overrides it — '
  'see runTom() in tom_desktop.',
);
