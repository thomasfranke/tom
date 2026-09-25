// `tom updates` — whether the toolchain this repository pins has fallen
// behind what Flutter has released.
library;

import 'dart:convert';
import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';
import 'toolchain.dart';

/// Prints what the repository pins, what this machine runs and what stable
/// is on, each dated — and changes no file, since moving the pin is a
/// decision CI builds against. Non-zero only when the feed could not be
/// read: being behind is the finding, not a failure.
Future<int> runUpdates() async {
  announce('Check for updates — Flutter and Dart');

  final pinned = pinnedFlutterVersion();
  final pin = pinned == null ? null : Version.parse(pinned);
  final flutter = await installedFlutter();
  final constraint = declaredDartConstraint();
  final feed = await _fetchFeed();

  // Every date comes from the feed, the installed versions' included: a
  // Flutter install does not carry the day it was published.
  final pinnedRelease = feed?.of(pin);
  final installedRelease = feed?.of(flutter?.framework);
  final latest = feed?.latest;

  stdout.writeln();
  _heading('Flutter');
  _row('pinned', pinned ?? 'unreadable', pinnedRelease?.date, fvmrcPath);
  _row(
    'installed',
    flutter == null ? 'not on PATH' : '${flutter.framework}',
    installedRelease?.date,
    flutter == null ? 'nothing to compare' : '${flutter.channel} channel',
  );
  _row(
    'latest',
    latest == null ? 'unavailable' : '${latest.flutter}',
    latest?.date,
    latest == null ? _feedFailure : 'stable channel',
  );

  stdout.writeln();
  _heading('Dart');
  // The Dart rows are the one bundled with each Flutter above, not the `dart`
  // on PATH: it is the SDK the app is built with, and it makes the three rows
  // comparable. `tom doctor` checks the CLI's own Dart.
  final bundled = flutter?.dart;
  _row('declared', constraint ?? 'unreadable', null, workspacePubspecPath);
  _row(
    'installed',
    '${bundled ?? installedDart() ?? 'unknown'}',
    bundled == null ? null : installedRelease?.date,
    bundled == null
        ? 'the SDK running this CLI'
        : 'bundled with Flutter ${flutter!.framework}',
  );
  _row(
    'latest',
    latest == null ? 'unavailable' : '${latest.dart}',
    latest?.date,
    latest == null ? _feedFailure : 'bundled with Flutter ${latest.flutter}',
  );

  stdout.writeln();
  if (latest == null) {
    _note(
      _Verdict.attention,
      'Could not reach the Flutter release feed.',
      _feedHint,
    );
    return 69; // EX_UNAVAILABLE
  }

  _reportFlutter(
    pin: pin,
    pinnedOn: pinnedRelease?.date,
    installed: flutter?.framework,
    latest: latest,
  );
  _reportDart(constraint: constraint, latest: latest);
  return 0;
}

/// Says whether the pin is current, and what to do when it is not.
///
/// The pin is compared, not the installation: the pin is the project's answer
/// and the installation is one machine's — `tom doctor`'s finding.
void _reportFlutter({
  required Version? pin,
  required DateTime? pinnedOn,
  required Version? installed,
  required _Release latest,
}) {
  if (pin == null) {
    _note(
      _Verdict.attention,
      'No pinned Flutter version to compare.',
      'Give $fvmrcPath a "flutter" entry — CI reads the same file.',
    );
    return;
  }

  if (pin < latest.flutter) {
    _note(
      _Verdict.attention,
      'Flutter $pin${_dated(pinnedOn)} is behind stable '
          '${latest.flutter}${_dated(latest.date)}'
          '${_gap(pinnedOn, latest.date)}.',
      'Set "flutter" to ${latest.flutter} in $fvmrcPath, then run `tom fvm` '
          'and `tom setup`.',
    );
  } else {
    _note(
      _Verdict.ok,
      'Flutter $pin${_dated(latest.date)} is the latest stable release.',
      null,
    );
  }

  if (installed != null && installed != pin) {
    _note(
      _Verdict.attention,
      'This machine runs Flutter $installed, not the pinned $pin.',
      'Run `tom fvm` to match it.',
    );
  }
}

/// Says whether the declared constraint still admits the current Dart.
///
/// A constraint is a floor and a major, so `^3.12.0` is current while Dart
/// ships 3.13.x and stops being so only when the next major arrives.
void _reportDart({required String? constraint, required _Release latest}) {
  final floor = constraint == null ? null : Version.parse(constraint);
  if (floor == null) {
    _note(
      _Verdict.attention,
      'No Dart constraint to compare.',
      'Give $workspacePubspecPath an `environment: sdk:` entry.',
    );
    return;
  }

  if (latest.dart.satisfiesCaret(floor)) {
    _note(
      _Verdict.ok,
      'Dart $constraint admits the current ${latest.dart}.',
      null,
    );
    return;
  }

  _note(
    _Verdict.attention,
    'Dart ${latest.dart} falls outside $constraint.',
    'Raise the `sdk:` constraint in every pubspec — the workspace shares one '
        'lockfile, so they move together.',
  );
}

/// What a closing line can say about a comparison.
enum _Verdict {
  ok(Status.ok),
  attention(Layout.detailMarker);

