/// A markdown file, as the app holds it while it is open.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/paths/space_relative_path.dart';

part 'document.freezed.dart';

/// One `.md` file inside a space.
///
/// **The file on disk is the truth** — this is a view over it, never a cache
/// that may diverge. Nothing here is rebuilt from anything but the bytes at
/// [path], which is what lets an editor running beside TOM stay a supported
/// way to work ([Decision
/// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)).
@freezed
abstract class Document with _$Document {
  /// Creates a document.
  const factory Document({
    /// Where the file is, relative to the space root; the identity of the
    /// document.
    required SpaceRelativePath path,

    /// The raw markdown source, exactly as it was read.
    ///
    /// Never normalized on the way in: a document written back with its line
    /// endings or its trailing newline changed produces a diff the user did
    /// not make, which is the one thing this product cannot do.
    required String content,
  }) = _Document;

  const Document._();

  /// What the UI calls this document — the file name.
  String get name => path.name;
}
