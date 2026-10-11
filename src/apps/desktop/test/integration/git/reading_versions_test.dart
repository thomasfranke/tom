/// Reading what git remembers of a file, as the composition root wires it:
/// its history, one version, its last known content and the two diffs, for a
/// path in the space and for one beside it
/// (`docs/product/git-workflow/file-history/doc.md`).
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack_isolated.dart';

void main() {
  late IsolatedStack stack;

  SpaceRelativePathValueObject path(String value) =>
      SpaceRelativePathValueObject(value);

  /// `docs/guide.md` and `README.md` each committed twice: [first] shas, then
  /// the second text.
  late String firstSha;
  late String secondSha;

  setUp(() {
    stack = IsolatedStack.create()..commitBase('# Guide\n\nFirst.\n');
    firstSha = stack.head;
    stack
      ..write('docs/guide.md', '# Guide\n\nSecond.\n')
      ..write('README.md', '# Guide\n\nSecond.\n')
      ..git(<String>['commit', '--quiet', '-am', 'second']);
    secondSha = stack.head;
  });

  T ok<T>(Result<T, AppFailure> result) =>
      (result as Success<T, AppFailure>).value;

  Object? failureOf<T>(Result<T, AppFailure> result) =>
      (result as Failure<T, AppFailure>).failure;

  Future<Result<List<CommitEntity>, AppFailure>> history(
    SpaceEntity space,
    String file, {
    int? limit,
  }) => stack.container
      .read(readFileHistoryProvider)
      .read(space, path(file), limit: limit);

  Future<ParsedDocumentValueObject> parsed(String file, String content) async =>
      ok(
        await stack.container
            .read(blockReaderProvider)
            .read(DocumentEntity(path: path(file), content: content)),
      );

  Future<Result<DocumentDiffValueObject, AppFailure>> diffDocument(
    SpaceEntity space,
    String file,
    String content, {
    String revision = 'HEAD',
  }) async => stack.container
      .read(diffDocumentProvider)
      .diff(
        space: space,
        after: await parsed(file, content),
        revision: revision,
      );

  Future<Result<LineDiffValueObject, AppFailure>> diffLines(
    SpaceEntity space,
    String file,
    String content,
  ) => stack.container
      .read(diffLinesProvider)
      .diff(
        space: space,
        after: DocumentEntity(path: path(file), content: content),
      );

  group('the history of a file', () {
    test(
      'in the space lists its commits, newest first, by their shas',
      () async {
        final List<CommitEntity> commits = ok(
          await history(stack.space, 'guide.md'),
        );

        expect(commits.map((CommitEntity it) => it.sha.value), <String>[
          secondSha,
          firstSha,
        ]);
        expect(commits.first.subject, 'second');
      },
    );

    test('beside the space is read through the repository', () async {
      final List<CommitEntity> commits = ok(
        await history(stack.beside, 'README.md'),
      );

      expect(commits, hasLength(2));
    });

    test(
      'is scoped to the file: a commit that touched another is absent',
      () async {
        stack
          ..write('docs/other.md', '# Other\n')
          ..git(<String>['add', '.'])
          ..git(<String>['commit', '--quiet', '-m', 'other only']);

        final List<CommitEntity> commits = ok(
          await history(stack.space, 'guide.md'),
        );

        expect(commits.map((CommitEntity it) => it.subject), <String>[
          'second',
          'base',
        ]);
      },
    );

    test('honours the limit', () async {
      expect(
        ok(await history(stack.space, 'guide.md', limit: 1)),
        hasLength(1),
      );
    });

    test('of a file git never saw is empty', () async {
      expect(ok(await history(stack.space, 'nothing.md')), isEmpty);
    });

    test(
      'of a name with a space, an accent and a leading dash is found',
      () async {
        for (final String name in <String>['with space é.md', '-dash.md']) {
          stack
            ..write('docs/$name', '# $name\n')
            ..git(<String>['add', '--', 'docs/$name'])
            ..git(<String>['commit', '--quiet', '-m', 'add $name']);

          final List<CommitEntity> commits = ok(
            await history(stack.space, name),
          );

          expect(commits.map((CommitEntity it) => it.subject), <String>[
            'add $name',
          ]);
        }
      },
    );

    test('before the first commit says there is nothing yet', () async {
      stack = IsolatedStack.create()..write('docs/guide.md', '# Guide\n');

      final Result<List<CommitEntity>, AppFailure> result = await history(
        stack.space,
        'guide.md',
      );

      // An unborn branch has no history; whether that is an empty list or a
      // failure is the repository's to say, but it must be one of the two.
      expect(
        result is Success<List<CommitEntity>, AppFailure>
            ? result.value
            : <CommitEntity>[],
        isEmpty,
      );
    });
  });

  group('one version of a document', () {
    Future<Result<DocumentEntity, AppFailure>> version(
      SpaceEntity space,
      String sha,
      String file,
    ) => stack.container
        .read(readVersionProvider)
        .read(space, CommitShaValueObject(sha), path(file));

    test('in the space comes back with the working copy\'s path', () async {
      final DocumentEntity old = ok(
        await version(stack.space, firstSha, 'guide.md'),
      );

      expect(old.content, '# Guide\n\nFirst.\n');
      expect(old.path.value, 'guide.md');
    });

    test('beside the space is read at its repository path', () async {
      final DocumentEntity old = ok(
        await version(stack.beside, firstSha, 'README.md'),
      );

      expect(old.content, '# Guide\n\nFirst.\n');
    });

    test(
      'of a revision that does not hold the file is not in that revision',
      () async {
        stack
          ..write('docs/later.md', '# Later\n')
          ..git(<String>['add', '.'])
          ..git(<String>['commit', '--quiet', '-m', 'later']);

        expect(
          failureOf(await version(stack.space, firstSha, 'later.md')),
          isA<GitPathNotInRevision>(),
        );
      },
    );

    test('of a sha that is not in the repository fails', () async {
      expect(
        await version(stack.space, 'a' * 40, 'guide.md'),
        isA<Failure<DocumentEntity, AppFailure>>(),
      );
    });
  });

  group('the last content git knew', () {
    Future<Result<FileContentValueObject, AppFailure>> committed(
      SpaceEntity space,
      String file,
    ) =>
        stack.container.read(readCommittedFileProvider).read(space, path(file));

    String textOf(FileContentValueObject content) =>
        (content as FileContentText).document.content;

    test(
      'is HEAD\'s, in the space and beside it, deletion staged or not',
      () async {
        stack
          ..write('docs/guide.md', '# edited on disk, not committed\n')
          ..git(<String>['rm', '--quiet', '-f', 'README.md']);

        expect(
          textOf(ok(await committed(stack.space, 'guide.md'))),
          '# Guide\n\nSecond.\n',
        );
        expect(
          textOf(ok(await committed(stack.beside, 'README.md'))),
          '# Guide\n\nSecond.\n',
        );
      },
    );

    test('of a file only the index holds is the index\'s', () async {
      stack
        ..write('docs/draft.md', '# Staged draft\n')
        ..git(<String>['add', 'docs/draft.md'])
        ..write('docs/draft.md', '# Edited after staging\n');

      expect(
        textOf(ok(await committed(stack.space, 'draft.md'))),
        '# Staged draft\n',
      );
    });

    test(
      'of a file neither HEAD nor the index holds is not in the revision',
      () async {
        stack.write('docs/untracked.md', '# Untracked\n');

        expect(
          failureOf(await committed(stack.space, 'untracked.md')),
          isA<GitPathNotInRevision>(),
        );
      },
    );

    test('of a binary file is binary, not text', () async {
      stack
        ..writeBytes('docs/pic.bin', Uint8List.fromList(<int>[0, 1, 2, 255, 0]))
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'binary']);

      expect(
        ok(await committed(stack.space, 'pic.bin')),
        isA<FileContentBinary>(),
      );
    });

    test('of a name with a space and an accent is found', () async {
      stack
        ..write('docs/with space é.md', '# Odd\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'odd']);

      expect(
        textOf(ok(await committed(stack.space, 'with space é.md'))),
        '# Odd\n',
      );
    });
  });

  group('the rendered diff against HEAD', () {
    List<DiffBlockValueObject> changed(DocumentDiffValueObject diff) => diff
        .blocks
        .where((DiffBlockValueObject it) => it is! DiffBlockUnchanged)
        .toList();

    test('of an edit in the space marks the edited block modified', () async {
      final DocumentDiffValueObject diff = ok(
        await diffDocument(
          stack.space,
          'guide.md',
          '# Guide\n\nSecond, edited.\n',
        ),
      );

      expect(changed(diff), hasLength(1));
      expect(changed(diff).single, isA<DiffBlockModified>());
    });

    test(
      'of an edit beside the space is read through the repository',
      () async {
        final DocumentDiffValueObject diff = ok(
          await diffDocument(
            stack.beside,
            'README.md',
            '# Guide\n\nSecond, edited.\n',
          ),
        );

        expect(changed(diff).single, isA<DiffBlockModified>());
      },
    );

    test('of a file HEAD does not hold is every block added', () async {
      final DocumentDiffValueObject diff = ok(
        await diffDocument(stack.space, 'new.md', '# New\n\nBody.\n'),
      );

      expect(diff.blocks, isNotEmpty);
      expect(diff.blocks, everyElement(isA<DiffBlockAdded>()));
    });

    test('of text equal to HEAD has no change', () async {
      final DocumentDiffValueObject diff = ok(
        await diffDocument(stack.space, 'guide.md', '# Guide\n\nSecond.\n'),
      );

      expect(changed(diff), isEmpty);
    });

    test('against an older commit shows what has changed since', () async {
      final DocumentDiffValueObject diff = ok(
        await diffDocument(
          stack.space,
          'guide.md',
          '# Guide\n\nSecond.\n',
          revision: firstSha,
        ),
      );

      // "First." and "Second." share no word, so they are a removal and an
      // addition rather than one edited block.
      expect(changed(diff), isNotEmpty);
    });

    test(
      'of a file with a space, an accent and a dash in its name works',
      () async {
        stack
          ..write('docs/-odd é name.md', '# Odd\n')
          ..git(<String>['add', '--', 'docs/-odd é name.md'])
          ..git(<String>['commit', '--quiet', '-m', 'odd']);

        final DocumentDiffValueObject diff = ok(
          await diffDocument(stack.space, '-odd é name.md', '# Odd\n\nMore.\n'),
        );

        expect(changed(diff), isNotEmpty);
        expect(diff.blocks.whereType<DiffBlockAdded>(), hasLength(1));
      },
    );

    test(
      'of a CRLF document committed as CRLF, unchanged, shows nothing',
      () async {
        stack
          ..write('docs/crlf.md', '# Windows\r\n\r\nLine.\r\n')
          ..git(<String>['add', '.'])
          ..git(<String>['commit', '--quiet', '-m', 'crlf']);

        final DocumentDiffValueObject diff = ok(
          await diffDocument(
            stack.space,
            'crlf.md',
            stack.read('docs/crlf.md'),
          ),
        );

        expect(changed(diff), isEmpty);
      },
    );

    test('of a CRLF document committed as CRLF and saved with LF shows '
        'no change in the words', () async {
      stack
        ..write('docs/crlf.md', '# Windows\r\n\r\nLine.\r\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'crlf']);

      final DocumentDiffValueObject diff = ok(
        await diffDocument(stack.space, 'crlf.md', '# Windows\n\nLine.\n'),
      );

      expect(changed(diff), isEmpty);
    });
  });

  group('the line diff against HEAD', () {
    test('of one line edited is one modified run', () async {
      stack
        ..write('docs/notes.txt', 'one\ntwo\nthree\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'notes']);

      final LineDiffValueObject diff = ok(
        await diffLines(stack.space, 'notes.txt', 'one\nTWO\nthree\n'),
      );

      expect(diff.runs, hasLength(1));
      expect(diff.runs.single, isA<LineRunModified>());
    });

    test('of lines deleted is a removed run, and of lines appended an added '
        'one', () async {
      stack
        ..write('docs/notes.txt', 'one\ntwo\nthree\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'notes']);

      expect(
        ok(
          await diffLines(stack.space, 'notes.txt', 'one\nthree\n'),
        ).runs.single,
        isA<LineRunRemoved>(),
      );
      expect(
        ok(
          await diffLines(stack.space, 'notes.txt', 'one\ntwo\nthree\nfour\n'),
        ).runs.single,
        isA<LineRunAdded>(),
      );
    });

    test('beside the space is read through the repository', () async {
      final LineDiffValueObject diff = ok(
        await diffLines(
          stack.beside,
          'README.md',
          '# Guide\n\nSecond, edited.\n',
        ),
      );

      expect(diff.runs.single, isA<LineRunModified>());
    });

    test('of a file HEAD does not hold is every line added', () async {
      final LineDiffValueObject diff = ok(
        await diffLines(stack.space, 'fresh.txt', 'a\nb\n'),
      );

      expect(diff.runs.single, isA<LineRunAdded>());
    });

    test('of text equal to HEAD is unchanged', () async {
      final LineDiffValueObject diff = ok(
        await diffLines(stack.space, 'guide.md', '# Guide\n\nSecond.\n'),
      );

      expect(diff.isUnchanged, isTrue);
    });

    test('of a name with a space and an accent works', () async {
      stack
        ..write('docs/lista é 1.txt', 'a\nb\n')
        ..git(<String>['add', '.'])
        ..git(<String>['commit', '--quiet', '-m', 'list']);

      final LineDiffValueObject diff = ok(
        await diffLines(stack.space, 'lista é 1.txt', 'a\nB\n'),
      );

      expect(diff.runs.single, isA<LineRunModified>());
    });
  });
}
