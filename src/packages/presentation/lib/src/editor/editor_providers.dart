/// What the editor is wired from, declared where the editor lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'editor_providers.g.dart';

/// Reads a document's source off the disk.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which disk ends up behind it.
@riverpod
ReadDocumentUseCase readDocument(Ref ref) => throw StateError(
  'readDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Writes the buffer back to the file it came from.
@riverpod
SaveDocumentUseCase saveDocument(Ref ref) => throw StateError(
  'saveDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
