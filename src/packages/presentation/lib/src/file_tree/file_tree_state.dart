/// What the file tree is showing right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/file_tree/file_tree_row.dart';

part 'file_tree_state.freezed.dart';

/// The states the file tree can be in, and there are only these.
@freezed
sealed class FileTreeState with _$FileTreeState {
  /// No space is open, so there is nothing to list — not a stalled load.
  const factory FileTreeState.initial() = FileTreeInitial;

  /// The space's folder is being read.
  const factory FileTreeState.loading() = FileTreeLoading;

  /// The space was read, and this is what it holds.
  const factory FileTreeState.ready({
    /// Everything the space holds, in the order a tree shows it.
    ///
    /// The whole space rather than one level, so expanding a folder is a
    /// filter over a list. Handed over unmodifiable, never copied: Freezed
    /// compares collections element-wise and copies nothing.
    required List<SpaceEntryValueObject> entries,

    /// The folders the user has closed — closed rather than open, so a
    /// space opens showing what it holds.
    required Set<SpaceRelativePathValueObject> collapsed,
  }) = FileTreeReady;

  /// The space's folder could not be read at all; a folder inside it that
  /// the machine will not open is skipped by the walk instead.
  const factory FileTreeState.failed(AppFailure failure) = FileTreeFailed;
}

/// What the panel draws: the entries minus what a closed folder hides.
extension FileTreeRows on FileTreeReady {
  /// The visible rows, in order, top-level first.
  ///
  /// A getter rather than a cached copy that can disagree. Hiding a closed
  /// folder is a prefix test only because a folder arrives immediately
  /// before what is inside it.
  List<FileTreeRow> get rows {
    final List<FileTreeRow> visible = <FileTreeRow>[];
    String? closed;
    for (final SpaceEntryValueObject entry in entries) {
      final String path = entry.path.value;
      if (closed != null && path.startsWith(closed)) {
        continue;
      }
      closed = null;
      final bool isFolder = entry.type == SpaceEntryTypeEnum.directory;
      final bool isExpanded = isFolder && !collapsed.contains(entry.path);
      if (isFolder && !isExpanded) {
        closed = '$path/';
      }
      visible.add(
        FileTreeRow(
          entry: entry,
          depth: '/'.allMatches(path).length,
          isExpanded: isExpanded,
        ),
      );
    }
    return List<FileTreeRow>.unmodifiable(visible);
  }
}
