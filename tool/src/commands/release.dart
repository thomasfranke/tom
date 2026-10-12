// `tom release` — bump the version in lockstep, write the changelog since
// the last tag, and leave a commit and an annotated tag ready to push.
library;

import 'dart:io';

import '../repo.dart';
import 'process.dart';

/// The three bumps semantic versioning offers, read from the word after
/// `tom release` — `major`, `minor` or `patch`
/// ([versioning.md](../../../docs/technical/process/versioning.md)).
const releaseBumps = {'major', 'minor', 'patch'};

/// Every pubspec whose `version:` line moves together — the desktop app's
/// own is the one [currentVersion] reads, because every other package is
/// asserted against it.
const List<String> versionedPubspecs = <String>[
  'src/apps/desktop/pubspec.yaml',
  'src/apps/mobile/pubspec.yaml',
  'src/packages/core/pubspec.yaml',
  'src/packages/domain/pubspec.yaml',
  'src/packages/application/pubspec.yaml',
  'src/packages/infra/pubspec.yaml',
  'src/packages/data/pubspec.yaml',
  'src/packages/presentation/pubspec.yaml',
  'src/packages/ui/pubspec.yaml',
];

/// `major.minor.patch`, with no build metadata: the one shape every pubspec
/// here uses, and the one a release bumps.
final class SemVer {
  const SemVer(this.major, this.minor, this.patch);

  factory SemVer.parse(String value) {
    final parts = value.trim().split('.');
    if (parts.length != 3) {
      throw FormatException('tom release: "$value" is not major.minor.patch');
    }
    return SemVer(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int major;
  final int minor;
  final int patch;

  /// The next version for [bump], one of [releaseBumps].
  ///
  /// A major resets both the numbers below it, and a minor resets the patch
  /// — semver's own rule, not this project's.
  SemVer bump(String kind) => switch (kind) {
    'major' => SemVer(major + 1, 0, 0),
    'minor' => SemVer(major, minor + 1, 0),
    'patch' => SemVer(major, minor, patch + 1),
    _ => throw ArgumentError('tom release: unknown bump "$kind"'),
  };

  @override
  String toString() => '$major.$minor.$patch';
}

/// The version every package shares right now.
String currentVersion() {
  final file = File('${repoRoot().path}/${versionedPubspecs.first}');
  final match = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(file.readAsStringSync());
  if (match == null) {
    throw StateError('tom release: no version: line in ${file.path}');
  }
  return match.group(1)!;
}

/// Writes [next] into every pubspec in [versionedPubspecs].
void _writeVersion(SemVer next) {
  for (final path in versionedPubspecs) {
    final file = File('${repoRoot().path}/$path');
    file.writeAsStringSync(
      file.readAsStringSync().replaceFirst(
        RegExp(r'^version:\s*\S+', multiLine: true),
        'version: $next',
      ),
    );
  }
}

/// One commit's subject and body, which is all a changelog reads.
final class CommitMessage {
  const CommitMessage(this.subject, this.body);

  final String subject;
  final String body;

  /// A `!` before the colon, or a `BREAKING CHANGE:` footer — the two shapes
  /// Conventional Commits marks a break with.
  bool get isBreaking =>
      RegExp(r'^\w+(\([^)]+\))?!:').hasMatch(subject) ||
      body.contains('BREAKING CHANGE');

  bool get isFeature => subject.startsWith('feat');

  bool get isFix => subject.startsWith('fix');
}

/// Every commit since [previousTag], oldest first — every commit ever when
/// there is none, because a first release has no earlier point to read from.
Future<List<CommitMessage>> commitsSince(String? previousTag) async {
  const separator = '\x01';
  const terminator = '\x02';
  final range = previousTag == null ? 'HEAD' : '$previousTag..HEAD';
  final result = await capture('git', [
    'log',
    range,
    '--reverse',
    '--pretty=format:%s$separator%b$terminator',
  ]);
  final output = result?.stdout as String? ?? '';
  return [
    for (final block in output.split(terminator))
      if (block.trim().isNotEmpty) _commitOf(block, separator),
  ];
}

/// One [commitsSince] block, split at its one [separator] into subject and
/// body.
CommitMessage _commitOf(String block, String separator) {
  final parts = block.split(separator);
  return CommitMessage(parts.first, parts.skip(1).join(separator));
}

/// The `v<tag>` most recently reached, or `null` on a repository with none.
Future<String?> _latestTag() async {
  final result = await capture('git', ['describe', '--tags', '--abbrev=0']);
  if (result == null || result.exitCode != 0) return null;
  return (result.stdout as String).trim();
}

/// The release notes [version] ships with, grouped the way `versioning.md`
/// promises: breaking changes first, then features, then fixes — everything
/// else in [commits] (chores, docs, refactors) says nothing a user reads.
String changelogFor(SemVer version, List<CommitMessage> commits) {
  final breaking = commits.where((c) => c.isBreaking);
  final features = commits.where((c) => c.isFeature && !c.isBreaking);
  final fixes = commits.where((c) => c.isFix && !c.isBreaking);

  final buffer = StringBuffer('## v$version\n');
  void section(String title, Iterable<CommitMessage> entries) {
    if (entries.isEmpty) return;
    buffer.writeln('\n### $title\n');
    for (final entry in entries) {
      buffer.writeln('- ${entry.subject}');
    }
  }

  section('Breaking changes', breaking);
  section('Features', features);
  section('Fixes', fixes);
  return buffer.toString();
}

/// Bumps the version, writes the changelog, and leaves a commit and an
/// annotated tag — locally. Pushing is a separate, explicit step
/// ([`tom-git-workflow`](../../../.ai/skills/tom-git-workflow/SKILL.md)):
/// this command never touches a remote.
Future<int> runRelease(String? bump) async {
  if (bump == null || !releaseBumps.contains(bump)) {
    stderr.writeln('tom release: pass major, minor or patch');
    return 64; // EX_USAGE
  }

  final next = SemVer.parse(currentVersion()).bump(bump);
  final previousTag = await _latestTag();
  final changelog = changelogFor(next, await commitsSince(previousTag));

  _writeVersion(next);
  final add = await capture('git', ['add', ...versionedPubspecs]);
  if (add == null || add.exitCode != 0) {
    stderr.writeln('tom release: git add failed');
    return 1;
  }
  final commit = await capture('git', [
    'commit',
    '--message',
    'chore(release): v$next',
  ]);
  if (commit == null || commit.exitCode != 0) {
    stderr.writeln('tom release: git commit failed\n${commit?.stdout}');
    return 1;
  }
  final tag = await capture('git', [
    'tag',
    '--annotate',
    'v$next',
    '--message',
    changelog,
  ]);
  if (tag == null || tag.exitCode != 0) {
    stderr.writeln('tom release: git tag failed\n${tag?.stdout}');
    return 1;
  }

  stdout
    ..writeln(changelog)
    ..writeln('Committed and tagged v$next locally.')
    ..writeln('Nothing was pushed — push when ready:')
    ..writeln('  git push origin main --tags');
  return 0;
}
