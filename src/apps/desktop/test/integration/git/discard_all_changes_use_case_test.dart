/// `Discard all changes` as the composition root wires it, over real git:
/// what it puts back, and the two states it refuses in
/// (`docs/product/git-workflow/git-menu/doc.md`).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack.dart';

void main() {
  late RealStack stack;

  setUp(() => stack = RealStack.create());

  Future<Result<void, AppFailure>> discardAll() =>
      stack.container.read(discardAllChangesProvider).discard(stack.space);

  bool midMerge() => File('${stack.repository}/.git/MERGE_HEAD').existsSync();

  test('puts tracked files back, inside the space and beside it, and keeps '
      'what git never committed', () async {
    stack
      ..commitBase('# Guide\n')
      ..write('docs/guide.md', '# Guide, changed\n')
      ..write('README.md', '# Changed beside the space\n')
      ..write('docs/added.md', '# Added\n')
      ..git(<String>['add', 'docs/added.md'])
      ..write('docs/untracked.md', '# Untracked\n');

    expect(await discardAll(), isA<Success<void, AppFailure>>());

    expect(stack.read('docs/guide.md'), '# Guide\n');
    expect(stack.read('README.md'), '# Guide\n');
    expect(stack.read('docs/added.md'), '# Added\n');
    expect(stack.read('docs/untracked.md'), '# Untracked\n');
    expect(stack.staged, isEmpty);
  });

  group('while a merge is in progress', () {
    setUp(() => stack.conflict());

    test('it is refused, the merge is still there and the conflicted files '
        'are as git wrote them', () async {
      final String asGitWroteIt = stack.read('docs/guide.md');
      expect(midMerge(), isTrue);

      final Result<void, AppFailure> result = await discardAll();

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<GitMergeConflict>(),
      );
      expect(midMerge(), isTrue, reason: 'discarding must not end the merge');
      expect(stack.read('docs/guide.md'), asGitWroteIt);
      expect(stack.unmerged, <String>['README.md', 'docs/guide.md']);
    });

    test('a resolution typed and not yet staged survives it', () async {
      stack.write('docs/guide.md', '# Guide\n\nResolved by hand.\n');

      await discardAll();

      expect(stack.read('docs/guide.md'), '# Guide\n\nResolved by hand.\n');
    });
  });

  group('before the first commit', () {
    setUp(() {
      stack
        ..write('docs/guide.md', '# Guide\n')
        ..git(<String>['add', 'docs/guide.md'])
        ..write('docs/guide.md', '# Guide, edited since\n');
    });

    test('it is refused, and what was staged is still staged', () async {
      final Result<void, AppFailure> result = await discardAll();

      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<GitNoCommitsYet>(),
      );
      expect(
        stack.git(<String>['diff', '--cached', '--name-only']).trim(),
        'docs/guide.md',
        reason: 'the index must not be emptied by half of the action',
      );
      expect(stack.read('docs/guide.md'), '# Guide, edited since\n');
    });
  });
}
