/// One of the three answers a waiting command is given.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';

/// What a [TomRowActionWidget] answers.
enum TomRowActionKind {
  /// `Run`: this one command, once. A check on a filled `accent`.
  confirm,

  /// `Always allow`: this command, from now on. Two checks, outlined.
  always,

  /// `Deny`: stop the plan. A cross on a filled `removed`.
  refuse,
}

/// The `Row action` of
/// [components](../../../../../../docs/design/components/controls.md): 20
/// tall and as wide as its label — 6, a 14 glyph, 3, the label, 10.
///
/// Three kinds for a row of the commands panel that waits
/// ([approvals](../../../../../../docs/product/git-workflow/approvals/doc.md)).
/// The glyph is drawn **with** the label, never instead of it: a cross and a
/// check are not the whole of what the button does.
class TomRowActionWidget extends StatelessWidget {
  /// Creates the action [kind], reading [label], calling [onPressed].
  const TomRowActionWidget({
    required this.kind,
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// The answer it gives.
  final TomRowActionKind kind;

  /// What it says.
  final String label;

  /// What it does.
  final VoidCallback onPressed;

  /// Its height.
  static const double height = 20;

  /// The glyph.
  static const double glyph = 14;

  /// The label's size.
  static const double labelSize = 11;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TomRowActionKind>('kind', kind))
      ..add(StringProperty('label', label))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final Color ink = switch (kind) {
      TomRowActionKind.always => colors.accent,
      _ => colors.surfaceRaised,
    };
    final Color? fill = switch (kind) {
      TomRowActionKind.confirm => colors.accent,
      TomRowActionKind.always => null,
      TomRowActionKind.refuse => colors.removed,
    };
    final BorderRadius radius = BorderRadius.circular(5);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          height: height,
          // The outline is drawn inside the box's measure, so the one kind
          // that has it gives up a point of padding on each side.
          padding: kind == TomRowActionKind.always
              ? const EdgeInsets.only(left: 5, right: 9)
              : const EdgeInsets.only(left: 6, right: 10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: kind == TomRowActionKind.always
                ? Border.all(color: colors.accent)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // The glyph is the kind's, not the label's: two checks read as
              // "again, and again", one as "this once".
              if (kind == TomRowActionKind.always)
                _TwoChecks(color: ink)
              else
                SizedBox.square(
                  dimension: glyph,
                  child: Center(
                    child: TomGlyphWidget(
                      glyph: kind == TomRowActionKind.confirm
                          ? TomGlyphEnum.check
                          : TomGlyphEnum.close,
                      color: ink,
                      size: 11,
                    ),
                  ),
                ),
              const SizedBox(width: 3),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `Always allow`'s mark: the check twice, overlapping.
class _TwoChecks extends StatelessWidget {
  const _TwoChecks({required this.color});

  final Color color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: TomRowActionWidget.glyph,
    height: TomRowActionWidget.glyph,
    child: Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 1.5,
          child: TomGlyphWidget(
            glyph: TomGlyphEnum.check,
            color: color,
            size: 10,
          ),
        ),
        Positioned(
          left: 4,
          top: 1.5,
          child: TomGlyphWidget(
            glyph: TomGlyphEnum.check,
            color: color,
            size: 10,
          ),
        ),
      ],
    ),
  );
}
