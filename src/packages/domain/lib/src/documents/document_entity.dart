/// A markdown file, as the app holds it while it is open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'document_entity.freezed.dart';

/// One `.md` file inside a space.
///
/// A view over the file on disk, never a cache that may diverge ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
@freezed
abstract class DocumentEntity with _$DocumentEntity {
  /// A document.
  const factory DocumentEntity({
    /// Where the file is, relative to the space root; the document's identity.
    required SpaceRelativePathValueObject path,

    /// The raw markdown source, exactly as it was read.
    ///
    /// Never normalized: a line ending or trailing newline changed on the way
    /// through is a diff the user did not make.
    required String content,
  }) = _DocumentEntity;

  const DocumentEntity._();

  /// The file name, which is what the UI calls this document.
  String get name => path.name;
}
