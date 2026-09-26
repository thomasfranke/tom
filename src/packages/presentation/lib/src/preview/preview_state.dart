/// What the preview is showing right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'preview_state.freezed.dart';

/// The states the preview can be in, and there are only these.
///
/// [PreviewEmpty] is a space with no document chosen, not a stalled load.
@freezed
sealed class PreviewState with _$PreviewState {
  /// No document is open.
  const factory PreviewState.empty() = PreviewEmpty;

  /// A document is being read.
  const factory PreviewState.loading() = PreviewLoading;

  /// The document was read, and this is what it holds.
  const factory PreviewState.ready(
    ParsedDocumentValueObject document, {

    /// What it changed against the base, once git has said; null until
    /// then, when the comparison failed, and for a version nobody asked to
    /// compare (`docs/product/diff/rendered-diff/what-is-compared/doc.md`).
    DocumentDiffValueObject? diff,
  }) = PreviewReady;

  /// The document could not be read or could not be parsed.
  const factory PreviewState.failed(AppFailure failure) = PreviewFailed;
}
