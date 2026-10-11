/// [BranchNameValueObject] against the git that would have to accept it.
///
/// The unit test says what the parser refuses; this asks the real
/// `git check-ref-format --branch` whether it agrees, which is the only
/// proof that a name the dialog lets through is one git takes.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  /// Whether the git on this machine takes [name] as a branch.
  bool gitAccepts(String name) =>
      Process.runSync('git', <String>[
        'check-ref-format',
        '--branch',
        name,
      ]).exitCode ==
      0;

  group('a name beginning with a dash', () {
    for (final String name in const <String>['-x', '--force', '-D', '-']) {
      test('"$name" is refused by git and by the parser alike', () {
        expect(gitAccepts(name), isFalse);
        expect(BranchNameValueObject.tryParse(name), isNull);
      });
    }

    test('a dash anywhere else is taken by both', () {
      for (final String name in const <String>['feat/-wip', 'a-b']) {
        expect(gitAccepts(name), isTrue);
        expect(BranchNameValueObject.tryParse(name)?.value, name);
      }
    });
  });

  test('whatever the parser accepts, git accepts', () {
    for (final String name in const <String>[
      'main',
      'feat/rendered-diff-v0',
      'fix/a.b',
      'release/1.2',
      'feat/-wip',
    ]) {
      expect(BranchNameValueObject.tryParse(name), isNotNull);
      expect(gitAccepts(name), isTrue, reason: name);
    }
  });
}
