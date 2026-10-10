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
