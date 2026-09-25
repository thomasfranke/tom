import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Documents documents;
  late _Blocks blocks;
  late _Blocks committed;
  late _Git git;
  late _Aligner aligner;
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

  setUp(() {
    documents = _Documents();
    blocks = _Blocks();
    committed = _Blocks();
    git = _Git();
    aligner = _Aligner();
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
        splitDocumentProvider.overrideWithValue(
          SplitDocumentUseCase(blocks: blocks, observability: const _Silent()),
        ),
        readVersionProvider.overrideWithValue(
          ReadVersionUseCase(
            gitFor: (SpaceEntity space) => git,
            observability: const _Silent(),
          ),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            gitFor: (SpaceEntity space) => git,
            // Its own reader: the committed side is a second parse, and
            // counting it against the buffer's would break "typing parses
            // once".
            blocks: committed,
            differ: BlockDifferService(aligner: aligner),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts the preview, and answers its first state.
  PreviewState start() {
    container.listen<PreviewState>(previewProvider, (_, _) {});
    return container.read(previewProvider);
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

  /// Everything scheduled, including what is waiting out the debounce.
  Future<void> settleTyping() =>
      Future<void>.delayed(PreviewNotifier.settle * 2);

  String rendered() => (container.read(previewProvider) as PreviewReady)
      .document
      .document
      .content;

  test('with no space open there is nothing to render', () async {
    expect(start(), isA<PreviewEmpty>());
    await settle();

    expect(documents.asked, isEmpty);
    expect(blocks.asked, isEmpty);
  });

  test('a space with no document chosen is empty, not loading', () async {
    start();
    show(docs, null);
    await settle();

    expect(container.read(previewProvider), isA<PreviewEmpty>());
    expect(blocks.asked, isEmpty);
  });

  test('choosing a document renders what the editor read', () async {
    start();
    show(docs, writing);

    expect(container.read(previewProvider), isA<PreviewLoading>());
    await settle();

    expect(rendered(), '# writing.md\n');
    expect(documents.asked, <SpaceRelativePathValueObject>[writing]);
  });

  test('choosing another document renders that one', () async {
    start();
    show(docs, writing);
    await settle();

    container.read(spaceSessionProvider.notifier).show(index);
    await settle();

    expect(rendered(), '# index.md\n');
  });

  test('a document that is gone is a failure, not an empty page', () async {
    documents.answer = Failure<DocumentEntity, DocumentFailure>(
      DocumentNotFound(writing.value),
    );
    start();
    show(docs, writing);
    await settle();

    expect(
      (container.read(previewProvider) as PreviewFailed).failure,
      DocumentNotFound(writing.value),
    );
  });

  group('typing', () {
    test('an edit reaches the preview with no refresh step', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# typed\n');
      await settleTyping();

      expect(rendered(), '# typed\n');
    });

    test('a run of typing is parsed once, not once per character', () async {
      start();
      show(docs, writing);
      await settle();
      final int before = blocks.asked.length;

      container.read(editorProvider.notifier)
        ..edit('# a\n')
        ..edit('# ab\n')
        ..edit('# abc\n');
      await settleTyping();

      expect(blocks.asked.length - before, 1);
      expect(rendered(), '# abc\n');
    });

    test('the last blocks stay on screen while the next parse waits', () async {
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier).edit('# typed\n');

      expect(container.read(previewProvider), isA<PreviewReady>());
      expect(rendered(), '# writing.md\n');
    });

    test('a parse that broke says so rather than showing the last', () async {
      start();
      show(docs, writing);
      await settle();
      blocks.answer = const Failure<ParsedDocumentValueObject, DocumentFailure>(
        DocumentOperationFailed('guides/writing.md'),
      );

      container.read(editorProvider.notifier).edit('# broken\n');
      await settleTyping();

      expect(
        (container.read(previewProvider) as PreviewFailed).failure,
        const DocumentOperationFailed('guides/writing.md'),
      );
    });

    test('a parse the user has already typed past is dropped', () async {
      start();
      show(docs, writing);
      await settle();
      blocks.delay = PreviewNotifier.settle * 4;

      container.read(editorProvider.notifier).edit('# first\n');
      await settleTyping();
      container.read(editorProvider.notifier).edit('# second\n');
      await Future<void>.delayed(PreviewNotifier.settle * 10);

      expect(rendered(), '# second\n');
    });

    test('saving redraws nothing, because nothing changed', () async {
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# typed\n');
      await settleTyping();
      final int before = blocks.asked.length;

      await container.read(editorProvider.notifier).save();
      await settleTyping();

      expect(blocks.asked.length, before);
    });
  });

  group('a preview that arrives after the document', () {
    test('renders what the editor is already holding', () async {
      // The editor first and the preview after, the way the mode bar brings
      // the panel back over a buffer already held.
      container.listen<EditorState>(editorProvider, (_, _) {});
      show(docs, writing);
      await settle();

      start();
      await settle();

      expect(rendered(), '# writing.md\n');
    });
  });

  group('a version that cannot be read', () {
    test('says so, instead of showing the working copy as the past', () async {
      start();
      show(docs, writing);
      await settle();
      git.answer = const Failure<String, GitFailure>(
        GitPathNotInRevision('docs/guides/writing.md'),
      );

      container
          .read(spaceSessionProvider.notifier)
          .read(
            CommitEntity(
              sha: CommitShaValueObject(
                'abc1234def5678901234567890abcdef12345678',
              ),
              subject: 'Before this file existed',
              body: '',
              author: const AuthorValueObject(
                name: 'Test',
                email: 'test@example.com',
              ),
              date: CommitDateValueObject(
                utc: DateTime.utc(2026),
                offset: Duration.zero,
              ),
            ),
          );
      await settle();
      await settle();

      expect(
        (container.read(previewProvider) as PreviewFailed).failure,
        isA<GitPathNotInRevision>(),
      );
    });
  });

  group('the rendered diff', () {
    /// What the state says changed, once everything scheduled has run.
    DocumentDiffValueObject? diffOf() =>
        (container.read(previewProvider) as PreviewReady).diff;

    test('the document is drawn first and decorated after', () async {
      start();
      show(docs, writing);
      await settle();

      expect(container.read(previewProvider), isA<PreviewReady>());
      await settle();
      expect(diffOf(), isNotNull);
    });

    test('an edit never publishes the document without its marks', () async {
      git.content = '# Committed\n';
      final List<PreviewState> published = <PreviewState>[];
      start();
      container.listen<PreviewState>(
        previewProvider,
        (PreviewState? _, PreviewState next) => published.add(next),
      );
      show(docs, writing);
      await settle();
      await settle();
      expect(diffOf(), isNotNull, reason: 'it starts decorated');
      published.clear();

      container.read(editorProvider.notifier).edit('# Typed\n');
      await settleTyping();
      await settle();

      expect(
        published.whereType<PreviewReady>().where(
          (PreviewReady state) => state.diff == null,
        ),
        isEmpty,
      );
      expect(diffOf(), isNotNull);
    });

    test('what changed is what git said, against the buffer', () async {
      git.content = '# Committed\n';
      start();
      show(docs, writing);
      await settle();
      container.read(editorProvider.notifier).edit('# Typed\n');
      await settleTyping();
      await settle();

      final DocumentDiffValueObject diff = diffOf()!;
      expect(diff.before.document.content, '# Committed\n');
      expect(diff.after.document.content, '# Typed\n');
    });

    test('a comparison git refused leaves the document on screen', () async {
      git.answer = const Failure<String, GitFailure>(GitNotInstalled());
      start();
      show(docs, writing);
      await settle();
      await settle();

      expect(container.read(previewProvider), isA<PreviewReady>());
      expect(diffOf(), isNull);
    });

    test('the base is HEAD until somebody asks for another', () async {
      start();
      show(docs, writing);
      await settle();
      await settle();

      expect(git.revisionsAsked, <String>['HEAD']);
    });

    test('another base is read from that revision instead', () async {
      // The whole item: the same comparison, against something else
      // (`docs/product/diff/branch-diff/doc.md`).
      git.perRevision['feat/rendered-diff'] = '# On the branch\n';
      start();
      show(docs, writing);
      await settle();
      await settle();

      container
          .read(spaceSessionProvider.notifier)
          .compare(
            RevisionValueObject.branch(
              BranchEntity(
                name: BranchNameValueObject('feat/rendered-diff'),
                isCurrent: false,
              ),
            ),
          );
      await settle();
      await settle();

      expect(git.revisionsAsked.last, 'feat/rendered-diff');
      expect(diffOf()!.before.document.content, '# On the branch\n');
      expect(diffOf()!.after.document.content, '# writing.md\n');
    });

    test('a commit is a base by its full sha', () async {
      start();
      show(docs, writing);
      await settle();
      await settle();

      container
          .read(spaceSessionProvider.notifier)
          .compare(RevisionValueObject.commit(_earlier));
      await settle();
      await settle();

      expect(git.revisionsAsked.last, _earlier.sha.value);
    });

    test('the text stays on screen while the new base is read', () async {
      // Another base is not another document, so the pane must not go back
      // to "reading it" — there is nothing new to read.
      start();
      show(docs, writing);
      await settle();
      await settle();
      final int parses = blocks.asked.length;

      container
          .read(spaceSessionProvider.notifier)
          .compare(RevisionValueObject.commit(_earlier));

      expect(container.read(previewProvider), isA<PreviewReady>());
      await settle();
      await settle();
      expect(rendered(), '# writing.md\n');
      expect(
        blocks.asked.length,
        parses,
        reason: 'the document was parsed again for a comparison',
      );
    });

    test('taking the base back compares against HEAD again', () async {
      start();
      show(docs, writing);
      await settle();
      await settle();
      container
          .read(spaceSessionProvider.notifier)
          .compare(RevisionValueObject.commit(_earlier));
      await settle();
      await settle();

      container.read(spaceSessionProvider.notifier).compare(null);
      await settle();
      await settle();

      expect(git.revisionsAsked.last, 'HEAD');
    });

    test('a commit re-marks the document without re-reading it', () async {
      // A commit moves `HEAD` without touching a character of the buffer, so
      // a document that was marked has to come back clean — and the pane
      // must not go back to "reading it" to say so.
      git.content = '# Committed\n';
      start();
      show(docs, writing);
      await settle();
      await settle();
      expect(diffOf(), isNotNull);
      final int parses = blocks.asked.length;
      final int comparisons = git.revisionsAsked.length;

      // What `ChangesNotifier` does at the end of every operation.
      container
          .read(spaceSessionProvider.notifier)
          .observe(
            const GitStatusValueObject(
              branch: null,
              upstream: null,
              ahead: 0,
              behind: 0,
              entries: <StatusEntryValueObject>[],
              isDetached: false,
            ),
          );
      await settle();
      await settle();

      expect(
        git.revisionsAsked.length,
        comparisons + 1,
        reason: 'the marks were left standing over a commit',
      );
      expect(blocks.asked.length, parses, reason: 'it re-read the document');
    });

    test('a version being read is compared when a base was chosen', () async {
      // Two commits, which is the other half of this item: the past is
      // compared only when somebody asks.
      start();
      show(docs, writing);
      await settle();
      container.read(spaceSessionProvider.notifier)
        ..compare(RevisionValueObject.commit(_earlier))
        ..read(_earlier);
      await settle();
      await settle();

      expect(diffOf(), isNotNull);
    });

    test('a version being read is not compared against anything', () async {
      start();
      show(docs, writing);
      await settle();
      aligner.asked = 0;

      container
          .read(spaceSessionProvider.notifier)
          .read(
            CommitEntity(
              sha: CommitShaValueObject(
                'abc1234def5678901234567890abcdef12345678',
              ),
              subject: 'Earlier',
              body: '',
              author: const AuthorValueObject(
                name: 'Test',
                email: 'test@example.com',
              ),
              date: CommitDateValueObject(
                utc: DateTime.utc(2026),
                offset: Duration.zero,
              ),
            ),
          );
      await settle();
      await settle();

      expect(aligner.asked, 0);
      expect(diffOf(), isNull);
    });
  });
}

/// A repository that answers what it was told to, and remembers what it was
/// asked for.
final class _Documents implements DocumentRepository {
  Result<DocumentEntity, DocumentFailure>? answer;

  /// What this was asked to read, in order.
  final List<SpaceRelativePathValueObject> asked =
      <SpaceRelativePathValueObject>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async {
    asked.add(path);
    return answer ??
        Success<DocumentEntity, DocumentFailure>(
          DocumentEntity(path: path, content: '# ${path.name}\n'),
        );
  }

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async =>
      const Success<void, DocumentFailure>(null);
}

/// A reader that splits nothing: one heading block, whatever it is given.
final class _Blocks implements BlockReaderPort {
  /// What this was asked to split, in order.
  final List<DocumentEntity> asked = <DocumentEntity>[];

  /// What to answer instead of splitting, when a test says so.
  Result<ParsedDocumentValueObject, DocumentFailure>? answer;

  /// How long to take about it.
  Duration delay = Duration.zero;

  @override
  Future<Result<ParsedDocumentValueObject, DocumentFailure>> read(
    DocumentEntity document,
  ) async {
    asked.add(document);
    // Only when asked: a zero `Future.delayed` is still a timer, and costs
    // an event-loop turn the settling helper does not wait for.
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (answer
        case final Result<ParsedDocumentValueObject, DocumentFailure> given) {
      return given;
    }
    return Success<ParsedDocumentValueObject, DocumentFailure>(
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
}

/// A commit to compare against, and to open as a version.
final CommitEntity _earlier = CommitEntity(
  sha: CommitShaValueObject('abc1234def5678901234567890abcdef12345678'),
  author: const AuthorValueObject(name: 'Test', email: 'test@example.com'),
  date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
  subject: 'Earlier',
  body: '',
);

/// Git, answering with whatever the test says the revision holds.
final class _Git implements GitRepository {
  String content = '';
  Result<String, GitFailure>? answer;

  /// What it was asked to read, and at which revision.
  final List<String> revisionsAsked = <String>[];

  /// What a named revision holds, when a test set it apart from [content].
  final Map<String, String> perRevision = <String, String>{};

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    revisionsAsked.add(revision);
    return answer ??
        Success<String, GitFailure>(perRevision[revision] ?? content);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An aligner calling every old block gone and every new one new; the
/// classification is the domain's, this test is about *when* the preview
/// asks.
final class _Aligner implements BlockAlignerPort {
  /// How many times it was asked.
  int asked = 0;

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    ParsedDocumentValueObject before,
    ParsedDocumentValueObject after, {
    required double threshold,
  }) async {
    asked++;
    return Success<List<SequenceEditValueObject>, DocumentFailure>(
      <SequenceEditValueObject>[
        for (int index = 0; index < before.blocks.length; index++)
          SequenceEditValueObject(
            kind: SequenceEditKindEnum.removed,
            beforeIndex: index,
          ),
        for (int index = 0; index < after.blocks.length; index++)
          SequenceEditValueObject(
            kind: SequenceEditKindEnum.added,
            afterIndex: index,
          ),
      ],
    );
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
