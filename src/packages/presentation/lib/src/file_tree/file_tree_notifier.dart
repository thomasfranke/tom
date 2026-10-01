/// The file tree's state, and the two things a row can be asked to do.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/file_tree/file_tree_providers.dart';
import 'package:tom_presentation/src/file_tree/file_tree_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'file_tree_notifier.g.dart';

/// Drives the explorer: list the space, open and close its folders, say
/// which document the window should show. No business logic — a use case is
/// called and its [Result] becomes state.
///
/// Which folders are closed lives here because no other panel cares; which
/// document is open goes to the session, because every panel does.
@riverpod
class FileTreeNotifier extends _$FileTreeNotifier {
  /// Reads what the space holds.
  ListSpaceEntriesUseCase get listSpaceEntries =>
      ref.read(listSpaceEntriesProvider);

  @override
  FileTreeState build() {
    // The space only, not the session: watching it whole would re-read the
    // folder on every click of a document.
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const FileTreeState.initial();
    }
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _load(space)));
    return const FileTreeState.loading();
  }

  /// Walks the space again, for when TOM itself wrote to the disk.
  ///
  /// Changes made outside the app are the watcher's to notice ([Decision
  /// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)),
  /// not this method's.
  Future<void> refresh() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space != null) {
      await _load(space);
    }
  }

  /// Opens or closes [entry] — whichever clicking its row means.
  ///
  /// A folder toggles, a markdown file becomes the open document, anything
  /// else does nothing
  /// (`docs/product/navigation/file-tree/what-is-shown/doc.md`).
  void activate(SpaceEntryValueObject entry) {
    if (entry.type == SpaceEntryTypeEnum.directory) {
      _toggle(entry.path);
      return;
    }
    if (entry.isDocument) {
      ref.read(spaceSessionProvider.notifier).show(entry.path);
    }
  }

  /// Reads [space] and shows what it holds.
  Future<void> _load(SpaceEntity space) async {
    final Result<List<SpaceEntryValueObject>, AppFailure> listed =
        await listSpaceEntries.list(space);
    // The panel can be gone by the time the walk answers.
    if (!ref.mounted) {
      return;
    }
    state = switch (listed) {
      Success<List<SpaceEntryValueObject>, AppFailure>(
        value: final List<SpaceEntryValueObject> entries,
      ) =>
        FileTreeState.ready(
          entries: List<SpaceEntryValueObject>.unmodifiable(entries),
          collapsed: const <SpaceRelativePathValueObject>{},
        ),
      Failure<List<SpaceEntryValueObject>, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        FileTreeState.failed(failure),
    };
  }

  /// Closes [folder] if it is open, opens it if it is closed; nothing before
  /// the space has been read.
  void _toggle(SpaceRelativePathValueObject folder) {
    if (state case FileTreeReady(
      entries: final List<SpaceEntryValueObject> entries,
      collapsed: final Set<SpaceRelativePathValueObject> collapsed,
    )) {
      final Set<SpaceRelativePathValueObject> next = collapsed.toSet();
      if (!next.remove(folder)) {
        next.add(folder);
      }
      state = FileTreeState.ready(
        entries: entries,
        collapsed: Set<SpaceRelativePathValueObject>.unmodifiable(next),
      );
    }
  }
}
