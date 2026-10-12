/// One row put back as the composition root wires it, over real git: a row
/// drawn as *new* is deleted only if git, asked at that moment, never
/// committed it (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack.dart';

void main() {
  late RealStack stack;

  setUp(() {
    stack = RealStack.create()..commitBase('# Guide\n');
  });

  DiscardChangeUseCase discarding() =>
      stack.container.read(discardChangeProvider);

  /// The row git lists for [path] right now, read through the app's own
  /// status.
  Future<StatusEntryValueObject> rowOf(String path) async {
    final Result<GitStatusValueObject, AppFailure> status = await stack
        .container
        .read(readGitStatusProvider)
        .read(stack.space);
    return (status as Success<GitStatusValueObject, AppFailure>).value.entries
        .singleWhere((StatusEntryValueObject it) => it.path.value == path);
  }

  for (final String path in const <String>['docs/new.md', 'new-beside.md']) {
    group('$path, new to git', () {
      setUp(() => stack.write(path, '# New\n'));

      test('is deleted', () async {
        final StatusEntryValueObject row = await rowOf(path);

        expect(
          await discarding().discard(stack.space, row),
          isA<Success<void, AppFailure>>(),
        );
        expect(stack.has(path), isFalse);
      });

      test('staged and then edited, is deleted too', () async {
        stack
          ..git(<String>['add', path])
          ..write(path, '# New, edited since\n');
        final StatusEntryValueObject row = await rowOf(path);

        expect(
          await discarding().discard(stack.space, row),
          isA<Success<void, AppFailure>>(),
        );
        expect(stack.has(path), isFalse);
        expect(stack.staged, isEmpty);
      });

      // The row is read, then the file is committed in a terminal, then the
      // row's ↶ is pressed: the press is about a list that is no longer true.
      test('committed since its row was drawn, is refused and kept', () async {
        final StatusEntryValueObject row = await rowOf(path);
        expect(DiscardKindEnum.of(row), DiscardKindEnum.delete);
        stack
          ..git(<String>['add', path])
          ..git(<String>['commit', '--quiet', '-m', 'meanwhile'])
          ..write(path, '# New, and now edited\n');

        final Result<void, AppFailure> result = await discarding().discard(
          stack.space,
          row,
        );

        expect(
          (result as Failure<void, AppFailure>).failure,
          isA<GitPathCommitted>().having(
            (GitPathCommitted it) => it.paths,
            'the files named',
            <String>[path],
          ),
        );
        expect(stack.read(path), '# New, and now edited\n');
        expect(stack.git(<String>['ls-files', path]).trim(), path);
      });
    });
  }
}
