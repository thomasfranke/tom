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

  const String conflicted =
      '# Guide\n' // 0
      '\n' // 1
      '<<<<<<< HEAD\n' // 2
      'ours\n' // 3
      '=======\n' // 4
      'theirs\n' // 5
      '>>>>>>> main\n' // 6
      'After.\n'; // 7

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
        // The preview's three: with no conflict the marks are the diff's, and
        // the diff is the preview's reading. Nothing here produces one — git
        // refuses every revision — so the fall-through says *no marks*, which
        // is what these cases are about. `ofDiff` is exercised on its own.
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

  /// Opens the space on [document], whose content is [text].
  Future<void> open(
    SpaceRelativePathValueObject document,
    String text, {
    bool merging = true,
    SpaceRelativePathValueObject? conflictedIs,
  }) async {
    documents.content = text;
    container.listen<EditorState>(editorProvider, (_, _) {});
    container.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..show(document)
      ..observe(_statusConflictedOn(conflictedIs ?? document))
      ..observeMerge(
        merging
            ? const MergeStateValueObject(
                inProgress: true,
                message: 'Merge main',
              )
            : MergeStateValueObject.none,
      );
    await Future<void>.delayed(Duration.zero);
  }

  EditorMarks marks() => container.read(editorMarksProvider);

  // The provider answers a fresh object on every git reading, so the pane
  // would rebuild on each one if two readings of the same lines differed.
  test('two readings of the same lines are the same value', () {
    const ConflictScannerService scanner = ConflictScannerService();
    expect(
      EditorMarks.ofConflicts(conflicted, scanner.scan(conflicted)),
      EditorMarks.ofConflicts(conflicted, scanner.scan(conflicted)),
    );
    expect(
      const EditorMarks.none(),
      isNot(EditorMarks.ofConflicts(conflicted, scanner.scan(conflicted))),
    );
  });

  test('a span is its lines, its mark and what it draws', () {
    const EditorMarkSpan block = EditorMarkSpan.block(
      from: 2,
      to: 4,
      mark: EditorMarkEnum.modified,
    );

    expect(
      block,
      const EditorMarkSpan.block(from: 2, to: 4, mark: EditorMarkEnum.modified),
    );
    expect(
      block.hashCode,
      const EditorMarkSpan.block(
        from: 2,
        to: 4,
        mark: EditorMarkEnum.modified,
      ).hashCode,
    );
    expect(
      block,
      isNot(
        const EditorMarkSpan.tint(
          from: 2,
          to: 4,
          mark: EditorMarkEnum.modified,
        ),
      ),
    );
    expect(
      block,
      isNot(const EditorMarkSpan.letter(2, EditorMarkEnum.modified)),
    );
    expect(block.toString(), contains('2..4'));
    expect(
      EditorMarks.ofConflicts(
        conflicted,
        const ConflictScannerService().scan(conflicted),
      ).hashCode,
      EditorMarks.ofConflicts(
        conflicted,
        const ConflictScannerService().scan(conflicted),
      ).hashCode,
    );
  });

  test('the mark lands on the line the markers open on', () async {
    await open(writing, conflicted);

    expect(marks().isEmpty, isFalse);
    expect(marks().at(2), EditorMarkEnum.conflicted);
    // Only the first line of the region: the letter says a conflict begins
    // here, and the sides under it are not three more marks.
    expect(marks().at(3), isNull);
    expect(marks().at(0), isNull);
  });

  test('the markers are not tinted, and the two sides are', () async {
    // The markers stay on screen as git wrote them; what is tinted is the
    // two sides, both in the same role — `removed` would say your work is
    // leaving (`docs/product/editor/conflicted-document/doc.md`).
    await open(writing, conflicted);

    // `# Guide`, blank, `<<<<<<< HEAD`, `ours`, `=======`, `theirs`, `>>>>>>>`
    expect(marks().bandAt(2), isNull);
    expect(marks().bandAt(3), EditorMarkEnum.modified);
    expect(marks().bandAt(4), isNull);
    expect(marks().bandAt(5), EditorMarkEnum.modified);
    expect(marks().bandAt(6), isNull);
  });

  test('a side carries no letter, only the marker line does', () async {
    await open(writing, conflicted);

    expect(marks().at(2), EditorMarkEnum.conflicted);
    expect(marks().at(3), isNull);
    expect(marks().at(5), isNull);
  });

  test('two regions are two marks, counted through the text', () async {
    await open(
      writing,
      '$conflicted'
      '\n'
      '<<<<<<< HEAD\n'
      'again\n'
      '=======\n'
      'still\n'
      '>>>>>>> main\n',
    );

    expect(marks().at(2), EditorMarkEnum.conflicted);
    expect(marks().at(9), EditorMarkEnum.conflicted);
  });

  test('no merge in progress means no mark, markers or not', () async {
    await open(writing, conflicted, merging: false);

    expect(marks().isEmpty, isTrue);
  });

  test('another document being conflicted marks nothing here', () async {
    await open(writing, conflicted, conflictedIs: index);

    expect(marks().isEmpty, isTrue);
  });

  test('a document with no marker is not marked', () async {
    await open(writing, '# Guide\n\nJust prose.\n');

    expect(marks().isEmpty, isTrue);
  });

  test('the marks follow the buffer, not the file', () async {
    await open(writing, conflicted);
    expect(marks().at(2), EditorMarkEnum.conflicted);

    // A choice taken in the preview rewrites the buffer; the file on disk
    // still holds the markers until somebody saves.
    container.read(editorProvider.notifier).edit('# Guide\n\nours\n');

    expect(marks().isEmpty, isTrue);
  });

  test('nothing open is nothing marked', () {
    expect(container.read(editorMarksProvider).isEmpty, isTrue);
  });

  group('the diff, turned into lines', () {
    /// A block spanning [from] to [to] in whichever version holds it.
    BlockValueObject block(int from, int to) => BlockValueObject(
      startLine: from,
      endLine: to,
      source: 'x',
      kind: BlockKindEnum.paragraph,
    );

    /// A diff over [blocks]; the two parsed sides are not read here.
    DocumentDiffValueObject diffOf(List<DiffBlockValueObject> blocks) {
      final ParsedDocumentValueObject parsed = ParsedDocumentValueObject(
        document: DocumentEntity(path: writing, content: ''),
        blocks: const <BlockValueObject>[],
        linkDefinitions: '',
      );
      return DocumentDiffValueObject(
        before: parsed,
        after: parsed,
        blocks: blocks,
      );
    }

    test('a changed block is marked on its first line, in its own letter', () {
      final EditorMarks lines = EditorMarks.ofDiff(
        diffOf(<DiffBlockValueObject>[
          DiffBlockValueObject.unchanged(block(0, 0)),
          DiffBlockValueObject.added(block(1, 3)),
          DiffBlockValueObject.modified(
            before: block(9, 9),
            after: block(4, 5),
          ),
        ]),
      );

      expect(lines.at(0), isNull);
      expect(lines.at(1), EditorMarkEnum.added);
      // The first line only: the lines under it are the same change.
      expect(lines.at(2), isNull);
      expect(lines.at(4), EditorMarkEnum.modified);
    });

    test('a removal leaves its seam on the line that closed over it', () {
      // It is not in the buffer, so it has no line of its own: the seam goes
      // between the two lines it used to be between.
      final EditorMarks lines = EditorMarks.ofDiff(
        diffOf(<DiffBlockValueObject>[
          DiffBlockValueObject.unchanged(block(0, 2)),
          DiffBlockValueObject.removed(block(7, 9)),
          DiffBlockValueObject.unchanged(block(3, 4)),
        ]),
      );

      expect(lines.seamAbove(3), isTrue);
      expect(lines.seamAbove(2), isFalse);
    });

    test('a seam and a change can share a line, and both are said', () {
      // The seam is *between* two lines and the letter is *on* one, so a
      // removal followed by an addition no longer costs one of the two.
      final EditorMarks lines = EditorMarks.ofDiff(
        diffOf(<DiffBlockValueObject>[
          DiffBlockValueObject.unchanged(block(0, 2)),
          DiffBlockValueObject.removed(block(7, 9)),
          DiffBlockValueObject.added(block(3, 3)),
        ]),
      );

      expect(lines.at(3), EditorMarkEnum.added);
      expect(lines.seamAbove(3), isTrue);
    });

    test('the tint runs the whole block, the letter only its first line', () {
      // A changed block carries a letter **as well as** a tint
      // (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
      final EditorMarks lines = EditorMarks.ofDiff(
        diffOf(<DiffBlockValueObject>[DiffBlockValueObject.added(block(2, 5))]),
      );

      expect(lines.at(2), EditorMarkEnum.added);
      expect(lines.at(3), isNull);
      for (int line = 2; line <= 5; line++) {
        expect(lines.bandAt(line), EditorMarkEnum.added);
      }
      expect(lines.bandAt(6), isNull);
    });

    test('a removal is a seam, with nothing to tint and nothing to letter', () {
      final EditorMarks lines = EditorMarks.ofDiff(
        diffOf(<DiffBlockValueObject>[
          DiffBlockValueObject.unchanged(block(0, 2)),
          DiffBlockValueObject.removed(block(7, 9)),
          DiffBlockValueObject.unchanged(block(3, 4)),
        ]),
      );

      expect(lines.seamAbove(3), isTrue);
      expect(lines.bandAt(3), isNull);
      expect(lines.at(3), isNull);
    });

    test('a document nothing happened to is marked nowhere', () {
      expect(
        EditorMarks.ofDiff(
          diffOf(<DiffBlockValueObject>[
            DiffBlockValueObject.unchanged(block(0, 4)),
          ]),
        ).isEmpty,
        isTrue,
      );
    });
  });

  group('a file that is not markdown, by line', () {
    test('a run is lettered on its first line and tinted through', () {
      final EditorMarks lines = EditorMarks.ofLines(
        const LineDiffValueObject(
          runs: <LineRunValueObject>[
            LineRunValueObject.added(from: 1, to: 2),
            LineRunValueObject.modified(from: 4, to: 4),
          ],
        ),
      );
      expect(lines.at(1), EditorMarkEnum.added);
      expect(lines.at(2), isNull);
      expect(lines.bandAt(2), EditorMarkEnum.added);
      expect(lines.at(4), EditorMarkEnum.modified);
      expect(lines.bandAt(3), isNull);
    });

    test('removed lines are a seam above the line that followed', () {
      final EditorMarks lines = EditorMarks.ofLines(
        const LineDiffValueObject(
          runs: <LineRunValueObject>[
            LineRunValueObject.removed(at: 3, count: 2),
          ],
        ),
      );
      expect(lines.seamAbove(3), isTrue);
      expect(lines.at(3), isNull);
      expect(lines.bandAt(3), isNull);
    });

    test('nothing changed is marked nowhere', () {
      expect(
        EditorMarks.ofLines(
          const LineDiffValueObject(runs: <LineRunValueObject>[]),
        ).isEmpty,
        isTrue,
      );
    });
  });

  group('a deleted file', () {
    test('every line is under the removed band, lettered once', () {
      final EditorMarks lines = EditorMarks.ofDeleted('one\ntwo\nthree\n');
      expect(lines.at(0), EditorMarkEnum.removed);
      expect(lines.bandAt(0), EditorMarkEnum.removed);
      expect(lines.bandAt(2), EditorMarkEnum.removed);
      expect(lines.bandAt(3), isNull, reason: 'the break ends line three');
    });

    test('an empty one has nothing to mark', () {
      expect(EditorMarks.ofDeleted('').isEmpty, isTrue);
    });
  });

  group('where the marks come from', () {
    final DocumentEntity yaml = DocumentEntity(
      path: SpaceRelativePathValueObject('site.yaml'),
      content: 'a: 1\nb: 2\n',
    );

    /// The marks of an editor holding [buffer], the line diff answering
    /// [lines].
    EditorMarks marksOf(EditorState buffer, {LineDiffValueObject? lines}) {
      final ProviderContainer holding = ProviderContainer(
        overrides: <Override>[
          editorProvider.overrideWith(() => _Holding(buffer)),
          lineDiffProvider.overrideWith(() => _Lines(lines)),
        ],
      );
      addTearDown(holding.dispose);
      return holding.read(editorMarksProvider);
    }

    test('a text file is marked by its line diff', () {
      expect(
        marksOf(
          EditorState.ready(saved: yaml, source: yaml.content),
          lines: const LineDiffValueObject(
            runs: <LineRunValueObject>[
              LineRunValueObject.added(from: 1, to: 1),
            ],
          ),
        ).at(1),
        EditorMarkEnum.added,
      );
    });

    test('a deleted file is every line removed, whatever its kind', () {
      final EditorMarks lines = marksOf(
        EditorState.ready(saved: yaml, source: yaml.content, isDeleted: true),
      );
      expect(lines.bandAt(0), EditorMarkEnum.removed);
      expect(lines.bandAt(1), EditorMarkEnum.removed);
    });

    test('a binary file is marked nowhere', () {
      expect(
        marksOf(
          EditorState.ready(
            saved: DocumentEntity(path: yaml.path, content: ''),
            source: '',
            isBinary: true,
          ),
          lines: const LineDiffValueObject(
            runs: <LineRunValueObject>[
              LineRunValueObject.added(from: 0, to: 0),
            ],
          ),
        ).isEmpty,
        isTrue,
      );
    });
  });
}

/// An editor holding one buffer and doing nothing else.
final class _Holding extends EditorNotifier {
  _Holding(this.buffer);

  final EditorState buffer;

  @override
  EditorState build() => buffer;
}

/// A line diff that answers what it was told to.
final class _Lines extends LineDiffNotifier {
  _Lines(this.answer);

  final LineDiffValueObject? answer;

  @override
  LineDiffValueObject? build() => answer;
}

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

/// A repository answering whatever the test put in [content].
final class _Documents implements DocumentRepository {
  String content = '';

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
