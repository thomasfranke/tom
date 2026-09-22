import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('an ordinary name is accepted', () {
    expect(BranchNameValueObject('main').value, 'main');
  });

  test('the type names this project uses are ordinary', () {
    for (final String name in const <String>[
      'feat/rendered-diff-v0',
      'fix/watcher-echo-suppression',
      'docs/decision-013-space-config',
      'origin/main',
      'release/0.1',
    ]) {
      expect(BranchNameValueObject.tryParse(name), isNotNull, reason: name);
    }
  });

  test('two names with the same text are the same name', () {
    expect(BranchNameValueObject('main'), BranchNameValueObject('main'));
  });

  group('tryParse refuses what git would refuse', () {
    test('empty', () => expect(BranchNameValueObject.tryParse(''), isNull));

    test('a leading slash', () {
      expect(BranchNameValueObject.tryParse('/main'), isNull);
    });

    test('a trailing slash', () {
      expect(BranchNameValueObject.tryParse('feat/'), isNull);
    });

    test('two dots, which name a range', () {
      expect(BranchNameValueObject.tryParse('main..other'), isNull);
    });

    test('whitespace', () {
      expect(BranchNameValueObject.tryParse('my branch'), isNull);
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
        expect(BranchNameValueObject.tryParse(name), isNull, reason: name);
      }
    });

    test('the .lock suffix git reserves, on any component', () {
      expect(BranchNameValueObject.tryParse('main.lock'), isNull);
      expect(BranchNameValueObject.tryParse('feat/wip.lock'), isNull);
    });

    test('a component starting with a dot', () {
      expect(BranchNameValueObject.tryParse('.drafts'), isNull);
      expect(BranchNameValueObject.tryParse('feat/.wip'), isNull);
    });

    test('a component ending with a dot', () {
      expect(BranchNameValueObject.tryParse('docs.'), isNull);
      expect(BranchNameValueObject.tryParse('feat/docs.'), isNull);
    });

    test('an empty component', () {
      expect(BranchNameValueObject.tryParse('release//v2'), isNull);
    });
  });

  test('a dot inside a component is ordinary', () {
    // Version-shaped branches are common; only the edges of a component and
    // the `..` of a range are refused.
    expect(BranchNameValueObject.tryParse('release/v1.2.3'), isNotNull);
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    expect(() => BranchNameValueObject('main..other'), throwsArgumentError);
  });
}
