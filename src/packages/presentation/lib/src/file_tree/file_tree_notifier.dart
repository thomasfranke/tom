/// The file tree's state, and the two things a row can be asked to do.
library;

import 'dart:async';

// `select` is an extension on `ProviderListenable` and lives in the runtime
// package; `riverpod_annotation` carries the annotations and not much else.
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

/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show. **No business logic** — it calls a
/// use case and turns [Result] into state.
///
/// Which folders are closed lives here because no other panel cares. Which
/// *document* is open is the opposite, so it goes to the session.
@riverpod
class FileTreeNotifier extends _$FileTreeNotifier {
  /// Reads what the space holds, from the scope the composition root filled.
  ListSpaceEntriesUseCase get listSpaceEntries =>
      ref.read(listSpaceEntriesProvider);

  @override
  FileTreeState build() {
    // The space only, not the session: showing another document must not
    // re-read the folder, and watching the whole session would do that on
    // every click.
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const FileTreeState.initial();
    }
    // Scheduled, not awaited: `build` answers synchronously, and the first
    // answer is "reading it".
    unawaited(Future<void>.microtask(() => _load(space)));
    return const FileTreeState.loading();
  }

  /// Opens or closes [entry] — whichever clicking its row means.
  ///
  /// A folder toggles, a markdown file becomes the open document, and
  /// anything else does nothing: the tree shows every file and the editor
  /// opens only what it can read
  /// (`docs/product/navigation/file-tree/doc.md`).
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
    // The walk is real disk, and the panel can be gone by the time it
    // answers — a window closed, a space switched. Nothing to show then.
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

  /// Closes [folder] if it is open, opens it if it is closed.
  ///
  /// Does nothing before the space has been read: there is no folder to
  /// toggle, and a set kept across a load would describe a tree that is gone.
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
