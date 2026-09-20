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
      ]) {
        expect(BranchName.tryParse(name), isNull, reason: name);
      }
    });

    test('the .lock suffix git reserves', () {
      expect(BranchName.tryParse('main.lock'), isNull);
    });
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    expect(() => BranchName('main..other'), throwsArgumentError);
  });
}
