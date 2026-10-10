import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceEntity notes = SpaceEntity(
    root: '/code/notes',
    repositoryRoot: '/code/notes',
    name: 'notes',
  );

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  SpaceSessionNotifier session() =>
      container.read(spaceSessionProvider.notifier);

  test('nothing is open until something opens it', () {
    expect(container.read(spaceSessionProvider), isNull);
  });

  group('a file that is not markdown', () {
    SpaceSessionState now() => container.read(spaceSessionProvider)!;

    test('is drawn in source, the choice kept for the next document', () {
      session()
        ..open(docs)
        ..look(DocumentModeEnum.preview)
        ..show(SpaceRelativePathValueObject('site.yaml'));

      expect(now().isSourceOnly, isTrue);
      expect(now().drawnMode, DocumentModeEnum.source);
      expect(now().mode, DocumentModeEnum.preview);

      session().showOutside(RepoRelativePathValueObject('ci/build.yml'));
      expect(now().drawnMode, DocumentModeEnum.source);

      session().show(SpaceRelativePathValueObject('guide.md'));
      expect(now().isSourceOnly, isFalse);
      expect(now().drawnMode, DocumentModeEnum.preview);
    });

    test('gives way to a pull request, which is markdown', () {
      session()
        ..open(docs)
        ..show(SpaceRelativePathValueObject('site.yaml'))
        ..proposeBranch(
          BranchNameValueObject('feat/x'),
          BranchNameValueObject('main'),
        );

      expect(now().isSourceOnly, isFalse);
    });
  });

  test('a space survives with nobody listening', () {
    // Riverpod disposes a provider nobody listens to, and the session is
    // written by Home — the screen on its way out.
    session().open(docs);

    expect(container.read(spaceSessionProvider)?.space, docs);
  });

  test('a space opens with no document showing', () {
    session().open(docs);

    expect(container.read(spaceSessionProvider)?.openDocument, isNull);
  });

  test('showing a document keeps the space', () {
    session().open(docs);

    session().show(SpaceRelativePathValueObject('guides/writing.md'));

    expect(
      container.read(spaceSessionProvider),
      SpaceSessionState(
        space: docs,
        openDocument: SpaceRelativePathValueObject('guides/writing.md'),
        tabs: <DocumentTab>[
          DocumentTab.inSpace(
            SpaceRelativePathValueObject('guides/writing.md'),
          ),
        ],
        previewTab: DocumentTab.inSpace(
          SpaceRelativePathValueObject('guides/writing.md'),
        ),
      ),
    );
  });

  group('tabs', () {
    final SpaceRelativePathValueObject a = SpaceRelativePathValueObject('a.md');
    final SpaceRelativePathValueObject b = SpaceRelativePathValueObject('b.md');
    final DocumentTab tabA = DocumentTab.inSpace(a);
    final DocumentTab tabB = DocumentTab.inSpace(b);

    test('a second click replaces the tab in preview', () {
      session()
        ..open(docs)
        ..show(a)
        ..show(b);

      expect(container.read(spaceSessionProvider)?.tabs, <DocumentTab>[tabB]);
    });

    test('a kept tab stays, and the next click opens beside it', () {
      session()
        ..open(docs)
        ..show(a)
        ..keep(tabA)
        ..show(b);

      expect(container.read(spaceSessionProvider)?.tabs, <DocumentTab>[
        tabA,
        tabB,
      ]);
      expect(container.read(spaceSessionProvider)?.previewTab, tabB);
    });

    test('closing the tab on screen shows its neighbour', () {
      session()
        ..open(docs)
        ..show(a)
        ..keep(tabA)
        ..show(b)
        ..closeTab(tabB);

      expect(container.read(spaceSessionProvider)?.openDocument, a);
      expect(container.read(spaceSessionProvider)?.tabs, <DocumentTab>[tabA]);
    });
  });

  group('a file outside the space', () {
    // `README.md` beside the space, and the space's own `README.md`: two
    // files with one spelling, which is why a tab says where it is from.
    final RepoRelativePathValueObject beside = RepoRelativePathValueObject(
      'README.md',
    );
    final SpaceRelativePathValueObject inside = SpaceRelativePathValueObject(
      'README.md',
    );
    SpaceSessionState now() => container.read(spaceSessionProvider)!;

    test('is on screen in the document\'s place, never beside it', () {
      session()
        ..open(docs)
        ..show(inside)
        ..showOutside(beside);

      expect(now().openDocument, isNull);
      expect(now().outsideDocument, beside);
      expect(now().onScreen, DocumentTab.outside(beside));
    });

    test('replaces the tab in preview like any click', () {
      session()
        ..open(docs)
        ..show(inside)
        ..showOutside(beside);

      expect(now().tabs, <DocumentTab>[DocumentTab.outside(beside)]);
      expect(now().previewTab, DocumentTab.outside(beside));
    });

    test('is a tab of its own beside a document of the same name', () {
      session()
        ..open(docs)
        ..show(inside)
        ..keep(DocumentTab.inSpace(inside))
        ..showOutside(beside)
        ..show(inside);

      expect(now().tabs, <DocumentTab>[
        DocumentTab.inSpace(inside),
        DocumentTab.outside(beside),
      ]);
      expect(now().openDocument, inside);
      expect(now().outsideDocument, isNull);
    });

    test('closing it shows its neighbour, a document of the space', () {
      session()
        ..open(docs)
        ..show(inside)
        ..keep(DocumentTab.inSpace(inside))
        ..showOutside(beside)
        ..closeTab(DocumentTab.outside(beside));

      expect(now().onScreen, DocumentTab.inSpace(inside));
      expect(now().tabs, <DocumentTab>[DocumentTab.inSpace(inside)]);
    });

    test('takes the screen from the preferences file', () {
      session()
        ..open(docs)
        ..openPreferencesFile(SpaceRelativePathValueObject('preferences.json'))
        ..showOutside(beside);

      expect(now().isShowingPreferencesFile, isFalse);
    });
  });

  group('the preferences file', () {
    final SpaceRelativePathValueObject a = SpaceRelativePathValueObject('a.md');
    final SpaceRelativePathValueObject b = SpaceRelativePathValueObject('b.md');
    final SpaceRelativePathValueObject file = SpaceRelativePathValueObject(
      'preferences.json',
    );
    SpaceSessionState now() => container.read(spaceSessionProvider)!;

    test('opens in a tab of its own, on screen, with no document', () {
      session()
        ..open(docs)
        ..show(a)
        ..openPreferencesFile(file);

      expect(now().preferencesFile, file);
      expect(now().openDocument, isNull);
      expect(now().isShowingPreferencesFile, isTrue);
      // Never one of the space's tabs: what reads them takes each for a
      // document of the space.
      expect(now().tabs, <DocumentTab>[DocumentTab.inSpace(a)]);
    });

    test('is drawn in source whatever mode was chosen', () {
      session()
        ..open(docs)
        ..look(DocumentModeEnum.preview)
        ..openPreferencesFile(file);

      expect(now().drawnMode, DocumentModeEnum.source);
      // The choice itself is kept for the next document.
      expect(now().mode, DocumentModeEnum.preview);
    });

    test('its tab, chosen, puts it back on screen', () {
      session()
        ..open(docs)
        ..openPreferencesFile(file)
        ..show(SpaceRelativePathValueObject('guide.md'))
        ..choose(DocumentTab.preferences(file));

      expect(now().isShowingPreferencesFile, isTrue);
      expect(now().tabs, <DocumentTab>[
        DocumentTab.inSpace(SpaceRelativePathValueObject('guide.md')),
      ]);
    });

    test('a file of the space by the same name is another tab', () {
      session()
        ..open(docs)
        ..openPreferencesFile(file)
        ..show(file);

      expect(now().preferencesTab, isNot(now().onScreen));
      expect(now().tabs, <DocumentTab>[DocumentTab.inSpace(file)]);
    });

    test('a document chosen takes the screen, and the tab stays', () {
      session()
        ..open(docs)
        ..openPreferencesFile(file)
        ..show(a);

      expect(now().isShowingPreferencesFile, isFalse);
      expect(now().preferencesFile, file);
      expect(now().drawnMode, DocumentModeEnum.split);
    });

    test('closing it shows the last document', () {
      session()
        ..open(docs)
        ..show(a)
        ..keep(DocumentTab.inSpace(a))
        ..show(b)
        ..openPreferencesFile(file)
        ..closeTab(DocumentTab.preferences(file));

      expect(now().preferencesFile, isNull);
      expect(now().openDocument, b);
    });

    test('closing it when it is not on screen leaves the screen alone', () {
      session()
        ..open(docs)
        ..openPreferencesFile(file)
        ..show(a)
        ..closeTab(DocumentTab.preferences(file));

      expect(now().preferencesFile, isNull);
      expect(now().openDocument, a);
    });

    test('closing the last document shows it, its right neighbour', () {
      session()
        ..open(docs)
        ..show(a)
        ..keep(DocumentTab.inSpace(a))
        ..show(b)
        ..openPreferencesFile(file)
        ..show(b)
        ..closeTab(DocumentTab.inSpace(b));

      expect(now().openDocument, isNull);
      expect(now().isShowingPreferencesFile, isTrue);
    });

    test('another space does not inherit it', () {
      session()
        ..open(docs)
        ..openPreferencesFile(file)
        ..open(notes);

      expect(now().preferencesFile, isNull);
    });
  });

  test('another space does not inherit the open document', () {
    session().open(docs);
    session().show(SpaceRelativePathValueObject('index.md'));

    session().open(notes);

    expect(container.read(spaceSessionProvider)?.openDocument, isNull);
  });

  group('the Diff chip', () {
    bool showing() => container.read(spaceSessionProvider)!.showingDiff;

    test('a press turns the marks off, and the next turns them on', () {
      session().open(docs);
      expect(showing(), isTrue);

      session().toggleDiff();
      expect(showing(), isFalse);

      session().toggleDiff();
      expect(showing(), isTrue);
    });

    test('the base survives the marks going off', () {
      final DiffBaseValueObject develop = DiffBaseValueObject(
        branch: BranchRefValueObject(name: BranchNameValueObject('develop')),
        forkPoint: CommitShaValueObject(
          'abc1234def5678901234567890abcdef12345678',
        ),
      );
      session()
        ..open(docs)
        ..compare(develop)
        ..toggleDiff();

      expect(container.read(spaceSessionProvider)?.comparingAgainst, develop);
    });
  });

  test('showing a document with nothing open changes nothing', () {
    session().show(SpaceRelativePathValueObject('index.md'));

    expect(container.read(spaceSessionProvider), isNull);
  });
}
