import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  group('ExportFailure', () {
    // Sealed, so this compiles with no default branch and a new variant
    // breaks every switch that has to say something about it.
    String headline(ExportFailure failure) => switch (failure) {
      ExportCannotWrite() => 'Could not write the file',
      ExportUnsupported() => 'Format not supported',
      ExportTooLarge() => 'Too large for the format',
    };

    test('every variant has a headline, with no default branch', () {
      expect(headline(const ExportCannotWrite('/a.pdf')), contains('write'));
      expect(
        headline(const ExportUnsupported(ExportFormatEnum.html)),
        contains('supported'),
      );
      expect(
        headline(const ExportTooLarge(ExportFormatEnum.pdf)),
        contains('large'),
      );
    });
  });

  test('a variant is a value, compared by what it names', () {
    expect(
      const ExportCannotWrite('/a.pdf'),
      const ExportCannotWrite('/a.pdf'),
    );
    expect(
      const ExportCannotWrite('/a.pdf'),
      isNot(const ExportCannotWrite('/b.pdf')),
    );
    expect(const ExportTooLarge(ExportFormatEnum.pdf), isA<ExportFailure>());
  });
}
