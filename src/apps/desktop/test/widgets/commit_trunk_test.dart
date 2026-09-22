import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/theme/tom_theme.dart';
import 'package:tom_desktop/widgets/commit_trunk.dart';
import 'package:tom_desktop/widgets/tom_wordmark.dart';

void main() {
  /// Mounts [child] under a trunk, optionally with animations switched off
  /// the way the platform's accessibility setting does.
  Widget app(Widget child, {bool still = false}) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: still),
      child: Scaffold(body: CommitTrunk(child: child)),
    ),
  );

  testWidgets('it hands the mark an anchor to be measured by', (
    WidgetTester tester,
  ) async {
    GlobalKey? under;
    GlobalKey? outside;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (BuildContext context) {
            under = CommitTrunk.anchorOf(context);
            return TomWordmark(
              key: under,
              letters: const Color(0xFFECEAE4),
              commit: const Color(0xFF84B5A5),
            );
          },
        ),
      ),
    );
    await tester.pump();

    // Outside a trunk the same call answers null, which is what lets any
    // other screen keep drawing the mark with nothing behind it.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            outside = CommitTrunk.anchorOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(under, isNotNull);
    expect(outside, isNull);
  });

  testWidgets('it draws a screen with no mark on it, and paints nothing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(const SizedBox.expand()));
    await tester.pump(const Duration(milliseconds: 200));

    // No anchor, no geometry, no guess at where the O might have been.
    expect(tester.takeException(), isNull);
  });

  testWidgets('it keeps a cycle running', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (BuildContext context) => TomWordmark(
            key: CommitTrunk.anchorOf(context),
            letters: const Color(0xFFECEAE4),
            commit: const Color(0xFF84B5A5),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.binding.hasScheduledFrame, isTrue);

    // The frame that never settles is the reason Home's own tests ask for
    // the still screen; leaving the widget running would hang them.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('it stands still when the platform asks for no animations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        still: true,
        Builder(
          builder: (BuildContext context) => TomWordmark(
            key: CommitTrunk.anchorOf(context),
            letters: const Color(0xFFECEAE4),
            commit: const Color(0xFF84B5A5),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Still is a design, not a fallback: the line and the commits are there,
    // and nothing is scheduled to move them.
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byType(TomWordmark), findsOneWidget);
  });
}
