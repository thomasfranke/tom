/// Drawing the number a footnote's marker stands for.
library;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Raises the number `FootnoteRefSyntaxImpl` emitted, and shrinks it.
///
/// Drawn rather than styled: the renderer's own `sup` is raised by the
/// `sups` font feature, and the serif face the prose is set in does not
/// carry one — the number then sits on the baseline and reads as part of the
/// sentence rather than as a marker.
class FootnoteMarkerBuilderImpl extends MarkdownElementBuilder {
  /// Creates the builder.
  FootnoteMarkerBuilderImpl();

  /// How much smaller than the prose around it.
  static const double scale = 0.7;

  /// How far above the baseline, as a share of the prose's size.
  static const double rise = 0.35;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final double size = parentStyle?.fontSize ?? preferredStyle?.fontSize ?? 15;
    return Transform.translate(
      offset: Offset(0, -size * rise),
      child: Text(
        element.textContent,
        style: (parentStyle ?? const TextStyle()).copyWith(
          fontSize: size * scale,
          // Never struck through or italic with the words around it: the
          // marker is not part of the sentence it sits in.
          fontStyle: FontStyle.normal,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
