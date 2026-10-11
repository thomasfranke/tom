import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Preferences stored;
  late _Approvals approvals;
  late ProviderContainer container;

  setUp(() {
    stored = _Preferences();
    approvals = _Approvals();
    container = ProviderContainer(
      overrides: <Override>[
        readPreferencesProvider.overrideWithValue(
          ReadPreferencesUseCase(preferences: stored),
        ),
        writePreferencesProvider.overrideWithValue(
          WritePreferencesUseCase(
            preferences: stored,
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the notifier and answers its first state.
  PreferencesValueObject start() {
    container.listen<PreferencesValueObject>(preferencesProvider, (_, _) {});
    return container.read(preferencesProvider);
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  PreferencesValueObject now() => container.read(preferencesProvider);

  test('it draws the defaults before the file has been read', () {
    // The window has to draw before anything has been read, and the read is
    // a disk trip.
    expect(start(), PreferencesValueObject.defaults);
  });

  test('what the machine holds replaces them', () async {
    stored.held = const PreferencesValueObject(theme: ThemeChoiceEnum.dark);
    start();

    await settle();

    expect(now().theme, ThemeChoiceEnum.dark);
  });

  test('a choice applies at once, with no OK and no Cancel', () async {
    start();
    await settle();

    container
        .read(preferencesProvider.notifier)
        .chooseTheme(ThemeChoiceEnum.light);

    // On screen before the disk: the window changes behind the popover.
    expect(now().theme, ThemeChoiceEnum.light);
  });

  test('and it reaches the store', () async {
    start();
    await settle();

    container
        .read(preferencesProvider.notifier)
        .chooseTheme(ThemeChoiceEnum.dark);
    await settle();

    expect(stored.held.theme, ThemeChoiceEnum.dark);
  });

  test('the language is stored, and nothing yet reads it', () async {
    // No literal in the app is translatable: the list is not the feature.
    start();
    await settle();

    container
        .read(preferencesProvider.notifier)
        .chooseLanguage(LanguageEnum.portuguese);
    await settle();

    expect(now().language, LanguageEnum.portuguese);
    expect(stored.held.language, LanguageEnum.portuguese);
  });

  test('the formatting bar is a toggle, and it persists', () async {
    start();
    await settle();

    container.read(preferencesProvider.notifier).toggleFormattingBar();
    await settle();

    expect(now().showingFormattingBar, isFalse);
    expect(stored.held.showingFormattingBar, isFalse);
  });

  test('checking for updates is on, then a toggle that persists', () async {
    start();
    await settle();
    expect(now().checkingForUpdates, isTrue);

    container.read(preferencesProvider.notifier).toggleCheckingForUpdates();
    await settle();

    expect(now().checkingForUpdates, isFalse);
    expect(stored.held.checkingForUpdates, isFalse);
  });

  test('a store that refuses loses the choice between runs, not on screen', () {
    // The choice is already applied; there is nothing to take back.
    stored.refuses = true;
    start();

    container.read(preferencesProvider.notifier).toggleFormattingBar();

    expect(now().showingFormattingBar, isFalse);
  });

  group('the file behind them', () {
    final SpaceEntity docs = SpaceEntity(
      root: '/code/docs',
      repositoryRoot: '/code/docs',
      name: 'docs',
    );
    final SpaceRelativePathValueObject file = SpaceRelativePathValueObject(
      'preferences.json',
    );

    setUp(() {
      container = ProviderContainer(
        overrides: <Override>[
          readPreferencesProvider.overrideWithValue(
            ReadPreferencesUseCase(preferences: stored),
          ),
          writePreferencesProvider.overrideWithValue(
            WritePreferencesUseCase(
              preferences: stored,
              observability: const _Silent(),
            ),
          ),
          preferencesFileProvider.overrideWithValue(file),
          seedApprovalsProvider.overrideWithValue(
            SeedApprovalsUseCase(
              approvals: approvals,
              observability: const _Silent(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    group('and the list of what may run unasked', () {
      final SpaceRelativePathValueObject list = SpaceRelativePathValueObject(
        'git-approvals.json',
      );

      test('opens the same way, every command listed first', () async {
        start();
        await settle();
        container.read(spaceSessionProvider.notifier).open(docs);

        await container.read(preferencesProvider.notifier).openApprovalsFile();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(session.appFiles, <SpaceRelativePathValueObject>[list]);
        expect(session.isShowingPreferencesFile, isTrue);
        expect(session.shownAppTab?.name, 'git-approvals.json');
        expect(approvals.seeded, 1);
        expect(stored.writes, 0, reason: 'the preferences are not its file');
      });

      test('opens nothing on Home, and lists nothing', () async {
        start();
        await settle();

        await container.read(preferencesProvider.notifier).openApprovalsFile();

        expect(container.read(spaceSessionProvider), isNull);
        expect(approvals.seeded, 0);
      });

      test('already open, it is chosen and not listed again', () async {
        start();
        await settle();
        container.read(spaceSessionProvider.notifier)
          ..open(docs)
          ..openPreferencesFile(list)
          ..show(SpaceRelativePathValueObject('a.md'));

        await container.read(preferencesProvider.notifier).openApprovalsFile();

        expect(
          container.read(spaceSessionProvider)!.isShowingPreferencesFile,
          isTrue,
        );
        expect(approvals.seeded, 0);
      });

      test('has a tab of its own beside the preferences file\'s', () async {
        start();
        await settle();
        container.read(spaceSessionProvider.notifier)
          ..open(docs)
          ..openPreferencesFile(file);

        await container.read(preferencesProvider.notifier).openApprovalsFile();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(session.appFiles, <SpaceRelativePathValueObject>[file, list]);
        expect(session.appFile, list, reason: 'the one just opened is shown');
      });

      test('never takes edits nobody saved from the other tab', () async {
        start();
        await settle();
        container.read(spaceSessionProvider.notifier)
          ..open(docs)
          ..openPreferencesFile(file)
          ..show(SpaceRelativePathValueObject('a.md'));
        container
            .read(heldBuffersProvider.notifier)
            .hold(
              EditorReady(
                saved: DocumentEntity(path: file, content: '{}'),
                source: '{"theme": "dark"}',
                isPreferences: true,
              ),
            );

        await container.read(preferencesProvider.notifier).openApprovalsFile();

        final SpaceSessionState session = container.read(spaceSessionProvider)!;
        expect(session.appFiles, contains(file), reason: 'not replaced');
        expect(
          container.read(heldBuffersProvider)[DocumentTab.preferences(file)],
          isNotNull,
          reason: 'its edits are still held',
        );
        expect(session.appFile, list);
      });

      test('a choice in the popover does not disturb its tab', () async {
        start();
        await settle();
        container.read(spaceSessionProvider.notifier)
          ..open(docs)
          ..openPreferencesFile(list);

        container
            .read(preferencesProvider.notifier)
            .chooseGitApprovals(GitApprovalModeEnum.manual);
        await settle();

        // The editor was never asked to follow a file this did not write.
        expect(container.exists(editorProvider), isFalse);
        expect(stored.held.gitApprovals, GitApprovalModeEnum.manual);
      });
    });

    test('opens in a tab of the space, what is in force written', () async {
      start();
      await settle();
      container.read(spaceSessionProvider.notifier).open(docs);
      container
          .read(preferencesProvider.notifier)
          .chooseLanguage(LanguageEnum.portuguese);
      await settle();
      stored.held = PreferencesValueObject.defaults;

      await container.read(preferencesProvider.notifier).openFile();

      expect(container.read(spaceSessionProvider)?.appFile, file);
      // A machine that never chose anything still finds them in the file.
      expect(stored.held.language, LanguageEnum.portuguese);
    });

    test('opens nothing on Home, which has no tabs', () async {
      start();
      await settle();

      await container.read(preferencesProvider.notifier).openFile();

      expect(container.read(spaceSessionProvider), isNull);
    });

    test(
      'a tab already open is chosen, and nothing is written over it',
      () async {
        start();
        await settle();
        container.read(spaceSessionProvider.notifier)
          ..open(docs)
          ..openPreferencesFile(file)
          ..show(SpaceRelativePathValueObject('a.md'));
        stored.writes = 0;

        await container.read(preferencesProvider.notifier).openFile();

        expect(
          container.read(spaceSessionProvider)!.isShowingPreferencesFile,
          isTrue,
        );
        expect(stored.writes, 0);
      },
    );

    test('reading again is what saving it by hand applies', () async {
      start();
      await settle();
      stored.held = const PreferencesValueObject(theme: ThemeChoiceEnum.dark);

      await container.read(preferencesProvider.notifier).reload();

      expect(now().theme, ThemeChoiceEnum.dark);
    });
  });

  test('one preference changing leaves the other two alone', () async {
    stored.held = const PreferencesValueObject(
      theme: ThemeChoiceEnum.dark,
      language: LanguageEnum.portuguese,
      showingFormattingBar: false,
    );
    start();
    await settle();

    container
        .read(preferencesProvider.notifier)
        .chooseTheme(ThemeChoiceEnum.light);
    await settle();

    expect(stored.held.language, LanguageEnum.portuguese);
    expect(stored.held.showingFormattingBar, isFalse);
  });
}

/// Preferences in memory, refusing to write when a test says so.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;
  bool refuses = false;
  int writes = 0;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    writes++;
    if (refuses) {
      return const Failure<void, AppFailure>(UnexpectedFailure('no store'));
    }
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}

/// The list of allowed commands, counting the times it was asked to list.
final class _Approvals implements ApprovalsRepository {
  int seeded = 0;

  @override
  Future<Result<void, AppFailure>> seed() async {
    seeded++;
    return const Success<void, AppFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
