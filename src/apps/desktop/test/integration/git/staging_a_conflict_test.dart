/// Resolving a conflict from the first save to the commit that concludes the
/// merge, as the composition root wires it, over a real `git merge` that
/// stopped (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack_isolated.dart';

void main() {
  late IsolatedStack stack;

  final RepoRelativePathValueObject guide = RepoRelativePathValueObject(
    'docs/guide.md',
  );
  final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
    'README.md',
  );

  setUp(() => stack = IsolatedStack.create());

  StageChangesUseCase staging() => stack.container.read(stageChangesProvider);

  Future<Result<void, AppFailure>> commit(String message) =>
      stack.container.read(commitChangesProvider).commit(stack.space, message);

  Future<Result<void, AppFailure>> save(String content) => stack.container
      .read(saveDocumentProvider)
      .save(
        stack.space,
        DocumentEntity(
          path: SpaceRelativePathValueObject('guide.md'),
          content: content,
        ),
      );

  Object? failureOf(Result<void, AppFailure> result) =>
      (result as Failure<void, AppFailure>).failure;

  /// What the commit `HEAD` holds at [path].
  String committed(String path) => stack.git(<String>['show', 'HEAD:$path']);

  List<String> parents() => stack
      .git(<String>['rev-list', '--parents', '-n', '1', 'HEAD'])
      .trim()
      .split(' ')
      .skip(1)
      .toList();

  group('resolving both files and concluding the merge', () {
    setUp(() => stack.conflict());

    test('save, stage and commit give a merge commit of two parents with no '
        'marker in what it recorded', () async {
      // The document of the space goes through the app's own save; the file
      // beside it is resolved in another editor.
      expect(
        await save('# Guide\n\nOur line.\nTheir line.\n'),
        isA<Success<void, AppFailure>>(),
      );
      stack.write('README.md', '# Guide\n\nResolved elsewhere.\n');

      expect(
        await staging().stage(stack.space, <RepoRelativePathValueObject>[
          guide,
          readme,
        ]),
        isA<Success<void, AppFailure>>(),
      );
      expect(stack.unmerged, isEmpty);

      expect(await commit('Merge other'), isA<Success<void, AppFailure>>());

      expect(parents(), hasLength(2));
      expect(committed('docs/guide.md'), '# Guide\n\nOur line.\nTheir line.\n');
      expect(committed('README.md'), '# Guide\n\nResolved elsewhere.\n');
      for (final String path in <String>['docs/guide.md', 'README.md']) {
        expect(committed(path), isNot(matches(RegExp('^(<<<<<<<|=======)'))));
      }
      expect(stack.git(<String>['status', '--porcelain']), isEmpty);
    });

    test('committing with one file still unmerged is refused by git and '
        'records nothing', () async {
      stack.write('README.md', '# Guide\n\nResolved elsewhere.\n');
      await staging().stage(stack.space, <RepoRelativePathValueObject>[readme]);
      final String before = stack.head;

      final Result<void, AppFailure> result = await commit('Too early');

      expect(result, isA<Failure<void, AppFailure>>());
      expect(stack.head, before);
      expect(stack.unmerged, <String>['docs/guide.md']);
    });
  });

  group('staging several paths at once', () {
    setUp(() {
      stack
        ..conflict()
        ..write('docs/clean.md', '# Clean\n');
    });

    test('one conflicted and one clean: the refusal stages neither', () async {
      final Result<void, AppFailure> result = await staging().stage(
        stack.space,
        <RepoRelativePathValueObject>[
          guide,
          RepoRelativePathValueObject('docs/clean.md'),
        ],
      );

      expect(
        failureOf(result),
        isA<GitConflictMarkersPresent>().having(
          (GitConflictMarkersPresent it) => it.paths,
          'the paths named',
          <String>['docs/guide.md'],
        ),
      );
      expect(stack.git(<String>['ls-files', '--', 'docs/clean.md']), isEmpty);
      expect(stack.unmerged, containsAll(<String>['docs/guide.md']));
    });

    test('one resolved and one still marked: only the marked one is named, '
        'and nothing is staged', () async {
      stack.write('README.md', '# Guide\n\nResolved elsewhere.\n');

      final Result<void, AppFailure> result = await staging().stage(
        stack.space,
        <RepoRelativePathValueObject>[guide, readme],
      );

      expect((failureOf(result)! as GitConflictMarkersPresent).paths, <String>[
        'docs/guide.md',
      ]);
      expect(
        stack.unmerged,
        containsAll(<String>['README.md', 'docs/guide.md']),
      );
    });
  });

  group('under diff3, where git writes the base between the sides', () {
    setUp(() {
      stack
        ..git(<String>['config', 'merge.conflictStyle', 'diff3'])
        ..conflict();
    });

    test('git wrote a base marker the app must be able to see', () {
      expect(stack.read('docs/guide.md'), contains('\n||||||| '));
    });

    test('a resolution written whole is staged and committed with no '
        'base marker', () async {
      await save('# Guide\n\nResolved.\n');
      stack.write('README.md', '# Guide\n\nResolved.\n');

      expect(
        await staging().stage(stack.space, <RepoRelativePathValueObject>[
          guide,
          readme,
        ]),
        isA<Success<void, AppFailure>>(),
      );
      expect(await commit('Merge other'), isA<Success<void, AppFailure>>());

      expect(committed('docs/guide.md'), '# Guide\n\nResolved.\n');
      expect(committed('docs/guide.md'), isNot(contains('|||||||')));
    });

    test('only the base marker and its text left behind is refused, because '
        'the commit would carry them', () async {
      stack.write('docs/guide.md', '# Guide\n\n||||||| base\nOriginal line.\n');

      final Result<void, AppFailure> result = await staging().stage(
        stack.space,
        <RepoRelativePathValueObject>[guide],
      );

      expect(failureOf(result), isA<GitConflictMarkersPresent>());
      expect(stack.unmerged, contains('docs/guide.md'));
    });
  });

  group('unstaging', () {
    setUp(() => stack.commitBase('# Guide\n'));

    test('takes a staged document and a staged file beside the space out of '
        'the index and leaves the disk alone', () async {
      stack
        ..write('docs/guide.md', '# Guide, changed\n')
        ..write('README.md', '# Changed beside\n')
        ..git(<String>['add', '.']);
      expect(stack.staged, hasLength(2));

      expect(
        await staging().unstage(stack.space, <RepoRelativePathValueObject>[
          guide,
          readme,
        ]),
        isA<Success<void, AppFailure>>(),
      );

      expect(stack.staged, isEmpty);
      expect(stack.read('docs/guide.md'), '# Guide, changed\n');
      expect(stack.read('README.md'), '# Changed beside\n');
    });

    test(
      'a file staged as new goes back to untracked, content intact',
      () async {
        stack
          ..write('docs/new.md', '# New\n')
          ..git(<String>['add', 'docs/new.md']);

        expect(
          await staging().unstage(stack.space, <RepoRelativePathValueObject>[
            RepoRelativePathValueObject('docs/new.md'),
          ]),
          isA<Success<void, AppFailure>>(),
        );

        expect(stack.git(<String>['ls-files', 'docs/new.md']), isEmpty);
        expect(stack.read('docs/new.md'), '# New\n');
      },
    );

    test(
      'a staged rename comes back as a deletion and an untracked file',
      () async {
        stack.git(<String>['mv', 'docs/guide.md', 'docs/renamed.md']);

        expect(
          await staging().unstage(stack.space, <RepoRelativePathValueObject>[
            guide,
            RepoRelativePathValueObject('docs/renamed.md'),
          ]),
          isA<Success<void, AppFailure>>(),
        );

        expect(stack.staged, isEmpty);
        expect(stack.has('docs/renamed.md'), isTrue);
        expect(stack.has('docs/guide.md'), isFalse);
      },
    );

    test('an empty list succeeds and changes nothing', () async {
      stack
        ..write('docs/guide.md', '# Guide, changed\n')
        ..git(<String>['add', '.']);

      expect(
        await staging().unstage(
          stack.space,
          const <RepoRelativePathValueObject>[],
        ),
        isA<Success<void, AppFailure>>(),
      );
      expect(stack.staged, <String>['docs/guide.md']);
    });
  });
}
