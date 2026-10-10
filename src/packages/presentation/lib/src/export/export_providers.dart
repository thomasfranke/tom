/// What exporting is wired from, declared where the export lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'export_providers.g.dart';

/// Writes a document as PDF or HTML.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ExportDocumentUseCase exportDocument(Ref ref) => throw StateError(
  'exportDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
