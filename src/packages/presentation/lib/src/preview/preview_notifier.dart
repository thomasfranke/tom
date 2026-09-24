/// The preview's state: the open document, as blocks.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/preview/preview_providers.dart';
import 'package:tom_presentation/src/preview/preview_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'preview_notifier.g.dart';

/// Reads whatever document the session says is open.
///
/// **No business logic**: it calls a use case and turns [Result] into state.
/// It watches the whole session rather than a part of it, because both
/// halves matter — another space and another document are both a different
/// file to read.
@riverpod
class PreviewNotifier extends _$PreviewNotifier {
  /// Reads a document and splits it into blocks.
  ReadDocumentUseCase get readDocument => ref.read(readDocumentProvider);

  @override
  PreviewState build() {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    if (session == null || session.openDocument == null) {
      return const PreviewState.empty();
    }
    // Scheduled, not awaited: `build` answers synchronously, and the first
    // answer is "reading it".
    unawaited(
      Future<void>.microtask(() => _load(session.space, session.openDocument!)),
    );
    return const PreviewState.loading();
  }

  /// Reads [path] inside [space] and shows what it holds.
  Future<void> _load(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async {
    final Result<ParsedDocumentValueObject, AppFailure> read =
        await readDocument.read(space, path);
    // The read is real disk, and the document can have changed under the
    // panel by the time it answers — the notifier is rebuilt for the next
    // one, and this instance has nobody left to tell.
    if (!ref.mounted) {
      return;
    }
    state = switch (read) {
      Success<ParsedDocumentValueObject, AppFailure>(
        value: final ParsedDocumentValueObject document,
      ) =>
        PreviewState.ready(document),
      Failure<ParsedDocumentValueObject, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        PreviewState.failed(failure),
    };
  }
}
