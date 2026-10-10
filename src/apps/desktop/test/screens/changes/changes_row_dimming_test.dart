/// What the commit in flight does to the rows it is about to change, and to
/// its own button (`docs/product/git-workflow/commit/confirming/doc.md`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_commit_button_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_discard_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  final StatusEntryValueObject staged = StatusEntryValueObject(
    path: RepoRelativePathValueObject('docs/tasks/roadmap.md'),
    state: FileStateEnum.modified,
    isStaged: true,
  );
  final StatusEntryValueObject unstaged = StatusEntryValueObject(
    path: RepoRelativePathValueObject('product/diff/doc.md'),
    state: FileStateEnum.added,
    isStaged: false,
  );

  /// Mounts both rows and the button over a panel in [state].
  Future<void> pumpRows(
    WidgetTester tester,
    ChangesState state, {
    Locale? locale,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          changesProvider.overrideWith(() => _Fixed(state)),
        ],
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 28,
                    child: ChangesRowWidget(entry: staged, isBusy: true),
                  ),
                  SizedBox(
                    height: 28,
                    child: ChangesRowWidget(entry: unstaged, isBusy: true),
                  ),
                  ChangesCommitButtonWidget(
                    canCommit: false,
                    branch: BranchNameValueObject('main'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Color? inkOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  const TomColors colors = TomColors.light;

  testWidgets('while the commit runs, the staged rows are dimmed', (
    WidgetTester tester,
  ) async {
    await pumpRows(
      tester,
      const ChangesState.ready(isBusy: true, isCommitting: true),
    );

    expect(inkOf(tester, 'roadmap.md'), colors.textMuted);
    expect(
      inkOf(tester, 'docs/tasks'),
      colors.textMuted.withValues(alpha: 0.6),
    );
    // What is not going in is not what the commit changes.
    expect(inkOf(tester, 'doc.md'), colors.textPrimary);
    expect(inkOf(tester, 'product/diff'), colors.textMuted);
  });

  testWidgets('while the commit runs, only the rows not going in offer ↶', (
    WidgetTester tester,
  ) async {
    await pumpRows(
      tester,
      const ChangesState.ready(isBusy: true, isCommitting: true),
    );

    expect(find.byType(ChangesDiscardWidget), findsOneWidget);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('doc.md'),
          matching: find.byType(ChangesRowWidget),
        ),
        matching: find.byType(ChangesDiscardWidget),
      ),
      findsOneWidget,
    );
  });

  testWidgets('staging is busy too, and dims nothing', (
    WidgetTester tester,
  ) async {
    await pumpRows(tester, const ChangesState.ready(isBusy: true));

    expect(inkOf(tester, 'roadmap.md'), colors.textPrimary);
    expect(inkOf(tester, 'docs/tasks'), colors.textMuted);
    expect(find.text('Commit to main'), findsOneWidget);
  });

  testWidgets('the button says the verb in progress, and keeps its fill', (
    WidgetTester tester,
  ) async {
    await pumpRows(
      tester,
      const ChangesState.ready(isBusy: true, isCommitting: true),
    );

    expect(find.text('Committing…'), findsOneWidget);
    expect(find.text('Commit to main'), findsNothing);
    final FilledButton button = tester.widget(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{
        WidgetState.disabled,
      }),
      colors.accent,
    );
  });

  testWidgets('in Portuguese it says it in Portuguese', (
    WidgetTester tester,
  ) async {
    await pumpRows(
      tester,
      const ChangesState.ready(isBusy: true, isCommitting: true),
      locale: const Locale('pt'),
    );

    expect(find.text('Fazendo commit…'), findsOneWidget);
  });
}

/// A panel held in one state.
final class _Fixed extends ChangesNotifier {
  _Fixed(this.fixed);

  final ChangesState fixed;

  @override
  ChangesState build() => fixed;
}
