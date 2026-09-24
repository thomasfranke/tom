/// Drives the history panel: the commits that touched the open document.
library;

import 'dart:async';

// `select` is an extension on `ProviderListenable` and lives in the runtime
// package; `riverpod_annotation` carries the annotations and not much else.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/history/history_providers.dart';
import 'package:tom_presentation/src/history/history_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'history_notifier.g.dart';

/// Lists what touched the open document, and opens one of those versions.
///
/// **It follows the document, not the repository**
/// (`docs/product/git-workflow/file-history/doc.md`): the list is rebuilt
/// when another file is opened and says so when none is.
///
/// Opening a version writes to the session rather than being kept here,
/// because the preview and the bar above the document both have to know —
/// and two copies of "which version is on screen" is the disagreement that
/// state exists to prevent.
@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  /// How many commits the panel asks for.
  ///
  /// A document with a thousand of them is a list nobody scrolls, and the
  /// panel would rather draw a hundred quickly than all of them eventually.
  static const int limit = 100;

  /// Reads the commits that touched a document.
  ReadFileHistoryUseCase get readFileHistory =>
      ref.read(readFileHistoryProvider);

  @override
  HistoryState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    final SpaceRelativePathValueObject? path = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    if (space == null || path == null) {
      return const HistoryState.idle();
    }
    // Scheduled, not awaited: `build` answers synchronously, and the first
    // answer is "asking git".
    unawaited(Future<void>.microtask(() => _load(space, path)));
    return const HistoryState.loading();
  }

  /// Asks git again — after a commit, or a switch, the list has moved.
  Future<void> refresh() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session?.openDocument case final SpaceRelativePathValueObject path) {
      await _load(session!.space, path);
    }
  }

  /// Shows the document as [commit] left it.
  ///
  /// The version is *rendered*, not shown as diff text, so all this does is
  /// say which one — the preview reads the session and fetches it.
  void open(CommitEntity commit) =>
      ref.read(spaceSessionProvider.notifier).read(commit);

  /// Goes back to the working copy.
  void closeVersion() => ref.read(spaceSessionProvider.notifier).read(null);

  /// Reads the commits that touched [path] in [space].
  Future<void> _load(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async {
    final Result<List<CommitEntity>, AppFailure> read = await readFileHistory
        .read(space, path, limit: limit);
    // Git is another process, and the panel can be gone by the time it
    // answers.
    if (!ref.mounted) {
      return;
    }
    state = switch (read) {
      Success<List<CommitEntity>, AppFailure>(
        value: final List<CommitEntity> commits,
      ) =>
        HistoryState.ready(commits),
      Failure<List<CommitEntity>, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        HistoryState.failed(failure),
    };
  }
}
