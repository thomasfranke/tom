/// What the preview is showing right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'preview_state.freezed.dart';

/// The states the preview can be in, and there are only these.
///
/// [PreviewEmpty] is not a stalled load: it is a space with no document
/// chosen, which is how every space opens.
@freezed
sealed class PreviewState with _$PreviewState {
  /// No document is open.
  const factory PreviewState.empty() = PreviewEmpty;

  /// A document is being read.
  const factory PreviewState.loading() = PreviewLoading;

  /// The document was read, and this is what it holds.
  const factory PreviewState.ready(ParsedDocumentValueObject document) =
      PreviewReady;

  /// The document could not be read or could not be parsed.
  const factory PreviewState.failed(AppFailure failure) = PreviewFailed;
}
