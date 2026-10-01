/// [ConflictScannerService] over markers a real `git merge` wrote.
///
/// The unit test proves the scanner against markers this repository typed.
/// This one proves the only thing that test cannot: that what git actually
/// leaves in a file is what the scanner is looking for.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late Directory tempDir;
  late String repoPath;

  const ConflictScannerService scanner = ConflictScannerService();

  void git(List<String> arguments, {bool allowFailure = false}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: repoPath,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0 && !allowFailure) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  void write(String relativePath, String content) {
    File('$repoPath/$relativePath')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  String read(String relativePath) =>
      File('$repoPath/$relativePath').readAsStringSync();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_conflict_scanner_');
    repoPath = '${tempDir.path}/repo';
    Directory(repoPath).createSync(recursive: true);
    git(<String>['init', '--quiet', '.']);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main']);
    for (final List<String> setting in const <List<String>>[
      <String>['user.name', 'Test'],
      <String>['user.email', 'test@example.com'],
      <String>['commit.gpgsign', 'false'],
    ]) {
      git(<String>['config', ...setting]);
    }
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  /// Leaves `guide.md` conflicted, the way a pull does, and answers with what
  /// git wrote into the working tree.
  String conflictOn({
    required String base,
    required String onMain,
    required String onOther,
  }) {
    write('guide.md', base);
    git(<String>['add', 'guide.md']);
    git(<String>['commit', '--quiet', '-m', 'base']);

    git(<String>['checkout', '--quiet', '-b', 'other']);
    write('guide.md', onOther);
    git(<String>['commit', '--quiet', '-am', 'theirs']);

    git(<String>['checkout', '--quiet', 'main']);
    write('guide.md', onMain);
    git(<String>['commit', '--quiet', '-am', 'ours']);

    // The merge is expected to fail; that failure is the arrangement.
    git(<String>['merge', 'other'], allowFailure: true);
    return read('guide.md');
  }

  test('reads the region git left, both sides and both labels', () {
    final String conflicted = conflictOn(
      base: '# Guide\n\nOriginal line.\n',
      onMain: '# Guide\n\nOur line.\n',
      onOther: '# Guide\n\nTheir line.\n',
    );

    final List<ConflictRegionValueObject> found = scanner.scan(conflicted);

    expect(found, hasLength(1));
    expect(found.single.current.trim(), 'Our line.');
    expect(found.single.incoming.trim(), 'Their line.');
    expect(found.single.currentLabel, 'HEAD');
    expect(found.single.incomingLabel, 'other');
  });

  test('a file git did not touch holds no marker', () {
    conflictOn(
      base: '# Guide\n\nOriginal line.\n',
      onMain: '# Guide\n\nOur line.\n',
      onOther: '# Guide\n\nTheir line.\n',
    );
    write('untouched.md', '# Untouched\n\nProse.\n');

    expect(scanner.holdsMarker(read('untouched.md')), isFalse);
  });

  // Git decides hunk boundaries, not this project: two edits close together
  // come back as one region, however many lines were touched. The separator
  // here is long enough that git leaves two, which is what the test is about.
  test('finds every region when git left more than one', () {
    final String gap = 'Untouched.\n' * 12;
    final String conflicted = conflictOn(
      base: '# Guide\n\nFirst.\n\n$gap\nSecond.\n',
      onMain: '# Guide\n\nOur first.\n\n$gap\nOur second.\n',
      onOther: '# Guide\n\nTheir first.\n\n$gap\nTheir second.\n',
    );

    final List<ConflictRegionValueObject> found = scanner.scan(conflicted);

    expect(found, hasLength(2));
    expect(found.first.current.trim(), 'Our first.');
    expect(found.last.current.trim(), 'Our second.');
    expect(found.first.end, lessThan(found.last.start));
  });

  // The point of the whole guard: what the scanner writes back has to be
  // something git accepts as resolved, not merely something that looks clean.
  test('a resolved document can be staged and committed', () {
    final String conflicted = conflictOn(
      base: '# Guide\n\nOriginal line.\n',
      onMain: '# Guide\n\nOur line.\n',
      onOther: '# Guide\n\nTheir line.\n',
    );

    final String resolved = scanner.resolve(
      conflicted,
      scanner.scan(conflicted).single,
      ConflictChoiceEnum.both,
    );
    write('guide.md', resolved);

    expect(scanner.holdsMarker(resolved), isFalse);
    expect(resolved, contains('Our line.'));
    expect(resolved, contains('Their line.'));

    git(<String>['add', 'guide.md']);
    git(<String>['commit', '--quiet', '-m', 'merge other']);

    final ProcessResult status = Process.runSync(
      'git',
      <String>['status', '--porcelain'],
      workingDirectory: repoPath,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    expect(status.stdout.toString().trim(), isEmpty);
  });

  test('git reports the conflicted path the way the guard expects', () {
    conflictOn(
      base: '# Guide\n\nOriginal line.\n',
      onMain: '# Guide\n\nOur line.\n',
      onOther: '# Guide\n\nTheir line.\n',
    );

    final ProcessResult conflicted = Process.runSync(
      'git',
      <String>['diff', '--name-only', '--diff-filter=U'],
      workingDirectory: repoPath,
      environment: const <String, String>{'LC_ALL': 'C'},
    );

    expect(conflicted.stdout.toString().trim(), 'guide.md');
  });
}
