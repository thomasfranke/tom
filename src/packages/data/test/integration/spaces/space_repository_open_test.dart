/// Opening a folder as a space, against real repositories.
///
/// Integration rather than unit, because the question is what git says about
/// a folder — where the repository above it is, and whether there is one at
/// all. A fake client would only prove that the fake agrees with itself, and
/// this is the path every session starts on.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory tempDir;
  late String base;
  late SpaceRepositoryImpl repository;

  /// Runs git directly, to arrange what the repository is then asked about.
  void git(List<String> arguments, {required String inside}) {
    final ProcessResult result = Process.runSync(
      'git',
      arguments,
      workingDirectory: inside,
      environment: const <String, String>{'LC_ALL': 'C'},
    );
    if (result.exitCode != 0) {
      throw StateError('git ${arguments.join(' ')}: ${result.stderr}');
    }
  }

  /// A repository at [path], with an identity and a `main` branch.
  void initRepository(String path) {
    Directory(path).createSync(recursive: true);
    git(<String>['init', '--quiet', '.'], inside: path);
    git(<String>['symbolic-ref', 'HEAD', 'refs/heads/main'], inside: path);
  }

  /// What [result] holds, or a failure of the test if it did not succeed.
  T valueOf<T>(Result<T> result) => switch (result) {
    Success<T>(value: final T value) => value,
    Failure<T>(failure: final AppFailure failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  AppFailure failureOf<T>(Result<T> result) => switch (result) {
    Success<T>() => throw StateError('expected a failure, got a success'),
    Failure<T>(failure: final AppFailure failure) => failure,
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_open_space_');
    // Resolved and forward-slashed: the macOS system temporary directory is
    // a symlink, and git reports the real path in its own spelling.
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    repository = SpaceRepositoryImpl(
      filesystem: const DartIoFilesystem(),
      gitClientFor: (String folder) =>
          DartIoGitClient(workingDirectory: folder),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('opening the repository itself', () {
    test('root and repositoryRoot are the same folder', () async {
      final String path = '$base/repo';
      initRepository(path);

      final Space space = valueOf(await repository.open(path));

      expect(space.root, path);
      expect(space.repositoryRoot, path);
      expect(space.rootWithinRepository, isNull);
    });

    test('the name comes from the folder', () async {
      final String path = '$base/my-notes';
      initRepository(path);

      expect(valueOf(await repository.open(path)).name, 'my-notes');
    });
  });

  group('opening a folder inside a repository', () {
    // The normal case, and the reason `Space` carries two paths: most teams
    // keep `docs/` inside the repository that holds the code.
    late String repoPath;

    setUp(() {
      repoPath = '$base/app';
      initRepository(repoPath);
      Directory('$repoPath/docs/adr').createSync(recursive: true);
    });

    test('git is found above the folder that was opened', () async {
      final Space space = valueOf(await repository.open('$repoPath/docs'));

      expect(space.root, '$repoPath/docs');
      expect(space.repositoryRoot, repoPath);
      expect(space.rootWithinRepository?.value, 'docs');
      expect(space.name, 'docs');
    });

    test('however deep the folder is', () async {
      final Space space = valueOf(await repository.open('$repoPath/docs/adr'));

      expect(space.repositoryRoot, repoPath);
      expect(space.rootWithinRepository?.value, 'docs/adr');
    });

    test('and the paths convert both ways', () async {
      // What every later git call depends on: a path the file tree shows
      // and a path git accepts are the same file.
      final Space space = valueOf(await repository.open('$repoPath/docs'));
      final SpaceRelativePath guide = SpaceRelativePath('guide.md');

      expect(space.toRepoRelative(guide).value, 'docs/guide.md');
      expect(space.toSpaceRelative(RepoRelativePath('docs/guide.md')), guide);
    });
  });

  group('when it is not a space', () {
    test('a folder outside any repository is named, not worked around', () {
      // TOM never runs `git init` for the user and never opens the folder in
      // a quieter mode (docs/product/home/doc.md).
      final String path = '$base/loose';
      Directory(path).createSync();

      expect(
        repository.open(path),
        completion(
          isA<Failure<Space>>().having(
            (Failure<Space> result) => result.failure,
            'failure',
            GitNotARepository(path),
          ),
        ),
      );
    });

    test('a folder that is not there is a different failure', () async {
      // Which sends the user somewhere else entirely: Home offers to forget
      // a recent space whose folder was deleted, rather than explaining
      // that git found no repository in a place that does not exist.
      final String path = '$base/gone';

      expect(failureOf(await repository.open(path)), SpaceFolderMissing(path));
    });

    test('no infrastructure failure reaches the caller', () async {
      final String path = '$base/loose';
      Directory(path).createSync();

      final AppFailure failure = failureOf(await repository.open(path));
      expect(failure, isNot(isA<GitClientFailure>()));
      expect(failure, isNot(isA<FilesystemFailure>()));
    });
  });

  group('what an opened space can then do', () {
    test('it lists itself, and git is not in the listing', () async {
      final String repoPath = '$base/app';
      initRepository(repoPath);
      File('$repoPath/guide.md').writeAsStringSync('# Guide\n');

      final Space space = valueOf(await repository.open(repoPath));
      final List<SpaceEntry> entries = valueOf(await repository.entries(space));

      expect(entries.map((SpaceEntry entry) => entry.path.value), <String>[
        'guide.md',
      ]);
    });
  });
}
