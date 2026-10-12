/// Starting and moving between branches as the composition root wires it,
/// over real git: what is recorded in the config, what a refused switch
/// leaves alone, and the base the diff is then read against
/// (`docs/product/git-workflow/branch-switch/doc.md`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack_isolated.dart';

void main() {
  late IsolatedStack stack;

  setUp(() => stack = IsolatedStack.create()..commitBase('# Guide\n'));

  BranchNameValueObject branch(String name) => BranchNameValueObject(name);

  Future<Result<void, AppFailure>> create(String name) => stack.container
      .read(switchBranchProvider)
      .create(stack.space, branch(name));

  Future<Result<void, AppFailure>> switchTo(String name) => stack.container
      .read(switchBranchProvider)
      .switchTo(stack.space, branch(name));

  Future<DiffBaseValueObject?> diffBase() async {
    final Result<DiffBaseValueObject?, AppFailure> read = await stack.container
        .read(readDiffBaseProvider)
        .read(stack.space);
    return (read as Success<DiffBaseValueObject?, AppFailure>).value;
  }

  String current() =>
      stack.git(<String>['rev-parse', '--abbrev-ref', 'HEAD']).trim();

  /// What `branch.<name>.tomBase` holds, or null when it is not set.
  String? recorded(String name) {
    final String value = stack.git(<String>[
      'config',
      '--get',
      'branch.$name.tomBase',
    ], allowFailure: true).trim();
    return value.isEmpty ? null : value;
  }

  group('starting a branch', () {
    test('moves onto it and records the one it came from', () async {
      expect(await create('feat/intro'), isA<Success<void, AppFailure>>());

      expect(current(), 'feat/intro');
      expect(recorded('feat/intro'), 'main');
    });

    test('from another branch records that one, not the default', () async {
      await create('first');
      stack
        ..write('docs/guide.md', '# Guide, on first\n')
        ..git(<String>['commit', '--quiet', '-am', 'on first']);

      await create('second');

      expect(recorded('second'), 'first');
      expect(recorded('first'), 'main');
    });

    test('from a detached HEAD creates it and records nothing', () async {
      stack.git(<String>['checkout', '--quiet', '--detach']);
      final String where = stack.head;

      expect(await create('rescued'), isA<Success<void, AppFailure>>());

      expect(current(), 'rescued');
      expect(stack.head, where);
      expect(recorded('rescued'), isNull);
    });

    test('carries uncommitted work onto the new branch', () async {
      stack
        ..write('docs/guide.md', '# Guide, edited\n')
        ..write('README.md', '# Edited beside\n');

      await create('with-work');

      expect(stack.read('docs/guide.md'), '# Guide, edited\n');
      expect(stack.read('README.md'), '# Edited beside\n');
    });

    test(
      'a name that already exists is refused and HEAD does not move',
      () async {
        await create('taken');
        stack.git(<String>['checkout', '--quiet', 'main']);

        final Result<void, AppFailure> result = await create('taken');

        expect(result, isA<Failure<void, AppFailure>>());
        expect(current(), 'main');
      },
    );
  });

  group('moving onto an existing branch', () {
    setUp(() {
      stack
        ..git(<String>['checkout', '--quiet', '-b', 'other'])
        ..write('docs/guide.md', '# Guide, on other\n')
        ..git(<String>['commit', '--quiet', '-am', 'on other'])
        ..git(<String>['checkout', '--quiet', 'main']);
    });

    test('changes the files on disk', () async {
      expect(await switchTo('other'), isA<Success<void, AppFailure>>());

      expect(current(), 'other');
      expect(stack.read('docs/guide.md'), '# Guide, on other\n');
    });

    test('carries an edit to a file the branches agree on', () async {
      stack.write('README.md', '# Edited beside\n');

      expect(await switchTo('other'), isA<Success<void, AppFailure>>());

      expect(stack.read('README.md'), '# Edited beside\n');
    });

    test('refused over an edit it would overwrite: the edit is intact and '
        'the branch has not changed', () async {
      stack.write('docs/guide.md', '# Guide, my unsaved thoughts\n');

      final Result<void, AppFailure> result = await switchTo('other');

      expect(result, isA<Failure<void, AppFailure>>());
      expect(current(), 'main');
      expect(stack.read('docs/guide.md'), '# Guide, my unsaved thoughts\n');
    });

    test('a branch that does not exist is refused', () async {
      expect(await switchTo('nowhere'), isA<Failure<void, AppFailure>>());
      expect(current(), 'main');
    });
  });

  group('the base the diff is read against', () {
    test('is the recorded branch, at the commit the new one left it, even '
        'after that branch moved on', () async {
      final String leftAt = stack.head;
      await create('feat');
      stack
        ..write('docs/guide.md', '# Guide, feature\n')
        ..git(<String>['commit', '--quiet', '-am', 'feature work'])
        ..git(<String>['checkout', '--quiet', 'main'])
        ..write('README.md', '# Main moved on\n')
        ..git(<String>['commit', '--quiet', '-am', 'main work'])
        ..git(<String>['checkout', '--quiet', 'feat']);

      final DiffBaseValueObject? base = await diffBase();

      expect(base, isNotNull);
      expect(base!.branch.name.value, 'main');
      expect(base.branch.isRemote, isFalse);
      expect(base.forkPoint.value, leftAt);
    });

    test('is nothing on the default branch', () async {
      expect(await diffBase(), isNull);
    });

    test('is nothing on a detached HEAD', () async {
      stack.git(<String>['checkout', '--quiet', '--detach']);

      expect(await diffBase(), isNull);
    });

    test(
      'of a branch started elsewhere than the default follows its record',
      () async {
        await create('parent');
        stack
          ..write('docs/guide.md', '# Guide, parent\n')
          ..git(<String>['commit', '--quiet', '-am', 'parent work']);
        final String leftAt = stack.head;
        await create('child');

        final DiffBaseValueObject? base = await diffBase();

        expect(base!.branch.name.value, 'parent');
        expect(base.forkPoint.value, leftAt);
      },
    );

    test(
      'with the record deleted is deduced from the history instead',
      () async {
        await create('parent');
        stack
          ..write('docs/guide.md', '# Guide, parent\n')
          ..git(<String>['commit', '--quiet', '-am', 'parent work']);
        await create('child');
        stack.git(<String>['config', '--unset', 'branch.child.tomBase']);

        final DiffBaseValueObject? base = await diffBase();

        expect(base, isNotNull);
        expect(base!.branch.name.value, 'parent');
      },
    );
  });
}
