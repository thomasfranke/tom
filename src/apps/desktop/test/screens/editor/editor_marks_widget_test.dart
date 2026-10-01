import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_desktop/screens/editor/editor_panel.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_marks_widget.dart';
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
        // The preview's three: with no conflict the marks are the diff's,
        // and the diff is the preview's reading. Git here has no earlier
        // version of anything, so the fall-through is *no marks*.
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

  /// The painter the gutter mounted, or null when it mounted none.
  EditorMarksPainter? painter(WidgetTester tester) {
    final Finder paint = find.descendant(
      of: find.byType(EditorMarksWidget),
      matching: find.byType(CustomPaint),
    );
    return paint.evaluate().isEmpty
        ? null
        : tester.widget<CustomPaint>(paint).painter as EditorMarksPainter?;
  }

  testWidgets('a conflict is marked on the line the markers open on', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);

    expect(find.byType(EditorMarksWidget), findsOneWidget);
    // One mark for the one region, on `<<<<<<<` and not on the sides under it.
    expect(painter(tester)!.marks.at(1), EditorMarkEnum.conflicted);
    expect(painter(tester)!.marks.at(2), isNull);
  });

  testWidgets('every mark is a letter as well as a colour', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester);

    // The alphabet the tree and the changes list already use; a colour on its
    // own is not a signal
    // (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
    expect(EditorMarksPainter.letterOf(EditorMarkEnum.conflicted), 'C');
    expect(EditorMarksPainter.letterOf(EditorMarkEnum.added), 'A');
    expect(EditorMarksPainter.letterOf(EditorMarkEnum.removed), 'R');
    expect(EditorMarksPainter.letterOf(EditorMarkEnum.modified), 'M');
    expect(painter(tester)!.colors, TomColors.light);
  });

  test('the mark fits the gutter the boards keep left of the numbers', () {
    // `design/screens/desktop/git-diff/comparing-light.svg` draws the letter
    // at 18 with the numbers ending at 78; the square must not reach them.
    expect(
      EditorDesign.markLeft + TomMetrics.mark,
      lessThanOrEqualTo(EditorDesign.gutter),
    );
  });

  testWidgets('no merge in progress is no mark, markers or not', (
    WidgetTester tester,
  ) async {
    documents.content = conflicted;

    await pumpEditor(tester, merging: false);

    expect(painter(tester), isNull);
  });

  testWidgets('a document with no marker is not marked', (
    WidgetTester tester,
  ) async {
    documents.content = '# Guide\n\nJust prose.\n';

    await pumpEditor(tester);

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

/// A repository answering with whatever content the test set.
final class _Documents implements DocumentRepository {
  String content = '';

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => Success<DocumentEntity, DocumentFailure>(
    DocumentEntity(path: path, content: content),
  );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
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
