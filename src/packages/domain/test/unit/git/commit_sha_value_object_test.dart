import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  const String full = 'a618609c8c58e65560ac3b7341607f93cb4e3019';

  test('a full sha is accepted and keeps its text', () {
    expect(CommitShaValueObject(full).value, full);
  });

  test('short is what a commit list shows', () {
    expect(CommitShaValueObject(full).short, 'a618609');
  });

  test('two shas with the same text are the same sha', () {
    expect(CommitShaValueObject(full), CommitShaValueObject(full));
  });

  group('tryParse answers null instead of throwing', () {
    test('for an abbreviation', () {
      expect(CommitShaValueObject.tryParse('a618609'), isNull);
    });

    test('for uppercase, which git does not print', () {
      expect(CommitShaValueObject.tryParse(full.toUpperCase()), isNull);
    });

    test('for something that is not hexadecimal', () {
      expect(CommitShaValueObject.tryParse('z' * 40), isNull);
    });

    test('for empty', () {
      expect(CommitShaValueObject.tryParse(''), isNull);
    });
  });

  test('the constructor throws, because reaching it with junk is a bug', () {
    // The invariant is checked once, here. A parser reading git output uses
    // tryParse; anything else is the code's own mistake.
    expect(() => CommitShaValueObject('nope'), throwsArgumentError);
  });
}
