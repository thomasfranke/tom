import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';

void main() {
  group('Result', () {
    // The property the whole error model rests on: this function compiles
    // without a default branch. If Result stopped being sealed, it would not.
    String describe(Result<int> result) => switch (result) {
      Success<int>(value: final int value) => 'ok $value',
      Failure<int>() => 'failed',
    };

    test('a switch over a result needs no default branch', () {
      expect(describe(const Success<int>(1)), 'ok 1');
      expect(describe(const Failure<int>(UnexpectedFailure('boom'))), 'failed');
    });
  });

  group('UnexpectedFailure', () {
    // Built at runtime rather than const: const instances are canonicalised,
    // which would make the test pass even with no `==` at all.
    UnexpectedFailure describing(String what) => UnexpectedFailure(what);

    test('compares by value', () {
      expect(describing('boom'), describing('boom'));
      expect(describing('boom'), isNot(describing('other')));
    });

    test('hashCode agrees with ==', () {
      expect(describing('boom').hashCode, describing('boom').hashCode);
    });
  });
}
