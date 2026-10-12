/// The round mark that stands for a person.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// A circle of [size] holding [initials], or the outline of a person when
/// there are none.
///
/// Initials rather than GitHub's picture: everything TOM learns about an
/// account comes through `gh`, `git` or `ssh`, and a picture would be the one
/// HTTP request the app makes of its own ([Decision
/// 35](../../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
class AccountAvatarWidget extends StatelessWidget {
  /// Creates the avatar.
  const AccountAvatarWidget({
    required this.initials,
    required this.size,
    super.key,
  });

  /// What it says, or null for nobody.
  final String? initials;

  /// Its diameter.
  final double size;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('initials', initials))
      ..add(DoubleProperty('size', size));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final String? letters = initials;
    if (letters == null) {
      return SizedBox.square(
        dimension: size,
        child: Center(
          // Outlined, as the gear beside it is: an empty seat, not a person.
          child: TomGlyphWidget(
            glyph: TomGlyphEnum.person,
            color: colors.textSecondary,
            size: size * 0.6,
            outline: true,
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        letters,
        maxLines: 1,
        style: TextStyle(
          fontSize: size * 0.42,
          height: 1,
          fontWeight: FontWeight.w600,
          color: colors.accent,
        ),
      ),
    );
  }
}
