import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_lens_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

void main() {
  late _Documents documents;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject writing = SpaceRelativePathValueObject(
    'guides/writing.md',
  );

  const String conflicted =
      '# Guide\n'
      '<<<<<<< HEAD\n'
      'ours\n'
      '=======\n'
      'theirs\n'
      '>>>>>>> main\n';

  setUp(() {
    documents = _Documents();
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
        // The preview's three, because the marks watch it once there is no
        // conflict; git here has no earlier version of anything.
        splitDocumentProvider.overrideWithValue(
          SplitDocumentUseCase(
            blocks: _Blocks(),
            observability: const _Silent(),
          ),
        ),
        readVersionProvider.overrideWithValue(
          ReadVersionUseCase(
            gitFor: (SpaceEntity space) => _Git(),
            observability: const _Silent(),
          ),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            gitFor: (SpaceEntity space) => _Git(),
            blocks: _Blocks(),
            differ: BlockDifferService(aligner: _Aligner()),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Mounts the source pane on a document, mid-merge when [merging].
  Future<void> pumpEditor(WidgetTester tester, {bool merging = true}) async {
    tester.view
      ..physicalSize = const Size(1280, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(writing)
      ..observe(_statusConflictedOn(writing))
      ..observeMerge(
        merging
            ? const MergeStateValueObject(
                inProgress: true,
                message: 'Merge main',
              )
            : MergeStateValueObject.none,
      );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: tomTheme(Brightness.light),
          home: const Scaffold(body: EditorPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The painter the lens mounted, or null when it mounted none.
  EditorLensPainter? painter(WidgetTester tester) {
    final Finder paint = find.descendant(
      of: find.byType(EditorLensWidget),
      matching: find.byType(CustomPaint),
    );
    return paint.evaluate().isEmpty
        ? null
        : tester.widget<CustomPaint>(paint).painter as EditorLensPainter?;
  }

  /// Presses [choice] on the conflict that opens at [line].
  Future<void> press(
    WidgetTester tester,
    int line,
    ConflictChoiceEnum choice,
  ) async {
    final Rect word = painter(tester)!.wordFor(line, choice)!;
    final Offset origin = tester.getTopLeft(
      find.descendant(
        of: find.byType(EditorLensWidget),
        matching: find.byType(CustomPaint),
      ),
    );
    await tester.tapAt(origin + word.center);
    await tester.pump();
  }

  /// What the buffer holds now.
  String buffer() => switch (container.read(editorProvider)) {
    EditorReady(source: final String source) => source,
    _ => '',
  };

  testWidgets('the three choices stand on the line the conflict opens on', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);

    // On `<<<<<<< HEAD` (line 1) and on no other line.
    for (final ConflictChoiceEnum choice in ConflictChoiceEnum.values) {
      expect(painter(tester)!.wordFor(1, choice), isNotNull);
      expect(painter(tester)!.wordFor(2, choice), isNull);
    }
    // VS Code's words and order, in `modified`, at the board's size.
    expect(
      painter(tester)!.choices.map(((String, ConflictChoiceEnum) c) => c.$1),
      <String>[
        'Accept Current Change',
        'Accept Incoming Change',
        'Accept Both Changes',
      ],
    );
    expect(painter(tester)!.colors, TomColors.light);
    expect(EditorDesign.lens, 11);
  });

  testWidgets('they follow the marker, in the order the situation has them', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);

    final EditorLensPainter lens = painter(tester)!;
    final Rect current = lens.wordFor(1, ConflictChoiceEnum.current)!;
    final Rect incoming = lens.wordFor(1, ConflictChoiceEnum.incoming)!;
    final Rect both = lens.wordFor(1, ConflictChoiceEnum.both)!;
    // Past the first character of source, so never over the marker itself.
    expect(
      current.left,
      greaterThan(EditorDesign.numbers + EditorDesign.numbersToCode),
    );
    expect(incoming.left, greaterThan(current.right));
    expect(both.left, greaterThan(incoming.right));
  });

  testWidgets('accepting the current change keeps ours and drops the rest', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);
    await press(tester, 1, ConflictChoiceEnum.current);

    expect(buffer(), '# Guide\nours\n');
    // An edit, not a save: the file on disk still holds the conflict.
    expect(documents.written, isNull);
  });

  testWidgets('accepting the incoming change keeps theirs', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);
    await press(tester, 1, ConflictChoiceEnum.incoming);

    expect(buffer(), '# Guide\ntheirs\n');
  });

  testWidgets('accepting both keeps the two, current first', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);
    await press(tester, 1, ConflictChoiceEnum.both);

    expect(buffer(), '# Guide\nours\ntheirs\n');
  });

  testWidgets('a resolved conflict takes its choices with it', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);
    await press(tester, 1, ConflictChoiceEnum.current);
    await tester.pumpAndSettle();

    expect(painter(tester), isNull);
  });

  testWidgets('only the words take a press; the rest of the line is text', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);

    final EditorLensPainter lens = painter(tester)!;
    final Rect current = lens.wordFor(1, ConflictChoiceEnum.current)!;
    expect(lens.hitTest(current.center), isTrue);
    // Left of the choices is the marker, which the editor keeps.
    expect(lens.hitTest(Offset(current.left - 20, current.center.dy)), isFalse);
    // A line below is the side under it.
    expect(lens.hitTest(current.center.translate(0, 22)), isFalse);
  });

  testWidgets('no merge in progress is no choice, markers or not', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester, merging: false);

    expect(painter(tester), isNull);
  });
}

/// A status reporting [path] as the one document git could not merge.
GitStatusValueObject _statusConflictedOn(SpaceRelativePathValueObject path) =>
    GitStatusValueObject(
      branch: BranchNameValueObject('main'),
      upstream: BranchNameValueObject('origin/main'),
      ahead: 0,
      behind: 0,
      entries: <StatusEntryValueObject>[
        StatusEntryValueObject(
          path: RepoRelativePathValueObject('docs/${path.value}'),
          state: FileStateEnum.conflicted,
          isStaged: false,
        ),
      ],
      isDetached: false,
    );

/// A reader that splits nothing: one heading block, whatever it is given.
final class _Blocks implements BlockReaderPort {
  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async => Success<ParsedDocumentValueObject, DocumentFailure>(
    ParsedDocumentValueObject(
      document: document,
      blocks: <BlockValueObject>[
        BlockValueObject(
          startLine: 0,
          endLine: 0,
          source: document.content.trimRight(),
          kind: BlockKindEnum.heading,
        ),
      ],
      linkDefinitions: '',
    ),
  );
}

/// Git with no earlier version of anything, so no comparison is possible.
final class _Git implements GitRepository {
  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async => Failure<String, GitFailure>(GitPathNotInRevision(path.value));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An aligner nothing asks, because nothing gets that far here.
final class _Aligner implements BlockAlignerPort {
  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async => const Success<List<SequenceEditValueObject>, DocumentFailure>(
    <SequenceEditValueObject>[],
  );
}

/// A repository answering with whatever content the test set, and keeping
/// whatever was written.
final class _Documents implements DocumentRepository {
  String content = '';
  String? written;

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written = document.content;
    return const Success<void, DocumentFailure>(null);
  }
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
