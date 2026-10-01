import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('SearchFailure', () {
    // The reason the hierarchy is sealed: this compiles with no default
    // branch, so a new variant breaks every switch that has to handle it.
    String headline(SearchFailure failure) => switch (failure) {
      SearchIndexCorrupted() => 'Index corrupted',
    };

    test('every variant has a headline, with no default branch', () {
      expect(headline(const SearchIndexCorrupted()), 'Index corrupted');
    });
  });

  test('SearchIndexCorrupted is a value with no data to compare', () {
    expect(const SearchIndexCorrupted(), const SearchIndexCorrupted());
    expect(const SearchIndexCorrupted(), isA<SearchFailure>());
  });
}
