/// The update check's own preference: on until somebody unticks it, and
/// kept in the store under its own name.
library;

import 'package:test/test.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  test('a store that never heard of it holds it on', () {
    final PreferencesValueObject read = PreferencesDto.fromRow(
      <String, Object?>{'theme': 'dark'},
    ).toValueObject();

    expect(read.checkingForUpdates, isTrue);
  });

  test('a value nobody can read is on too', () {
    final PreferencesValueObject read = PreferencesDto.fromRow(
      <String, Object?>{'checkingForUpdates': 'yes'},
    ).toValueObject();

    expect(read.checkingForUpdates, isTrue);
  });

  test('a stored false stays false: whoever unticked it keeps the choice', () {
    final PreferencesValueObject read = PreferencesDto.fromRow(
      <String, Object?>{'checkingForUpdates': false},
    ).toValueObject();

    expect(read.checkingForUpdates, isFalse);
  });

  test('unticked, it survives a write and a read', () {
    const PreferencesValueObject unticked = PreferencesValueObject(
      checkingForUpdates: false,
    );

    final Map<String, Object?> row = PreferencesDto.of(unticked).toRow();

    expect(row['checkingForUpdates'], isFalse);
    expect(
      PreferencesDto.fromRow(row).toValueObject().checkingForUpdates,
      isFalse,
    );
  });

  test('on by default in the value object itself', () {
    expect(PreferencesValueObject.defaults.checkingForUpdates, isTrue);
  });
}
