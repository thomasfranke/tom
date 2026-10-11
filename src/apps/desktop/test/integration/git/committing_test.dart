/// Recording the index as the composition root wires it, over real git: the
/// refusal on a detached `HEAD`, the first commit, and what a message becomes
/// in history (`docs/product/git-workflow/commit/confirming/doc.md`).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack_isolated.dart';

void main() {
  late IsolatedStack stack;

  setUp(() => stack = IsolatedStack.create());

  Future<Result<void, AppFailure>> commit(String message) =>
      stack.container.read(commitChangesProvider).commit(stack.space, message);

  Future<List<CommitEntity>> historyOfGuide() async {
    final Result<List<CommitEntity>, AppFailure> history = await stack.container
        .read(readFileHistoryProvider)
        .read(stack.space, SpaceRelativePathValueObject('guide.md'));
    return (history as Success<List<CommitEntity>, AppFailure>).value;
  }

  group('on a detached HEAD', () {
    setUp(() {
      stack
        ..commitBase('# Guide\n')
        ..git(<String>['checkout', '--quiet', '--detach'])
        ..write('docs/guide.md', '# Guide, changed\n')
        ..write('README.md', '# Changed beside\n')
        ..git(<String>['add', '.']);
    });

    test(
      'is refused, HEAD stays where it was and the index stays staged',
      () async {
        final String before = stack.head;

        final Result<void, AppFailure> result = await commit('Orphaned');

        expect(
          (result as Failure<void, AppFailure>).failure,
          isA<GitDetachedHead>(),
        );
        expect(stack.head, before);
        expect(stack.staged, <String>['README.md', 'docs/guide.md']);
        expect(
          stack.git(<String>['rev-list', '--count', '--all']).trim(),
          '1',
          reason: 'no commit was made that only HEAD could reach',
        );
      },
    );
  });

  group('the first commit', () {
    test(
      'on an unborn branch records the staged files and no parent',
      () async {
        stack
          ..write('docs/guide.md', '# Guide\n')
          ..write('README.md', '# Beside\n')
          ..git(<String>['add', '.']);

        expect(await commit('First'), isA<Success<void, AppFailure>>());

        expect(
          stack.git(<String>['rev-parse', '--abbrev-ref', 'HEAD']).trim(),
          'main',
        );
        expect(stack.git(<String>['rev-list', '--count', 'HEAD']).trim(), '1');
        expect(
          stack.git(<String>[
            'rev-list',
            '--parents',
            '-n',
            '1',
            'HEAD',
          ]).trim(),
          stack.head,
          reason: 'the first commit has no parent',
        );
        expect(stack.git(<String>['show', 'HEAD:README.md']), '# Beside\n');
      },
    );
  });

  group('refused by git', () {
    setUp(() => stack.commitBase('# Guide\n'));

    test('with nothing staged, nothing is recorded', () async {
      stack.write('docs/guide.md', '# Guide, changed but not staged\n');
      final String before = stack.head;

      expect(await commit('Empty'), isA<Failure<void, AppFailure>>());

      expect(stack.head, before);
      expect(stack.read('docs/guide.md'), '# Guide, changed but not staged\n');
    });

    test('by a pre-commit hook, the index is kept as it was', () async {
      final File hook = File('${stack.repository}/.git/hooks/pre-commit')
        ..writeAsStringSync('#!/bin/sh\necho "no commits today" >&2\nexit 1\n');
      Process.runSync('chmod', <String>['+x', hook.path]);
      stack
        ..write('docs/guide.md', '# Guide, changed\n')
        ..git(<String>['add', '.']);
      final String before = stack.head;

      expect(await commit('Hooked'), isA<Failure<void, AppFailure>>());

      expect(stack.head, before);
      expect(stack.staged, <String>['docs/guide.md']);
    });
  });

  test(
    'without any identity nothing is committed and the index is kept',
    () async {
      stack = IsolatedStack.create(identity: false)
        ..write('docs/guide.md', '# Guide\n')
        ..git(<String>['add', '.']);

      final Result<void, AppFailure> result = await commit('Nobody');

      expect(result, isA<Failure<void, AppFailure>>());
      expect(stack.git(<String>['rev-list', '--count', '--all']).trim(), '0');
      expect(stack.staged, <String>['docs/guide.md']);
    },
  );

  group('a message in history', () {
    setUp(() => stack.commitBase('# Guide\n'));

    test('keeps summary, description and the indentation inside it', () async {
      stack
        ..write('docs/guide.md', '# Guide, changed\n')
        ..git(<String>['add', '.']);

      expect(
        await commit(
          'Reword the guide\n'
          '\n'
          'First paragraph of why.\n'
          '\n'
          '    indented as code\n'
          '- and a list\n',
        ),
        isA<Success<void, AppFailure>>(),
      );

      final CommitEntity latest = (await historyOfGuide()).first;
      expect(latest.subject, 'Reword the guide');
      expect(
        latest.body,
        'First paragraph of why.\n\n    indented as code\n- and a list',
      );
    });

    test('with a summary alone has an empty description', () async {
      stack
        ..write('docs/guide.md', '# Guide, changed\n')
        ..git(<String>['add', '.']);

      await commit('Only a summary');

      final CommitEntity latest = (await historyOfGuide()).first;
      expect(latest.subject, 'Only a summary');
      expect(latest.body, isEmpty);
    });

    test('with a non-ASCII summary comes back as typed', () async {
      stack
        ..write('docs/guide.md', '# Guide, changed\n')
        ..git(<String>['add', '.']);

      await commit('Revisão do guia — acentuação');

      expect(
        (await historyOfGuide()).first.subject,
        'Revisão do guia — acentuação',
      );
    });
  });
}
