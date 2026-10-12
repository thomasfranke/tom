/// The formats a document can be exported as.
library;

/// What an export is written as (`docs/product/export/doc.md`).
enum ExportFormatEnum {
  /// One self-contained HTML page.
  html('html'),

  /// A PDF.
  pdf('pdf');

  const ExportFormatEnum(this.extension);

  /// The file extension, without its dot.
  final String extension;

  /// The name an export of [documentName] is offered under: the document's
  /// own, with this format's extension in place of its markdown one
  /// ([Decision 30](../../../../../../docs/technical/decisions/030-export-renders-the-preview-not-the-file.md)).
  String fileNameFor(String documentName) {
    final int dot = documentName.lastIndexOf('.');
    final String stem = dot > 0 ? documentName.substring(0, dot) : documentName;
    return '$stem.$extension';
  }
}
