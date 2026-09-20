import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  CommitDate dateAt(Duration offset) =>
      CommitDate(utc: DateTime.utc(2026, 9, 20, 4, 44, 1), offset: offset);

  test('authorLocal reads as the clock the author saw', () {
    expect(dateAt(const Duration(hours: -3)).authorLocal.hour, 1);
    expect(dateAt(const Duration(hours: 2)).authorLocal.hour, 6);
  });

  test('an offset can carry the day across midnight', () {
    // The reason the offset is kept at all: the instant says Sunday, the
    // author's clock said Saturday night.
    final DateTime local = dateAt(const Duration(hours: -6)).authorLocal;

    expect(local.day, 19);
    expect(local.hour, 22);
  });

  test('a zero offset leaves the instant alone', () {
    final CommitDate date = dateAt(Duration.zero);

    expect(date.authorLocal, date.utc);
  });

  test('offsets that are not whole hours are ordinary', () {
    expect(
      dateAt(const Duration(hours: 5, minutes: 45)).authorLocal.minute,
      29,
    );
  });

  test('the same instant on two clocks is two different dates', () {
    expect(
      dateAt(const Duration(hours: -3)),
      isNot(dateAt(const Duration(hours: 2))),
    );
  });

  test('two dates with the same content are equal', () {
    expect(dateAt(Duration.zero), dateAt(Duration.zero));
  });
}
