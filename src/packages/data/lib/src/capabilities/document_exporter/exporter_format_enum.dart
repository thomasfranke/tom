/// The formats an exporter can be asked for.
library;

/// What an export is written as.
///
/// The capability's word for the domain's `ExportFormatEnum`, kept apart for
/// the reason `ExporterBlockKindEnum` is.
enum ExporterFormatEnum {
  /// One self-contained HTML page.
  html,

  /// A PDF.
  pdf,
}
