/// What the preview is wired from, declared where the preview lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'preview_providers.g.dart';

/// Reads a document and splits it into blocks.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which parser or which disk
/// ends up behind it.
@riverpod
ReadDocument readDocument(Ref ref) => throw StateError(
  'readDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
