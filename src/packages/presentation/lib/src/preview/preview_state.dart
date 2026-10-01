/// What the preview is showing right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/preview/preview_segment.dart';

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

    /// The document cut at its conflicts, or null when it holds none.
    ///
    /// Non-null replaces the parsed document on screen rather than decorating
    /// it: while a marker is there the preview shows the conflict and
    /// nothing else, which is also why the diff stays null — comparing to
    /// `HEAD` mid-merge answers a question nobody has asked yet, in the
    /// same tint the conflict already uses
    /// (`docs/product/editor/conflicted-document/doc.md`).
    List<PreviewSegment>? segments,
  }) = PreviewReady;

  /// The document could not be read or could not be parsed.
  const factory PreviewState.failed(AppFailure failure) = PreviewFailed;
}
