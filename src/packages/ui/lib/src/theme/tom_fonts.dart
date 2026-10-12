/// The three faces, and what each one is for.
library;

import 'package:flutter/painting.dart';

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

  /// The rendered document's prose, headings and notes — the one place the
  /// reader is reading rather than operating. Public Sans.
  static const String reading = 'packages/tom_ui/PublicSans';

  /// The icon set: Font Awesome Free's solid face, one glyph per code point
  /// ([icons](../../../../../../docs/design/components/icons.md)).
  ///
  /// Unprefixed, unlike the faces above: an `IconData` names its package
  /// separately, in [iconsPackage].
  static const String icons = 'FontAwesomeSolid';

  /// The weight of the chosen segment of a segmented control.
  static const FontWeight segmentChosen = FontWeight.w600;

  /// The weight of the others — Regular, because Medium sits too close to
  /// SemiBold for the chosen one to stand out by weight alone.
  static const FontWeight segmentRest = FontWeight.w400;

  /// The package [icons] is declared in.
  static const String iconsPackage = 'tom_ui';
}
