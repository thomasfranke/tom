/// One entry of a directory listing, in `dart:io` terms.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_infra/src/filesystem/filesystem_entry_type.dart';

part 'filesystem_entry.freezed.dart';

/// A path the disk holds, and what lives at it.
///
/// Technical, not product vocabulary — the same split as
/// [FilesystemFailure](filesystem_failure.dart) against `DocumentFailure`.
/// `Document` is the domain entity and it carries the file's *content*;
/// `tom_infra` depends only on `tom_core` and cannot name one, so what
/// crosses the contract is what a listing knows: a path, and its kind.
/// Turning the `.md` ones into documents is `tom_data`'s job.
@freezed
abstract class FilesystemEntry with _$FilesystemEntry {
  /// Creates an entry.
  const factory FilesystemEntry({
    /// The absolute path of the entry.
    required String path,

    /// What the entry is.
    required FilesystemEntryType type,
  }) = _FilesystemEntry;
}
