/// What a file holds, once it is known whether that is text.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_domain/src/documents/document_entity.dart';
import 'package:tom_domain/src/paths/space_relative_path_value_object.dart';

part 'file_content_value_object.freezed.dart';

/// A file read as text, or found not to be text.
///
/// Binary is git's own test — a zero byte in the first 8 KB — or bytes that
/// do not read as UTF-8 (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@freezed
sealed class FileContentValueObject with _$FileContentValueObject {
  /// A file that reads as text, held as a document.
  const factory FileContentValueObject.text(DocumentEntity document) =
      FileContentText;

  /// A file that is not text; nothing of it is held.
  const factory FileContentValueObject.binary() = FileContentBinary;

  const FileContentValueObject._();

  /// How far into a file git looks for a zero byte.
  static const int sniffedBytes = 8000;

  /// The file at [path] holding [bytes], wherever they were read: the disk,
  /// a commit or the index.
  ///
  /// One test over the bytes themselves, because a decoded string no longer
  /// says where a byte sat nor that one was not UTF-8.
  static FileContentValueObject ofBytes(
    SpaceRelativePathValueObject path,
    Uint8List bytes,
  ) {
    final int sniffed = bytes.length < sniffedBytes
        ? bytes.length
        : sniffedBytes;
    for (int at = 0; at < sniffed; at++) {
      if (bytes[at] == 0) {
        return const FileContentValueObject.binary();
      }
    }
    try {
      return FileContentValueObject.text(
        DocumentEntity(path: path, content: utf8.decode(bytes)),
      );
    } on FormatException {
      return const FileContentValueObject.binary();
    }
  }
}
