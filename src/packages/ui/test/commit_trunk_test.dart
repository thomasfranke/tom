import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// Mounts [child] under a trunk, optionally with animations switched off
  /// the way the platform's accessibility setting does.
  Widget app(Widget child, {bool still = false}) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: still),
      child: Scaffold(body: CommitTrunkWidget(child: child)),
    ),
  );

  /// Where the line belongs: the centre of the mark's commit, in the trunk's
  /// own coordinates.
  double commitX(WidgetTester tester) {
    final Rect mark = tester.getRect(find.byType(TomWordmarkWidget));
    final double scale = mark.width / TomMark.boxWidth;
    return mark.left -
        tester.getTopLeft(find.byType(CommitTrunkWidget)).dx +
        (TomMark.commitCentre.dx - TomMark.left) * scale;
  }

  /// What the ground paints: the first `CustomPaint` under the trunk, the
  /// wordmark's own being the other one.
  RenderObject ground(WidgetTester tester) => tester.renderObject(
    find
        .descendant(
          of: find.byType(CommitTrunkWidget),
          matching: find.byType(CustomPaint),
        )
        .first,
  );

  /// The mark, centred, carrying the anchor the trunk measures.
  Widget centredMark() => Center(
    child: Builder(
      builder: (BuildContext context) => TomWordmarkWidget(
        key: CommitTrunkWidget.anchorOf(context),
        letters: const Color(0xFFECEAE4),
        commit: const Color(0xFF84B5A5),
      ),
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
            under = CommitTrunkWidget.anchorOf(context);
            return TomWordmarkWidget(
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
            outside = CommitTrunkWidget.anchorOf(context);
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
          builder: (BuildContext context) => TomWordmarkWidget(
            key: CommitTrunkWidget.anchorOf(context),
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
          builder: (BuildContext context) => TomWordmarkWidget(
            key: CommitTrunkWidget.anchorOf(context),
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
    expect(find.byType(TomWordmarkWidget), findsOneWidget);
  });

  testWidgets('it runs its lanes clear of the mark, at any width', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 816);

    await tester.pumpWidget(app(still: true, centredMark()));
    await tester.pumpAndSettle();

    /// A lane is the one thing drawn from the top of the ground to the
    /// bottom of it — the trunk itself stops at the mark, twice.
    bool isLane(Symbol method, List<Object?> arguments) {
      if (method != #drawLine) {
        return false;
      }
      final Offset from = arguments[0]! as Offset;
      final Offset to = arguments[1]! as Offset;
      return from.dy == 0 &&
          to.dy == tester.getSize(find.byType(CommitTrunkWidget)).height;
    }

    // A lane that lands on the wordmark is a line through the letters, which
    // is what placing one in pixels rather than in proportion would do.
    bool clearsTheMark(List<Object?> arguments) {
      final Rect mark = tester
          .getRect(find.byType(TomWordmarkWidget))
          .shift(-tester.getTopLeft(find.byType(CommitTrunkWidget)));
      final double x = (arguments[0]! as Offset).dx;
      return x < mark.left - 8 || x > mark.right + 8;
    }

    for (final Size window in <Size>[
      const Size(1440, 816),
      const Size(900, 700),
    ]) {
      tester.view.physicalSize = window;
      await tester.pumpAndSettle();

      expect(ground(tester), paints..something(isLane));
      expect(
        ground(tester),
        paints..everything(
          (Symbol method, List<Object?> arguments) =>
              !isLane(method, arguments) || clearsTheMark(arguments),
        ),
      );
    }
  });

  testWidgets('it keeps the line under the mark when the window resizes', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);

    await tester.pumpWidget(app(still: true, centredMark()));
    await tester.pumpAndSettle();

    expect(ground(tester), paints..line(p1: Offset(commitX(tester), 0)));

    // A narrower window re-centres the mark and rebuilds nothing here — the
    // only media query this widget depends on is `disableAnimations` — so a
    // box remembered from the last frame would leave the line behind.
    tester.view.physicalSize = const Size(700, 800);
    await tester.pumpAndSettle();

    expect(ground(tester), paints..line(p1: Offset(commitX(tester), 0)));
  });
}
