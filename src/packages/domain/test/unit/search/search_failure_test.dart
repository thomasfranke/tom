import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('SearchFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(SearchFailure failure) => switch (failure) {
      IndexCorrupted() => 'Index corrupted',
    };

    test('every variant has a headline, with no default branch', () {
      expect(headline(const IndexCorrupted()), 'Index corrupted');
    });
  });

  test('IndexCorrupted is a value with no data to compare', () {
    expect(const IndexCorrupted(), const IndexCorrupted());
    expect(const IndexCorrupted(), isA<SearchFailure>());
  });
}
