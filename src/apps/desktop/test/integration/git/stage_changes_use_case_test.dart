/// Staging mid-merge as the composition root wires it, over a real merge
/// that stopped: no marker line reaches the index
/// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack.dart';

void main() {
  late RealStack stack;

  final RepoRelativePathValueObject guide = RepoRelativePathValueObject(
    'docs/guide.md',
  );
  final RepoRelativePathValueObject readme = RepoRelativePathValueObject(
    'README.md',
  );

  setUp(() => stack = RealStack.create());

  StageChangesUseCase staging() => stack.container.read(stageChangesProvider);

  Future<Result<void, AppFailure>> stage(RepoRelativePathValueObject path) =>
      staging().stage(stack.space, <RepoRelativePathValueObject>[path]);

  /// [text] without its first line starting with [marker].
  String without(String text, String marker) {
    final List<String> lines = text.split('\n');
    return (lines..removeAt(
          lines.indexWhere((String line) => line.startsWith(marker)),
        ))
        .join('\n');
  }

  void expectRefused(Result<void, AppFailure> result, String path) {
    expect(
      ((result as Failure<void, AppFailure>).failure
              as GitConflictMarkersPresent)
          .paths,
      <String>[path],
    );
    expect(stack.unmerged, contains(path));
  }

  group('a document of the space, conflicted', () {
    setUp(() => stack.conflict());

    test('is refused as git wrote it, and stays unmerged', () async {
      expectRefused(await stage(guide), 'docs/guide.md');
    });

    for (final String marker in const <String>[
      '<<<<<<<',
      '=======',
      '>>>>>>>',
    ]) {
      test('is refused with the $marker line deleted by hand and the rest '
          'left', () async {
        stack.write(
          'docs/guide.md',
          without(stack.read('docs/guide.md'), marker),
        );

        expectRefused(await stage(guide), 'docs/guide.md');
      });
    }

    test('is refused with one single marker line left', () async {
      stack.write('docs/guide.md', '# Guide\n\nOur line.\n=======\n');

      expectRefused(await stage(guide), 'docs/guide.md');
    });

    test('is staged once no marker line is left, and git calls it '
        'resolved', () async {
      stack.write('docs/guide.md', '# Guide\n\nOur line.\nTheir line.\n');

      expect(await stage(guide), isA<Success<void, AppFailure>>());
      expect(stack.unmerged, <String>['README.md']);
    });
  });

  test(
    'written with its base (diff3), the base marker alone refuses',
    () async {
      stack
        ..git(<String>['config', 'merge.conflictStyle', 'diff3'])
        ..conflict();
      final String asGitWroteIt = stack.read('docs/guide.md');
      expect(asGitWroteIt, contains('\n||||||| '));
      stack.write(
        'docs/guide.md',
        asGitWroteIt
            .split('\n')
            .where(
              (String line) =>
                  !RegExp('^(<<<<<<<|=======|>>>>>>>)').hasMatch(line),
            )
            .join('\n'),
      );

      expectRefused(await stage(guide), 'docs/guide.md');
    },
  );

  group('a conflicted file beside the space', () {
    setUp(() => stack.conflict());

    test('is refused while it holds a marker', () async {
      expectRefused(await stage(readme), 'README.md');
    });

    test('is staged once it reads clean', () async {
      stack.write('README.md', '# Guide\n\nResolved in another editor.\n');

      expect(await stage(readme), isA<Success<void, AppFailure>>());
      expect(stack.unmerged, <String>['docs/guide.md']);
    });
  });

  group('a document about merging, which git does not call conflicted', () {
    const String page =
        '# Resolving conflicts\n'
        '\n'
        'Git writes this into the file:\n'
        '\n'
        '<<<<<<< HEAD\n'
        'yours\n'
        '=======\n'
        'theirs\n'
        '>>>>>>> main\n';
    final RepoRelativePathValueObject howTo = RepoRelativePathValueObject(
      'docs/resolving.md',
    );

    test('stages outside a merge', () async {
      stack
        ..commitBase('# Guide\n')
        ..write('docs/resolving.md', page);

      expect(await stage(howTo), isA<Success<void, AppFailure>>());
      expect(stack.staged, <String>['docs/resolving.md']);
    });

    test('stages during one, while the conflicted document beside it is '
        'refused', () async {
      stack
        ..conflict()
        ..write('docs/resolving.md', page);

      expect(await stage(howTo), isA<Success<void, AppFailure>>());
      expectRefused(await stage(guide), 'docs/guide.md');
      expect(stack.staged, contains('docs/resolving.md'));
    });
  });
}
