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
        readPreferencesFileProvider.overrideWithValue(
          ReadDocumentUseCase(
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

  test('the preferences file is neither rendered nor diffed', () async {
    // JSON in no repository: a diff would mark every line added
    // (`docs/product/preferences/where-it-is-stored/doc.md`).
    container.listen<EditorState>(editorProvider, (_, _) {});
    start();
    show(docs, writing);
    await settle();
    blocks.asked.clear();

    container
        .read(spaceSessionProvider.notifier)
        .openPreferencesFile(SpaceRelativePathValueObject('preferences.json'));
    await settle();
    await settle();

    expect(container.read(editorProvider), isA<EditorReady>());
    expect(container.read(previewProvider), isA<PreviewEmpty>());
    expect(blocks.asked, isEmpty);
    expect(container.read(editorMarksProvider), const EditorMarks.none());
  });

  test('a pull request draft is rendered and never diffed', () async {
    // It has no committed version: a diff would mark every line added, as
    // the preferences file's did (Decision 33).
    final _HeldEditor editor = _HeldEditor();
    final ProviderContainer drafts = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => editor),
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
            blocks: committed,
            differ: BlockDifferService(aligner: aligner),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(drafts.dispose);
    drafts.listen<PreviewState>(previewProvider, (_, _) {});
    drafts.read(spaceSessionProvider.notifier)
      ..open(docs)
      ..proposeBranch(
        BranchNameValueObject('feat/proposal'),
        BranchNameValueObject('main'),
      );
    final SpaceRelativePathValueObject draft = SpaceRelativePathValueObject(
      'feat/proposal.md',
    );

    editor.state = EditorState.ready(
      saved: DocumentEntity(path: draft, content: '# Proposal\n'),
      source: '# Proposal\n',
      isDraft: true,
    );
    await settle();
    await settle();

    final PreviewState preview = drafts.read(previewProvider);
    expect(preview, isA<PreviewReady>());
    expect((preview as PreviewReady).diff, isNull);
    expect(git.revisionsAsked, isEmpty);
    expect(drafts.read(editorMarksProvider), const EditorMarks.none());
  });

  test('a folder with no repository is rendered and never diffed', () async {
    // Nothing committed to compare with, and git is never asked
    // (`docs/product/workspace/without-a-repository/doc.md`).
    final _HeldEditor editor = _HeldEditor();
    final ProviderContainer loose = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => editor),
        splitDocumentProvider.overrideWithValue(
          SplitDocumentUseCase(blocks: blocks, observability: const _Silent()),
        ),
        diffDocumentProvider.overrideWithValue(
          DiffDocumentUseCase(
            gitFor: (SpaceEntity space) => git,
            blocks: committed,
            differ: BlockDifferService(aligner: aligner),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(loose.dispose);
    loose.listen<PreviewState>(previewProvider, (_, _) {});
    loose.read(spaceSessionProvider.notifier)
      ..open(SpaceEntity(root: '/notes', repositoryRoot: null, name: 'notes'))
      ..show(writing);

    editor.state = EditorState.ready(
      saved: DocumentEntity(path: writing, content: '# Writing\n'),
      source: '# Writing\n',
    );
    await settle();
    await settle();

    final PreviewState preview = loose.read(previewProvider);
    expect(preview, isA<PreviewReady>());
    expect((preview as PreviewReady).diff, isNull);
    expect(git.revisionsAsked, isEmpty);
    expect(loose.read(editorMarksProvider), const EditorMarks.none());
  });

  group('a changed file opened from the list', () {
    late _HeldEditor editor;
    late ProviderContainer held;

    setUp(() {
      editor = _HeldEditor();
      held = ProviderContainer(
        overrides: <Override>[
          editorProvider.overrideWith(() => editor),
          splitDocumentProvider.overrideWithValue(
            SplitDocumentUseCase(
              blocks: blocks,
              observability: const _Silent(),
            ),
          ),
          diffDocumentProvider.overrideWithValue(
            DiffDocumentUseCase(
              gitFor: (SpaceEntity space) => git,
              blocks: committed,
              differ: BlockDifferService(aligner: aligner),
              observability: const _Silent(),
            ),
          ),
        ],
      );
      addTearDown(held.dispose);
      held.listen<PreviewState>(previewProvider, (_, _) {});
      held.read(spaceSessionProvider.notifier)
        ..open(docs)
        ..show(writing);
    });

    test('a deleted document is every block removed, git never asked, '
        'whatever the chip says', () async {
      held.read(spaceSessionProvider.notifier).decorate(showing: false);
      editor.state = EditorState.ready(
        saved: DocumentEntity(path: writing, content: '# Gone\n'),
        source: '# Gone\n',
        isDeleted: true,
      );
      await settle();
      await settle();

      final PreviewReady preview = held.read(previewProvider) as PreviewReady;
      expect(preview.document.document.content, '# Gone\n');
      expect(preview.diff?.blocks, everyElement(isA<DiffBlockRemoved>()));
      expect(preview.diff?.blocks, isNotEmpty);
      expect(git.revisionsAsked, isEmpty);
    });

    test('a text file is not rendered', () async {
      editor.state = EditorState.ready(
        saved: DocumentEntity(
          path: SpaceRelativePathValueObject('site.yaml'),
          content: 'a: 1\n',
        ),
        source: 'a: 1\n',
      );
      await settle();

      expect(held.read(previewProvider), isA<PreviewEmpty>());
      expect(blocks.asked, isEmpty);
    });

    test('a binary file is not rendered, even named .md', () async {
      editor.state = EditorState.ready(
        saved: DocumentEntity(path: writing, content: ''),
        source: '',
        isBinary: true,
      );
      await settle();

      expect(held.read(previewProvider), isA<PreviewEmpty>());
    });
  });

  test('choosing another document renders that one', () async {
    start();
    show(docs, writing);
    await settle();

    container.read(spaceSessionProvider.notifier).show(index);
    await settle();

    expect(rendered(), '# index.md\n');
  });

  group('a conflicted document', () {
    const String conflicted =
        '# Guide\n'
        '\n'
        'Before.\n'
        '<<<<<<< HEAD\n'
        'ours\n'
        '=======\n'
        'theirs\n'
        '>>>>>>> main\n'
        'After.\n';

    /// Shows a document whose buffer holds [text], mid-merge.
    ///
    /// The merge is set up as well as the text, because the conflict is
    /// offered only while git reports that document conflicted: the markers
    /// alone are what a document *about* merging has.
    Future<void> showing(String text) async {
      documents.answer = Success<DocumentEntity, DocumentFailure>(
        DocumentEntity(path: writing, content: text),
      );
      start();
      show(docs, writing);
      container.read(spaceSessionProvider.notifier)
        ..observe(_conflictedOn(writing))
        ..observeMerge(
          const MergeStateValueObject(inProgress: true, message: 'Merge main'),
        );
      await settle();
    }

    PreviewReady ready() => container.read(previewProvider) as PreviewReady;

    test('a document with no marker is not cut at all', () async {
      await showing('# Guide\n\nJust prose.\n');

      expect(ready().segments, isNull);
    });

    test('is cut into prose, the conflict, and prose', () async {
      await showing(conflicted);

      final List<PreviewSegment> cut = ready().segments!;
      expect(cut, hasLength(3));
      expect(cut[0], isA<PreviewProse>());
      expect(cut[1], isA<PreviewConflict>());
      expect(cut[2], isA<PreviewProse>());
    });

    test('each side is parsed, so the preview can render it', () async {
      await showing(conflicted);

      final PreviewConflict part = ready().segments!
          .whereType<PreviewConflict>()
          .single;
      expect(part.current.document.content, 'ours');
      expect(part.incoming.document.content, 'theirs');
      expect(part.current.blocks, isNotEmpty);
      expect(part.incoming.blocks, isNotEmpty);
    });

    // The rule: while a marker is on screen the preview shows the conflict
    // and nothing else — comparing against `HEAD` mid-merge answers a
    // question nobody has asked yet, in the tint the conflict already uses.
    test('turns the diff off while a marker is there', () async {
      await showing(conflicted);

      expect(ready().segments, isNotNull);
      expect(ready().diff, isNull);
    });

    test('each side keeps the document path, so its links resolve', () async {
      await showing(conflicted);

      final PreviewConflict part = ready().segments!
          .whereType<PreviewConflict>()
          .single;
      expect(part.current.document.path, writing);
      expect(part.incoming.document.path, writing);
    });

    test('stops being cut once the markers are gone', () async {
      await showing(conflicted);
      expect(ready().segments, isNotNull);

      container.read(editorProvider.notifier).edit('# Guide\n\nResolved.\n');
      await settleTyping();

      expect(ready().segments, isNull);
    });
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

    test('a caret moved before the wait is over still lets it land', () async {
      // A formatting press rewrites the text and the pane hands the
      // selection back straight after: a move that cancelled the pending
      // parse left the preview showing the text before the press.
      start();
      show(docs, writing);
      await settle();

      container.read(editorProvider.notifier)
        ..edit('# typed\n')
        ..select(2, 2);
      await settleTyping();

      expect(rendered(), '# typed\n');
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

    test('one the person refused to read goes back to the working copy, '
        'and says nothing', () async {
      start();
      show(docs, writing);
      await settle();
      git.answer = const Failure<String, GitFailure>(GitCommandDenied());

      container
          .read(spaceSessionProvider.notifier)
          .read(
            CommitEntity(
              sha: CommitShaValueObject(
                'abc1234def5678901234567890abcdef12345678',
              ),
              subject: 'An earlier pass',
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

      expect(container.read(spaceSessionProvider)?.readingVersion, isNull);
      expect(container.read(previewProvider), isNot(isA<PreviewFailed>()));
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

    test('the base is HEAD until one is read', () async {
      start();
      show(docs, writing);
      await settle();
      await settle();

      expect(git.revisionsAsked, <String>['HEAD']);
      expect(git.pathsAsked, <RepoRelativePathValueObject>[
        RepoRelativePathValueObject('docs/guides/writing.md'),
      ]);
    });

    test('a changed file outside the space is compared by git\'s own path, '
        'not as a document of the space', () async {
      start();
      show(docs, null);
      container
          .read(spaceSessionProvider.notifier)
          .showOutside(RepoRelativePathValueObject('README.md'));
      await settle();
      await settle();
      await settle();

      expect(rendered(), '# README.md\n');
      expect(git.pathsAsked, <RepoRelativePathValueObject>[
        RepoRelativePathValueObject('README.md'),
      ]);
      expect(diffOf(), isNotNull);
    });

    test('a base is read where the branch left it, never at its tip', () async {
      // The whole item: the same comparison, against what the branch started
      // from — what the base did since is not this branch's change
      // (`docs/product/diff/branch-diff/doc.md`).
      git
        ..perRevision[_develop.forkPoint.value] = '# Where it left\n'
        ..perRevision['develop'] = '# Develop moved on\n';
      start();
      show(docs, writing);
      await settle();
      await settle();

      container.read(spaceSessionProvider.notifier).compare(_develop);
      await settle();
      await settle();

      expect(git.revisionsAsked.last, _develop.forkPoint.value);
      expect(diffOf()!.before.document.content, '# Where it left\n');
      expect(diffOf()!.after.document.content, '# writing.md\n');
    });

    test('the text stays on screen while the new base is read', () async {
      // Another base is not another document, so the pane must not go back
      // to "reading it" — there is nothing new to read.
      start();
      show(docs, writing);
      await settle();
      await settle();
      final int parses = blocks.asked.length;

      container.read(spaceSessionProvider.notifier).compare(_develop);

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

    test('no base any more compares against HEAD again', () async {
      // Switched onto the branch the base was: there is nothing to have
      // come from.
      start();
      show(docs, writing);
      await settle();
      await settle();
      container.read(spaceSessionProvider.notifier).compare(_develop);
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

    test(
      'turned off, the document is published with no marks at all',
      () async {
        start();
        show(docs, writing);
        await settle();
        await settle();
        expect(diffOf(), isNotNull);
        final int parses = blocks.asked.length;

        container.read(spaceSessionProvider.notifier).decorate(showing: false);
        await settle();
        await settle();

        expect(diffOf(), isNull, reason: 'the marks were left on screen');
        expect(
          blocks.asked.length,
          parses,
          reason: 'it re-read the document to stop marking it',
        );
      },
    );

    test('turned on again it marks against the base it had', () async {
      // Off is a reading position, not a comparison
      // (`docs/product/diff/rendered-diff/turning-it-off/doc.md`).
      start();
      show(docs, writing);
      await settle();
      await settle();
      container.read(spaceSessionProvider.notifier).compare(_develop);
      await settle();
      await settle();
      final String chosen = git.revisionsAsked.last;

      container.read(spaceSessionProvider.notifier).decorate(showing: false);
      await settle();
      await settle();
      container.read(spaceSessionProvider.notifier).decorate(showing: true);
      await settle();
      await settle();

      expect(diffOf(), isNotNull);
      expect(git.revisionsAsked.last, chosen, reason: 'the base was forgotten');
    });

    test('a version being read is not compared, base or not', () async {
      // The past is shown as it was: the base measures the working copy,
      // and nothing is being changed against a commit.
      start();
      show(docs, writing);
      await settle();
      container.read(spaceSessionProvider.notifier)
        ..compare(_develop)
        ..read(_earlier);
      await settle();
      await settle();

      expect(diffOf(), isNull);
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async =>
      throw UnimplementedError();

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

/// A status reporting [path] as the one document git could not merge.
GitStatusValueObject _conflictedOn(SpaceRelativePathValueObject path) =>
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

/// The branch the checked-out one came from, and where it left it.
final DiffBaseValueObject _develop = DiffBaseValueObject(
  branch: BranchRefValueObject(name: BranchNameValueObject('develop')),
  forkPoint: CommitShaValueObject('f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0'),
);

/// A commit to open as a version.
final CommitEntity _earlier = CommitEntity(
  sha: CommitShaValueObject('abc1234def5678901234567890abcdef12345678'),
  author: const AuthorValueObject(name: 'Test', email: 'test@example.com'),
  date: CommitDateValueObject(utc: DateTime.utc(2026), offset: Duration.zero),
  subject: 'Earlier',
  body: '',
);

/// An editor that holds whatever the test puts in it.
final class _HeldEditor extends EditorNotifier {
  @override
  EditorState build() => const EditorState.empty();
}

/// Git, answering with whatever the test says the revision holds.
final class _Git implements GitRepository {
  String content = '';
  Result<String, GitFailure>? answer;

  /// What it was asked to read, and at which revision.
  final List<String> revisionsAsked = <String>[];

  /// The paths it was asked to read, as git names them.
  final List<RepoRelativePathValueObject> pathsAsked =
      <RepoRelativePathValueObject>[];

  /// What a named revision holds, when a test set it apart from [content].
  final Map<String, String> perRevision = <String, String>{};

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    revisionsAsked.add(revision);
    pathsAsked.add(path);
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
