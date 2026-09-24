import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';

/// A failure vocabulary of its own, so the tests can prove the *failure* side
/// of a switch is exhaustive too — which is the whole reason `F` exists.
sealed class TestFailure implements AppFailure {}

final class Broke implements TestFailure {
  const Broke({this.cause});

  @override
  final AppFailure? cause;
}

final class Refused implements TestFailure {
  const Refused({this.cause});

  @override
  final AppFailure? cause;
}

/// Another vocabulary, to translate into.
final class Louder implements AppFailure {
  const Louder(this.cause);

  @override
  final AppFailure cause;
}

void main() {
  group('Result', () {
    // The property the whole error model rests on: this function compiles
    // without a default branch. If Result stopped being sealed, it would not.
    String describe(Result<int, TestFailure> result) => switch (result) {
      Success<int, TestFailure>(value: final int value) => 'ok $value',
      Failure<int, TestFailure>() => 'failed',
    };

    // And this one: the failure is typed, so the inner switch needs no
    // catch-all either. Before `F`, every translation carried one it
    // documented as unreachable.
    String why(Result<int, TestFailure> result) => switch (result) {
      Success<int, TestFailure>() => 'none',
      Failure<int, TestFailure>(failure: final TestFailure failure) =>
        switch (failure) {
          Broke() => 'broke',
          Refused() => 'refused',
        },
    };

    test('a switch over a result needs no default branch', () {
      expect(describe(const Success<int, TestFailure>(1)), 'ok 1');
      expect(describe(const Failure<int, TestFailure>(Broke())), 'failed');
    });

    test('a switch over the failure needs no default branch either', () {
      expect(why(const Success<int, TestFailure>(1)), 'none');
      expect(why(const Failure<int, TestFailure>(Broke())), 'broke');
      expect(why(const Failure<int, TestFailure>(Refused())), 'refused');
    });

    test('a narrow failure widens to AppFailure with no conversion', () {
      // Covariance in F, which is what lets a use case widen for free.
      const Result<int, TestFailure> narrow = Failure<int, TestFailure>(
        Broke(),
      );
      const Result<int, AppFailure> wide = narrow;

      expect(wide, same(narrow));
    });
  });

  group('map', () {
    test('transforms a success', () {
      expect(
        const Success<int, TestFailure>(2).map((int n) => n * 3),
        isA<Success<int, TestFailure>>().having(
          (Success<int, TestFailure> s) => s.value,
          'value',
          6,
        ),
      );
    });

    test('carries a failure untouched', () {
      const TestFailure failure = Broke();

      expect(
        const Failure<int, TestFailure>(failure).map((int n) => n * 3),
        isA<Failure<int, TestFailure>>().having(
          (Failure<int, TestFailure> f) => f.failure,
          'failure',
          same(failure),
        ),
      );
    });
  });

  group('flatMap', () {
    test('continues into the next operation', () {
      expect(
        const Success<int, TestFailure>(
          2,
        ).flatMap((int n) => Success<String, TestFailure>('$n')),
        isA<Success<String, TestFailure>>().having(
          (Success<String, TestFailure> s) => s.value,
          'value',
          '2',
        ),
      );
    });

    test('stops at the first failure', () {
      expect(
        const Failure<int, TestFailure>(
          Broke(),
        ).flatMap((int n) => Success<String, TestFailure>('$n')),
        isA<Failure<String, TestFailure>>(),
      );
    });

    test('reports the second operation failing', () {
      expect(
        const Success<int, TestFailure>(
          2,
        ).flatMap((_) => const Failure<String, TestFailure>(Refused())),
        isA<Failure<String, TestFailure>>().having(
          (Failure<String, TestFailure> f) => f.failure,
          'failure',
          isA<Refused>(),
        ),
      );
    });
  });

  group('mapFailure', () {
    test('translates a failure into another vocabulary', () {
      const TestFailure original = Broke();

      expect(
        const Failure<int, TestFailure>(
          original,
        ).mapFailure<Louder>(Louder.new),
        isA<Failure<int, Louder>>().having(
          (Failure<int, Louder> f) => f.failure.cause,
          'cause',
          same(original),
        ),
      );
    });

    test('leaves a success alone', () {
      expect(
        const Success<int, TestFailure>(7).mapFailure<Louder>(Louder.new),
        isA<Success<int, Louder>>().having(
          (Success<int, Louder> s) => s.value,
          'value',
          7,
        ),
      );
    });
  });

  group('fold and valueOrNull', () {
    test('fold collapses both branches', () {
      String read(Result<int, TestFailure> result) =>
          result.fold((int n) => 'ok $n', (TestFailure _) => 'no');

      expect(read(const Success<int, TestFailure>(1)), 'ok 1');
      expect(read(const Failure<int, TestFailure>(Broke())), 'no');
    });

    test('valueOrNull answers null for a failure', () {
      expect(const Success<int, TestFailure>(1).valueOrNull, 1);
      expect(const Failure<int, TestFailure>(Broke()).valueOrNull, isNull);
    });
  });

  group('over a future', () {
    Future<Result<int, TestFailure>> succeeding() async =>
        const Success<int, TestFailure>(2);
    Future<Result<int, TestFailure>> failing() async =>
        const Failure<int, TestFailure>(Broke());

    test('map awaits and transforms', () async {
      expect(
        await succeeding().map((int n) => n + 1),
        isA<Success<int, TestFailure>>(),
      );
    });

    test('flatMap chains an asynchronous operation', () async {
      expect(
        await succeeding().flatMap(
          (int n) async => Success<String, TestFailure>('$n'),
        ),
        isA<Success<String, TestFailure>>().having(
          (Success<String, TestFailure> s) => s.value,
          'value',
          '2',
        ),
      );
    });

    test('flatMap does not run the next operation after a failure', () async {
      bool ran = false;

      await failing().flatMap((int n) async {
        ran = true;
        return Success<String, TestFailure>('$n');
      });

      expect(ran, isFalse);
    });

    test('mapFailure and fold await too', () async {
      expect(
        await failing().mapFailure<Louder>(Louder.new),
        isA<Failure<int, Louder>>(),
      );
      expect(
        await succeeding().fold((int n) => 'ok $n', (TestFailure _) => 'no'),
        'ok 2',
      );
    });
  });

  group('the cause chain', () {
    test('reads outermost first and ends where nothing was translated', () {
      const Broke bottom = Broke();
      const Louder middle = Louder(bottom);
      const Louder top = Louder(middle);

      expect(top.chain, <AppFailure>[top, middle, bottom]);
      expect(bottom.chain, <AppFailure>[bottom]);
    });

    test('diagnostics names every link', () {
      const Louder failure = Louder(Broke());

      expect(failure.diagnostics.split('\n'), hasLength(2));
    });

    test('diagnostics prints each link once, however deep the chain', () {
      // A generated `toString` prints the cause inside its own text, so a
      // chain joined naively would repeat the bottom failure once per
      // ancestor. `UnexpectedFailure` is the one Freezed failure this
      // package holds, which makes it the real thing rather than a stand-in.
      const UnexpectedFailure failure = UnexpectedFailure(
        'top',
        cause: UnexpectedFailure('middle', cause: UnexpectedFailure('bottom')),
      );

      final List<String> lines = failure.diagnostics.split('\n');

      expect(lines, hasLength(3));
      expect(lines[0], 'UnexpectedFailure(description: top)');
      expect(lines[1], 'UnexpectedFailure(description: middle)');
      expect(lines[2], 'UnexpectedFailure(description: bottom)');
      expect('bottom'.allMatches(failure.diagnostics), hasLength(1));
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

    test('is the bottom of a chain', () {
      // It is what the guard produces from an exception, and an exception was
      // not a failure that anything translated.
      expect(describing('boom').cause, isNull);
    });
  });
}
