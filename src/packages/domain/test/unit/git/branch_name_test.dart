import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('an ordinary name is accepted', () {
    expect(BranchName('main').value, 'main');
  });

  test('the type names this project uses are ordinary', () {
    for (final String name in const <String>[
      'feat/rendered-diff-v0',
      'fix/watcher-echo-suppression',
      'docs/decision-013-space-config',
      'origin/main',
      'release/0.1',
    ]) {
      expect(BranchName.tryParse(name), isNotNull, reason: name);
    }
  });

  test('two names with the same text are the same name', () {
    expect(BranchName('main'), BranchName('main'));
  });

  group('tryParse refuses what git would refuse', () {
    test('empty', () => expect(BranchName.tryParse(''), isNull));

    test('a leading slash', () {
      expect(BranchName.tryParse('/main'), isNull);
    });

    test('a trailing slash', () {
      expect(BranchName.tryParse('feat/'), isNull);
    });

    test('two dots, which name a range', () {
      expect(BranchName.tryParse('main..other'), isNull);
    });

    test('whitespace', () {
      expect(BranchName.tryParse('my branch'), isNull);
    });

    test('a ref modifier', () {
      for (final String name in const <String>[
        'main~1',
        'main^',
        'main:other',
        'main?',
        'main*',
        'main[0]',
        'main@{1}',
      ]) {
        expect(BranchName.tryParse(name), isNull, reason: name);
      }
    });

    test('the .lock suffix git reserves, on any component', () {
      expect(BranchName.tryParse('main.lock'), isNull);
      expect(BranchName.tryParse('feat/wip.lock'), isNull);
    });

    test('a component starting with a dot', () {
      expect(BranchName.tryParse('.drafts'), isNull);
      expect(BranchName.tryParse('feat/.wip'), isNull);
    });

    test('a component ending with a dot', () {
      expect(BranchName.tryParse('docs.'), isNull);
      expect(BranchName.tryParse('feat/docs.'), isNull);
    });

    test('an empty component', () {
      expect(BranchName.tryParse('release//v2'), isNull);
    });
  });

  test('a dot inside a component is ordinary', () {
    // Version-shaped branches are common; only the edges of a component and
    // the `..` of a range are refused.
    expect(BranchName.tryParse('release/v1.2.3'), isNotNull);
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    expect(() => BranchName('main..other'), throwsArgumentError);
  });
}
