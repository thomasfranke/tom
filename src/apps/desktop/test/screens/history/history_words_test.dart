import 'package:flutter_test/flutter_test.dart';
import 'package:tom_desktop/screens/history/history_words.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 9, 24, 12);

  CommitDateValueObject ago(
    Duration since, {
    Duration offset = Duration.zero,
  }) => CommitDateValueObject(utc: now.subtract(since), offset: offset);

  String words(Duration since, {Duration offset = Duration.zero}) =>
      whenInWords(ago(since, offset: offset), now: now);

  test('anything under a minute is just now', () {
    expect(words(const Duration(seconds: 40)), 'just now');
  });

  test('a clock ahead of the commit still reads forwards', () {
    // A machine whose time is off, or a commit made a moment ago while the
    // seconds tick — "in -1 minutes" is not a thing to show anybody.
    expect(words(const Duration(seconds: -30)), 'just now');
  });

  test('it counts in the largest unit that still says something', () {
    expect(words(const Duration(minutes: 5)), '5 minutes ago');
    expect(words(const Duration(hours: 5)), '5 hours ago');
    expect(words(const Duration(days: 5)), '5 days ago');
    expect(words(const Duration(days: 70)), '2 months ago');
    expect(words(const Duration(days: 800)), '2 years ago');
  });

  test('one of anything is singular', () {
    expect(words(const Duration(minutes: 1)), '1 minute ago');
    expect(words(const Duration(hours: 1)), '1 hour ago');
    expect(words(const Duration(days: 1)), '1 day ago');
    expect(words(const Duration(days: 40)), '1 month ago');
    expect(words(const Duration(days: 400)), '1 year ago');
  });

  test('the author\'s offset changes nothing about how old it is', () {
    // The offset is what the date is *displayed* in; age is measured on the
    // instant, or two commits from two timezones would be ordered by where
    // their authors were sitting.
    expect(
      words(const Duration(days: 3), offset: const Duration(hours: -3)),
      words(const Duration(days: 3), offset: const Duration(hours: 9)),
    );
  });
}
