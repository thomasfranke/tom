import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late _Buffer buffer;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject site = SpaceRelativePathValueObject(
    'site.yaml',
  );

  EditorState textOf(String source, {SpaceRelativePathValueObject? path}) =>
      EditorState.ready(
        saved: DocumentEntity(path: path ?? site, content: 'a: 1\n'),
        source: source,
      );

  setUp(() {
    git = _Git();
    container = ProviderContainer(
      overrides: <Override>[
        editorProvider.overrideWith(() => buffer = _Buffer()),
        diffLinesProvider.overrideWithValue(
          DiffLinesUseCase(
            gitFor: (SpaceEntity space) => git,
            differ: const LineDifferService(aligner: _AllAdded()),
            observability: const _Silent(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(spaceSessionProvider.notifier).open(docs);
    container.read(editorProvider);
  });

  /// Starts the diff, holding it alive as the marks would.
  void start() =>
      container.listen<LineDiffValueObject?>(lineDiffProvider, (_, _) {});

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  LineDiffValueObject? diff() => container.read(lineDiffProvider);

  test('a text buffer is compared against HEAD, by git\'s path', () async {
    buffer.held = textOf('a: 1\nb: 2\n');
    start();
    await settle();

    expect(git.revisions, <String>['HEAD']);
    expect(git.paths.single.value, 'docs/site.yaml');
    expect(diff()?.runs, <LineRunValueObject>[
      const LineRunValueObject.added(from: 0, to: 1),
    ]);
  });

  test('against the fork point when the branch came from another', () async {
    container
        .read(spaceSessionProvider.notifier)
        .compare(
          DiffBaseValueObject(
            branch: BranchRefValueObject(name: BranchNameValueObject('main')),
            forkPoint: CommitShaValueObject('b' * 40),
          ),
        );
    buffer.held = textOf('a: 1\n');
    start();
    await settle();

    expect(git.revisions.last, 'b' * 40);
  });

  test('typing is compared again once it settles', () async {
    buffer.held = textOf('a: 1\n');
    start();
    await settle();

    buffer.held = textOf('a: 1\nb: 2\nc: 3\n');
    await settle();
    expect(git.revisions, hasLength(1), reason: 'the keystroke waits');

    await Future<void>.delayed(
      LineDiffNotifier.settle + const Duration(milliseconds: 20),
    );
    expect(git.revisions, hasLength(2));
    expect(diff()?.runs.single, const LineRunValueObject.added(from: 0, to: 2));
  });

  test('a file outside the space is compared in the repository', () async {
    buffer.held = EditorState.ready(
      saved: DocumentEntity(
        path: SpaceRelativePathValueObject('ci/build.yml'),
        content: '',
      ),
      source: 'on: push\n',
      isOutside: true,
    );
    start();
    await settle();

    expect(git.paths.single.value, 'ci/build.yml');
  });

  group('nothing is compared for', () {
    Future<void> holding(EditorState state) async {
      buffer.held = state;
      start();
      await settle();
      expect(diff(), isNull);
      expect(git.revisions, isEmpty);
    }

    test('a markdown document, whose marks are the preview\'s', () async {
      await holding(
        textOf('# Title\n', path: SpaceRelativePathValueObject('a.md')),
      );
    });

    test('a deleted file, which is all removed', () async {
      await holding(
        EditorState.ready(
          saved: DocumentEntity(path: site, content: 'a: 1\n'),
          source: 'a: 1\n',
          isDeleted: true,
        ),
      );
    });

    test('a binary file', () async {
      await holding(
        EditorState.ready(
          saved: DocumentEntity(path: site, content: ''),
          source: '',
          isBinary: true,
        ),
      );
    });

    test('the preferences file', () async {
      await holding(
        EditorState.ready(
          saved: DocumentEntity(
            path: SpaceRelativePathValueObject('preferences.json'),
            content: '{}',
          ),
          source: '{}',
          isPreferences: true,
        ),
      );
    });

    test('a folder with no repository', () async {
      container
          .read(spaceSessionProvider.notifier)
          .open(SpaceEntity(root: '/notes', repositoryRoot: null, name: 'n'));
      await holding(textOf('a: 1\n'));
    });
  });

  test('leaving the text file clears what was marked', () async {
    buffer.held = textOf('a: 1\n');
    start();
    await settle();
    expect(diff(), isNotNull);

    buffer.held = const EditorState.empty();
    expect(diff(), isNull);
  });
}

/// An editor whose buffer the test sets.
final class _Buffer extends EditorNotifier {
  @override
  EditorState build() => const EditorState.empty();

  EditorState get held => state;

  set held(EditorState next) => state = next;
}

/// Git holding nothing at any revision, writing down what it was asked.
final class _Git implements GitRepository {
  final List<String> revisions = <String>[];
  final List<RepoRelativePathValueObject> paths =
      <RepoRelativePathValueObject>[];

  @override
  Future<Result<String, GitFailure>> contentAt({
    required String revision,
    required RepoRelativePathValueObject path,
  }) async {
    revisions.add(revision);
    paths.add(path);
    return Failure<String, GitFailure>(GitPathNotInRevision(path.value));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An aligner that finds every new line added, which is the truth against
/// a revision that holds nothing.
final class _AllAdded implements LineAlignerPort {
  const _AllAdded();

  @override
  Future<Result<List<SequenceEditValueObject>, DocumentFailure>> align(
    List<String> before,
    List<String> after, {
    required SpaceRelativePathValueObject path,
    required double threshold,
  }) async => Success<List<SequenceEditValueObject>, DocumentFailure>(<
    SequenceEditValueObject
  >[
    for (int at = 0; at < after.length; at++)
      SequenceEditValueObject(kind: SequenceEditKindEnum.added, afterIndex: at),
  ]);
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
