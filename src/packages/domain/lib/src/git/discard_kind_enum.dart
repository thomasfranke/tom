/// What discarding one row of the changes list does.
library;

import 'package:tom_domain/src/git/file_state_enum.dart';
import 'package:tom_domain/src/git/status_entry_value_object.dart';

/// The three ways one file goes back, decided by where its row is
/// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
enum DiscardKindEnum {
  /// A row in `CHANGES`: the working tree goes back to what is staged, and
  /// what is staged stays.
  toStaged,

  /// A row in `STAGED`: back to the last commit, staged or not.
  toLastCommit,

  /// A file git never had: it is deleted, since nothing can bring it back.
  delete;

  /// How [entry] is discarded, or null for a conflicted file — resolving it
  /// is the way out, and `Abort the pull` the way back.
  static DiscardKindEnum? of(StatusEntryValueObject entry) =>
      switch (entry.state) {
        FileStateEnum.conflicted => null,
        FileStateEnum.untracked || FileStateEnum.added => delete,
        _ when entry.isStaged => toLastCommit,
        _ => toStaged,
      };
}
