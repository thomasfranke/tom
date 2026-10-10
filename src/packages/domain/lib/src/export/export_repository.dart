/// Where an exported document is written.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/documents/parsed_document_value_object.dart';
import 'package:tom_domain/src/export/export_failure.dart';
import 'package:tom_domain/src/export/export_format_enum.dart';
import 'package:tom_domain/src/spaces/space_entity.dart';

/// Writes a document out of the app, in a format other tools read.
///
/// From the parse the preview holds and never from the file, so an export
/// mid-edit is the buffer and says what the preview says ([Decision
/// 30](../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md)).
abstract interface class ExportRepository {
  /// Writes [document] as [format] at [destination], an absolute path the
  /// person chose, replacing whatever is there; the images it names are
  /// read from [space], the one it lives in.
  Future<Result<void, ExportFailure>> export(
    SpaceEntity space,
    ParsedDocumentValueObject document,
    ExportFormatEnum format,
    String destination,
  );
}