  const _Verdict(this.glyph);

  final String glyph;

  String get color => this == _Verdict.ok ? palette.ok : palette.detailIcon;
}

/// A finding, with the thing to do about it underneath.
void _note(_Verdict verdict, String finding, String? action) {
  stdout.writeln('  ${verdict.color}${verdict.glyph}${Ansi.reset}  $finding');
  if (action != null) {
    stdout.writeln('     ${palette.detail}$action${Ansi.reset}');
  }
}

void _heading(String what) =>
    stdout.writeln('  ${palette.section}$what${Ansi.reset}');

/// One `label  value  released  note` line.
///
/// Fixed columns rather than measured, so the Flutter and Dart blocks line
/// up against each other; a [released] of `null` prints an em dash so an
/// unknown date does not read as a column that ended early.
void _row(String label, String value, DateTime? released, String? note) {
  stdout.writeln(
    '    ${palette.detail}${label.padRight(_labelWidth)}${Ansi.reset}'
    '${palette.row}${value.padRight(_valueWidth)}${Ansi.reset}'
    '${palette.detail}${_day(released).padRight(_dateWidth)}'
    '${note ?? ''}${Ansi.reset}',
  );
}

const _labelWidth = 12;
const _valueWidth = 12;
const _dateWidth = 13;

/// One release the feed lists.
typedef _Release = ({Version flutter, Version dart, DateTime? date});

/// The feed, read: every release it lists, and the one it calls current.
final class _Feed {
  const _Feed(this.latest, this._byVersion);

  /// The release `current_release.stable` points at.
  final _Release latest;

  final Map<String, _Release> _byVersion;

  /// The release that published [flutter], or `null` when the feed does not
  /// list it — a local build, or one old enough to have been dropped.
  _Release? of(Version? flutter) =>
      flutter == null ? null : _byVersion['$flutter'];
}

/// What a value column says when the feed did not answer — a fragment, since
/// it sits beside a value rather than standing on its own.
const _feedFailure = 'could not reach the Flutter release feed';
const _feedHint =
    'It needs network access. Everything else this CLI does works offline.';

/// The feed, or `null` when it could not be read.
///
/// The same file `flutter upgrade` consults, per host platform. There is no
/// narrower endpoint, and the whole history is wanted anyway: the day a
/// version this machine already has was published is one entry in it.
Future<_Feed?> _fetchFeed() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(Uri.parse(_releasesUrl));
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) return null;

    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 20));
    return _readFeed(body);
  } on Exception {
    // Unreachable, refused, timed out, not JSON: all the same answer to the
    // caller, and the closing note says what to do about it.
    return null;
  } finally {
    client.close(force: true);
  }
}

/// The feed [body] indexed by version, with the current stable picked out.
///
/// Tested with `is` rather than cast: this is someone else's JSON, so a shape
/// that does not match is an answer, not an `Error` for the CLI to crash on.
_Feed? _readFeed(String body) {
  final feed = jsonDecode(body);
  if (feed is! Map<String, dynamic>) return null;

  final current = feed['current_release'];
  final releases = feed['releases'];
  if (current is! Map<String, dynamic> || releases is! List) return null;

  final byVersion = <String, _Release>{};
  _Release? latest;

  // The feed lists a release once per architecture, minutes apart; first one
  // wins, since they agree on the day and only the day is shown.
  for (final entry in releases.whereType<Map<String, dynamic>>()) {
    final flutter = Version.parse('${entry['version']}');
    final dart = Version.parse('${entry['dart_sdk_version']}');
    if (flutter == null || dart == null) continue;

    final release = (
      flutter: flutter,
      dart: dart,
      date: DateTime.tryParse('${entry['release_date']}'),
    );
    byVersion.putIfAbsent('$flutter', () => release);

    // By hash rather than by the first stable entry: the list carries older
    // releases too, and the hash is what the feed itself calls current.
    if (entry['hash'] == current['stable']) latest ??= release;
  }

  return latest == null ? null : _Feed(latest, byVersion);
}

String get _releasesUrl =>
    'https://storage.googleapis.com/flutter_infra_release/releases/'
    'releases_$_feedPlatform.json';

/// Which feed to read: Flutter publishes one per host platform, and a release
/// rolls out per platform, so the honest answer is the machine asking.
String get _feedPlatform => switch (Platform.operatingSystem) {
  'macos' => 'macos',
  'windows' => 'windows',
  _ => 'linux',
};

/// A release date as a day, the only part worth reading; an em dash for a
/// date that is not known, so a column keeps its shape.
String _day(DateTime? date) =>
    date == null ? '—' : '${date.year}-${_two(date.month)}-${_two(date.day)}';

/// A day in parentheses after a version, or nothing when there is none.
String _dated(DateTime? date) => date == null ? '' : ' (${_day(date)})';

/// How far apart two releases are, in days — the number that answers "should
/// I care", since two versions behind is a week on one channel and half a
/// year on another.
String _gap(DateTime? from, DateTime? to) {
  if (from == null || to == null) return '';
  final days = to.difference(from).inDays;
  return days <= 0 ? '' : ' — $days days apart';
}

String _two(int value) => value.toString().padLeft(2, '0');
