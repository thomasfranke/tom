/// The ↶ at the end of every row, and pressing a row's name, in both
/// sections (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_discard_widget.dart';
import 'package:tom_desktop/screens/changes/widgets/changes_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  StatusEntryValueObject entry(
    String path,
    FileStateEnum state, {
    bool isStaged = false,
    String? previous,
  }) => StatusEntryValueObject(
    path: RepoRelativePathValueObject(path),
    state: state,
    isStaged: isStaged,
    previousPath: previous == null
        ? null
        : RepoRelativePathValueObject(previous),
  );

  const double panel = 280;

  late _Recording changes;
  late ProviderContainer container;

  /// Mounts [entries] as rows of a [panel]-wide column with the space open.
  Future<void> pumpRows(
    WidgetTester tester,
    List<StatusEntryValueObject> entries, {
    Brightness brightness = Brightness.light,
    Locale? locale,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        changesProvider.overrideWith(() => changes = _Recording()),
        // A deleted row opens the last commit that touched it.
        readFileHistoryProvider.overrideWithValue(
          ReadFileHistoryUseCase(
            gitFor: (SpaceEntity space) => _History(),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier).open(docs);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(brightness),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: panel,
                child: Column(
                  children: <Widget>[
                    for (final StatusEntryValueObject each in entries)
                      SizedBox(
                        height: ChangesDesign.rowPitch,
                        child: ChangesRowWidget(entry: each, isBusy: false),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  final Finder glyph = find.byWidgetPredicate(
    (Widget widget) =>
        widget is TomGlyphWidget && widget.glyph == TomGlyphEnum.discard,
  );

  for (final Brightness brightness in Brightness.values) {
    testWidgets('every row draws the ↶ at the board\'s place, '
        '${brightness.name}', (WidgetTester tester) async {
      await pumpRows(tester, <StatusEntryValueObject>[
        entry('docs/a.md', FileStateEnum.modified),
        entry('docs/b.md', FileStateEnum.modified, isStaged: true),
        entry('docs/c.md', FileStateEnum.untracked),
      ], brightness: brightness);

      expect(glyph, findsNWidgets(3));
      final TomGlyphWidget drawn = tester.widget(glyph.first);
      final TomColors colors = brightness == Brightness.light
          ? TomColors.light
          : TomColors.dark;
      expect(drawn.size, 12);
      expect(drawn.color, colors.textSecondary);
      final Rect box = tester.getRect(glyph.first);
      expect(box.right, panel - ChangesDesign.inset);
      expect(box.center.dy, ChangesDesign.rowPitch / 2);
    });
  }

  testWidgets('the tooltip says what it does, and Delete for a new file', (
    WidgetTester tester,
  ) async {
    await pumpRows(tester, <StatusEntryValueObject>[
      entry('docs/a.md', FileStateEnum.modified),
      entry('docs/c.md', FileStateEnum.added, isStaged: true),
    ]);

    final List<String> said = tester
        .widgetList<Tooltip>(
          find.descendant(
            of: find.byType(ChangesDiscardWidget),
            matching: find.byType(Tooltip),
          ),
        )
        .map((Tooltip it) => it.message!)
        .toList();
    expect(said, <String>['Discard changes', 'Delete']);
  });

  testWidgets('a conflicted row offers nothing', (WidgetTester tester) async {
    await pumpRows(tester, <StatusEntryValueObject>[
      entry('docs/a.md', FileStateEnum.conflicted),
    ]);

    expect(glyph, findsNothing);
  });

  testWidgets('a row in CHANGES asks, and Cancel does nothing', (
    WidgetTester tester,
  ) async {
    await pumpRows(tester, <StatusEntryValueObject>[
      entry('docs/a.md', FileStateEnum.modified),
    ]);

    await tester.tap(glyph);
    await tester.pumpAndSettle();

    expect(find.text('Discard changes to a.md?'), findsOneWidget);
    expect(
      find.text('Everything not staged is lost. What is already staged stays.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(changes.discarded, isEmpty);
  });

  testWidgets('a row in CHANGES is put back once the question is answered', (
    WidgetTester tester,
  ) async {
    final StatusEntryValueObject a = entry('docs/a.md', FileStateEnum.modified);
    await pumpRows(tester, <StatusEntryValueObject>[a]);

    await tester.tap(glyph);
    await tester.pumpAndSettle();
    final Finder action = find.widgetWithText(
      OutlinedButton,
      'Discard changes',
    );
    // Outlined in `removed`, and never the filled one Enter would reach.
    expect(
      tester
          .widget<OutlinedButton>(action)
          .style
          ?.foregroundColor
          ?.resolve(<WidgetState>{}),
      TomColors.light.removed,
    );
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(changes.discarded, <StatusEntryValueObject>[a]);
  });

  testWidgets('a row in STAGED says it goes back to the last commit', (
    WidgetTester tester,
  ) async {
    await pumpRows(tester, <StatusEntryValueObject>[
      entry('docs/a.md', FileStateEnum.modified, isStaged: true),
    ]);

    await tester.tap(glyph);
    await tester.pumpAndSettle();

    expect(find.text('Discard changes to a.md?'), findsOneWidget);
    expect(
      find.text(
        'Everything changed since the last commit is lost, staged or not.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a file git never had is deleted, after saying so', (
    WidgetTester tester,
  ) async {
    final StatusEntryValueObject c = entry(
      'docs/c.md',
      FileStateEnum.untracked,
    );
    await pumpRows(tester, <StatusEntryValueObject>[c]);

    await tester.tap(glyph);
    await tester.pumpAndSettle();

    expect(find.text('Delete c.md?'), findsOneWidget);
    expect(
      find.text('It was never committed, so it cannot come back.'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(changes.discarded, <StatusEntryValueObject>[c]);
  });

  testWidgets('in Portuguese it asks in Portuguese', (
    WidgetTester tester,
  ) async {
    await pumpRows(tester, <StatusEntryValueObject>[
      entry('docs/a.md', FileStateEnum.modified, isStaged: true),
      entry('docs/c.md', FileStateEnum.untracked),
    ], locale: const Locale('pt'));

    await tester.tap(glyph.first);
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações em a.md?'), findsOneWidget);
    expect(
      find.text(
        'Tudo o que mudou desde o último commit se perde, no stage ou não.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(glyph.last);
    await tester.pumpAndSettle();
    expect(find.text('Excluir c.md?'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Excluir'), findsOneWidget);
  });

  group('pressing a name opens it with the diff on', () {
    for (final StatusEntryValueObject it in <StatusEntryValueObject>[
      entry('docs/guides/a.md', FileStateEnum.modified),
      entry('docs/guides/a.md', FileStateEnum.modified, isStaged: true),
      entry('docs/guides/a.md', FileStateEnum.added, isStaged: true),
      entry('docs/guides/a.md', FileStateEnum.untracked),
      entry(
        'docs/guides/a.md',
        FileStateEnum.renamed,
        isStaged: true,
        previous: 'docs/old.md',
      ),
    ]) {
      testWidgets('${it.state.name}, '
          '${it.isStaged ? 'in STAGED' : 'in CHANGES'}', (
        WidgetTester tester,
      ) async {
        await pumpRows(tester, <StatusEntryValueObject>[it]);

        await tester.tap(find.text('a.md'));
        await tester.pump();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(
          session.openDocument,
          SpaceRelativePathValueObject('guides/a.md'),
        );
        expect(session.showingDiff, isTrue);
      });
    }

    for (final bool isStaged in <bool>[false, true]) {
      testWidgets('a deleted document opens in preview, not as a version, '
          '${isStaged ? 'in STAGED' : 'in CHANGES'}', (
        WidgetTester tester,
      ) async {
        await pumpRows(tester, <StatusEntryValueObject>[
          entry('docs/a.md', FileStateEnum.deleted, isStaged: isStaged),
        ]);

        await tester.tap(find.text('a.md'));
        await tester.pump();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(session.openDocument, SpaceRelativePathValueObject('a.md'));
        expect(session.readingVersion, isNull);
        expect(session.mode, DocumentModeEnum.preview);
      });
    }
  });
}

/// A ready panel that remembers what it was asked to put back.
final class _Recording extends ChangesNotifier {
  final List<StatusEntryValueObject> discarded = <StatusEntryValueObject>[];

  @override
  ChangesState build() => const ChangesState.ready();

  @override
  Future<void> discard(StatusEntryValueObject entry) async =>
      discarded.add(entry);
}

/// Git's log, holding one commit for every file.
final class _History implements GitRepository {
  static final CommitEntity last = CommitEntity(
    sha: CommitShaValueObject('a' * 40),
    author: const AuthorValueObject(
      name: 'Thomas Franke',
      email: 'thomas@example.invalid',
    ),
    date: CommitDateValueObject(
      utc: DateTime.utc(2026, 10, 9),
      offset: Duration.zero,
    ),
    subject: 'Write the notes',
    body: '',
  );

  @override
  Future<Result<List<CommitEntity>, GitFailure>> history({
    RepoRelativePathValueObject? path,
    int? limit,
  }) async => Success<List<CommitEntity>, GitFailure>(<CommitEntity>[last]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
