/// The three faces, and what each one is for.
library;

/// The families the boards are drawn in, vendored in this package's `fonts/`
/// ([foundations](../../../../../../docs/design/foundations/README.md)).
///
/// Prefixed with `packages/tom_ui/` because a font declared by a package is
/// namespaced by it — the prefix is the family's real name, not a path, and
/// a style that drops it silently falls back to the platform's own face.
abstract final class TomFonts {
  /// The interface: every label, every panel, every control.
  static const String sans = 'packages/tom_ui/IBMPlexSans';

  /// Code, in the source pane and in the preview's fences alike.
  static const String mono = 'packages/tom_ui/IBMPlexMono';

  /// The rendered document's prose — the one place the reader is reading
  /// rather than operating.
  static const String serif = 'packages/tom_ui/IBMPlexSerif';
}
