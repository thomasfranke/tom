/// What the preview is wired from, declared where the preview lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'preview_providers.g.dart';

/// Splits a document's source into blocks.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which parser ends up behind
/// it.
@riverpod
SplitDocumentUseCase splitDocument(Ref ref) => throw StateError(
  'splitDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Reads a document as one commit left it.
///
/// Here rather than beside the history panel because the preview is what
/// needs it: history says *which* version is on screen, and this is what
/// turns that into text to render.
@riverpod
ReadVersionUseCase readVersion(Ref ref) => throw StateError(
  'readVersionProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
