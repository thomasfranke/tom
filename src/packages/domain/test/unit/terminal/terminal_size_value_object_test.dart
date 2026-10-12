/// [TerminalSizeValueObject]: a screen holds at least one cell.
library;

import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('compares by value', () {
    expect(
      const TerminalSizeValueObject(columns: 80, rows: 24),
      const TerminalSizeValueObject(columns: 80, rows: 24),
    );
  });

  test('refuses a screen with no column or no row', () {
    expect(
      () => TerminalSizeValueObject(columns: 0, rows: 24),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => TerminalSizeValueObject(columns: 80, rows: 0),
      throwsA(isA<AssertionError>()),
    );
  });
}
