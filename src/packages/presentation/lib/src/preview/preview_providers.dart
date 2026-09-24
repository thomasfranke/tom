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

/// Compares the document on screen against what `HEAD` holds.
///
/// Beside the preview because the preview is what draws the answer: the
/// rendered diff is decoration on the blocks that are already there, not a
/// second screen (`docs/product/diff/rendered-diff/doc.md`).
@riverpod
DiffDocumentUseCase diffDocument(Ref ref) => throw StateError(
  'diffDocumentProvider has no default. The composition root overrides it '
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
