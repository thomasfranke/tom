import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  /// [child] under a trunk, [still] the way the platform's accessibility
  /// setting asks.
  Widget app(Widget child, {bool still = false}) => MaterialApp(
    theme: tomTheme(Brightness.dark),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: still),
      child: Scaffold(body: CommitTrunkWidget(child: child)),
    ),
  );

  /// The centre of the mark's commit, in the trunk's own coordinates.
  double commitX(WidgetTester tester) {
    final Rect mark = tester.getRect(find.byType(TomWordmarkWidget));
    final double scale = mark.width / TomMark.boxWidth;
    return mark.left -
        tester.getTopLeft(find.byType(CommitTrunkWidget)).dx +
        (TomMark.commitCentre.dx - TomMark.left) * scale;
  }

  /// The ground's paint: the first `CustomPaint` under the trunk, the
  /// wordmark's own being the other.
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

    // Unmounted on purpose: a cycle that never settles outlives the test.
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

    /// Whether a draw is a lane: the one line from the top of the ground to
    /// the bottom, since the trunk itself stops at the mark.
    bool isLane(Symbol method, List<Object?> arguments) {
      if (method != #drawLine) {
        return false;
      }
      final Offset from = arguments[0]! as Offset;
      final Offset to = arguments[1]! as Offset;
      return from.dy == 0 &&
          to.dy == tester.getSize(find.byType(CommitTrunkWidget)).height;
    }

    /// Whether a lane misses the wordmark, which one placed in pixels rather
    /// than in proportion would not at every width.
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

    // A resize re-centres the mark and rebuilds nothing in the trunk, so a
    // box remembered from the last frame would leave the line behind.
    tester.view.physicalSize = const Size(700, 800);
    await tester.pumpAndSettle();

    expect(ground(tester), paints..line(p1: Offset(commitX(tester), 0)));
  });
}
