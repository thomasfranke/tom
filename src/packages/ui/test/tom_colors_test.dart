import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

/// WCAG contrast of two opaque colours.
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('accent_muted is the soft teal, in both themes', () {
    expect(TomColors.dark.accentMuted, const Color(0xFF3E937E));
    expect(TomColors.light.accentMuted, const Color(0xFF389E84));
  });

  test('accent_muted is a glyph on the island: 3:1 at least', () {
    expect(
      _contrast(TomColors.dark.accentMuted, TomColors.dark.surfaceRaised),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrast(TomColors.light.accentMuted, TomColors.light.surfaceRaised),
      greaterThanOrEqualTo(3),
    );
  });

  test('accent_muted is teal, not grey: the green leads the red', () {
    for (final TomColors colors in <TomColors>[
      TomColors.dark,
      TomColors.light,
    ]) {
      final Color c = colors.accentMuted;
      expect(c.g, greaterThan(c.r + 0.15));
    }
  });

  test('accent_muted survives copyWith and lerp', () {
    const Color other = Color(0xFF000000);
    expect(TomColors.dark.copyWith(accentMuted: other).accentMuted, other);
    expect(
      TomColors.dark.lerp(TomColors.light, 1).accentMuted,
      TomColors.light.accentMuted,
    );
  });
}
