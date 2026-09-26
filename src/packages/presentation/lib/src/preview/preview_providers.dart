/// What the preview is wired from, declared where the preview lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'preview_providers.g.dart';

/// Splits a document's source into blocks.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
SplitDocumentUseCase splitDocument(Ref ref) => throw StateError(
  'splitDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Compares the document on screen against what `HEAD` holds.
///
/// Beside the preview because the preview draws the answer: the rendered
/// diff is decoration on the blocks already there
/// (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
@riverpod
DiffDocumentUseCase diffDocument(Ref ref) => throw StateError(
  'diffDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Reads a document as one commit left it.
///
/// Beside the preview rather than history, because the preview is what
/// turns the version history named into text to render.
@riverpod
ReadVersionUseCase readVersion(Ref ref) => throw StateError(
  'readVersionProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
