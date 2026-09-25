/// Opening a folder as a space against real repositories, because the
/// question is what git says about a folder.
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
  T valueOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>(value: final T value) => value,
    Failure<T, F>(failure: final F failure) => throw StateError(
      'expected a success, got $failure',
    ),
  };

  /// What [result] failed with, or a failure of the test if it succeeded.
  F failureOf<T, F extends AppFailure>(Result<T, F> result) => switch (result) {
    Success<T, F>() => throw StateError('expected a failure, got a success'),
    Failure<T, F>(failure: final F failure) => failure,
  };

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('tom_open_space_');
    // Resolved and forward-slashed, because the macOS temporary directory is
    // a symlink and git reports the real path in its own spelling.
    base = tempDir.resolveSymbolicLinksSync().replaceAll(r'\', '/');
    repository = SpaceRepositoryImpl(
      spaces: SpaceDataSource(
        filesystem: const DartIoFilesystemImpl(),
        gitClientFor: (String folder) =>
            DartIoGitClientImpl(workingDirectory: folder),
      ),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  group('opening the repository itself', () {
    test('root and repositoryRoot are the same folder', () async {
      final String path = '$base/repo';
      initRepository(path);

      final SpaceEntity space = valueOf(await repository.open(path));

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
    late String repoPath;

    setUp(() {
      repoPath = '$base/app';
      initRepository(repoPath);
      Directory('$repoPath/docs/adr').createSync(recursive: true);
    });

    test('git is found above the folder that was opened', () async {
      final SpaceEntity space = valueOf(
        await repository.open('$repoPath/docs'),
      );

      expect(space.root, '$repoPath/docs');
      expect(space.repositoryRoot, repoPath);
      expect(space.rootWithinRepository?.value, 'docs');
      expect(space.name, 'docs');
    });

    test('however deep the folder is', () async {
      final SpaceEntity space = valueOf(
        await repository.open('$repoPath/docs/adr'),
      );

      expect(space.repositoryRoot, repoPath);
      expect(space.rootWithinRepository?.value, 'docs/adr');
    });

    test(
      'a folder reached through a link is the folder it points at',
      () async {
        // On macOS `/tmp` itself is a link, so this is the ordinary case.
        Link('$base/linked').createSync(repoPath);

        final SpaceEntity space = valueOf(
          await repository.open('$base/linked/docs'),
        );

        expect(space.root, '$repoPath/docs');
        expect(space.repositoryRoot, repoPath);
        expect(space.rootWithinRepository?.value, 'docs');
      },
      skip: Platform.isWindows
          ? 'creating a symbolic link needs a privilege on Windows'
          : false,
    );

    test('and the paths convert both ways', () async {
      final SpaceEntity space = valueOf(
        await repository.open('$repoPath/docs'),
      );
      final SpaceRelativePathValueObject guide = SpaceRelativePathValueObject(
        'guide.md',
      );

      expect(space.toRepoRelative(guide).value, 'docs/guide.md');
      expect(
        space.toSpaceRelative(RepoRelativePathValueObject('docs/guide.md')),
        guide,
      );
    });
  });

  group('when it is not a space', () {
    test('a folder outside any repository is named, not worked around', () {
      final String path = '$base/loose';
      Directory(path).createSync();

      expect(
        repository.open(path),
        completion(
          isA<Failure<SpaceEntity, AppFailure>>().having(
            (Failure<SpaceEntity, AppFailure> result) => result.failure,
            'failure',
            isA<GitNotARepository>().having(
              (GitNotARepository failure) => failure.path,
              'path',
              path,
            ),
          ),
        ),
      );
    });

    test('a folder that is not there is a different failure', () async {
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

      final SpaceEntity space = valueOf(await repository.open(repoPath));
      final List<SpaceEntryValueObject> entries = valueOf(
        await repository.entries(space),
      );

      expect(
        entries.map((SpaceEntryValueObject entry) => entry.path.value),
        <String>['guide.md'],
      );
    });
  });
}
