import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Spaces spaces;
  late _Recents recents;
  late _Documents documents;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceEntity handbook = SpaceEntity(
    root: '/code/acme/handbook',
    repositoryRoot: '/code/acme',
    name: 'handbook',
  );
  final SpaceRelativePathValueObject note = SpaceRelativePathValueObject(
    'note.md',
  );
  final RecentSpaceEntity elsewhere = RecentSpaceEntity(
    root: '/code/acme/handbook',
    name: 'handbook',
    lastOpened: DateTime.utc(2026, 9, 20),
  );

  setUp(() {
    spaces = _Spaces();
    recents = _Recents();
    documents = _Documents();
    const _Silent silent = _Silent();
    container = ProviderContainer(
      overrides: <Override>[
        openSpaceProvider.overrideWithValue(
          OpenSpaceUseCase(
            spaces: spaces,
            recents: recents,
            observability: silent,
          ),
        ),
        listRecentSpacesProvider.overrideWithValue(
          ListRecentSpacesUseCase(recents: recents, observability: silent),
        ),
        // Leaving asks about the buffer, so the editor is wired even here.
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: silent,
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) => documents,
            observability: silent,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the menu over an open space and lets the first reads land.
  Future<void> open({bool withDocument = false}) async {
    container
      ..listen<SpaceMenuState>(spaceMenuProvider, (_, _) {})
      ..listen<EditorState>(editorProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    if (withDocument) {
      container.read(spaceSessionProvider.notifier).show(note);
    }
    await Future<void>.delayed(Duration.zero);
  }

  /// Types into the open document, so the buffer stops matching the disk.
  void typeSomething() =>
      container.read(editorProvider.notifier).edit('changed');

  SpaceMenuNotifier notifier() => container.read(spaceMenuProvider.notifier);
  SpaceMenuState state() => container.read(spaceMenuProvider);

  group('what the menu offers', () {
    test('the recents are read on the way in, not when it opens', () async {
      recents.stored = <RecentSpaceEntity>[elsewhere];

      await open();

      expect(state().recents, <RecentSpaceEntity>[elsewhere]);
      expect(state().isShowing, isFalse);
    });

    test('a list that cannot be read is empty, never an error', () async {
      recents.broken = true;

      await open();

      expect(state().recents, isEmpty);
    });
  });

  group('closing the space', () {
    test('with a clean buffer it leaves at once', () async {
      await open();

      await notifier().close();

      expect(container.read(spaceSessionProvider), isNull);
    });

    test('with an unsaved buffer it asks instead', () async {
      await open(withDocument: true);
      typeSomething();

      await notifier().close();

      expect(state().pending, const SpaceDeparture.closing());
      expect(
        container.read(spaceSessionProvider),
        isNotNull,
        reason: 'the space must still be open while the question stands',
      );
    });

    test('staying answers the question and keeps the space', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().close();

      notifier().stay();

      expect(state().pending, isNull);
      expect(container.read(spaceSessionProvider), isNotNull);
    });

    test('discarding leaves, and nothing was written', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().close();

      await notifier().discardAndLeave();

      expect(container.read(spaceSessionProvider), isNull);
      expect(documents.written, isEmpty);
    });

    test('saving writes first, then leaves', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().close();

      await notifier().saveAndLeave();

      expect(documents.written, <String>['changed']);
      expect(container.read(spaceSessionProvider), isNull);
    });

    test('a save that failed keeps the space and the question', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().close();
      documents.refuses = true;

      await notifier().saveAndLeave();

      expect(
        container.read(spaceSessionProvider),
        isNotNull,
        reason: 'leaving on a failed save loses what the question protected',
      );
      expect(state().pending, const SpaceDeparture.closing());
    });
  });

  group('switching to another space', () {
    test('it opens without going through Home', () async {
      await open();
      spaces.answer = Success<SpaceEntity, AppFailure>(handbook);

      await notifier().switchTo(elsewhere);

      expect(container.read(spaceSessionProvider)?.space, handbook);
      expect(state().isShowing, isFalse);
    });

    test(
      'an unsaved buffer is asked about first, naming where it goes',
      () async {
        await open(withDocument: true);
        typeSomething();

        await notifier().switchTo(elsewhere);

        expect(state().pending, SpaceDeparture.switching(elsewhere));
        expect(container.read(spaceSessionProvider)?.space, docs);
      },
    );

    test('and answering it goes there', () async {
      await open(withDocument: true);
      typeSomething();
      await notifier().switchTo(elsewhere);
      spaces.answer = Success<SpaceEntity, AppFailure>(handbook);

      await notifier().discardAndLeave();

      expect(container.read(spaceSessionProvider)?.space, handbook);
    });

    test('a folder that has moved keeps the space that is open', () async {
      await open();
      spaces.answer = const Failure<SpaceEntity, AppFailure>(
        GitNotARepository('/code/acme/handbook'),
      );

      await notifier().switchTo(elsewhere);

      expect(container.read(spaceSessionProvider)?.space, docs);
      expect(state().failure, contains('handbook'));
      expect(state().isBusy, isFalse);
    });
  });

  test('putting the menu away cancels the question behind it', () async {
    await open(withDocument: true);
    typeSomething();
    await notifier().close();

    notifier().dismiss();

    expect(state().pending, isNull);
    expect(state().isShowing, isFalse);
  });
}

/// The spaces a folder opens into.
final class _Spaces implements SpaceRepository {
  Result<SpaceEntity, AppFailure> answer =
      const Failure<SpaceEntity, AppFailure>(GitNotARepository('/unset'));

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async => answer;

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => const Success<List<SpaceEntryValueObject>, SpaceFailure>(
    <SpaceEntryValueObject>[],
  );
}

/// A recent list held in memory, which can also refuse to be read.
final class _Recents implements RecentSpacesRepository {
  List<RecentSpaceEntity> stored = <RecentSpaceEntity>[];
  bool broken = false;

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async => broken
      ? throw const _Unreadable()
      : Success<List<RecentSpaceEntity>, Never>(stored);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
}

/// What the list throws when it cannot be read.
final class _Unreadable implements Exception {
  const _Unreadable();
}

/// The one document these tests open, and what was written to it.
final class _Documents implements DocumentRepository {
  final List<String> written = <String>[];
  bool refuses = false;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: 'on disk'),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    if (refuses) {
      return Failure<void, DocumentFailure>(
        DocumentPermissionDenied(document.path.value),
      );
    }
    written.add(document.content);
    return const Success<void, DocumentFailure>(null);
  }
}

/// Observability that records nothing.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
