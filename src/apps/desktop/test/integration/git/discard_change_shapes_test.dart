/// The other shapes of a row put back, over real git: a change kept in the
/// working tree, a staged one, a rename, a deletion, a conflicted row and a
/// row on a branch with no commit
/// (`docs/product/git-workflow/commit/the-changes-list/doc.md`). Rows that
/// git never committed are `discard_change_use_case_test.dart`'s.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack_isolated.dart';

void main() {
  late IsolatedStack stack;

  Future<StatusEntryValueObject> rowOf(String path) async {
    final Result<GitStatusValueObject, AppFailure> status = await stack
        .container
        .read(readGitStatusProvider)
        .read(stack.space);
    return (status as Success<GitStatusValueObject, AppFailure>).value.entries
        .singleWhere((StatusEntryValueObject it) => it.path.value == path);
  }

  Future<Result<void, AppFailure>> discard(StatusEntryValueObject row) =>
      stack.container.read(discardChangeProvider).discard(stack.space, row);

  group('on a branch with a commit', () {
    setUp(() => stack = IsolatedStack.create()..commitBase('# Guide\n'));

    for (final String path in const <String>['docs/guide.md', 'README.md']) {
      group(path, () {
        test(
          'edited, not staged, goes back to what the index holds (HEAD)',
          () async {
            stack.write(path, '# Edited\n');

            expect(
              await discard(await rowOf(path)),
              isA<Success<void, AppFailure>>(),
            );

            expect(stack.read(path), '# Guide\n');
            expect(stack.git(<String>['status', '--porcelain']), isEmpty);
          },
        );

        test('staged goes back to HEAD in the index and on disk', () async {
          stack
            ..write(path, '# Staged\n')
            ..git(<String>['add', path]);
          final StatusEntryValueObject row = await rowOf(path);
          expect(DiscardKindEnum.of(row), DiscardKindEnum.toLastCommit);

          expect(await discard(row), isA<Success<void, AppFailure>>());

          expect(stack.read(path), '# Guide\n');
          expect(stack.git(<String>['status', '--porcelain']), isEmpty);
        });

        test('staged and then edited again goes back to HEAD, both edits '
            'gone', () async {
          stack
            ..write(path, '# Staged\n')
            ..git(<String>['add', path])
            ..write(path, '# Staged, then edited\n');

          expect(
            await discard(await rowOf(path)),
            isA<Success<void, AppFailure>>(),
          );

          expect(stack.read(path), '# Guide\n');
          expect(stack.git(<String>['status', '--porcelain']), isEmpty);
        });

        test('deleted from the disk comes back', () async {
          stack.delete(path);
          final StatusEntryValueObject row = await rowOf(path);
          expect(row.state, FileStateEnum.deleted);

          expect(await discard(row), isA<Success<void, AppFailure>>());

          expect(stack.read(path), '# Guide\n');
          expect(stack.git(<String>['status', '--porcelain']), isEmpty);
        });

        test('deleted and staged comes back', () async {
          stack.git(<String>['rm', '--quiet', path]);
          final StatusEntryValueObject row = await rowOf(path);
          expect(row.isStaged, isTrue);

          expect(await discard(row), isA<Success<void, AppFailure>>());

          expect(stack.read(path), '# Guide\n');
          expect(stack.git(<String>['status', '--porcelain']), isEmpty);
        });
      });
    }

    test('a neighbour in the same folder is left as it was', () async {
      stack
        ..write('docs/neighbour.md', '# Neighbour\n')
        ..git(<String>['add', 'docs/neighbour.md'])
        ..git(<String>['commit', '--quiet', '-m', 'neighbour'])
        ..write('docs/guide.md', '# Edited\n')
        ..write('docs/neighbour.md', '# Neighbour, edited\n');

      await discard(await rowOf('docs/guide.md'));

      expect(stack.read('docs/neighbour.md'), '# Neighbour, edited\n');
    });

    test(
      'a staged rename puts the old name back and removes the new one',
      () async {
        stack.git(<String>['mv', 'docs/guide.md', 'docs/renamed.md']);
        final StatusEntryValueObject row = await rowOf('docs/renamed.md');
        expect(row.state, FileStateEnum.renamed);
        expect(row.previousPath?.value, 'docs/guide.md');

        expect(await discard(row), isA<Success<void, AppFailure>>());

        expect(stack.read('docs/guide.md'), '# Guide\n');
        expect(stack.has('docs/renamed.md'), isFalse);
        expect(stack.git(<String>['status', '--porcelain']), isEmpty);
      },
    );

    test('a staged rename whose new file was then edited still goes back '
        'to the old name, unedited', () async {
      stack
        ..git(<String>['mv', 'docs/guide.md', 'docs/renamed.md'])
        ..write('docs/renamed.md', '# Renamed and edited\n');

      expect(
        await discard(await rowOf('docs/renamed.md')),
        isA<Success<void, AppFailure>>(),
      );

      expect(stack.read('docs/guide.md'), '# Guide\n');
      expect(stack.has('docs/renamed.md'), isFalse);
    });

    test(
      'a file with a space, an accent and a leading dash is put back',
      () async {
        for (final String name in <String>['docs/ação é.md', 'docs/-dash.md']) {
          stack
            ..write(name, '# Odd\n')
            ..git(<String>['add', '--', name])
            ..git(<String>['commit', '--quiet', '-m', 'odd'])
            ..write(name, '# Odd, edited\n');

          expect(
            await discard(await rowOf(name)),
            isA<Success<void, AppFailure>>(),
          );

          expect(stack.read(name), '# Odd\n');
        }
      },
    );

    test('a conflicted row is refused with its path, and the file is as '
        'git wrote it', () async {
      stack = IsolatedStack.create()..conflict();
      final String asGitWroteIt = stack.read('docs/guide.md');

      final Result<void, AppFailure> result = await discard(
        await rowOf('docs/guide.md'),
      );

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<GitMergeConflict>(),
      );
      expect(stack.read('docs/guide.md'), asGitWroteIt);
      expect(stack.unmerged, contains('docs/guide.md'));
    });
  });

  group('before the first commit', () {
    setUp(() => stack = IsolatedStack.create());

    test('a staged new file is deleted, not left behind half staged', () async {
      stack
        ..write('docs/draft.md', '# Draft\n')
        ..git(<String>['add', 'docs/draft.md']);
      final StatusEntryValueObject row = await rowOf('docs/draft.md');
      expect(DiscardKindEnum.of(row), DiscardKindEnum.delete);

      expect(await discard(row), isA<Success<void, AppFailure>>());

      expect(stack.has('docs/draft.md'), isFalse);
      expect(stack.git(<String>['ls-files']), isEmpty);
    });

    test('an untracked file beside the space is deleted', () async {
      stack.write('NOTES.md', '# Notes\n');

      expect(
        await discard(await rowOf('NOTES.md')),
        isA<Success<void, AppFailure>>(),
      );

      expect(stack.has('NOTES.md'), isFalse);
    });
  });
}
