// `tom updates` — whether the toolchain this repository pins has fallen
// behind what Flutter has released.
//
// Three rows per SDK and nothing else: what the repository asks for, what
// this machine runs, and what is current on the stable channel — each with
// the day it was released, because "two versions behind" and "two months
// behind" are different facts and only the second one tells you whether to
// care. It changes no file. Moving the pin is a decision rather than a chore — `src/.fvmrc` is
// what CI builds against, so raising it raises it for everyone — and a
// command that did it quietly would be taking that decision on its own.
library;

import 'dart:convert';
import 'dart:io';

import '../theme/theme.dart';
import 'process.dart';
import 'toolchain.dart';

/// Prints what the repository is on and what the stable channel is on.
///
/// Returns non-zero only when the release feed could not be read: with no
/// answer from it there is no comparison to make, and reporting success for a
/// question that was never asked is how a check quietly stops checking. Being
/// behind is not a failure — it is the finding.
Future<int> runUpdates() async {
  announce('Check for updates — Flutter and Dart');

  final pinned = pinnedFlutterVersion();
  final pin = pinned == null ? null : Version.parse(pinned);
  final flutter = await installedFlutter();
  final constraint = declaredDartConstraint();
  final feed = await _fetchFeed();

  // Every date on screen comes from the feed, including the ones for versions
  // this machine already has: a Flutter install does not carry the day it was
  // published, and reading it off the binary's own timestamp would report
  // when it was downloaded instead.
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
  // The Dart rows are the one bundled with each Flutter above, rather than
  // whatever `dart` is on PATH: it is the SDK the app is actually built with,
  // and it makes the three rows comparable — all of them dated by the Flutter
  // release that carries them. `tom doctor` is where the CLI's own Dart is
  // checked against the constraint, which is a different question.
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
/// The pin is what is compared, not what happens to be installed: the pin is
/// the project's answer and the installation is one machine's. A machine that
/// drifted from the pin is `tom doctor`'s finding, and is repeated here only
/// when it is true.
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
/// The constraint is a floor and a major, not a version, so "behind" means
/// something different here: a workspace on `^3.12.0` is perfectly current
/// while Dart ships 3.13.x, and only stops being current when the next major
/// arrives and the constraint shuts it out.
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
/// Fixed columns rather than columns measured from the content: the two
/// blocks are read against each other, and a Dart block whose numbers sat
/// two characters left of Flutter's would make them harder to compare than
/// no alignment at all.
///
/// A [released] of `null` prints an em dash rather than a blank, so a date
/// that is unknown does not read as a column that ended early — and so the
/// one row that can never have a date, the Dart constraint, says as much.
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

/// What a value column says when the feed did not answer. A fragment, not a
/// sentence: it sits beside a value rather than standing on its own.
const _feedFailure = 'could not reach the Flutter release feed';
const _feedHint =
    'It needs network access. Everything else this CLI does works offline.';

/// The feed, or `null` when it could not be read.
///
/// The same file `flutter upgrade` consults, per host platform. There is no
/// narrower endpoint — the whole release history comes down, some 370 KB —
/// and that history is exactly what is wanted here: the current release is
/// one entry in it, and the day a version this machine already has was
/// published is another.
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
    // Unreachable, refused, timed out, not JSON: every one of them is the
    // same answer to the caller — there is nothing to compare against — and
    // the closing note already says what to do about it.
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Indexes the feed [body] by version, and picks out the current stable.
///
/// Tested with `is` rather than cast: this is someone else's JSON arriving
/// over a network, so a shape that does not match is an answer — there is
/// nothing to compare against — and not a bug for the CLI to crash on. A cast
/// would throw an `Error`, which the caller deliberately does not catch.
_Feed? _readFeed(String body) {
  final feed = jsonDecode(body);
  if (feed is! Map<String, dynamic>) return null;

  final current = feed['current_release'];
  final releases = feed['releases'];
  if (current is! Map<String, dynamic> || releases is! List) return null;

  final byVersion = <String, _Release>{};
  _Release? latest;

  // The feed lists a release once per architecture, and the two carry
  // timestamps minutes apart. First one wins: they agree on the day, which is
  // the only part shown, and choosing between them would be inventing a
  // difference that does not exist.
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

    // Found by hash rather than by taking the first stable entry: the list
    // also carries older releases, and the hash is what the feed itself calls
    // current.
    if (entry['hash'] == current['stable']) latest ??= release;
  }

  return latest == null ? null : _Feed(latest, byVersion);
}

String get _releasesUrl =>
    'https://storage.googleapis.com/flutter_infra_release/releases/'
    'releases_$_feedPlatform.json';

/// Which feed to read.
///
/// Flutter publishes one per host platform and they do not always agree on
/// the day — a release rolls out per platform — so the honest answer is the
/// one for the machine asking.
String get _feedPlatform => switch (Platform.operatingSystem) {
  'macos' => 'macos',
  'windows' => 'windows',
  _ => 'linux',
};

/// A release date as a day, which is the only part worth reading here — the
/// feed's timestamps differ by minutes between architectures of one release.
///
/// An em dash for a date that is not known, so a column keeps its shape.
String _day(DateTime? date) =>
    date == null ? '—' : '${date.year}-${_two(date.month)}-${_two(date.day)}';

/// A day in parentheses after a version, or nothing when there is none.
String _dated(DateTime? date) => date == null ? '' : ' (${_day(date)})';

/// How far apart two releases are, spelled in days.
///
/// The number that actually answers "should I care": two versions behind is
/// a week on one channel and half a year on another, and only the second one
/// is a reason to move the pin.
String _gap(DateTime? from, DateTime? to) {
  if (from == null || to == null) return '';
  final days = to.difference(from).inDays;
  return days <= 0 ? '' : ' — $days days apart';
}

String _two(int value) => value.toString().padLeft(2, '0');
