/// One entry of a directory listing, in `dart:io` terms.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_data/src/capabilities/filesystem/filesystem_entry_type_enum.dart';

part 'filesystem_entry_dto.freezed.dart';

/// A path the disk holds, and what lives at it.
///
/// A DTO because it crosses the capability's contract ([Decision
/// 21](../../../../../../../docs/technical/decisions/021-dtos-and-daos-when-they-are-real.md));
/// `SpaceEntryValueObject` is the domain's word, which `tom_infra` cannot name.
@freezed
abstract class FilesystemEntryDto with _$FilesystemEntryDto {
  /// Creates an entry.
  const factory FilesystemEntryDto({
    /// The absolute path of the entry.
    required String path,

    /// What the entry is.
    required FilesystemEntryTypeEnum type,
  }) = _FilesystemEntryDto;
}
