import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/home/widgets/home_recent_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  final RecentSpaceEntity docs = RecentSpaceEntity(
    root: '/work/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 10, 8),
  );

  /// Mounts [docs]'s row over git answering [branch] for its folder.
  Future<void> pumpRow(
    WidgetTester tester, {
    required RecentBranchRepository branches,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          readRecentBranchProvider.overrideWithValue(
            ReadRecentBranchUseCase(
              branches: branches,
              observability: const _Silent(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: Scaffold(
            body: SizedBox(
              width: 440,
              child: HomeRecentRowWidget(recent: docs),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a row names the branch its space was left on', (
    WidgetTester tester,
  ) async {
    await pumpRow(
      tester,
      branches: _Branches(BranchNameValueObject('feat/notes')),
    );

    expect(find.text('docs'), findsOneWidget);
    expect(find.text('feat/notes'), findsOneWidget);
    final TomGlyphWidget glyph = tester.widget(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TomGlyphWidget && widget.glyph == TomGlyphEnum.branch,
      ),
    );
    expect(glyph.color, TomColors.light.textMuted);
  });

  testWidgets('the branch sits between the name and the way to forget it', (
    WidgetTester tester,
  ) async {
    await pumpRow(tester, branches: _Branches(BranchNameValueObject('main')));

    final double name = tester.getTopRight(find.text('docs')).dx;
    final double branch = tester.getTopLeft(find.text('main')).dx;
    final double forget = tester
        .getTopLeft(find.byTooltip('Forget this space'))
        .dx;
    expect(name, lessThan(branch));
    expect(tester.getTopRight(find.text('main')).dx, lessThan(forget));
  });

  group('the way to forget a row', () {
    /// Whether the ✕ is drawn.
    bool isDrawn(WidgetTester tester) => tester
        .widget<Visibility>(
          find.ancestor(
            of: find.byTooltip('Forget this space'),
            matching: find.byType(Visibility),
          ),
        )
        .visible;

    /// A mouse over the row, taken away when the test ends.
    Future<TestGesture> hover(WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('docs')));
      await tester.pumpAndSettle();
      return mouse;
    }

    testWidgets('is not drawn on a row the pointer is not over', (
      WidgetTester tester,
    ) async {
      // A column of ✕ down the list is a column of ways to lose a row.
      await pumpRow(tester, branches: const _Branches(null));

      expect(isDrawn(tester), isFalse);
    });

    testWidgets('is drawn under the pointer, and goes when it leaves', (
      WidgetTester tester,
    ) async {
      await pumpRow(tester, branches: const _Branches(null));

      final TestGesture mouse = await hover(tester);
      expect(isDrawn(tester), isTrue);

      await mouse.moveTo(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(isDrawn(tester), isFalse);
    });

    testWidgets('keeps its room, so the branch does not move under the '
        'pointer', (WidgetTester tester) async {
      await pumpRow(tester, branches: _Branches(BranchNameValueObject('main')));
      final double before = tester.getTopLeft(find.text('main')).dx;

      await hover(tester);

      expect(tester.getTopLeft(find.text('main')).dx, before);
    });
  });

  testWidgets('a row on no branch draws none', (WidgetTester tester) async {
    await pumpRow(tester, branches: const _Branches(null));

    expect(find.text('docs'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TomGlyphWidget && widget.glyph == TomGlyphEnum.branch,
      ),
      findsNothing,
    );
  });

  testWidgets('a long branch is cut rather than pushing the name away', (
    WidgetTester tester,
  ) async {
    await pumpRow(
      tester,
      branches: _Branches(
        BranchNameValueObject('feat/a-very-long-branch-name-nobody-shortened'),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.textContaining('feat/')).width, lessThan(160));
    expect(find.text('docs'), findsOneWidget);
  });
}

/// Answers [branch] for every folder.
final class _Branches implements RecentBranchRepository {
  const _Branches(this.branch);

  final BranchNameValueObject? branch;

  @override
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  ) async => Success<BranchNameValueObject?, Never>(branch);
}

/// An [Observability] that drops everything.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
