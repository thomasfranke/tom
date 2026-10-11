import 'dart:convert';
import 'dart:typed_data';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Documents documents;
  late ProviderContainer container;
  late List<String> rootsAsked;
  _Reading? reading;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );
  final SpaceRelativePathValueObject index = SpaceRelativePathValueObject(
    'index.md',
  );

  late _Committed committed;
  late List<String> revealed;

  setUp(() {
    documents = _Documents();
    committed = _Committed();
    revealed = <String>[];
    reading = null;
    // The folder every read and write was rooted in, in order.
    final List<String> roots = rootsAsked = <String>[];
    container = ProviderContainer(
      overrides: <Override>[
        // Made to exist only by the tests about it, as the shell does.
        gitReadingProvider.overrideWith(() => reading = _Reading()),
        readDocumentProvider.overrideWithValue(
          ReadDocumentUseCase(
            documentsFor: (SpaceEntity space) {
              roots.add(space.root);
              return documents;
            },
            observability: const _Silent(),
          ),
        ),
        saveDocumentProvider.overrideWithValue(
          SaveDocumentUseCase(
            documentsFor: (SpaceEntity space) {
              roots.add(space.root);
              return documents;
            },
            observability: const _Silent(),
          ),
        ),
        readFileProvider.overrideWithValue(
          ReadFileUseCase(
            documentsFor: (SpaceEntity space) {
              roots.add(space.root);
              return documents;
            },
            observability: const _Silent(),
          ),
        ),
        readCommittedFileProvider.overrideWithValue(
          ReadCommittedFileUseCase(
            gitFor: (SpaceEntity space) => committed,
            observability: const _Silent(),
          ),
        ),
        revealFolderProvider.overrideWithValue(
          RevealFolderUseCase(
            desktop: _Desktop(revealed),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the editor, and answers its first state.
  EditorState start() {
    container.listen<EditorState>(editorProvider, (_, _) {});
    return container.read(editorProvider);
  }

  /// Opens [space] and shows [document], the way the tree does.
  void show(SpaceEntity space, SpaceRelativePathValueObject? document) {
    container.read(spaceSessionProvider.notifier).open(space);
    if (document != null) {
      container.read(spaceSessionProvider.notifier).show(document);
    }
  }

  /// Everything scheduled, run.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  EditorReady ready() => container.read(editorProvider) as EditorReady;

  test('with no document chosen there is no buffer', () async {
    expect(start(), isA<EditorEmpty>());
    show(docs, null);
    await settle();

    expect(container.read(editorProvider), isA<EditorEmpty>());
    expect(documents.asked, isEmpty);
  });

  test('choosing a document reads it into a clean buffer', () async {
    start();
    show(docs, writing);

    expect(container.read(editorProvider), isA<EditorLoading>());
    await settle();

    expect(ready().source, '# writing.md\n');
    expect(container.read(editorProvider).isDirty, isFalse);
    expect(documents.asked, <SpaceRelativePathValueObject>[writing]);
  });

  test('a document that is gone is a failure, not an empty buffer', () async {
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
      DocumentNotFound(writing.value),
    );
    start();
    show(docs, writing);
    await settle();

    expect(
      (container.read(editorProvider) as EditorFailed).failure,
      DocumentNotFound(writing.value),
    );
  });

  group('the buffer and the file', () {
    test('typing makes the document unsaved', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# changed\n');

      expect(container.read(editorProvider).isDirty, isTrue);
      expect(documents.written, isEmpty);
    });

    test('typing a character and taking it back leaves it clean', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier)
        ..edit('# writing.md!\n')
        ..edit('# writing.md\n');

      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('saving writes the buffer and clears the mark', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      await container.read(editorProvider.notifier).save();

      expect(
        documents.written.single,
        DocumentEntity(path: writing, content: '# changed\n'),
      );
      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('saving has git read again, so the tree marks it at once', () async {
      container.listen<GitReadingState>(gitReadingProvider, (_, _) {});
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      await container.read(editorProvider.notifier).save();

      expect(reading?.refreshes, 1);
    });

    test('and makes no reading where none exists', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      await container.read(editorProvider.notifier).save();

      expect(container.exists(gitReadingProvider), isFalse);
    });

    test('saving a document nobody touched writes nothing', () async {
      start();
      show(docs, writing);
      await settle();

      await container.read(editorProvider.notifier).save();

      expect(documents.written, isEmpty);
    });

    test('a refused save keeps the work and says so', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');
      documents.refusal = Failure<void, DocumentFailure>(
        DocumentPermissionDenied(writing.value),
      );

      await container.read(editorProvider.notifier).save();

      expect(ready().source, '# changed\n');
      expect(container.read(editorProvider).isDirty, isTrue);
      expect(ready().saveFailure, DocumentPermissionDenied(writing.value));
    });

    test('typing during a save leaves the document dirty again', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# first\n');

      final Future<void> saving = container
          .read(editorProvider.notifier)
          .save();
      container.read(editorProvider.notifier).edit('# second\n');
      await saving;

      expect(documents.written.single.content, '# first\n');
      expect(ready().source, '# second\n');
      expect(container.read(editorProvider).isDirty, isTrue);
    });

    test('a second save finds the first one on disk, and writes', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# first\n');
      await container.read(editorProvider.notifier).save();
      container.read(editorProvider.notifier).edit('# second\n');

      await container.read(editorProvider.notifier).save();

      expect(documents.written.last.content, '# second\n');
      expect(ready().changedOnDisk, isFalse);
    });
  });

  group('a file changed on disk under an edit', () {
    /// Somebody else writes [text] into the open document's file.
    void diskSays(String text) =>
        documents.answer = Success<DocumentEntity, DocumentFailure>(
          DocumentEntity(path: writing, content: text),
        );

    Future<void> editThenChangeTheDisk() async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# mine\n');
      diskSays('# theirs\n');
    }

    test('the save writes nothing, keeps the work and asks', () async {
      await editThenChangeTheDisk();

      await container.read(editorProvider.notifier).save();

      expect(documents.written, isEmpty);
      expect(ready().source, '# mine\n');
      expect(ready().changedOnDisk, isTrue);
      expect(ready().isSaving, isFalse);
      // A question, not a refusal by the machine.
      expect(ready().saveFailure, isNull);
      expect(container.read(editorProvider.notifier).hasUnsaved, isTrue);
    });

    test('saving again while it asks still writes nothing', () async {
      await editThenChangeTheDisk();
      await container.read(editorProvider.notifier).save();

      await container.read(editorProvider.notifier).save();

      expect(documents.written, isEmpty);
      expect(ready().changedOnDisk, isTrue);
    });

    test('Keep mine, and the next save writes over what is there', () async {
      await editThenChangeTheDisk();
      await container.read(editorProvider.notifier).save();

      container.read(editorProvider.notifier).keepMine();
      expect(ready().changedOnDisk, isFalse);
      await container.read(editorProvider.notifier).save();

      expect(documents.written.single.content, '# mine\n');
      expect(container.read(editorProvider).isDirty, isFalse);
      expect(ready().overwritesDisk, isFalse);
    });

    test('Keep mine answers once: a later change asks again', () async {
      await editThenChangeTheDisk();
      await container.read(editorProvider.notifier).save();
      container.read(editorProvider.notifier).keepMine();
      await container.read(editorProvider.notifier).save();
      container.read(editorProvider.notifier).edit('# mine again\n');
      diskSays('# theirs again\n');

      await container.read(editorProvider.notifier).save();

      expect(documents.written, hasLength(1));
      expect(ready().changedOnDisk, isTrue);
    });

    test('Reload takes what is on disk, and the edit goes', () async {
      await editThenChangeTheDisk();
      await container.read(editorProvider.notifier).save();

      await container.read(editorProvider.notifier).reload();

      expect(ready().source, '# theirs\n');
      expect(ready().changedOnDisk, isFalse);
      expect(container.read(editorProvider).isDirty, isFalse);
      expect(documents.written, isEmpty);
    });

    test('a file that is gone is written again, with nothing asked', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# mine\n');
      documents.answer = Failure<DocumentEntity, DocumentFailure>(
        DocumentNotFound(writing.value),
      );

      await container.read(editorProvider.notifier).save();

      expect(documents.written.single.content, '# mine\n');
      expect(ready().changedOnDisk, isFalse);
    });

    test('saving everything leaves a held tab unsaved, and it asks when '
        'it comes back', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# mine\n');
      container.read(spaceSessionProvider.notifier).show(index);
      await settle();
      documents.changed[writing] = '# theirs\n';

      await container.read(editorProvider.notifier).saveAll();

      expect(documents.written, isEmpty);
      expect(container.read(editorProvider.notifier).hasUnsaved, isTrue);
      container.read(spaceSessionProvider.notifier).show(writing);
      await settle();
      expect(ready().source, '# mine\n');
      expect(ready().changedOnDisk, isTrue);
    });
  });

  group('the selection and the formatting bar', () {
    test('moving the selection leaves the buffer clean', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).select(2, 12);

      expect(ready().selectionStart, 2);
      expect(ready().selectionEnd, 12);
      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('going to a place selects it, and asking again asks again', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).goTo(2, 12);
      expect(ready().selectionStart, 2);
      expect(ready().selectionEnd, 12);
      expect(ready().reveals, 1);
      expect(container.read(editorProvider).isDirty, isFalse);

      // The same place, because the pane may have been scrolled away.
      container.read(editorProvider.notifier).goTo(2, 12);
      expect(ready().reveals, 2);
    });

    test('the same selection again changes nothing', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).select(2, 12);
      final EditorReady before = ready();

      container.read(editorProvider.notifier).select(2, 12);

      expect(identical(ready(), before), isTrue);
    });

    test('a command formats the selection and keeps it selected', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier)
        ..select(2, 12)
        ..format(FormatCommandEnum.bold);

      expect(ready().source, '# **writing.md**\n');
      expect(
        ready().source.substring(ready().selectionStart, ready().selectionEnd),
        'writing.md',
      );
      expect(container.read(editorProvider).isDirty, isTrue);
      expect(documents.written, isEmpty);
    });

    test('with no buffer there is nothing to format', () {
      start();

      container.read(editorProvider.notifier)
        ..select(0, 1)
        ..format(FormatCommandEnum.bold);

      expect(container.read(editorProvider), isA<EditorEmpty>());
    });
  });

  test('choosing another document starts another buffer', () async {
    start();
    show(docs, writing);
    await settle();
    container.read(editorProvider.notifier).edit('# changed\n');

    container.read(spaceSessionProvider.notifier).show(index);
    await settle();

    expect(ready().source, '# index.md\n');
    expect(container.read(editorProvider).isDirty, isFalse);
    expect(documents.asked, <SpaceRelativePathValueObject>[writing, index]);
  });

  group('tabs', () {
    test('editing keeps a tab opened in preview', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# changed\n');

      expect(container.read(spaceSessionProvider)?.previewTab, isNull);
    });

    test(
      'an unsaved tab keeps its buffer while another is on screen',
      () async {
        start();
        show(docs, writing);
        await settle();
        container.read(editorProvider.notifier).edit('# changed\n');
        container.read(spaceSessionProvider.notifier).show(index);
        await settle();

        container.read(spaceSessionProvider.notifier).show(writing);
        await settle();

        expect(ready().source, '# changed\n');
        expect(container.read(editorProvider).isDirty, isTrue);
        expect(documents.asked, <SpaceRelativePathValueObject>[writing, index]);
      },
    );

    test('both are unsaved, and leaving would ask', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');
      container.read(spaceSessionProvider.notifier).show(index);
      await settle();

      expect(container.read(unsavedDocumentsProvider), <DocumentTab>{
        DocumentTab.inSpace(writing),
      });
      expect(container.read(editorProvider.notifier).hasUnsaved, isTrue);
    });

    test('saving everything writes the held buffer too', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');
      container.read(spaceSessionProvider.notifier).show(index);
      await settle();

      await container.read(editorProvider.notifier).saveAll();

      expect(container.read(unsavedDocumentsProvider), isEmpty);
    });

    test('a closed tab\'s edits are not held', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      container
          .read(spaceSessionProvider.notifier)
          .closeTab(DocumentTab.inSpace(writing));
      await settle();

      expect(container.read(heldBuffersProvider), isEmpty);
    });
  });

  group('the preferences file', () {
    late _Documents appFolder;
    late _Preferences preferences;
    late _Approvals approvals;
    final SpaceRelativePathValueObject file = SpaceRelativePathValueObject(
      'preferences.json',
    );

    setUp(() {
      appFolder = _Documents();
      preferences = _Preferences();
      approvals = _Approvals();
      container = ProviderContainer(
        overrides: <Override>[
          readDocumentProvider.overrideWithValue(
            ReadDocumentUseCase(
              documentsFor: (SpaceEntity space) => documents,
              observability: const _Silent(),
            ),
          ),
          saveDocumentProvider.overrideWithValue(
            SaveDocumentUseCase(
              documentsFor: (SpaceEntity space) => documents,
              observability: const _Silent(),
            ),
          ),
          preferencesFileProvider.overrideWithValue(file),
          readPreferencesFileProvider.overrideWithValue(
            ReadDocumentUseCase(
              documentsFor: (SpaceEntity space) => appFolder,
              observability: const _Silent(),
            ),
          ),
          savePreferencesFileProvider.overrideWithValue(
            SaveDocumentUseCase(
              documentsFor: (SpaceEntity space) => appFolder,
              observability: const _Silent(),
            ),
          ),
          readPreferencesProvider.overrideWithValue(
            ReadPreferencesUseCase(preferences: preferences),
          ),
          writePreferencesProvider.overrideWithValue(
            WritePreferencesUseCase(
              preferences: preferences,
              observability: const _Silent(),
            ),
          ),
          readApprovalsProvider.overrideWithValue(
            ReadApprovalsUseCase(approvals: approvals),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    /// Opens the file over [document], the way the popover's button does.
    Future<void> openFile({SpaceRelativePathValueObject? over}) async {
      start();
      show(docs, over);
      await settle();
      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await settle();
    }

    test('is read from the app\'s own folder, never the space', () async {
      await openFile();

      expect(appFolder.asked, <SpaceRelativePathValueObject>[file]);
      expect(documents.asked, isEmpty);
      expect(ready().isPreferences, isTrue);
      expect(ready().saved.path, file);
    });

    test('takes no markdown from the formatting buttons', () async {
      await openFile();

      container.read(editorProvider.notifier).format(FormatCommandEnum.bold);

      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('saving it writes the file and applies what it says', () async {
      container.listen(preferencesProvider, (_, _) {});
      await openFile();
      container.read(editorProvider.notifier).edit('{"theme": "dark"}');
      // What the store reads back once the file says so.
      preferences.held = const PreferencesValueObject(
        theme: ThemeChoiceEnum.dark,
      );

      await container.read(editorProvider.notifier).save();
      await settle();

      expect(appFolder.written.single.content, '{"theme": "dark"}');
      expect(documents.written, isEmpty);
      expect(container.read(preferencesProvider).theme, ThemeChoiceEnum.dark);
    });

    test('text that is not JSON is still written: it is their file', () async {
      container.listen(preferencesProvider, (_, _) {});
      await openFile();
      container.read(editorProvider.notifier).edit('{"theme": ');

      await container.read(editorProvider.notifier).save();
      await settle();

      expect(appFolder.written.single.content, '{"theme": ');
      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('git-approvals.json opens in the same tab, from the same folder, '
        'and saving it has what waits judged again', () async {
      final SpaceRelativePathValueObject list = SpaceRelativePathValueObject(
        'git-approvals.json',
      );
      preferences.held = const PreferencesValueObject(
        gitApprovals: GitApprovalModeEnum.semi,
      );
      start();
      show(docs, null);
      await settle();
      // A push that waits, because the list does not allow it yet.
      const CommandRequest push = CommandRequest(
        key: 'git push',
        executable: 'git',
        arguments: <String>['push'],
        isWrite: true,
      );
      final Future<CommandVerdict> verdict = container
          .read(commandsProvider.notifier)
          .ask(push);
      await settle();

      container.read(spaceSessionProvider.notifier).openPreferencesFile(list);
      await settle();

      expect(appFolder.asked, <SpaceRelativePathValueObject>[list]);
      expect(ready().isPreferences, isTrue);
      expect(ready().kind, FileKindEnum.json);
      expect(ready().tab?.name, 'git-approvals.json');

      container.read(editorProvider.notifier).edit('{"git push": true}');
      approvals.held['git push'] = true;
      await container.read(editorProvider.notifier).save();
      await settle();

      expect(appFolder.written.single.path, list);
      expect(documents.written, isEmpty, reason: 'never the space');
      expect(await verdict, isA<CommandRun>());
    });

    test('both files open at once keep an edit each, and saving one '
        'writes only that one', () async {
      final SpaceRelativePathValueObject list = SpaceRelativePathValueObject(
        'git-approvals.json',
      );
      await openFile();
      container.read(editorProvider.notifier).edit('{"theme": "dark"}');

      container.read(spaceSessionProvider.notifier).openPreferencesFile(list);
      await settle();
      // The preferences' edit waits behind the list's tab.
      expect(
        container.read(unsavedDocumentsProvider),
        contains(DocumentTab.preferences(file)),
      );
      expect(ready().saved.path, list);
      container.read(editorProvider.notifier).edit('{"git push": true}');

      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await settle();
      expect(ready().source, '{"theme": "dark"}');
      expect(
        container.read(unsavedDocumentsProvider),
        contains(DocumentTab.preferences(list)),
      );

      await container.read(editorProvider.notifier).save();
      await settle();

      expect(
        appFolder.written.map((DocumentEntity d) => d.path).toList(),
        <SpaceRelativePathValueObject>[file],
      );
    });

    test('leaving it for a document holds its edits, and coming back '
        'finds them', () async {
      await openFile(over: writing);
      container.read(editorProvider.notifier).edit('{}');

      container.read(spaceSessionProvider.notifier).show(writing);
      await settle();
      expect(
        container.read(unsavedDocumentsProvider),
        contains(DocumentTab.preferences(file)),
      );

      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await settle();

      expect(ready().source, '{}');
      expect(ready().isPreferences, isTrue);
    });

    group('a choice made in the popover meanwhile', () {
      /// What the file reads once the popover has written it.
      void diskSays(String text) =>
          appFolder.answer = Success<DocumentEntity, DocumentFailure>(
            DocumentEntity(path: file, content: text),
          );

      Future<void> choose() async {
        container
            .read(preferencesProvider.notifier)
            .chooseTheme(ThemeChoiceEnum.dark);
        await settle();
        await settle();
      }

      setUp(() => container.listen(preferencesProvider, (_, _) {}));

      test('a clean tab follows it', () async {
        await openFile();
        diskSays('{"theme": "dark"}');

        await choose();

        expect(ready().source, '{"theme": "dark"}');
        expect(ready().changedOnDisk, isFalse);
      });

      test('a tab with edits keeps them, and is told', () async {
        await openFile();
        container.read(editorProvider.notifier).edit('{"mine": true}');
        diskSays('{"theme": "dark"}');

        await choose();

        expect(ready().source, '{"mine": true}');
        expect(ready().changedOnDisk, isTrue);
        // Applied on screen all the same: no OK and no Cancel.
        expect(container.read(preferencesProvider).theme, ThemeChoiceEnum.dark);
      });

      test('Keep mine puts the question away, and the edit stays', () async {
        await openFile();
        container.read(editorProvider.notifier).edit('{"mine": true}');
        await choose();

        container.read(editorProvider.notifier).keepMine();

        expect(ready().changedOnDisk, isFalse);
        expect(ready().source, '{"mine": true}');
      });

      test('Reload takes what is on disk', () async {
        await openFile();
        container.read(editorProvider.notifier).edit('{"mine": true}');
        diskSays('{"theme": "dark"}');
        await choose();

        await container.read(editorProvider.notifier).reload();

        expect(ready().source, '{"theme": "dark"}');
        expect(ready().changedOnDisk, isFalse);
        expect(container.read(editorProvider).isDirty, isFalse);
      });

      test('saving puts it away too: the disk is the buffer\'s now', () async {
        await openFile();
        container.read(editorProvider.notifier).edit('{"mine": true}');
        await choose();

        await container.read(editorProvider.notifier).save();

        expect(ready().changedOnDisk, isFalse);
      });

      test('a held tab with edits is told when it comes back', () async {
        await openFile(over: writing);
        container.read(editorProvider.notifier).edit('{"mine": true}');
        container.read(spaceSessionProvider.notifier).show(writing);
        await settle();

        await choose();
        container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
        await settle();

        expect(ready().source, '{"mine": true}');
        expect(ready().changedOnDisk, isTrue);
      });
    });

    test('a document\'s edits wait behind it', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      container.read(spaceSessionProvider.notifier).openPreferencesFile(file);
      await settle();

      expect(container.read(heldBuffersProvider).keys, <DocumentTab>[
        DocumentTab.inSpace(writing),
      ]);
    });
  });

  test('changing the mode does not throw the buffer away', () async {
    start();
    show(docs, writing);
    await settle();
    container.read(editorProvider.notifier).edit('# changed\n');

    container
        .read(spaceSessionProvider.notifier)
        .look(DocumentModeEnum.preview);
    await settle();

    expect(ready().source, '# changed\n');
    expect(documents.asked, <SpaceRelativePathValueObject>[writing]);
  });

  group('a changed file outside the space', () {
    final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
      'README.md',
    );

    test('is read from the repository root, by git\'s path', () async {
      start();
      show(docs, null);
      container.read(spaceSessionProvider.notifier).showOutside(readme);
      await settle();

      expect(rootsAsked, <String>['/code/app']);
      expect(documents.asked, <SpaceRelativePathValueObject>[
        SpaceRelativePathValueObject('README.md'),
      ]);
      expect(ready().isOutside, isTrue);
      expect(ready().tab, DocumentTab.outside(readme));
    });

    test('is saved where it came from, and git is asked again', () async {
      start();
      container.listen(gitReadingProvider, (_, _) {});
      show(docs, null);
      container.read(spaceSessionProvider.notifier).showOutside(readme);
      await settle();
      container.read(editorProvider.notifier).edit('# changed\n');

      await container.read(editorProvider.notifier).save();

      expect(rootsAsked.last, '/code/app');
      expect(documents.written.single.path.value, 'README.md');
      expect(reading?.refreshes, 1);
    });

    test('its edits are held apart from a document of the same name', () async {
      start();
      show(docs, SpaceRelativePathValueObject('README.md'));
      await settle();
      container.read(spaceSessionProvider.notifier)
        ..keep(DocumentTab.inSpace(SpaceRelativePathValueObject('README.md')))
        ..showOutside(readme);
      await settle();
      container.read(editorProvider.notifier).edit('# outside\n');

      container
          .read(spaceSessionProvider.notifier)
          .show(SpaceRelativePathValueObject('README.md'));
      await settle();

      expect(ready().isOutside, isFalse);
      expect(ready().source, '# README.md\n');
      expect(container.read(unsavedDocumentsProvider), <DocumentTab>{
        DocumentTab.outside(readme),
      });
    });
  });

  group('a changed file opened from the list', () {
    final SpaceRelativePathValueObject site = SpaceRelativePathValueObject(
      'site.yaml',
    );

    /// Git reporting [path] — `docs/`-prefixed, as git names it — deleted.
    void deletedInGit(String path) => container
        .read(spaceSessionProvider.notifier)
        .observe(
          GitStatusValueObject(
            branch: BranchNameValueObject('main'),
            upstream: null,
            ahead: 0,
            behind: 0,
            entries: <StatusEntryValueObject>[
              StatusEntryValueObject(
                path: RepoRelativePathValueObject(path),
                state: FileStateEnum.deleted,
                isStaged: false,
              ),
            ],
            isDetached: false,
          ),
        );

    test('a text file is an editable buffer, its kind named', () async {
      documents.answer = Success<DocumentEntity, DocumentFailure>(
        DocumentEntity(path: site, content: 'title: Docs\n'),
      );
      start();
      show(docs, site);
      await settle();

      expect(ready().source, 'title: Docs\n');
      expect(ready().kind, FileKindEnum.yaml);
      expect(ready().isRendered, isFalse);
      expect(ready().isReadOnly, isFalse);

      container.read(editorProvider.notifier).edit('title: Notes\n');
      await container.read(editorProvider.notifier).save();
      expect(documents.written.single.content, 'title: Notes\n');
    });

    test('a text file takes no markdown formatting', () async {
      documents.answer = Success<DocumentEntity, DocumentFailure>(
        DocumentEntity(path: site, content: 'title: Docs\n'),
      );
      start();
      show(docs, site);
      await settle();
      container.read(editorProvider.notifier)
        ..select(0, 5)
        ..format(FormatCommandEnum.bold);

      expect(ready().source, 'title: Docs\n');
    });

    test('a binary file holds nothing and takes nothing', () async {
      documents.bytes = <int>[0xFF, 0xD8, 0xFF, 0xE0];
      start();
      show(docs, SpaceRelativePathValueObject('logo.png'));
      await settle();

      expect(ready().isBinary, isTrue);
      expect(ready().source, isEmpty);
      expect(ready().isReadOnly, isTrue);

      container.read(editorProvider.notifier).edit('typed over it');
      await container.read(editorProvider.notifier).save();
      expect(ready().source, isEmpty);
      expect(documents.written, isEmpty);
    });

    test('a deleted file is its last committed version, read-only', () async {
      documents.answer = Failure<DocumentEntity, DocumentFailure>(
        DocumentNotFound(site.value),
      );
      start();
      show(docs, site);
      deletedInGit('docs/site.yaml');
      await settle();

      expect(ready().source, 'the last version\n');
      expect(ready().isDeleted, isTrue);
      expect(ready().isReadOnly, isTrue);
      expect(committed.asked.single.value, 'docs/site.yaml');

      container.read(editorProvider.notifier).edit('typed over it');
      expect(ready().source, 'the last version\n');
      expect(container.read(editorProvider).isDirty, isFalse);
    });

    test('a deleted file that was binary is both', () async {
      documents.answer = const Failure<DocumentEntity, DocumentFailure>(
        DocumentNotFound('logo.png'),
      );
      committed.bytes = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      start();
      show(docs, SpaceRelativePathValueObject('logo.png'));
      deletedInGit('docs/logo.png');
      await settle();

      expect(ready().isDeleted, isTrue);
      expect(ready().isBinary, isTrue);
      expect(ready().source, isEmpty);
    });

    test('a deleted document is its last version too', () async {
      documents.answer = Failure<DocumentEntity, DocumentFailure>(
        DocumentNotFound(writing.value),
      );
      committed.answer = const Success<String, GitFailure>('# Gone\n');
      start();
      show(docs, writing);
      deletedInGit('docs/guides/writing.md');
      await settle();

      expect(ready().source, '# Gone\n');
      expect(ready().isDeleted, isTrue);
      expect(ready().isRendered, isTrue);
    });

    test('a file git does not list that is gone stays a failure', () async {
      documents.answer = Failure<DocumentEntity, DocumentFailure>(
        DocumentNotFound(site.value),
      );
      start();
      show(docs, site);
      await settle();

      expect(container.read(editorProvider), isA<EditorFailed>());
      expect(committed.asked, isEmpty);
    });

    test('a file staged and then deleted is what the index holds', () async {
      documents.answer = Failure<DocumentEntity, DocumentFailure>(
        DocumentNotFound(site.value),
      );
      committed
        ..answer = const Failure<String, GitFailure>(
          GitPathNotInRevision('docs/site.yaml'),
        )
        ..indexed = const Success<String, GitFailure>('title: Staged\n');
      start();
      show(docs, site);
      deletedInGit('docs/site.yaml');
      await settle();

      expect(committed.askedOfIndex.single.value, 'docs/site.yaml');
      expect(ready().source, 'title: Staged\n');
      expect(ready().isDeleted, isTrue);
      expect(ready().isReadOnly, isTrue);
    });

    test(
      'a deletion neither HEAD nor the index held stays a failure',
      () async {
        documents.answer = Failure<DocumentEntity, DocumentFailure>(
          DocumentNotFound(site.value),
        );
        committed.answer = const Failure<String, GitFailure>(
          GitPathNotInRevision('docs/site.yaml'),
        );
        start();
        show(docs, site);
        deletedInGit('docs/site.yaml');
        await settle();

        expect(committed.asked, hasLength(1));
        expect(committed.askedOfIndex, hasLength(1));
        expect(
          (container.read(editorProvider) as EditorFailed).failure,
          DocumentNotFound(site.value),
        );
      },
    );

    test('Reveal in Finder shows the folder the file is in', () async {
      start();
      show(docs, SpaceRelativePathValueObject('assets/logo.png'));
      await settle();

      await container.read(editorProvider.notifier).reveal();

      expect(revealed, <String>['/code/app/docs/assets']);
    });
  });
}

/// The git reading, counting the times it was asked to re-read.
final class _Reading extends GitReadingNotifier {
  int refreshes = 0;

  @override
  GitReadingState build() => const GitReadingState.initial();

  @override
  Future<void> refresh() async => refreshes++;
}

/// A repository that answers what it was told to, and remembers everything.
final class _Documents implements DocumentRepository {
  Result<DocumentEntity, DocumentFailure>? answer;
  Result<void, DocumentFailure>? refusal;

  /// What a file holds when it is not the text [answer] would give.
  List<int>? bytes;

  /// What this was asked to read, in order.
  final List<SpaceRelativePathValueObject> asked =
      <SpaceRelativePathValueObject>[];

  /// What actually reached the disk, in order.
  final List<DocumentEntity> written = <DocumentEntity>[];

  /// What a file holds once it was written — by a save here, or by a test
  /// standing in for somebody else.
  final Map<SpaceRelativePathValueObject, String> changed =
      <SpaceRelativePathValueObject, String>{};

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    asked.add(path);
    return answer ??
        Success<DocumentEntity, DocumentFailure>(
          DocumentEntity(
            path: path,
            content: changed[path] ?? '# ${path.name}\n',
          ),
        );
  }

  @override
  Future<Result<Uint8List, DocumentFailure>> readBytes(
    SpaceRelativePathValueObject path,
  ) async => (await read(path)).map(
    (DocumentEntity read) =>
        Uint8List.fromList(bytes ?? utf8.encode(read.content)),
  );

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document);
    if (refusal == null) {
      changed[document.path] = document.content;
      // A fixed answer was the disk before this write, not after it.
      if (answer is Success<DocumentEntity, DocumentFailure>) {
        answer = Success<DocumentEntity, DocumentFailure>(document);
      }
    }
    return refusal ?? const Success<void, DocumentFailure>(null);
  }
}

/// Git holding one committed text for whatever is asked, or refusing.
final class _Committed implements GitRepository {
  Result<String, GitFailure> answer = const Success<String, GitFailure>(
    'the last version\n',
  );

  /// What the index holds, which is nothing unless a test says so.
  Result<String, GitFailure> indexed = const Failure<String, GitFailure>(
    GitPathNotInRevision('anything'),
  );

  /// What `HEAD` holds when it is not the text [answer] would give.
  List<int>? bytes;

  final List<RepoRelativePathValueObject> asked =
      <RepoRelativePathValueObject>[];
  final List<RepoRelativePathValueObject> askedOfIndex =
      <RepoRelativePathValueObject>[];

  @override
  Future<Result<Uint8List, GitFailure>> bytesAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    asked.add(path);
    return answer.map(
      (String text) => Uint8List.fromList(bytes ?? utf8.encode(text)),
    );
  }

  @override
  Future<Result<Uint8List, GitFailure>> stagedBytes(
    RepoRelativePathValueObject path,
  ) async {
    askedOfIndex.add(path);
    return indexed.map(utf8.encode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A desktop that writes down every folder it was asked to show.
final class _Desktop implements DesktopRepository {
  _Desktop(this.revealed);

  final List<String> revealed;

  @override
  Future<Result<void, AppFailure>> reveal(String folder) async {
    revealed.add(folder);
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> openTerminal(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async =>
      throw UnimplementedError();
}

/// Preferences in memory.
final class _Preferences implements PreferencesRepository {
  PreferencesValueObject held = PreferencesValueObject.defaults;

  @override
  Future<PreferencesValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    PreferencesValueObject preferences,
  ) async {
    held = preferences;
    return const Success<void, AppFailure>(null);
  }
}

/// `git-approvals.json` as the gate reads it, whatever the tab's text says.
final class _Approvals implements ApprovalsRepository {
  final Map<String, bool> held = <String, bool>{};

  @override
  Future<ApprovalsValueObject> read() async =>
      ApprovalsValueObject(Map<String, bool>.of(held));

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
